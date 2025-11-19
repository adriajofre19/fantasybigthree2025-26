import type { APIRoute } from "astro";
import { getSupabaseClient } from "@/lib/supabase";

export const POST: APIRoute = async ({ request, cookies }) => {
    try {
        const supabase = await getSupabaseClient(cookies);

        // Check if user is authenticated
        const {
            data: { user },
            error: authError,
        } = await supabase.auth.getUser();

        if (authError || !user) {
            return new Response(
                JSON.stringify({ error: "No autenticat. Has d'iniciar sessió per comprar jugadors." }),
                { status: 401, headers: { "Content-Type": "application/json" } }
            );
        }

        const body = await request.json();
        const { player_id, purchase_date, is_starter } = body;

        if (!player_id) {
            return new Response(
                JSON.stringify({ error: "player_id és obligatori" }),
                { status: 400, headers: { "Content-Type": "application/json" } }
            );
        }

        // Check if player exists
        const { data: player, error: playerError } = await supabase
            .from("players")
            .select("id")
            .eq("id", player_id)
            .single();

        if (playerError || !player) {
            return new Response(
                JSON.stringify({ error: "Jugador no trobat" }),
                { status: 404, headers: { "Content-Type": "application/json" } }
            );
        }

        // Check if user already has this player active
        const { data: existingPlayer, error: checkError } = await supabase
            .from("user_players")
            .select("id, is_active, sale_date")
            .eq("user_id", user.id)
            .eq("player_id", player_id)
            .eq("is_active", true)
            .single();

        if (existingPlayer && !existingPlayer.sale_date) {
            return new Response(
                JSON.stringify({ error: "Ja tens aquest jugador al teu equip" }),
                { status: 400, headers: { "Content-Type": "application/json" } }
            );
        }

        // Get user balance
        const { data: profile, error: profileError } = await supabase
            .from("user_profiles")
            .select("balance")
            .eq("id", user.id)
            .single();

        // If profile doesn't exist, create it with default balance
        let currentBalance = 5000000.00;
        if (profileError && profileError.code === "PGRST116") {
            const { data: newProfile } = await supabase
                .from("user_profiles")
                .insert({
                    id: user.id,
                    balance: 5000000.00,
                })
                .select("balance")
                .single();
            if (newProfile) {
                currentBalance = newProfile.balance;
            }
        } else if (profile) {
            currentBalance = profile.balance;
        }

        // Calculate player price (default: 100,000)
        // You can modify this to calculate based on player stats or add a price field to players table
        const playerPrice = 100000;

        // Check if user has enough balance
        if (currentBalance < playerPrice) {
            return new Response(
                JSON.stringify({
                    error: `No tens suficients diners. Saldo actual: ${currentBalance.toLocaleString('es-ES')}€, Preu: ${playerPrice.toLocaleString('es-ES')}€`,
                    balance: currentBalance,
                    required: playerPrice
                }),
                { status: 400, headers: { "Content-Type": "application/json" } }
            );
        }

        // Check current starter count
        const { count: starterCount } = await supabase
            .from("user_players")
            .select("*", { count: "exact", head: true })
            .eq("user_id", user.id)
            .eq("is_starter", true)
            .eq("is_active", true)
            .is("sale_date", null);

        // Automatically assign as starter if less than 5 starters, otherwise as bench
        const willBeStarter = (starterCount || 0) < 5;

        // If explicitly set as starter and already have 5, return error
        if (is_starter === true && starterCount && starterCount >= 5) {
            return new Response(
                JSON.stringify({
                    error: "Ja tens 5 titulars. Has de treure un titular abans d'afegir-ne un altre.",
                    max_starters: 5,
                    current_starters: starterCount
                }),
                { status: 400, headers: { "Content-Type": "application/json" } }
            );
        }

        // Deduct balance
        const newBalance = currentBalance - playerPrice;
        const { error: balanceUpdateError } = await supabase
            .from("user_profiles")
            .upsert({
                id: user.id,
                balance: newBalance,
            }, {
                onConflict: "id"
            });

        if (balanceUpdateError) {
            console.error("Error updating balance:", balanceUpdateError);
            return new Response(
                JSON.stringify({ error: "Error actualitzant el saldo" }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        // Insert new purchase
        const purchaseData: any = {
            user_id: user.id,
            player_id: player_id,
            purchase_date: purchase_date || new Date().toISOString(),
            is_active: true,
            sale_date: null,
            is_starter: willBeStarter, // Automatically assign based on current starter count
        };

        const { data: newPurchase, error: insertError } = await supabase
            .from("user_players")
            .insert(purchaseData)
            .select()
            .single();

        if (insertError) {
            console.error("Error purchasing player:", insertError);
            return new Response(
                JSON.stringify({ error: insertError.message }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        // Calculate initial total_points (will be 0 if no stats exist yet)
        const { error: updateError } = await supabase.rpc("calculate_user_player_points", {
            p_user_player_id: newPurchase.id,
        });

        if (updateError) {
            console.warn("Warning: Could not calculate initial points:", updateError);
        }

        // Get updated purchase with calculated points
        const { data: updatedPurchase, error: fetchError } = await supabase
            .from("user_players")
            .select(`
                *,
                players (
                    id,
                    player_id,
                    full_name,
                    first_name,
                    last_name,
                    position,
                    team_name,
                    photo_url
                )
            `)
            .eq("id", newPurchase.id)
            .single();

        if (fetchError) {
            console.error("Error fetching updated purchase:", fetchError);
        }

        return new Response(
            JSON.stringify({
                success: true,
                message: `Jugador comprat correctament${willBeStarter ? " com a titular" : " com a suplent"}`,
                data: updatedPurchase || newPurchase,
                balance: newBalance,
                was_starter: willBeStarter,
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error purchasing player:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Error desconegut" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

