param([string]$TestScript=(Join-Path $PSScriptRoot '..\..\scripts\C7-TEST.ps1'))
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @"
using System; using System.IO; using System.Net; using System.Text;
public sealed class C7MockResponse : WebResponse {
 public HttpStatusCode StatusCode {get;private set;}
 private readonly string body;
 public C7MockResponse(int status,string value){StatusCode=(HttpStatusCode)status;body=value;}
 public override Stream GetResponseStream(){return new MemoryStream(Encoding.UTF8.GetBytes(body));}
}
"@
$global:C7Requests=0; $global:C7Mode='refusal'
function Throw-C7Mock($Status,$Json) {
    $response=New-Object C7MockResponse($Status,'')
    $exception=New-Object Net.WebException('Offline refusal',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
    $record=New-Object Management.Automation.ErrorRecord($exception,'OfflineRefusal',[Management.Automation.ErrorCategory]::InvalidData,$null)
    $record.ErrorDetails=New-Object Management.Automation.ErrorDetails($Json)
    throw $record
}
function global:Invoke-WebRequest {
    param($Uri,$Method,$Headers,$UseBasicParsing,$DisableKeepAlive,$MaximumRedirection,$TimeoutSec,$ErrorAction,$Body,$ContentType)
    if (-not $DisableKeepAlive -or $MaximumRedirection -ne 0 -or -not $Uri.StartsWith('https://nixflex-voice-engine-staging.up.railway.app/v1/')) { throw 'Unsafe options' }
    $global:C7Requests++
    if ($global:C7Mode -eq 'transport' -or ($global:C7Mode -eq 'drop-once' -and $global:C7Requests -eq 1)) { throw (New-Object Net.WebException('Offline transport')) }
    if ($global:C7Mode -eq 'bad-json') { return [pscustomobject]@{StatusCode=200;Content='not json'} }
    if ($Headers.Authorization -ceq 'Bearer nxf_C7_INVALID:nxfs_C7_INVALID' -or $global:C7Mode -eq 'refusal') { Throw-C7Mock 401 '{"error":{"code":"unauthorized","message":"Offline","doc_url":"https://docs.nixflex.com/errors/unauthorized"}}' }
    if ($Headers.Authorization -cne 'Bearer offline-key') { throw 'Offline credential required' }
    $path=$Uri.Substring('https://nixflex-voice-engine-staging.up.railway.app'.Length)
    if ($Method -in @('POST','PUT') -and $path -match '^/v1/agents') { Throw-C7Mock 400 '{"error":{"code":"invalid_agent_field","message":"Keep up to 20 words - remove some to save","details":{"field":"boosted_keywords"}}}' }
    $obj=@{}
    if ($path -eq '/v1/agents?limit=1') { $obj=@(@{agent_id='agent_fixture'}) }
    elseif ($path -eq '/v1/agent-inbox/numbers?offset=0') { $obj=@{numbers=@(@{phone_number='+447861926140'},@{phone_number='+447457401554'},@{phone_number='+12025550123'});agents=@();has_more=$false} }
    elseif ($path -eq '/v1/sms/campaigns?limit=1') { $obj=@{campaigns=@(@{campaign_id='campaign_fixture'})} }
    elseif ($path -eq '/v1/agent-inbox/web/%2B12025550123?limit=1&period=all') { $obj=@{conversations=@(@{thread_key='visitor/plus+ ü'})} }
    else {
        foreach ($case in $script:C7Cases | Where-Object {-not $_.write}) {
            $route=$case.path.Replace(':number','%2B12025550123').Replace(':channel','web').Replace(':id','campaign_fixture').Replace(':thread',[uri]::EscapeDataString('visitor/plus+ ü'))
            if ($path.Split('?')[0] -ceq $route) { foreach ($f in $case.fields) { $obj[$f]=$null }; break }
        }
        if ($path -match '/features') { $obj.enabled=$false }
        if ($path -match '/agent-web/') { $obj.revision='999999999999999999' }
        if ($path -eq '/v1/contact-hours/preview') { $obj.preview_only=$true; $obj.rows=@(@{}) }
    }
    return [pscustomobject]@{StatusCode=200;Content=(ConvertTo-Json -InputObject $obj -Depth 10 -Compress)}
}
Remove-Item Env:NXF_STAGING_KEY -ErrorAction SilentlyContinue
$out=@(& $TestScript)
if ($global:C7Requests -ne 29 -or -not ($out -match 'TOTAL \| PASS=29 FAIL=0 PENDING=31')) { throw 'Missing-key run failed' }
Write-Output 'PASS | 29 consumed-stream ErrorDetails refusals; 31 pending checks'
. $TestScript -LoadFunctionsOnly
$response=New-Object C7MockResponse(400,'{"error":{"code":"invalid_agent_field"}}')
$exception=New-Object Net.WebException('Offline',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
$record=New-Object Management.Automation.ErrorRecord($exception,'Offline',[Management.Automation.ErrorCategory]::InvalidData,$null)
if ((Read-C7HttpError $record).Source -cne 'stream') { throw 'Stream fallback lost' }
$blocked=0
foreach ($case in $script:C7Cases | Where-Object {$_.write}) {
    $path=$case.path.Replace(':id','existing').Replace(':number','%2B12025550123').Replace(':channel','web').Replace(':thread','existing')
    $denied=$false; try { Assert-C7Request $case.method $path '{}' 'Real' } catch { $denied=$true }
    if (-not $denied) { throw 'Mutation allowed' }; $blocked++
}
foreach ($path in @('/v1/agent-web/%2B447861926140','/v1/agent-inbox/retention?number=%2B447457401554','/v1/phone-numbers','/v1/organisation/signing-secret','/v1/calls/outbound')) {
    $denied=$false; try { Assert-C7Request 'GET' $path '' 'Real' } catch { $denied=$true }
    if (-not $denied) { throw 'Forbidden read allowed' }; $blocked++
}
$script:C7Agent='agent_fixture'
foreach ($badBody in @('{"boosted_keywords":"one","name":{}}','{"boosted_keywords":"one","name":"valid"}',('{"boosted_keywords":"'+$script:C7Terms+'","name":"valid"}'),('{"boosted_keywords":"'+$script:C7Terms+'","name":{},"pickup_delay":1}'))) {
    $denied=$false; try { Assert-C7Request 'PUT' '/v1/agents/agent_fixture' $badBody 'Real' } catch { $denied=$true }
    if (-not $denied) { throw 'Unsafe keyterm body allowed' }; $blocked++
}
Write-Output ('PASS | '+$blocked+' unsafe requests blocked; stream fallback preserved')
$env:NXF_STAGING_KEY='offline-key'
$global:C7Mode='drop-once'; $global:C7Requests=0
$r=Invoke-C7Request 'GET' '/v1/agent-inbox/features'
if ($global:C7Requests -ne 2 -or -not $script:C7Retried -or $r.Status -ne 200 -or $r.Json.enabled -isnot [bool]) { throw 'One retry failed' }
$global:C7Mode='transport'; $global:C7Requests=0
$r=Invoke-C7Request 'GET' '/v1/agent-inbox/features'
if ($global:C7Requests -ne 2 -or $r.Status -ne 0) { throw 'Retry bound failed' }
$global:C7Requests=0
$r=Invoke-C7Request 'POST' '/v1/contact-hours/preview' '{"agent_id":"agent_fixture","recipients":[{"phone":"+12025550101","country":"US","timezone":"America/New_York"}]}'
if ($global:C7Requests -ne 1 -or $script:C7Retried) { throw 'Preview retried' }
$global:C7Requests=0
$body=[ordered]@{boosted_keywords=$script:C7Terms;name=[pscustomobject]@{}} | ConvertTo-Json -Compress
$r=Invoke-C7Request 'PUT' '/v1/agents/agent_fixture' $body
if ($global:C7Requests -ne 1 -or $script:C7Retried) { throw 'Write retried' }
$global:C7Mode='refusal'; $global:C7Requests=0
$r=Invoke-C7Request 'GET' '/v1/agent-inbox/features'
if ($global:C7Requests -ne 1 -or $script:C7Retried) { throw 'HTTP error retried' }
$global:C7Mode='bad-json'; $global:C7Requests=0
try { $r=Invoke-C7Request 'GET' '/v1/agent-inbox/features' } catch { }
if ($global:C7Requests -ne 1 -or $script:C7Retried) { throw 'Parse error retried' }
Write-Output 'PASS | GET HTTP=0 retried exactly once; HTTP errors, malformed replies, preview and writes never retried'
$global:C7Mode='success'; $global:C7Requests=0
$out=@(& $TestScript)
if (-not ($out -match 'TOTAL \| PASS=42 FAIL=0 PENDING=18')) { $out | Write-Output; throw 'Authenticated fixture flow failed' }
Write-Output 'PASS | 11 mocked reads/previews and two validation refusals; 18 successful writes pending'
