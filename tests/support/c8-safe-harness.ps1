param([string]$TestScript=(Join-Path $PSScriptRoot '..\..\scripts\C8-TEST.ps1'))
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @"
using System; using System.IO; using System.Net; using System.Text;
public sealed class C8MockResponse : WebResponse {
 public HttpStatusCode StatusCode {get;private set;}
 private readonly string body;
 public C8MockResponse(int status,string value){StatusCode=(HttpStatusCode)status;body=value;}
 public override Stream GetResponseStream(){return new MemoryStream(Encoding.UTF8.GetBytes(body));}
}
"@
$global:C8Requests=0;$global:C8Mode='normal'
$global:C8Mocks=Get-Content -LiteralPath (Join-Path $PSScriptRoot 'c8-mock-responses.json') -Raw|ConvertFrom-Json
function Throw-C8Mock($Status,$Json){
 $response=New-Object C8MockResponse($Status,'')
 $exception=New-Object Net.WebException('Offline refusal',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
 $record=New-Object Management.Automation.ErrorRecord($exception,'OfflineRefusal',[Management.Automation.ErrorCategory]::InvalidData,$null)
 $record.ErrorDetails=New-Object Management.Automation.ErrorDetails($Json);throw $record
}
function global:Invoke-WebRequest {
 param($Uri,$Method,$Headers,$UseBasicParsing,$DisableKeepAlive,$MaximumRedirection,$TimeoutSec,$ErrorAction,$Body,$ContentType)
 if(-not $DisableKeepAlive -or $MaximumRedirection -ne 0 -or -not $Uri.StartsWith('https://nixflex-voice-engine-staging.up.railway.app/v1/')){throw 'Unsafe options'}
 $global:C8Requests++
 if($global:C8Mode -eq 'transport' -or ($global:C8Mode -eq 'drop-once' -and $global:C8Requests -eq 1)){throw (New-Object Net.WebException('Offline transport'))}
 if($global:C8Mode -eq 'bad-json'){return [pscustomobject]@{StatusCode=200;Content='not json'}}
 if($Headers.Authorization -ceq 'Bearer nxf_C8_INVALID:nxfs_C8_INVALID'){Throw-C8Mock 401 '{"error":{"code":"unauthorized","message":"Offline","doc_url":"https://docs.nixflex.com/errors/unauthorized"}}'}
 if($Headers.Authorization -cne 'Bearer offline-key'){throw 'Offline credential required'}
 $path=$Uri.Substring('https://nixflex-voice-engine-staging.up.railway.app'.Length)
 if($path -match 'protected_call|447861926140|447457401554|signing-secret|/drafts/'){throw 'Protected request'}
 if($Method -cin @('POST','PUT') -and $path -cmatch '^/v1/agents(?:/agent_fixture)?$'){
  $obj=[Text.Encoding]::UTF8.GetString($Body)|ConvertFrom-Json
  if($obj.name -isnot [pscustomobject]){throw 'Missing independent no-save guard'}
  $value=$obj.boosted_keywords
  if($value.Split(',').Count -eq 21){Throw-C8Mock 400 '{"error":{"code":"invalid_agent_field","message":"Keep up to 20 words - remove some to save","details":{"field":"boosted_keywords"}}}'}
  if($value.Length -eq 51){Throw-C8Mock 400 '{"error":{"code":"keyterms_term_too_long","message":"Keep each word or phrase within 50 characters to save","details":{"field":"boosted_keywords","limit":50}}}'}
  Throw-C8Mock 400 '{"error":{"code":"keyterms_list_too_large","message":"This list is 31 bytes over the 450-byte safety limit. Shorten or remove some words to save.","details":{"field":"boosted_keywords","limit":450,"actual_bytes":481,"over_bytes":31}}}'
 }
 $p=$global:C8Mocks.PSObject.Properties[$path];if($null -eq $p){throw 'Mock route absent'}
 return [pscustomobject]@{StatusCode=200;Content=(ConvertTo-Json -InputObject $p.Value -Depth 30 -Compress)}
}
Remove-Item Env:NXF_STAGING_KEY -ErrorAction SilentlyContinue
$out=@(& $TestScript)
if($global:C8Requests -ne 40 -or -not ($out -match 'TOTAL \| PASS=40 FAIL=0 PENDING=148')){throw ('Missing-key run failed: '+($out[-1]))}
Write-Output 'PASS | 40 ErrorDetails-first refusals and 148 explicit pending checks'
. $TestScript -LoadFunctionsOnly
$record=New-Object Management.Automation.ErrorRecord((New-Object Net.WebException('Offline',$null,[Net.WebExceptionStatus]::ProtocolError,(New-Object C8MockResponse(400,'{"error":{"code":"invalid_input"}}')))),'Offline',[Management.Automation.ErrorCategory]::InvalidData,$null)
if((Read-C8HttpError $record).Source -cne 'stream'){throw 'Stream fallback lost'}
$blocked=0
foreach($case in $script:C8Cases|Where-Object {-not $_.read -or $_.number -in @(105,158)}){
 $path=RefusalPath-C8 $case;$body='{}';if($case.method -ceq 'GET'){$body=''}
 try{Assert-C8Request $case.method $path $body 'Real'}catch{$blocked++;continue};throw ('Unsafe operation allowed: '+$case.number)
}
foreach($path in @('/v1/phone-numbers/%2B447861926140','/v1/agent-inbox/web/%2B447457401554','/v1/agents/../keys','/v1/agents?x=%0a')){try{Assert-C8Request GET $path '' 'Real'}catch{$blocked++;continue};throw 'Unsafe path allowed'}
Write-Output ('PASS | '+$blocked+' unsafe requests blocked before HTTP')
$env:NXF_STAGING_KEY='offline-key';$script:C8Agent='agent_fixture'
foreach($mode in @('drop-once','transport')){$global:C8Mode=$mode;$global:C8Requests=0;$r=Invoke-C8Request GET '/v1/agents?limit=1';if($global:C8Requests -ne 2 -or -not $script:C8Retried){throw 'GET retry bound lost'}}
$global:C8Requests=0;$body=[ordered]@{boosted_keywords=$script:C8Terms.count;name=[pscustomobject]@{}}|ConvertTo-Json -Depth 3 -Compress
$r=Invoke-C8Request POST '/v1/agents' $body;if($global:C8Requests -ne 1 -or $script:C8Retried){throw 'Write retried'}
$global:C8Mode='normal';$global:C8Requests=0;$r=Invoke-C8Request GET '/v1/knowledge/capabilities' '' 'Invalid';if($global:C8Requests -ne 1 -or $script:C8Retried){throw 'HTTP error retried'}
Write-Output 'PASS | exactly one GET HTTP=0 retry; HTTP errors and writes never retry'
$env:NXF_C8_JOB_ID='33333333-3333-4333-8333-333333333333';$env:NXF_C8_EXPORT_ID='44444444-4444-4444-8444-444444444444';$env:NXF_C8_SESSION_ID='55555555-5555-4555-8555-555555555555';$env:NXF_C8_CALLER_NUMBER='+12025550101'
$out=@(& $TestScript)
$fail=@($out|Where-Object {$_ -match '^FAIL'});if($fail.Count){$fail|Write-Output;throw 'Authenticated fixture flow failed'}
if(-not ($out -match 'TOTAL \| PASS=103 FAIL=0 PENDING=85')){throw ('Unexpected full totals: '+$out[-1])}
Write-Output 'PASS | 57 mocked read/calculation examples and six no-save keyterm refusals; 85 pending manual tests'
