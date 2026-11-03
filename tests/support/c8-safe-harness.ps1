# Offline only. Synthetic values. Shadow HTTP so no network request can occur.
$ErrorActionPreference='Stop'
Set-StrictMode -Version 2
$runner=Join-Path $PSScriptRoot '..\..\scripts\C8-TEST.ps1'
Add-Type -TypeDefinition @"
using System; using System.IO; using System.Net; using System.Text;
public sealed class C8MockResponse : WebResponse {
 public HttpStatusCode StatusCode {get;private set;}
 private readonly string body;
 public C8MockResponse(int status,string value){StatusCode=(HttpStatusCode)status;body=value;}
 public override Stream GetResponseStream(){return new MemoryStream(Encoding.UTF8.GetBytes(body));}
}
"@
$global:Requests=0;$global:Mode='normal'
$global:Mocks=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'c8-mock-responses.json') -Raw | ConvertFrom-Json
function Refuse-C8($Status,$Json){
 $response=New-Object C8MockResponse($Status,'stream must not win')
 $exception=New-Object Net.WebException('Offline',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
 $record=New-Object Management.Automation.ErrorRecord($exception,'Offline',[Management.Automation.ErrorCategory]::InvalidData,$null)
 $record.ErrorDetails=New-Object Management.Automation.ErrorDetails($Json);throw $record
}
function global:Invoke-WebRequest {
 param($Uri,$Method,$Headers,$UseBasicParsing,$DisableKeepAlive,$MaximumRedirection,$TimeoutSec,$ErrorAction)
 if($Method -cne 'GET' -or -not $DisableKeepAlive -or $MaximumRedirection -ne 0 -or -not $Uri.StartsWith('https://nixflex-voice-engine-staging.up.railway.app/v1/')){throw 'Unsafe HTTP settings'}
 $global:Requests++
 if($global:Mode -ceq 'transport' -or ($global:Mode -ceq 'drop-once' -and $global:Requests -eq 1)){throw (New-Object Net.WebException('Offline transport'))}
 if($global:Mode -ceq 'http-error'){Refuse-C8 429 '{"error":{"code":"rate_limit_exceeded"}}'}
 if($global:Mode -ceq 'bad-json'){return [pscustomobject]@{StatusCode=200;Content='bad json'}}
 $path=$Uri.Substring('https://nixflex-voice-engine-staging.up.railway.app'.Length)
 if($path -match 'protected_call|447861926140|447457401554|signing-secret|/drafts/'){throw 'Forbidden target'}
 if($path -ceq '/v1/account/delete'){Refuse-C8 410 '{"error":{"code":"dashboard_owner_required"}}'}
 if($Headers.Authorization -cne 'Bearer offline-C9-test-only'){throw 'Synthetic auth required'}
 if($path -in @('/v1/numbers/not-a-number/knowledge-base','/v1/agents/not-an-agent/knowledge-numbers','/v1/knowledge/targets?kind=number')){Refuse-C8 410 '{"error":{"code":"number_knowledge_removed"}}'}
 $p=$global:Mocks.PSObject.Properties[$path.Split('?')[0]]
 if($null -eq $p){throw ('No synthetic route '+$path)}
 return [pscustomobject]@{StatusCode=200;Content=(ConvertTo-Json -InputObject $p.Value -Depth 40 -Compress)}
}
Remove-Item Env:NXF_STAGING_KEY -ErrorAction SilentlyContinue
$out=@(& $runner)
if($global:Requests -ne 1 -or -not ($out -match 'TOTAL \| PASS=1 FAIL=0 PENDING=145')){throw ('No-key run: '+$out[-1])}
Write-Output 'PASS | no-key run: only unauthenticated account tombstone, 145 explicit pending checks'
. $runner -LoadFunctionsOnly
$blocked=0
foreach($method in @('POST','PUT','PATCH','DELETE','HEAD','OPTIONS')){
 try{Guard-C8 $method '/v1/agents'}catch{$blocked++;continue};throw 'Non-GET allowed'
}
foreach($path in @('/v1/phone-numbers/%2B447861926140','/v1/phone-numbers/%252B447457401554','/v1/agents/../keys','https://api.nixflex.com/v1/agents','/v1/agents?x=%0a','/v1/agents?pickup_delay=1','/v1/knowledge-bases/base/drafts/draft','/v1/organisation/signing-secret','/v1/billing/status?refresh_cards=true')){
 try{Guard-C8 GET $path}catch{$blocked++;continue};throw 'Unsafe path allowed'
}
Write-Output ('PASS | '+$blocked+' unsafe requests blocked before HTTP')
$env:NXF_STAGING_KEY='offline-C9-test-only'
foreach($mode in @('drop-once','transport')){$global:Mode=$mode;$global:Requests=0;$r=Request-C8 '/v1/agents?limit=1';if($global:Requests -ne 2 -or -not $script:Retried){throw 'Retry bound failed'}}
$global:Mode='http-error';$global:Requests=0;$r=Request-C8 '/v1/agents';if($global:Requests -ne 1 -or $script:Retried -or $r.ErrorSource -cne 'ErrorDetails.Message' -or $r.Status -ne 429){throw 'HTTP error retry or error-body failure'}
$record=New-Object Management.Automation.ErrorRecord((New-Object Net.WebException('Offline',$null,[Net.WebExceptionStatus]::ProtocolError,(New-Object C8MockResponse(400,'{"error":{"code":"invalid_input"}}')))),'Offline',[Management.Automation.ErrorCategory]::InvalidData,$null)
if((HttpError-C8 $record).Source -cne 'stream'){throw 'Fallback stream lost'}
Write-Output 'PASS | HTTP=0 retried exactly once; HTTP errors not retried; ErrorDetails first, stream fallback'
$global:Mode='normal'
$rejected=0
foreach($sample in @(
 [pscustomobject]@{Value=([pscustomobject]@{enabled='false'});Schema=($script:Cases|Where-Object {$_.number -eq 55}).schema},
 [pscustomobject]@{Value=([pscustomobject]@{});Schema=($script:Cases|Where-Object {$_.number -eq 55}).schema},
 [pscustomobject]@{Value=([pscustomobject]@{items='bad';next_cursor=$null});Schema=($script:Cases|Where-Object {$_.number -eq 111}).schema}
)) {try{Shape-C8 $sample.Value $sample.Schema}catch{$rejected++;continue};throw 'Bad shape accepted'}
if($rejected -ne 3){throw 'Shape rejection missing'}
Write-Output 'PASS | wrong boolean, missing required field, wrong nested array rejected'

# C8 row 84: PS5 unwraps root arrays. Verify empty, one and several items from raw JSON.
$schema=($script:Cases|Where-Object {$_.number -eq 84}).schema
$call=[pscustomobject]@{call_id='call_example'}
foreach($raw in @('[]',(ConvertTo-Json -InputObject @($call) -Depth 40 -Compress),(ConvertTo-Json -InputObject @($call,$call) -Depth 40 -Compress))){
 $response=[pscustomobject]@{Json=(ConvertFrom-Json -InputObject $raw);RootArray=$true}
 WireShape-C8 $response $schema
}
foreach($raw in @('{}','null','"array"')){
 $rejected=$false
 try{WireShape-C8 ([pscustomobject]@{Json=(ConvertFrom-Json -InputObject $raw);RootArray=$false}) $schema}catch{$rejected=$true}
 if(-not $rejected){throw 'Wrong row 84 shape accepted'}
}
# C8 row 187: catalog normalization permits null accent language and label.
$voices=$global:Mocks.PSObject.Properties['/v1/voices'].Value
$voices.data[0].accents=@([pscustomobject]@{language=$null;locale=$null;label=$null})
Shape-C8 $voices ($script:Cases|Where-Object {$_.number -eq 187}).schema
$voices.data[0].accents[0].language=123
$rejected=$false
try{Shape-C8 $voices ($script:Cases|Where-Object {$_.number -eq 187}).schema}catch{$rejected=$true}
if(-not $rejected){throw 'Invalid accent metadata accepted'}
$voices.data[0].accents[0].language=$null
if(-not (CallerAbsent-C8 ([pscustomobject]@{Status=404;Json=('{"error":{"code":"caller_not_found"}}'|ConvertFrom-Json)}))){throw 'Valid caller absence rejected'}
foreach($bad in @([pscustomobject]@{Status=404;Json=('{"error":{"code":"phone_number_not_found"}}'|ConvertFrom-Json)},[pscustomobject]@{Status=200;Json=('{"error":{"code":"caller_not_found"}}'|ConvertFrom-Json)})){
 if(CallerAbsent-C8 $bad){throw 'Wrong caller absence accepted'}
}
Write-Output 'PASS | row 84 wire arrays, row 187 null accents, exact caller absence; wrong shapes still rejected'

$env:NXF_C8_NUMBER='+12025550123'
$env:NXF_C8_JOB_ID='33333333-3333-4333-8333-333333333333'
$env:NXF_C8_EXPORT_ID='44444444-4444-4444-8444-444444444444'
$env:NXF_C8_SESSION_ID='55555555-5555-4555-8555-555555555555'
$env:NXF_C8_CALLER_NUMBER='+12025550101'
$out=@(& $runner)

$fails=@($out|Where-Object {$_ -match '^FAIL'})
if($fails.Count){$fails|Write-Output;throw 'Full synthetic run failed'}
if(-not ($out -match 'TOTAL \| PASS=58 FAIL=0 PENDING=88')){throw ('Unexpected full totals: '+$out[-1])}
Write-Output 'PASS | full synthetic run: 54 public read shapes + 4 GET tombstones; 88 manual exclusions'
