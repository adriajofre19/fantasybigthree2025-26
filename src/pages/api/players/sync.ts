import type { APIRoute } from "astro";
import { createClient } from "@supabase/supabase-js";

// Utilitzar la clau de servei per a operacions de sincronització que bypassen RLS
// Si no està disponible, utilitzar la clau anònima (requereix polítiques RLS adequades)
const getSupabaseClient = () => {
    const serviceRoleKey = import.meta.env.SUPABASE_SERVICE_ROLE_KEY;

    if (serviceRoleKey) {
        // Utilitzar service role key per bypassar RLS (només per a operacions del servidor)
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

    // Fallback a la clau anònima (requereix polítiques RLS)
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

interface NBAPlayer {
    PERSON_ID: number;
    DISPLAY_FIRST_LAST: string;
    FIRST_NAME: string;
    LAST_NAME: string;
    TEAM_ID: number;
    TEAM_NAME: string;
    ROSTERSTATUS: number;
    POSITION?: string;
    [key: string]: any; // Per permetre altres camps
}

// Funció per obtenir la URL de la foto del jugador
const getPlayerPhotoUrl = (playerId: number): string => {
    // Format oficial de la NBA: https://cdn.nba.com/headshots/nba/latest/260x190/{player_id}.png
    return `https://cdn.nba.com/headshots/nba/latest/260x190/${playerId}.png`;
};

// Funció per obtenir la posició del jugador
// L'API de commonallplayers no sempre retorna la posició, cal buscar-la en altres camps
const getPlayerPosition = (player: NBAPlayer): string | null => {
    // Intentar obtenir la posició de diferents camps possibles
    if (player.POSITION) return player.POSITION;
    if (player.PLAYER_POSITION) return player.PLAYER_POSITION;
    if (player.POS) return player.POS;

    // Si no hi ha posició disponible, retornar null
    return null;
};

export const POST: APIRoute = async ({ request }) => {
    try {
        // Obtenir jugadors de l'API de la NBA
        // Utilitzem l'endpoint commonallplayers de stats.nba.com
        const season = "2025-26";
        const url = `https://stats.nba.com/stats/commonallplayers?LeagueID=00&Season=${season}&IsOnlyCurrentSeason=1`;

        // Intentar obtenir les dades de l'API de la NBA
        let response;
        try {
            response = await fetch(url, {
                headers: {
                    "Accept": "application/json, text/plain, */*",
                    "Accept-Language": "en-US,en;q=0.9",
                    "Referer": "https://www.nba.com/",
                    "Origin": "https://www.nba.com",
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                    "Cache-Control": "no-cache",
                },
            });
        } catch (fetchError: any) {
            // Si falla la crida directa, utilitzem una alternativa o dades de prova
            console.error("Error fetching from NBA API:", fetchError);
            throw new Error(`Error connectant amb l'API de la NBA: ${fetchError.message}. Assegura't que l'API està accessible.`);
        }

        if (!response.ok) {
            const errorText = await response.text();
            console.error("NBA API error response:", errorText);

            // Si es 403, intentar automáticamente el endpoint alternativo
            if (response.status === 403) {
                console.log("NBA API bloquejada (403), intentant endpoint alternatiu (BallDontLie)...");

                // Llamar directamente a la función del endpoint alternativo
                try {
                    const { POST: altPost } = await import("./sync-alternative");
                    const altResponse = await altPost({ request } as any);

                    if (altResponse.ok) {
                        const altData = await altResponse.json();
                        return new Response(
                            JSON.stringify({
                                ...altData,
                                warning: "S'ha utilitzat automàticament l'API alternativa (BallDontLie) perquè l'API oficial de la NBA està bloquejada (403)."
                            }),
                            { status: 200, headers: { "Content-Type": "application/json" } }
                        );
                    } else {
                        const altError = await altResponse.text();
                        throw new Error(`Endpoint alternatiu també ha fallat: ${altError}`);
                    }
                } catch (altError: any) {
                    console.error("Error amb endpoint alternatiu:", altError);
                    return new Response(
                        JSON.stringify({
                            error: "Les APIs externes estan bloquejades o no disponibles.",
                            message: "Per a desenvolupament, executa el script SQL per inserir jugadors de mostra.",
                            solution: {
                                step1: "Obre Supabase SQL Editor",
                                step2: "Executa el fitxer: supabase/migrations/007_insert_sample_players.sql",
                                step3: "Això inserirà ~30 jugadors de mostra per desenvolupar",
                                alternative: "O pots inserir jugadors manualment a la taula 'players'"
                            },
                            details: altError.message || altError.toString()
                        }),
                        { status: 500, headers: { "Content-Type": "application/json" } }
                    );
                }
            }

            throw new Error(`NBA API error: ${response.status} ${response.statusText}`);
        }

        const data = await response.json();

        if (!data.resultSets || data.resultSets.length === 0) {
            return new Response(
                JSON.stringify({ error: "No data received from NBA API" }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        const playersData = data.resultSets[0];
        const headers = playersData.headers;
        const rows = playersData.rowSet;

        if (!rows || rows.length === 0) {
            return new Response(
                JSON.stringify({ error: "No players found in NBA API response" }),
                { status: 500, headers: { "Content-Type": "application/json" } }
            );
        }

        // Mapejar les dades
        const players: NBAPlayer[] = rows.map((row: any[]) => {
            const player: any = {};
            headers.forEach((header: string, index: number) => {
                player[header] = row[index];
            });
            return player;
        });

        // Obtenir informació detallada dels jugadors per obtenir la posició
        // L'API commonallplayers no sempre retorna la posició, però podem obtenir-la
        // de l'endpoint commonplayerinfo o de commonteamroster

        // Per optimitzar, processem els jugadors en lots per obtenir les posicions
        // Per ara, utilitzarem el que ve de l'API i intentarem obtenir la posició dels camps disponibles

        // Inserir o actualitzar jugadors a la base de dades
        const playersToInsert = await Promise.all(
            players.map(async (player) => {
                const playerId = player.PERSON_ID;
                let position = getPlayerPosition(player);

                // Si no tenim la posició, intentem obtenir-la de l'API de commonplayerinfo
                if (!position && playerId) {
                    try {
                        const playerInfoUrl = `https://stats.nba.com/stats/commonplayerinfo?PlayerID=${playerId}`;
                        const playerInfoResponse = await fetch(playerInfoUrl, {
                            headers: {
                                "Accept": "application/json, text/plain, */*",
                                "Accept-Language": "en-US,en;q=0.9",
                                "Referer": "https://www.nba.com/",
                                "Origin": "https://www.nba.com",
                                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
                            },
                        });

                        if (playerInfoResponse.ok) {
                            const playerInfoData = await playerInfoResponse.json();
                            if (playerInfoData.resultSets && playerInfoData.resultSets.length > 0) {
                                const playerInfo = playerInfoData.resultSets[0];
                                const infoHeaders = playerInfo.headers;
                                const infoRows = playerInfo.rowSet;

                                if (infoRows && infoRows.length > 0) {
                                    const playerInfoRow = infoRows[0];
                                    const posIndex = infoHeaders.indexOf("POSITION");
                                    if (posIndex !== -1 && playerInfoRow[posIndex]) {
                                        position = playerInfoRow[posIndex];
                                    }
                                }
                            }
                        }
                    } catch (error) {
                        // Si falla, continuem sense la posició
                        console.warn(`No s'ha pogut obtenir la posició del jugador ${playerId}`);
                    }
                }

                const photoUrl = getPlayerPhotoUrl(playerId);

                return {
                    player_id: playerId,
                    full_name: player.DISPLAY_FIRST_LAST || `${player.FIRST_NAME} ${player.LAST_NAME}`,
                    first_name: player.FIRST_NAME,
                    last_name: player.LAST_NAME,
                    team_id: player.TEAM_ID || null,
                    team_name: player.TEAM_NAME || null,
                    position: position,
                    photo_url: photoUrl,
                    is_active: player.ROSTERSTATUS === 1,
                    season: season,
                    updated_at: new Date().toISOString(),
                };
            })
        );

        // Utilitzar el client de Supabase (amb service role key si està disponible)
        const supabase = getSupabaseClient();

        // Utilitzar upsert per inserir o actualitzar
        // Supabase accepta les columnes directament per al onConflict
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
                message: `Sincronitzats ${playersToInsert.length} jugadors`,
                count: playersToInsert.length,
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error syncing players:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Error desconegut" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

