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
                JSON.stringify({ error: "No autenticat. Has d'iniciar sessió." }),
                { status: 401, headers: { "Content-Type": "application/json" } }
            );
        }

        const body = await request.json();
        const { user_player_id, is_starter } = body;

        if (user_player_id === undefined || is_starter === undefined) {
            return new Response(
                JSON.stringify({ error: "user_player_id i is_starter són obligatoris" }),
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

        // If setting as starter, check max 5 starters
        if (is_starter === true && userPlayer.is_starter !== true) {
            const { count: starterCount } = await supabase
                .from("user_players")
                .select("*", { count: "exact", head: true })
                .eq("user_id", user.id)
                .eq("is_starter", true)
                .eq("is_active", true)
                .is("sale_date", null)
                .neq("id", user_player_id);

            if (starterCount && starterCount >= 5) {
                return new Response(
                    JSON.stringify({ 
                        error: "Ja tens 5 titulars. Has de treure un titular abans d'afegir-ne un altre.",
                        max_starters: 5,
                        current_starters: starterCount
                    }),
                    { status: 400, headers: { "Content-Type": "application/json" } }
                );
            }
        }

        // Update player starter status
        const { data: updatedPlayer, error: updateError } = await supabase
            .from("user_players")
            .update({
                is_starter: is_starter === true,
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
            console.error("Error updating starter status:", updateError);
            return new Response(
                JSON.stringify({ error: updateError.message }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                message: is_starter ? "Jugador marcat com a titular" : "Jugador marcat com a suplent",
                data: updatedPlayer,
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error updating starter status:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Error desconegut" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

