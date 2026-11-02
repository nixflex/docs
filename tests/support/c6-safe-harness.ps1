param([string]$TestScript = (Join-Path $PSScriptRoot '..\..\scripts\C6-TEST.ps1'))
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @"
using System; using System.IO; using System.Net; using System.Text;
public sealed class C6MockResponse : WebResponse {
 public HttpStatusCode StatusCode {get;private set;}
 private readonly string body;
 public C6MockResponse(int status,string value){StatusCode=(HttpStatusCode)status;body=value;}
 public override Stream GetResponseStream(){return new MemoryStream(Encoding.UTF8.GetBytes(body));}
}
"@
$global:C6MockRequests=0
function global:Invoke-WebRequest {
 param($Uri,$Method,$Headers,$UseBasicParsing,$DisableKeepAlive,$MaximumRedirection,$TimeoutSec,$ErrorAction,$Body,$ContentType)
 if(-not $DisableKeepAlive -or $MaximumRedirection -ne 0 -or -not $Uri.StartsWith('https://nixflex-voice-engine-staging.up.railway.app/v1/')){throw 'Unsafe transport options'}
 if($Headers.Authorization -ceq 'Bearer C6_OFFLINE_ONLY') {
  if($Method -cne 'GET'){throw 'Authenticated mutation reached mock'}
  $wirePath=[uri]::UnescapeDataString(([uri]$Uri).AbsolutePath)
  $fixture=$global:C6ReadFixtures.PSObject.Properties[$wirePath]
  if($null -eq $fixture){throw 'Unexpected real-key route reached mock'}
  $global:C6ReadRequests++
  return [pscustomobject]@{StatusCode=200;Content=($fixture.Value|ConvertTo-Json -Depth 20 -Compress)}
 }
 if($Headers.Authorization -cne 'Bearer nxf_C6_INVALID:nxfs_C6_INVALID'){throw 'Offline suite blocks all other credentials'}
 $global:C6MockRequests++
 # Real PS5.1 regression: response stream is already consumed; only ErrorDetails has the JSON.
 $response=New-Object C6MockResponse(401,'')
 $exception=New-Object Net.WebException('Offline refusal',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
 $record=New-Object Management.Automation.ErrorRecord($exception,'OfflineRefusal',[Management.Automation.ErrorCategory]::AuthenticationError,$null)
 $record.ErrorDetails=New-Object Management.Automation.ErrorDetails('{"error":{"code":"unauthorized","message":"Offline refusal","doc_url":"https://docs.nixflex.com/errors/unauthorized"}}')
 throw $record
}
Remove-Item Env:NXF_STAGING_KEY -ErrorAction SilentlyContinue
$result=@(& $TestScript)
if($global:C6MockRequests -ne 46 -or -not ($result -match 'TOTAL | PASS=46 FAIL=0 PENDING=46')){throw 'Missing-key/error-body regression failed'}
Write-Output 'PASS | offline full run: 46 consumed-stream ErrorDetails refusals; 46 pending examples'
. $TestScript -LoadFunctionsOnly
# Fallback remains supported for callers whose error stream has not already been consumed.
$response=New-Object C6MockResponse(400,'{"error":{"code":"invalid_request"}}')
$exception=New-Object Net.WebException('Offline fallback',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
$record=New-Object Management.Automation.ErrorRecord($exception,'OfflineFallback',[Management.Automation.ErrorCategory]::InvalidData,$null)
$parsed=Read-C6HttpError $record
if($parsed.Status -ne 400 -or $parsed.Source -cne 'stream' -or ($parsed.Content|ConvertFrom-Json).error.code -cne 'invalid_request'){throw 'Fallback failed'}
Write-Output 'PASS | stream fallback preserved'
$blocked=0
foreach($case in $script:C6Cases | Where-Object {$_.write}) {
 $path=$case.path.Replace(':id','11111111-1111-4111-8111-111111111111').Replace(':phoneNumber','%2B447861926140').Replace(':agentId','example_agent')
 $refused=$false; try { Assert-C6Request $case.method $path '{}' 'Real' } catch { $refused=$true }
 if(-not $refused){throw 'Mutation guard failed'}; $blocked++
}
foreach($path in @('/v1/keys','/v1/keys/rotate','/v1/phone-numbers','/v1/phone-numbers/%2B447457401554','/v1/calls/outbound','/v1/sms')) {
 $refused=$false;try{Assert-C6Request 'POST' $path '{}' 'Real'}catch{$refused=$true};if(-not $refused){throw 'Forbidden write allowed'};$blocked++
}

foreach($path in @('/v1/organisation/signing-secret','/v1/organisation/accept','/v1/organisation/transfer','/v1/integrations/slack/number/%2B447861926140/extra','/v1/integrations/slack/number/%2B447861926140%2Fextra','/v1/organisation?extra=1')) {
 $refused=$false;try{Assert-C6Request 'GET' $path '' 'Real'}catch{$refused=$true};if(-not $refused){throw 'Excluded read allowed'};$blocked++
}
if($global:C6MockRequests -ne 46){throw 'Guard check reached transport'}
Write-Output ('PASS | '+$blocked+' unsafe requests blocked before transport')
$feature=$script:C6Cases|Where-Object {$_.number -eq 55}
foreach($enabled in @($true,$false)) { Assert-C6Fields $feature ([pscustomobject]@{enabled=$enabled}) }
foreach($bad in @([pscustomobject]@{enabled='false'},[pscustomobject]@{enabled=$null},[pscustomobject]@{different=$true})) {
 $refused=$false;try{Assert-C6Fields $feature $bad}catch{$refused=$true};if(-not $refused){throw 'Bad feature shape accepted'}
}
Write-Output 'PASS | row 55 true and false accepted; string, null and missing enabled refused'
. (Join-Path $PSScriptRoot '..\..\scripts\C5-TEST.ps1') -LoadFunctionsOnly
foreach($enabled in @($true,$false)) { Assert-C5FeatureResponse ([pscustomobject]@{Status=200;Json=[pscustomobject]@{enabled=$enabled}}) }
Write-Output 'PASS | corrected C5 boolean assertion accepts true and false'

$global:C6ReadFixtures=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'c6-read-fixtures.json') -Raw | ConvertFrom-Json
$global:C6ReadRequests=0
$env:NXF_STAGING_KEY='C6_OFFLINE_ONLY'; $env:NXF_PHONE_NUMBER='+12025550100'; $env:NXF_AGENT_ID='example_agent'
$result=@(& $TestScript)
if($global:C6ReadRequests -ne 15 -or -not ($result -match 'TOTAL | PASS=61 FAIL=0 PENDING=31')){Write-Output $result;throw 'Read example flow failed'}
Write-Output 'PASS | offline real-key mode: 15 read examples, 61 total checks, 31 manual checks; no successful write or secret read'
