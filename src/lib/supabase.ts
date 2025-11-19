import { createClient } from "@supabase/supabase-js";
import type { AstroCookies } from "astro";

export const supabase = createClient(
    import.meta.env.SUPABASE_URL,
    import.meta.env.SUPABASE_ANON_KEY,
    {
        auth: {
            flowType: "pkce",
        },
    },
);

// Helper function to get Supabase client with session from cookies (for API routes)
export async function getSupabaseClient(cookies: AstroCookies) {
    const accessToken = cookies.get("sb-access-token")?.value;
    const refreshToken = cookies.get("sb-refresh-token")?.value;

    const client = createClient(
        import.meta.env.SUPABASE_URL,
        import.meta.env.SUPABASE_ANON_KEY,
        {
            auth: {
                flowType: "pkce",
            },
        }
    );

    // Set session if tokens are available
    if (accessToken && refreshToken) {
        await client.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken,
        });
    }

    return client;
}