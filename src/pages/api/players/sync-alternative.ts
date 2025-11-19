import type { APIRoute } from "astro";
import { createClient } from "@supabase/supabase-js";

// Utilitzar la clau de servei per a operacions de sincronització que bypassen RLS
const getSupabaseClient = () => {
    const serviceRoleKey = import.meta.env.SUPABASE_SERVICE_ROLE_KEY;

    if (serviceRoleKey) {
        return createClient(
            import.meta.env.SUPABASE_URL,
            serviceRoleKey,
            {
                auth: {
                    flowType: "pkce",
                },
            }
        );
    }

    return createClient(
        import.meta.env.SUPABASE_URL,
        import.meta.env.SUPABASE_ANON_KEY,
        {
            auth: {
                flowType: "pkce",
            },
        }
    );
};

interface BallDontLiePlayer {
    id: number;
    first_name: string;
    last_name: string;
    position?: string;
    team?: {
        id: number;
        abbreviation: string;
        city: string;
        conference: string;
        division: string;
        full_name: string;
        name: string;
    };
    height_feet?: number;
    height_inches?: number;
    weight_pounds?: number;
}

export const POST: APIRoute = async ({ request }) => {
    try {
        const season = "2025-26";

        // BallDontLie API - Free tier allows 1000 requests per day
        // Endpoint: https://www.balldontlie.io/api/v1/players
        // Note: La API puede requerir parámetros específicos o puede haber cambiado
        const url = "https://www.balldontlie.io/api/v1/players?per_page=100&page=1";

        let response;
        try {
            response = await fetch(url, {
                headers: {
                    "Accept": "application/json",
                },
            });
        } catch (fetchError: any) {
            console.error("Error fetching from BallDontLie API:", fetchError);
            throw new Error(`Error connectant amb l'API de BallDontLie: ${fetchError.message}`);
        }

        if (!response.ok) {
            const errorText = await response.text();
            console.error("BallDontLie API error response:", errorText);

            return new Response(
                JSON.stringify({
                    error: `BallDontLie API error: ${response.status} ${response.statusText}`,
                    details: errorText.substring(0, 500)
                }),
                { status: response.status, headers: { "Content-Type": "application/json" } }
            );
        }

        const data = await response.json();

        if (!data.data || data.data.length === 0) {
            return new Response(
                JSON.stringify({ error: "No data received from BallDontLie API" }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        const players: BallDontLiePlayer[] = data.data;

        // Funció per obtenir la URL de la foto del jugador (NBA CDN)
        const getPlayerPhotoUrl = (playerId: number): string => {
            return `https://cdn.nba.com/headshots/nba/latest/260x190/${playerId}.png`;
        };

        // Mapejar les dades de BallDontLie al format de la nostra base de dades
        const playersToInsert = players.map((player) => {
            const fullName = `${player.first_name} ${player.last_name}`;

            return {
                player_id: player.id,
                full_name: fullName,
                first_name: player.first_name,
                last_name: player.last_name,
                team_id: player.team?.id || null,
                team_name: player.team?.full_name || player.team?.name || null,
                position: player.position || null,
                photo_url: getPlayerPhotoUrl(player.id),
                is_active: true, // BallDontLie API typically returns active players
                season: season,
                updated_at: new Date().toISOString(),
            };
        });

        // Utilitzar el client de Supabase
        const supabase = getSupabaseClient();

        // Utilitzar upsert per inserir o actualitzar
        const { error: upsertError } = await supabase
            .from("players")
            .upsert(playersToInsert, {
                onConflict: "player_id,season",
            });

        if (upsertError) {
            console.error("Error inserting players:", upsertError);
            return new Response(
                JSON.stringify({ error: upsertError.message }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                message: `Sincronitzats ${playersToInsert.length} jugadors des de BallDontLie API`,
                count: playersToInsert.length,
                source: "balldontlie.io",
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error syncing players:", error);
        return new Response(
            JSON.stringify({
                error: error.message || "Error desconegut",
                type: "sync_error"
            }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

