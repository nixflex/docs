param([Parameter(Mandatory)][string]$ScriptPath,[switch]$WithDates)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Net.Http
$code=@'
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
public class ReadCaptureHandler : HttpMessageHandler {
 public bool AllowAutoRedirect { get; set; }
 public static List<string> Uris = new List<string>();
 public static List<bool> HasAuth = new List<bool>();
 protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage req, CancellationToken token) {
  if(req.Method != HttpMethod.Get) throw new Exception("Only fixture GETs allowed");
  Uris.Add(req.RequestUri.AbsoluteUri); HasAuth.Add(req.Headers.Authorization != null);
  string path=req.RequestUri.AbsolutePath, body;
  if(req.RequestUri.Host=="fixture.supabase.co" && path.StartsWith("/storage/v1/object/sign/recordings/")) body="audio fixture";
  else if(req.RequestUri.Host!="nixflex-voice-engine-staging.up.railway.app") throw new Exception("Unexpected origin");
  else if(path=="/v1/calls/history") {
   bool more=!req.RequestUri.Query.Contains("cursor=");
   body="{\"data\":[{\"call_id\":\""+(more?"first":"second")+"\"}],\"totals\":{\"total\":2,\"cost_unknown\":0},\"has_more\":"+(more?"true":"false")+",\"next_cursor\":\"next+/=\",\"filters\":{}}";
  } else if(path.EndsWith("/recording")) body="{\"status\":\"available\",\"url\":\"https://fixture.supabase.co/storage/v1/object/sign/recordings/fixture.wav?token=synthetic\",\"expires_at\":\""+DateTime.UtcNow.AddSeconds(300).ToString("o")+"\"}";
  else if(path.EndsWith("/billing")) body="{\"status\":\"settled\",\"ai_billed_ms\":60000,\"human_free_ms\":60000,\"cost\":0.1,\"currency\":\"USD\",\"basis\":\"fenced\"}";
  else throw new Exception("Unexpected fixture path");
  return Task.FromResult(new HttpResponseMessage(HttpStatusCode.OK){Content=new StringContent(body)});
 }
}
'@
if ($PSVersionTable.PSVersion.Major -eq 5) {
 Add-Type -TypeDefinition $code -ReferencedAssemblies System.Net.Http
} else { Add-Type -TypeDefinition $code }
function Read-Host { ConvertTo-SecureString 'fixture:fixture' -AsPlainText -Force }
$source=[IO.File]::ReadAllText($ScriptPath)
$needle='$handler=[System.Net.Http.HttpClientHandler]::new()'
if (($source.Split(@($needle),[StringSplitOptions]::None).Count-1) -ne 1) { throw 'Expected exactly one real HTTP handler constructor' }
# Replace only the transport. All production URL construction and SendAsync calls execute.
$fake=$source.Replace($needle,'$handler=[ReadCaptureHandler]::new()')
$params=@{Number='+12025550100';Outcome='failed';Period='month';RecordingCallId='recorded';TakeoverCallId='takeover';ExpectedTotal=2}
if ($WithDates) { $params.Since='2026-10-25T00:00:00+01:00'; $params.Until='2026-10-26T12:34:56Z' }
& ([ScriptBlock]::Create($fake)) @params 6>$null | Out-Null
@{version=$PSVersionTable.PSVersion.ToString();uris=@([ReadCaptureHandler]::Uris);hasAuth=@([ReadCaptureHandler]::HasAuth)} | ConvertTo-Json -Compress
