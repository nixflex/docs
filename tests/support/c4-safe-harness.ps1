param([string]$TestScript = (Join-Path $PSScriptRoot '..\..\scripts\C4-TEST.ps1'))
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
$global:C4MockRequests=0; $global:C4MockDeleted=$false; $global:C4MockAgent=$null; $global:C4Scenario='normal'
Add-Type -TypeDefinition @"
using System; using System.IO; using System.Net; using System.Text;
public sealed class C4MockResponse : WebResponse {
 public HttpStatusCode StatusCode { get; private set; }
 private readonly byte[] body;
 public C4MockResponse(int status, string text) { StatusCode=(HttpStatusCode)status; body=Encoding.UTF8.GetBytes(text); }
 public override Stream GetResponseStream() { return new MemoryStream(body); }
}
"@
function global:Invoke-WebRequest {
 param($Uri,$Method,$Headers,$UseBasicParsing,$DisableKeepAlive,$MaximumRedirection,$TimeoutSec,$ErrorAction,$Body,$ContentType)
 if (-not $DisableKeepAlive -or $MaximumRedirection -ne 0 -or -not $Uri.StartsWith('https://nixflex-voice-engine-staging.up.railway.app/v1/')) { throw 'Unsafe HTTP options' }
 $global:C4MockRequests++
 $path=$Uri.Substring('https://nixflex-voice-engine-staging.up.railway.app'.Length)
 $status=200; $data=$null
 if ($Headers.ContainsKey('Authorization') -and $Headers.Authorization -eq 'Bearer nxf_C4_INVALID:nxfs_C4_INVALID') { $status=401; $data=@{error=@{code='unauthorized';message='Mock refusal'}} }
 elseif ($path -eq '/v1/keys' -and $Body -ceq '{') { $status=400; $data=@{error=@{code='invalid_json';message='Mock refusal'}} }
 elseif ($path -eq '/v1/account/retention') { $data=@{call_retention_days=90;applies_to='new_agents';processing_enabled=$true} }
 elseif ($path -eq '/v1/keys/activity?period=invalid') { $status=400; $data=@{error=@{code='invalid_period';message='Mock refusal'}} }
 elseif ($path -eq '/v1/keys/activity?period=today') { $data=@{period='today';timezone='UTC';requests=0;errors=0;requests_today=0;errors_today=0;day_start='2026-11-01T00:00:00Z';period_start='2026-11-01T00:00:00Z';as_of='2026-11-01T12:00:00Z';last_used_at=$null;top_endpoints=@()} }
 elseif ($path -eq '/v1/usage') { $data=@{plan='mock';total_calls=0;total_minutes=0;total_cost=0;rate_limit_per_minute=300;max_concurrent=10;peak_concurrent_this_month=0;rejected_at_cap_this_month=0} }
 elseif ($path -eq '/v1/agents' -and $Method -eq 'POST') {
   $status=201; $b=$Body|ConvertFrom-Json; $global:C4MockAgent=@{agent_id='agent_c4_mock';name=$b.name;temperature=0.3;pickup_delay=10;max_call_duration_seconds=300;silence_hangup_seconds=10;dynamic_greeting=$true;is_active=$true};$data=$global:C4MockAgent
   if ($global:C4Scenario -eq 'lost-create') { throw 'Simulated lost creation response' }
 }
 elseif ($path.StartsWith('/v1/agents?')) { $data=@($global:C4MockAgent) }
 elseif ($path -eq '/v1/agents/agent_c4_mock') {
   if ($Method -eq 'PUT') { $b=$Body|ConvertFrom-Json;if($b.temperature -eq 1){$status=400;$data=@{error=@{code='invalid_agent_field';message='Mock refusal'}}}elseif($global:C4Scenario -eq 'failed-update'){$status=503;$data=@{error=@{code='agent_store_unavailable';message='Mock failure'}}}else{$global:C4MockAgent.name=$b.name;$global:C4MockAgent.temperature=$b.temperature;$data=$global:C4MockAgent} }
   elseif($Method -eq 'DELETE'){$global:C4MockDeleted=$true;$global:C4MockAgent.is_active=$false;$data=@{deleted=$true}}
   else{$data=$global:C4MockAgent}
 }
 elseif ($path -eq '/v1/voices?gender=invalid') { $status=400;$data=@{error=@{code='invalid_gender';message='Mock refusal'}} }
 elseif ($path -eq '/v1/voices?limit=1' -or $path -eq '/v1/voices/voice_mock') {
   $v=@{voice_key='voice_mock';displayName='Mock voice';gender='unknown';nativeLanguage='en';locale=$null;accents=@();languages=@('en');origin='standard';availability='active';selectable=$true;incompatibilityReason=$null;previewLanguage=$null;previewStatus='none';previewUrl=$null}
   if($path -eq '/v1/voices?limit=1'){$data=@{data=@($v);next_cursor=$null}}else{$data=$v}
 }
 elseif ($path -eq '/v1/calls?limit=1') { $data=@() }
 elseif ($path -eq '/v1/calls/history?limit=201') { $status=400;$data=@{error=@{code='invalid_call_history';message='Mock refusal'}} }
 elseif ($path -eq '/v1/calls/history?limit=1&period=all') { $data=@{data=@(@{call_id='call_mock'});totals=@{total=1;minutes=0;cost=0;cost_unknown=0;successful=0};filters=@{period='all';direction='all'};limit=1;offset=0;has_more=$false;next_cursor=$null} }
 elseif ($path -eq '/v1/calls/call_mock?view=detail') { $data=@{call_id='call_mock'} }
 elseif ($path -eq '/v1/calls/call_mock/recording') { $data=@{call_id='call_mock';status='unknown';url=$null;expires_at=$null} }
 elseif ($path -eq '/v1/phone-numbers' -and $Body -ceq '{"c4_unknown_field":true}') { $status=400;$data=@{error=@{code='unknown_field';message='Mock refusal'}} }
 elseif ($path -eq '/v1/phone-numbers/not-a-number' -and $Method -eq 'DELETE') { $status=400;$data=@{error=@{code='invalid_phone_format';message='Mock refusal'}} }
 elseif ($path -eq '/v1/phone-numbers/not-a-number' -and $Method -eq 'PATCH') { $status=400;$data=@{error=@{code='invalid_number_control';message='Mock refusal'}} }
 elseif ($path -eq '/v1/phone-numbers/not-a-number/callers/import') { $status=400;$data=@{error=@{code='invalid_body';message='Mock refusal'}} }
 elseif ($path -eq '/v1/calls/outbound' -or $path -eq '/v1/sms') { $status=400;$data=@{error=@{code='missing_field';message='Mock refusal'}} }
 else { throw 'Unmocked request is blocked; no network transport exists in this harness' }
 $json=ConvertTo-Json -InputObject $data -Depth 20 -Compress
 if($status -ge 400){$mockResponse=New-Object C4MockResponse($status,$json);throw (New-Object Net.WebException('Offline refusal',$null,[Net.WebExceptionStatus]::ProtocolError,$mockResponse))}
 return [pscustomobject]@{StatusCode=$status;Content=$json}
}
# Real live transport is replaced for the entire harness. There is no network fallback.
Remove-Item Env:NXF_STAGING_KEY -ErrorAction SilentlyContinue
$missing=@(& $TestScript)
if($global:C4MockRequests -ne 0 -or -not ($missing -match 'zero HTTP')){throw 'Missing-key guard failed'}
Write-Output 'PASS | offline missing-key guard: zero transport calls'
. $TestScript -LoadFunctionsOnly
$blocked=@(
 @('POST','/v1/keys','{}','None'),
 @('POST','/v1/keys/rotate','','Real'),
 @('POST','/v1/phone-numbers','{"phone_number":"+447861926140"}','Real'),
 @('DELETE','/v1/phone-numbers/%2B447861926140','','Real'),
 @('PATCH','/v1/phone-numbers/%2B447457401554','{"custom_prompt":"x"}','Real'),
 @('PATCH','/v1/phone-numbers/%2B12025550100','{"agent_id":"agent_target"}','Real'),
 @('POST','/v1/phone-numbers/not-a-number/callers/import','{"callers":[{"caller_number":"+12025550101","name":"x"}]}','Real'),
 @('DELETE','/v1/phone-numbers/not-a-number/callers/not-a-caller','','Real'),
 @('POST','/v1/calls/outbound','{"agent_id":"a","to_number":"+447453573770","prompt":"x"}','Real'),
 @('POST','/v1/sms','{"agent_id":"a","from_number":"+12025550100","to":"+447453573770","message":"x"}','Real'),
 @('PUT','/v1/agents/foreign','{"name":"x"}','Real'),
 @('DELETE','/v1/agents/foreign','','Real'),
 @('GET','https://example.com/v1/usage','','Real'),
 @('GET','/v1/agents/../keys','','Real')
)
foreach($case in $blocked){$didBlock=$false;try{Invoke-C4Request $case[0] $case[1] $case[2] $case[3]|Out-Null}catch{$didBlock=$true};if(-not $didBlock){throw 'Unsafe write was allowed'}}
$script:C4Owned.Add('agent_c4_mock')
try{Invoke-C4Request PUT '/v1/agents/agent_c4_mock' '{"pickup_delay":10}' 'Real'|Out-Null;throw 'Pickup change was allowed'}catch{if($_.Exception.Message -eq 'Pickup change was allowed'){throw}}
if($global:C4MockRequests -ne 0){throw 'Blocked requests reached transport'}
Write-Output 'PASS | offline guard: 15 unsafe requests blocked before transport'
$env:NXF_STAGING_KEY='nxf_OFFLINE:nxfs_OFFLINE'
foreach($scenario in @('normal','failed-update','lost-create')){
 $global:C4Scenario=$scenario;$global:C4MockDeleted=$false;$global:C4MockAgent=$null;$global:C4MockRequests=0
 $lines=@(& $TestScript)
 $summary=@($lines|Where-Object{$_ -like 'C4 RESULT*'})
 if($summary.Count -ne 1){$lines|Write-Output;throw 'No test result'}
 if($scenario -eq 'normal' -and $summary[0] -notmatch 'FAIL=0 '){$lines|Write-Output;throw 'Offline normal suite failed'}
 if($scenario -ne 'normal' -and $summary[0] -notmatch 'FAIL=1 '){$lines|Write-Output;throw 'Injected failure was not reported'}
 if(-not $global:C4MockDeleted -or $global:C4MockAgent.is_active -ne $false){throw 'Finally cleanup failed'}
 Write-Output ('PASS | offline '+$scenario+' | finally cleanup verified | '+$summary[0])
}
Remove-Item Env:NXF_STAGING_KEY -ErrorAction SilentlyContinue
Write-Output 'OFFLINE ONLY | Mock checks do not verify staging API behavior.'
