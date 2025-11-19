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
                JSON.stringify({ error: "No autenticat. Has d'iniciar sessió per vendre jugadors." }),
                { status: 401, headers: { "Content-Type": "application/json" } }
            );
        }

        const body = await request.json();
        const { user_player_id, sale_date } = body;

        if (!user_player_id) {
            return new Response(
                JSON.stringify({ error: "user_player_id és obligatori" }),
                { status: 400, headers: { "Content-Type": "application/json" } }
            );
        }

        // Check if user owns this player and it's active
        const { data: userPlayer, error: fetchError } = await supabase
            .from("user_players")
            .select("*")
            .eq("id", user_player_id)
            .eq("user_id", user.id)
            .eq("is_active", true)
            .is("sale_date", null)
            .single();

        if (fetchError || !userPlayer) {
            return new Response(
                JSON.stringify({ error: "Jugador no trobat o ja venut" }),
                { status: 404, headers: { "Content-Type": "application/json" } }
            );
        }

        // Validate sale_date is after purchase_date
        const saleDate = sale_date ? new Date(sale_date) : new Date();
        const purchaseDate = new Date(userPlayer.purchase_date);

        if (saleDate < purchaseDate) {
            return new Response(
                JSON.stringify({ error: "La data de venda no pot ser anterior a la data de compra" }),
                { status: 400, headers: { "Content-Type": "application/json" } }
            );
        }

        // Update player to mark as sold
        const { data: updatedPlayer, error: updateError } = await supabase
            .from("user_players")
            .update({
                sale_date: saleDate.toISOString(),
                is_active: false,
            })
            .eq("id", user_player_id)
            .select(`
                *,
                players (
                    id,
                    full_name,
                    position,
                    team_name,
                    photo_url
                )
            `)
            .single();

        if (updateError) {
            console.error("Error selling player:", updateError);
            return new Response(
                JSON.stringify({ error: updateError.message }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                message: "Jugador venut correctament",
                data: updatedPlayer,
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error selling player:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Error desconegut" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

