import type { APIRoute } from "astro";
import { getSupabaseClient } from "@/lib/supabase";

export const GET: APIRoute = async ({ request, cookies, url }) => {
    try {
        const supabase = await getSupabaseClient(cookies);

        // Check if user is authenticated
        const {
            data: { user },
            error: authError,
        } = await supabase.auth.getUser();

        if (authError || !user) {
            return new Response(
                JSON.stringify({ error: "No autenticat" }),
                { status: 401, headers: { "Content-Type": "application/json" } }
            );
        }

        const activeOnly = url.searchParams.get("active_only") === "true";
        const includeSold = url.searchParams.get("include_sold") === "true";

        let query = supabase
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
                    team_id,
                    photo_url,
                    is_active
                )
            `)
            .eq("user_id", user.id)
            .order("purchase_date", { ascending: false });

        if (activeOnly) {
            query = query.eq("is_active", true).is("sale_date", null);
        } else if (!includeSold) {
            query = query.is("sale_date", null);
        }

        const { data: userPlayers, error: fetchError } = await query;

        if (fetchError) {
            console.error("Error fetching user players:", fetchError);
            return new Response(
                JSON.stringify({ error: fetchError.message }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                data: userPlayers || [],
                count: userPlayers?.length || 0,
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error fetching user players:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Error desconegut" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

