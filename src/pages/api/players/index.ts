import type { APIRoute } from "astro";
import { supabase } from "../../../lib/supabase";

export const GET: APIRoute = async ({ url }) => {
    try {
        const season = url.searchParams.get("season") || "2025-26";
        
        const { data: players, error } = await supabase
            .from("players")
            .select("*")
            .eq("season", season)
            .order("full_name", { ascending: true });

        if (error) {
            console.error("Error fetching players:", error);
            return new Response(
                JSON.stringify({ error: error.message }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({ players: players || [] }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error fetching players:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Error desconegut" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

