// Supabase Edge Function: 通过密保问题重置密码
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { email, answer_hash, new_password } = await req.json();

    if (!email || !answer_hash || !new_password) {
      return new Response(
        JSON.stringify({ error: "缺少参数" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 用 service_role key 创建 admin 客户端
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // 查 profile
    const { data: profile, error: profileError } = await supabaseAdmin
      .from("profiles")
      .select("id, security_answer_hash")
      .eq("email", email)
      .single();

    if (profileError || !profile) {
      return new Response(
        JSON.stringify({ error: "该邮箱未注册" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 验证密保答案（不区分大小写和首尾空格）
    if ((profile.security_answer_hash || '').trim().toLowerCase() !== (answer_hash || '').trim().toLowerCase()) {
      return new Response(
        JSON.stringify({ error: "密保答案错误" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 重置密码
    const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
      profile.id,
      { password: new_password }
    );

    if (updateError) {
      return new Response(
        JSON.stringify({ error: updateError.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );

  } catch (e) {
    return new Response(
      JSON.stringify({ error: "服务器错误" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
