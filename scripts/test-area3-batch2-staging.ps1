#Requires -Version 5.1
[CmdletBinding()]
param(
 [Parameter(Mandatory)][string]$Number,
 [ValidateSet('all','successful','unsuccessful','unknown','failed')][string]$Outcome='failed',
 [ValidateSet('all','today','week','month')][string]$Period='month',
 [string]$Since,[string]$Until,
 [Parameter(Mandatory)][string]$RecordingCallId,
 [Parameter(Mandatory)][string]$TakeoverCallId,
 [int]$ExpectedTotal=-1
)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Net.Http
$base='https://nixflex-voice-engine-staging.up.railway.app'
if ($Number -notmatch '^\+[1-9][0-9]{6,14}$') { throw 'Number must be the business number in +countrycode format.' }
$handler=[System.Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect=$false
$http=[System.Net.Http.HttpClient]::new($handler)
$http.Timeout=[TimeSpan]::FromSeconds(30)
$secret=Read-Host 'Staging API key (local prompt only; never paste it into chat)' -AsSecureString
$bstr=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
try { $key=[Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
function Read-Api([string]$Path) {
 if (-not $Path.StartsWith('/v1/calls')) { throw 'Only call reads allowed.' }
 $request=[System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get,$base+$Path)
 $request.Headers.Authorization=[System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer',$key)
 $response=$null
 try {
  $response=$http.SendAsync($request).GetAwaiter().GetResult()
  if (-not $response.IsSuccessStatusCode) { throw "Staging read returned HTTP $([int]$response.StatusCode). No call or charge was requested." }
  return ($response.Content.ReadAsStringAsync().GetAwaiter().GetResult() | ConvertFrom-Json)
 } finally { if ($response) { $response.Dispose() }; $request.Dispose() }
}
try {
 $query=[ordered]@{number=$Number;outcome=$Outcome;period=$Period;limit='25'}
 if ($Since) { $query.since=$Since }
 if ($Until) { $query.until=$Until }
 $parts=foreach ($pair in $query.GetEnumerator()) {
  '{0}={1}' -f [uri]::EscapeDataString([string]$pair.Key),[uri]::EscapeDataString([string]$pair.Value)
 }
 $history=Read-Api ('/v1/calls/history?'+($parts -join '&'))
 if ($null -eq $history.totals -or $null -eq $history.data) { throw 'Missing history envelope.' }
 if ($ExpectedTotal -ge 0 -and $history.totals.total -ne $ExpectedTotal) { throw "History total differs: API=$($history.totals.total), dashboard=$ExpectedTotal. Use the same exact date bounds." }
 Write-Host "History: $($history.totals.total) matches; $($history.totals.cost_unknown) with unknown recorded cost."
 Write-Host "Compare dashboard with since=$($history.filters.since), until=$($history.filters.until), number and outcome above."
 $history.data | Select-Object call_id,call_type,ended_reason,call_successful,cost | Format-Table
 if ($history.has_more) {
  $next=Read-Api ('/v1/calls/history?limit=25&cursor='+[uri]::EscapeDataString($history.next_cursor))
  $seen=@($history.data.call_id)
  if (@($next.data | Where-Object { $_.call_id -in $seen }).Count) { throw 'Cursor page repeated a call.' }
  Write-Host 'Cursor: second page read, no repeated IDs.'
 }
 $rec=Read-Api ('/v1/calls/'+[uri]::EscapeDataString($RecordingCallId)+'/recording')
 if ($rec.status -ne 'available' -or -not $rec.url -or -not $rec.expires_at) { throw "Recording is $($rec.status); choose an existing managed, available recording for the link test." }
 $url=[uri]$rec.url
 if ($url.Scheme -ne 'https' -or $url.UserInfo -or $url.Host -notmatch '^[a-z0-9]+\.supabase\.co$' -or -not $url.AbsolutePath.StartsWith('/storage/v1/object/sign/recordings/')) {
  throw 'Unexpected download destination. Review it without sending API credentials.'
 }
 $remaining=([DateTimeOffset]::Parse($rec.expires_at)-[DateTimeOffset]::UtcNow).TotalSeconds
 if ($remaining -le 0 -or $remaining -gt 310) { throw 'Recording expiry is not short-lived.' }
 # No API Authorization on storage GET; read headers only, no audio saved to disk.
 $download=[System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get,$url)
 $download.Headers.Range=[System.Net.Http.Headers.RangeHeaderValue]::new(0,0)
 $reply=$null
 try {
  $reply=$http.SendAsync($download,[System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
  if ([int]$reply.StatusCode -notin @(200,206)) { throw "Recording link returned HTTP $([int]$reply.StatusCode)." }
  Write-Host 'Recording link: GET succeeded; short expiry checked. URL/token not printed; no audio saved.'
 } finally { if ($reply) { $reply.Dispose() }; $download.Dispose() }
 $bill=Read-Api ('/v1/calls/'+[uri]::EscapeDataString($TakeoverCallId)+'/billing')
 if ($bill.status -ne 'settled' -or $null -eq $bill.ai_billed_ms -or $null -eq $bill.human_free_ms -or $bill.basis -notin @('fenced','conservative')) {
  throw 'No settled takeover split for that call. Missing proof is not a zero charge.'
 }
 Write-Host "Billing: AI=$($bill.ai_billed_ms) ms; free remaining/human=$($bill.human_free_ms) ms; cost=$($bill.cost) $($bill.currency); basis=$($bill.basis)."
 if ($bill.basis -eq 'conservative') { Write-Host 'Protective billing cap, not proof of the exact human handover time.' }
 Write-Host 'PASS API reads. Confirm the same history rows/totals in dashboard. No paid call, SMS, mutation or charge was requested.'
} finally {
 $key=$null; $secret.Dispose(); $http.Dispose(); $handler.Dispose()
}
