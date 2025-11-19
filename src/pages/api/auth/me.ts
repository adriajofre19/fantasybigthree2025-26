import type { APIRoute } from "astro";
import { createClient } from "@supabase/supabase-js";

export const GET: APIRoute = async ({ cookies }) => {
    const accessToken = cookies.get("sb-access-token")?.value;
    const refreshToken = cookies.get("sb-refresh-token")?.value;

    if (!accessToken || !refreshToken) {
        return new Response(JSON.stringify({ user: null }), {
            status: 200,
            headers: {
                "Content-Type": "application/json",
            },
        });
    }

    try {
        const supabase = createClient(
            import.meta.env.SUPABASE_URL,
            import.meta.env.SUPABASE_ANON_KEY,
            {
                auth: {
                    flowType: "pkce",
                },
            }
        );

        // Set the session using the tokens
        const { data: { session }, error: sessionError } = await supabase.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken,
        });

        if (sessionError || !session) {
            return new Response(JSON.stringify({ user: null }), {
                status: 200,
                headers: {
                    "Content-Type": "application/json",
                },
            });
        }

        // Get user from the session
        const { data: { user }, error } = await supabase.auth.getUser();

        if (error || !user) {
            return new Response(JSON.stringify({ user: null }), {
                status: 200,
                headers: {
                    "Content-Type": "application/json",
                },
            });
        }

        return new Response(
            JSON.stringify({
                user: {
                    id: user.id,
                    email: user.email,
                    name: user.user_metadata?.full_name || user.user_metadata?.name || user.email?.split("@")[0] || "User",
                    avatar: user.user_metadata?.avatar_url || user.user_metadata?.picture || null,
                },
            }),
            {
                status: 200,
                headers: {
                    "Content-Type": "application/json",
                },
            }
        );
    } catch (error) {
        return new Response(JSON.stringify({ user: null }), {
            status: 200,
            headers: {
                "Content-Type": "application/json",
            },
        });
    }
};

