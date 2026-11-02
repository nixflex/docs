# C8 consolidated staging check. Windows PowerShell 5.1. No successful writes.
[CmdletBinding()]
param([switch]$LoadFunctionsOnly)
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
$script:C8Base='https://nixflex-voice-engine-staging.up.railway.app'
$script:C8Cases=@'
__CASES__
'@ | ConvertFrom-Json
$script:C8Pass=0; $script:C8Fail=0; $script:C8Pending=0
$script:C8Status=0; $script:C8Code='none'; $script:C8Retried=$false; $script:C8Phase='request'
$script:C8Agent=''
$script:C8Terms=@{count=((1..21|ForEach-Object {'C8_term_'+$_}) -join ',');length=('x'*51);bytes=((1..10|ForEach-Object {('x'*43)+[string]$_}) -join ',')}
function Assert-C8($Condition){if(-not $Condition){throw 'C8 assertion failed; response withheld'}}
function Field-C8($Object,[string]$Name){if($null -eq $Object){return $null};$p=$Object.PSObject.Properties[$Name];if($null -eq $p){return $null};return $p.Value}
function Reason-C8 {return ('HTTP='+$script:C8Status+' code='+$script:C8Code+' phase='+$script:C8Phase+' retried='+$script:C8Retried.ToString().ToLowerInvariant())}
function Pending-C8($Name,$Reason){$script:C8Pending++;Write-Output ('PENDING | '+$Name+' | '+$Reason)}
function Test-C8($Name,[scriptblock]$Action){$script:C8Status=0;$script:C8Code='none';$script:C8Retried=$false;$script:C8Phase='request';try{& $Action|Out-Null;$script:C8Pass++;Write-Output ('PASS | '+$Name+' | '+(Reason-C8))}catch{$script:C8Fail++;Write-Output ('FAIL | '+$Name+' | '+(Reason-C8)+' | response withheld')}}
function Read-C8HttpError($Record){
 $response=$Record.Exception.Response
 if($null -eq $response){return [pscustomobject]@{Status=0;Content='';Source='transport'}}
 $content='';$source='stream'
 if($Record.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($Record.ErrorDetails.Message)){$content=[string]$Record.ErrorDetails.Message;$source='ErrorDetails.Message'}
 else{$reader=New-Object IO.StreamReader($response.GetResponseStream());try{$content=$reader.ReadToEnd()}finally{$reader.Dispose()}}
 return [pscustomobject]@{Status=[int]$response.StatusCode;Content=$content;Source=$source}
}
function RefusalPath-C8($Case){return [regex]::Replace($Case.path,':([A-Za-z_]+)',{param($m) if($m.Groups[1].Value -ceq 'channel'){'web'}elseif($m.Groups[1].Value -cin @('number','phoneNumber','callerNumber')){'not-a-number'}else{'00000000-0000-4000-8000-000000000000'}})}
function MatchPath-C8($Template,$Path){$pattern='^'+[regex]::Escape($Template);$pattern=[regex]::Replace($pattern,':([A-Za-z_]+)','[^/?#]+');return $Path -cmatch ($pattern+'(?:\?[^#]*)?$')}
function Assert-C8Request([string]$Method,[string]$Path,[string]$Body,[string]$Auth){
 Assert-C8 ($Auth -cin @('Real','Invalid'))
 Assert-C8 ($Path -cmatch '^/v1/[A-Za-z0-9_/%+:?.=&,-]+$' -and $Path -notmatch '\.\.|://|%0[ad]')
 $decoded=[uri]::UnescapeDataString($Path)
 Assert-C8 (($decoded+$Body) -notmatch '447861926140|447457401554|pickup_delay|[\r\n]' -and $decoded -notmatch '\.\.|://')
 if($Auth -ceq 'Invalid'){
  Assert-C8 ($Body -ceq '' -or $Body -ceq '{}');$allowed=$false
  foreach($case in $script:C8Cases){if($case.new -and $case.method -ceq $Method -and (RefusalPath-C8 $case) -ceq $Path){$allowed=$true}}
  Assert-C8 $allowed;return
 }
 if($Method -ceq 'GET'){
  Assert-C8 ($Body -ceq '');$allowed=$false
  foreach($case in $script:C8Cases){if($case.method -ceq 'GET' -and $case.number -notin @(105,158) -and (MatchPath-C8 $case.path $Path)){$allowed=$true}}
  Assert-C8 $allowed;return
 }
 if($Method -ceq 'POST' -and $Path -ceq '/v1/contact-hours/preview'){
  $expected=[ordered]@{agent_id=$script:C8Agent;recipients=@([ordered]@{phone='+12025550101';country='US';timezone='America/New_York'})}|ConvertTo-Json -Depth 5 -Compress
  Assert-C8 ($script:C8Agent -and $Body -ceq $expected);return
 }
 if($Method -ceq 'POST' -and $script:C8Agent -and $Path -ceq ('/v1/agents/'+[uri]::EscapeDataString($script:C8Agent)+'/knowledge-base/source-measure')){Assert-C8 ($Body -ceq '{"text":"Appointments are available Monday to Friday."}');return}
 if($Method -ceq 'POST' -and $Path -cmatch '^/v1/knowledge-bases/[A-Za-z0-9_-]+/topic-search$'){Assert-C8 ($Body -ceq '{"query":"appointment times"}');return}
 # Keyterm refusals are the ONLY authenticated agent writes. An invalid name object
 # independently prohibits a save even if the keyterm string is grandfathered.
 Assert-C8 (($Method -ceq 'POST' -and $Path -ceq '/v1/agents') -or ($Method -ceq 'PUT' -and $script:C8Agent -and $Path -ceq ('/v1/agents/'+[uri]::EscapeDataString($script:C8Agent))))
 $obj=$Body|ConvertFrom-Json
 Assert-C8 (@($obj.PSObject.Properties.Name).Count -eq 2 -and $obj.PSObject.Properties.Name[0] -ceq 'boosted_keywords')
 Assert-C8 ($obj.boosted_keywords -cin @($script:C8Terms.Values))
 Assert-C8 ($obj.name -is [pscustomobject] -and @($obj.name.PSObject.Properties).Count -eq 0)
}
function Invoke-C8Request([string]$Method,[string]$Path,[string]$Body='', [ValidateSet('Real','Invalid')][string]$Auth='Real'){
 $script:C8Status=0;$script:C8Code='none';$script:C8Retried=$false;$script:C8Phase='guard'
 Assert-C8Request $Method $Path $Body $Auth
 $headers=@{};if($Auth -ceq 'Real'){Assert-C8 (-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY));$headers.Authorization='Bearer '+$env:NXF_STAGING_KEY}else{$headers.Authorization='Bearer nxf_C8_INVALID:nxfs_C8_INVALID'}
 $args=@{Uri=($script:C8Base+$Path);Method=$Method;Headers=$headers;UseBasicParsing=$true;DisableKeepAlive=$true;MaximumRedirection=0;TimeoutSec=30;ErrorAction='Stop'}
 if($Body){$args.Body=[Text.Encoding]::UTF8.GetBytes($Body);$args.ContentType='application/json'}
 $script:C8Phase='request';$status=0;$content='';$source='success'
 for($attempt=0;$attempt -lt 2;$attempt++){
  try{$r=Invoke-WebRequest @args;$status=[int]$r.StatusCode;$content=[string]$r.Content;$source='success'}catch{$e=Read-C8HttpError $_;$status=$e.Status;$content=$e.Content;$source=$e.Source}
  if($status -eq 0 -and $Method -ceq 'GET' -and $attempt -eq 0){$script:C8Retried=$true;Write-Host 'INFO | read HTTP=0 | retried once after 500 ms';Start-Sleep -Milliseconds 500;continue};break
 }
 $script:C8Status=$status;$script:C8Phase='parse';$json=$null
 if($content){try{$json=ConvertFrom-Json -InputObject $content}catch{throw 'Non-JSON response withheld'}}
 $err=Field-C8 $json 'error';$code=Field-C8 $err 'code'
 if($code){$script:C8Code='unrecognised';if($code -cin @('unauthorized','invalid_agent_field','keyterms_term_too_long','keyterms_list_too_large','agent_inbox_disabled','not_found','agent_not_found','knowledge_not_released','knowledge_unconfigured','export_expired','agent_timezone_required','knowledge_missing','invalid_input')){$script:C8Code=[string]$code}}
 $script:C8Phase='status'
 return [pscustomobject]@{Status=$status;Json=$json;IsArray=$content.TrimStart().StartsWith('[');ErrorSource=$source}
}
function Shape-C8($Value,$Schema,[int]$Depth=0){
 if($Depth -gt 5){return}
 $branches=Field-C8 $Schema 'anyOf';if(-not $branches){$branches=Field-C8 $Schema 'oneOf'}
 if($branches){$valid=$false;foreach($branch in @($branches)){try{Shape-C8 $Value $branch $Depth;$valid=$true;break}catch{}};Assert-C8 $valid;return}
 $type=Field-C8 $Schema 'type'
 if($null -eq $Value){Assert-C8 (@($type) -contains 'null');return}
 if(@($type) -contains 'object'){
  foreach($f in @(Field-C8 $Schema 'required')){if($f){Assert-C8 ($null -ne $Value.PSObject.Properties[$f])}}
  $props=Field-C8 $Schema 'properties';if($props){foreach($p in $props.PSObject.Properties){if($null -ne $Value.PSObject.Properties[$p.Name]){Shape-C8 $Value.PSObject.Properties[$p.Name].Value $p.Value ($Depth+1)}}}
 }elseif(@($type) -contains 'array'){
  # PowerShell unwraps one-item/empty arrays; wire-root arrays are checked separately.
  $items=Field-C8 $Schema 'items';if($items){foreach($v in @($Value)){Shape-C8 $v $items ($Depth+1)}}
 }elseif(@($type) -contains 'boolean'){Assert-C8 ($Value -is [bool])}
 elseif(@($type) -contains 'string'){Assert-C8 ($Value -is [string])}
 elseif(@($type) -contains 'integer'){Assert-C8 ($Value -is [int] -or $Value -is [long])}
 elseif(@($type) -contains 'number'){Assert-C8 ($Value -is [ValueType] -and $Value -isnot [bool])}
}
if($LoadFunctionsOnly){return}
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
foreach($case in $script:C8Cases){if($case.new){Test-C8 ('row '+$case.number+' documented error 401 unauthorized'){
 $body='';if($case.method -cne 'GET'){$body='{}'}
 $r=Invoke-C8Request $case.method (RefusalPath-C8 $case) $body 'Invalid'
 Assert-C8 ($r.Status -eq 401 -and (Field-C8 (Field-C8 $r.Json 'error') 'code') -ceq 'unauthorized')
 Assert-C8 ($r.ErrorSource -ceq 'ErrorDetails.Message')
 foreach($f in @('message','doc_url')){Assert-C8 ($null -ne (Field-C8 (Field-C8 $r.Json 'error') $f))}
}}}
$hasKey=-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)
$fixture=@{agent='';number='';thread='';campaign='';call='';voice='';kb='';topic='';job=$env:NXF_C8_JOB_ID;export=$env:NXF_C8_EXPORT_ID;session=$env:NXF_C8_SESSION_ID;caller=$env:NXF_C8_CALLER_NUMBER}
function Discover-C8([string]$Path){try{$r=Invoke-C8Request GET $Path;if($r.Status -eq 200){return $r.Json}}catch{};return $null}
if($hasKey){
 $rows=Discover-C8 '/v1/agents?limit=1';if(@($rows).Count -gt 0){$fixture.agent=[string](Field-C8 @($rows)[0] 'agent_id')};$script:C8Agent=$fixture.agent
 $numbers=Discover-C8 '/v1/agent-inbox/numbers?offset=0'
 foreach($n in @(Field-C8 $numbers 'numbers')){$phone=Field-C8 $n 'phone_number';if($phone -cmatch '^\+[1-9][0-9]{6,14}$' -and $phone -cnotin @('+447861926140','+447457401554')){$fixture.number=[string]$phone;break}}
 if($fixture.number){$inbox=Discover-C8 ('/v1/agent-inbox/web/'+[uri]::EscapeDataString($fixture.number)+'?limit=1&period=all');$rows=@(Field-C8 $inbox 'conversations');if($rows.Count -gt 0){$fixture.thread=[string](Field-C8 $rows[0] 'thread_key')}}
 $campaigns=Discover-C8 '/v1/sms/campaigns?limit=1';$rows=@(Field-C8 $campaigns 'campaigns');if($rows.Count -gt 0){$fixture.campaign=[string](Field-C8 $rows[0] 'campaign_id')}
 $voices=Discover-C8 '/v1/voices?limit=1';$rows=@(Field-C8 $voices 'data');if($rows.Count -gt 0){$fixture.voice=[string](Field-C8 $rows[0] 'voice_key')}
 $calls=Discover-C8 '/v1/calls/history?limit=20&period=all'
 foreach($call in @(Field-C8 $calls 'data')){if(($call|ConvertTo-Json -Depth 5 -Compress) -notmatch '447861926140|447457401554'){$fixture.call=[string](Field-C8 $call 'call_id');if($fixture.call){break}}}
 if($fixture.agent){$scope=Discover-C8 ('/v1/agents/'+[uri]::EscapeDataString($fixture.agent)+'/knowledge-base');$fixture.kb=[string](Field-C8 (Field-C8 $scope 'own') 'id')}
 if($fixture.kb){$topics=Discover-C8 ('/v1/knowledge-bases/'+[uri]::EscapeDataString($fixture.kb)+'/topics?limit=1');$rows=@(Field-C8 $topics 'items');if($rows.Count -gt 0){$fixture.topic=[string](Field-C8 $rows[0] 'id')}}
}
foreach($case in $script:C8Cases){
 $name='row '+$case.number+' example'
 if($case.number -eq 158){Pending-C8 $name 'pending manual test: private dashboard-only signing secret';continue}
 if($case.number -eq 105){Pending-C8 $name 'pending manual test: legacy draft GET can save repairs';continue}
 if(-not $case.read){Pending-C8 $name 'pending manual test: successful write deliberately blocked';continue}
 if(-not $hasKey){Pending-C8 $name 'pending staging run: NXF_STAGING_KEY absent';continue}
 $path=$case.path;$missing=$false
 foreach($p in [regex]::Matches($path,':([A-Za-z_]+)')){
  $key=$p.Groups[1].Value;$value=''
  switch -CaseSensitive ($key){'channel'{$value='web'} 'number'{$value=$fixture.number} 'phoneNumber'{$value=$fixture.number} 'callerNumber'{$value=$fixture.caller} 'thread'{$value=$fixture.thread} 'agentId'{$value=$fixture.agent} 'target'{$value=$fixture.agent} 'voice_key'{$value=$fixture.voice} 'kb'{$value=$fixture.kb} 'id'{if($case.number -eq 63){$value=$fixture.agent}elseif($case.number -in @(87,89)){$value=$fixture.call}elseif($case.number -eq 178){$value=$fixture.campaign}elseif($case.number -eq 121){$value=$fixture.topic}elseif($case.number -eq 128){$value=$fixture.export}elseif($case.number -eq 129){$value=$fixture.job}elseif($case.number -eq 133){$value=$fixture.session}}}
  if(-not $value -or $value -match '447861926140|447457401554'){$missing=$true;break};$path=$path.Replace($p.Value,[uri]::EscapeDataString($value))
 }
 if($missing -or ($case.number -eq 98 -and -not $fixture.agent)){Pending-C8 $name 'pending manual test: unprotected owned read fixture unavailable';continue}
 $body=$case.body
 if($case.number -eq 98){$body=[ordered]@{agent_id=$fixture.agent;recipients=@([ordered]@{phone='+12025550101';country='US';timezone='America/New_York'})}|ConvertTo-Json -Depth 5 -Compress}
 try{
  $query=$case.query
  if($case.number -eq 57){if(-not $fixture.number){Pending-C8 $name 'pending manual test: unprotected owned number unavailable';continue};$query='?number='+[uri]::EscapeDataString($fixture.number)}
  $r=Invoke-C8Request $case.method ($path+$query) $body
  if($r.Status -eq 404 -or ($r.Status -in @(409,422,503) -and $script:C8Code -cin @('agent_inbox_disabled','knowledge_not_released','knowledge_unconfigured','export_expired','agent_timezone_required','knowledge_missing'))){Pending-C8 $name ('pending manual test: fixture or feature unavailable; '+(Reason-C8));continue}
  Assert-C8 ($r.Status -eq 200);$script:C8Phase='shape'
  if((Field-C8 $case.schema 'type') -ceq 'array'){Assert-C8 $r.IsArray;if($null -ne $r.Json){foreach($item in @($r.Json)){Shape-C8 $item $case.schema.items}}}else{Shape-C8 $r.Json $case.schema}
  if($case.number -eq 55){Assert-C8 ($r.Json.enabled -is [bool])}
  $script:C8Pass++;Write-Output ('PASS | '+$name+' | '+(Reason-C8)+' | read wire example')
 }catch{$script:C8Fail++;Write-Output ('FAIL | '+$name+' | '+(Reason-C8)+' | response withheld')}
}
foreach($method in @('POST','PUT')){foreach($kind in @('count','length','bytes')){
 $name='keyterms '+$kind+' '+$method+' refusal'
 if(-not $hasKey){Pending-C8 $name 'pending staging run: NXF_STAGING_KEY absent';continue}
 if($method -ceq 'PUT' -and -not $script:C8Agent){Pending-C8 $name 'pending manual test: owned agent unavailable';continue}
 Test-C8 $name {
  $path='/v1/agents';if($method -ceq 'PUT'){$path+='/'+[uri]::EscapeDataString($script:C8Agent)}
  $body=[ordered]@{boosted_keywords=$script:C8Terms[$kind];name=[pscustomobject]@{}}|ConvertTo-Json -Depth 3 -Compress
  $r=Invoke-C8Request $method $path $body;$e=Field-C8 $r.Json 'error'
  Assert-C8 ($r.Status -eq 400 -and $r.ErrorSource -ceq 'ErrorDetails.Message' -and $e.details.field -ceq 'boosted_keywords')
  if($kind -ceq 'count'){Assert-C8 ($e.code -ceq 'invalid_agent_field' -and $e.message -ceq 'Keep up to 20 words - remove some to save')}
  elseif($kind -ceq 'length'){Assert-C8 ($e.code -ceq 'keyterms_term_too_long' -and $e.message -ceq 'Keep each word or phrase within 50 characters to save' -and $e.details.limit -eq 50)}
  else{Assert-C8 ($e.code -ceq 'keyterms_list_too_large' -and $e.details.limit -eq 450 -and $e.details.actual_bytes -eq 481 -and $e.details.over_bytes -eq 31 -and $e.message -ceq 'This list is 31 bytes over the 450-byte safety limit. Shorten or remove some words to save.')}
 }
}}
Write-Output ('TOTAL | PASS='+$script:C8Pass+' FAIL='+$script:C8Fail+' PENDING='+$script:C8Pending)
if($script:C8Fail -gt 0){exit 1}
