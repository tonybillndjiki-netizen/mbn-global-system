import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.2";
import { createHandler } from "./handler.ts";

Deno.serve(createHandler({
  secret: () => Deno.env.get("MBN_WEBHOOK_SECRET") ?? "",
  database: () => {
    const url = Deno.env.get("SUPABASE_URL");
    const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!url || !key) throw new Error("db_not_configured");
    return createClient(url,key,{auth:{persistSession:false,autoRefreshToken:false}});
  },
}));
