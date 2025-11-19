import type { APIRoute } from "astro";
import { getSupabaseClient } from "@/lib/supabase";

export const GET: APIRoute = async ({ cookies }) => {
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

        // Get user profile with balance
        const { data: profile, error: profileError } = await supabase
            .from("user_profiles")
            .select("balance")
            .eq("id", user.id)
            .single();

        if (profileError && profileError.code !== "PGRST116") {
            // PGRST116 means no rows found, which is OK - we'll create it
            console.error("Error fetching user profile:", profileError);
        }

        // If profile doesn't exist, create it with default balance
        if (!profile) {
            const { data: newProfile, error: createError } = await supabase
                .from("user_profiles")
                .insert({
                    id: user.id,
                    balance: 5000000.00,
                })
                .select("balance")
                .single();

            if (createError) {
                console.error("Error creating user profile:", createError);
                return new Response(
                    JSON.stringify({ error: createError.message }),
                    { status: 500, headers: { "Content-Type": "application/json" } }
                );
            }

            return new Response(
                JSON.stringify({
                    success: true,
                    balance: newProfile.balance,
                }),
                {
                    status: 200,
                    headers: { "Content-Type": "application/json" },
                }
            );
        }

        return new Response(
            JSON.stringify({
                success: true,
                balance: profile.balance,
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    } catch (error: any) {
        console.error("Error fetching user balance:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Error desconegut" }),
            { status: 500, headers: { "Content-Type": "application/json" } }
        );
    }
};

