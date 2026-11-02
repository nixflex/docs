param([string]$TestScript = (Join-Path $PSScriptRoot '..\..\scripts\C5-TEST.ps1'))
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @"
using System; using System.IO; using System.Net; using System.Text;
public sealed class C5MockResponse : WebResponse {
 public HttpStatusCode StatusCode {get;private set;}
 private readonly string body;
 public C5MockResponse(int status,string value){StatusCode=(HttpStatusCode)status;body=value;}
 public override Stream GetResponseStream(){return new MemoryStream(Encoding.UTF8.GetBytes(body));}
}
"@
$global:C5MockRequests=0
function global:Invoke-WebRequest {
 param($Uri,$Method,$Headers,$UseBasicParsing,$DisableKeepAlive,$MaximumRedirection,$TimeoutSec,$ErrorAction,$Body,$ContentType)
 if(-not $DisableKeepAlive -or $MaximumRedirection -ne 0 -or -not $Uri.StartsWith('https://nixflex-voice-engine-staging.up.railway.app/v1/')){throw 'Unsafe transport options'}
 if($Headers.Authorization -cne 'Bearer nxf_C5_INVALID:nxfs_C5_INVALID'){throw 'Offline suite blocks all other credentials'}
 $global:C5MockRequests++
 # Real PS5.1 regression: response stream is already consumed; only ErrorDetails has the JSON.
 $response=New-Object C5MockResponse(401,'')
 $exception=New-Object Net.WebException('Offline refusal',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
 $record=New-Object Management.Automation.ErrorRecord($exception,'OfflineRefusal',[Management.Automation.ErrorCategory]::AuthenticationError,$null)
 $record.ErrorDetails=New-Object Management.Automation.ErrorDetails('{"error":{"code":"unauthorized","message":"Offline refusal","doc_url":"https://docs.nixflex.com/errors/unauthorized"}}')
 throw $record
}
Remove-Item Env:NXF_STAGING_KEY -ErrorAction SilentlyContinue
$result=@(& $TestScript)
if($global:C5MockRequests -ne 27 -or -not ($result -match 'TOTAL \| PASS=27 FAIL=0 PENDING=27')){throw 'Missing-key/error-body regression failed'}
Write-Output 'PASS | offline full run: 27 consumed-stream ErrorDetails refusals; 27 pending examples'
. $TestScript -LoadFunctionsOnly
# Fallback remains supported for callers whose error stream has not already been consumed.
$response=New-Object C5MockResponse(400,'{"error":{"code":"invalid_request"}}')
$exception=New-Object Net.WebException('Offline fallback',$null,[Net.WebExceptionStatus]::ProtocolError,$response)
$record=New-Object Management.Automation.ErrorRecord($exception,'OfflineFallback',[Management.Automation.ErrorCategory]::InvalidData,$null)
$parsed=Read-C5HttpError $record
if($parsed.Status -ne 400 -or $parsed.Source -cne 'stream' -or ($parsed.Content|ConvertFrom-Json).error.code -cne 'invalid_request'){throw 'Fallback failed'}
Write-Output 'PASS | stream fallback preserved'
$blocked=0
foreach($case in $script:C5Cases | Where-Object {$_.write}) {
 $path=$case.path.Replace(':id','existing_campaign').Replace(':number','%2B447861926140').Replace(':thread','existing').Replace(':channel','sms')
 $refused=$false; try { Assert-C5Request $case.method $path '{}' 'Real' } catch { $refused=$true }
 if(-not $refused){throw 'Mutation guard failed'}; $blocked++
}
foreach($path in @('/v1/keys','/v1/keys/rotate','/v1/phone-numbers','/v1/phone-numbers/%2B447457401554','/v1/calls/outbound','/v1/sms')) {
 $refused=$false;try{Assert-C5Request 'POST' $path '{}' 'Real'}catch{$refused=$true};if(-not $refused){throw 'Forbidden write allowed'};$blocked++
}
$refused=$false;try{Assert-C5Request 'POST' '/v1/contact-hours/preview' '{"agent_id":"agent_test","recipients":[{"phone":"+447861926140","country":"GB","timezone":"Europe/London"}]}' 'Real'}catch{$refused=$true};if(-not $refused){throw 'Preview fixture guard failed'};$blocked++
if($global:C5MockRequests -ne 27){throw 'Guard check reached transport'}
Write-Output ('PASS | '+$blocked+' unsafe mutations blocked before transport')
