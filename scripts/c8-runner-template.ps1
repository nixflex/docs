# Chat C - C8/C9 staging reads only. All non-GET operations are pending manual tests. Windows PowerShell 5.1.
[CmdletBinding()]
param([switch]$LoadFunctionsOnly)
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
$script:C8Base='https://nixflex-voice-engine-staging.up.railway.app'
$script:Cases=@'
__CASES__
'@ | ConvertFrom-Json
$script:Pass=0;$script:Fail=0;$script:Pending=0
$script:Http=0;$script:Phase='guard';$script:Retried=$false
$script:Retired=@(
 [pscustomobject]@{Path='/v1/account/delete';Code='dashboard_owner_required';Auth=$false},
 [pscustomobject]@{Path='/v1/numbers/not-a-number/knowledge-base';Code='number_knowledge_removed';Auth=$true},
 [pscustomobject]@{Path='/v1/agents/not-an-agent/knowledge-numbers';Code='number_knowledge_removed';Auth=$true},
 [pscustomobject]@{Path='/v1/knowledge/targets?kind=number';Code='number_knowledge_removed';Auth=$true}
)
function Assert-C8($Condition){if(-not $Condition){throw 'C8 assertion failed; values withheld'}}
function Field-C8($Value,[string]$Name){if($null -eq $Value){return $null};$p=$Value.PSObject.Properties[$Name];if($null -eq $p){return $null};return $p.Value}
function Match-C8([string]$Template,[string]$Path){$pattern=[regex]::Replace([regex]::Escape($Template),':([A-Za-z_]+)','[^/?#]+');return $Path -cmatch ('^'+$pattern+'(?:\?[^#]*)?$')}
function Guard-C8([string]$Method,[string]$Path){
 Assert-C8 ($Method -ceq 'GET')
 Assert-C8 ($Path -cmatch '^/v1/[A-Za-z0-9_/%+:?.=&,-]+$')
 $decoded=$Path
 for($i=0;$i -lt 4;$i++){$decoded=[uri]::UnescapeDataString($decoded)}
 Assert-C8 ($decoded -notmatch '447861926140|447457401554|pickup_delay|\.\.|://|[\r\n#]')
 Assert-C8 ($decoded -notmatch '/drafts/|/signing-secret|refresh_cards')
 $allowed=$false
 foreach($case in $script:Cases){if(Match-C8 $case.path $Path){$allowed=$true;break}}
 foreach($case in $script:Retired){if($case.Path -ceq $Path){$allowed=$true;break}}
 Assert-C8 $allowed
}
function HttpError-C8($Record){
 $response=$Record.Exception.Response
 if($null -eq $response){return [pscustomobject]@{Status=0;Content='';Source='transport'}}
 $content='';$source='stream'
 if($Record.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($Record.ErrorDetails.Message)){$content=[string]$Record.ErrorDetails.Message;$source='ErrorDetails.Message'}
 else {try{$reader=New-Object IO.StreamReader($response.GetResponseStream());try{$content=$reader.ReadToEnd()}finally{$reader.Dispose()}}catch{$content=''}}
 return [pscustomobject]@{Status=[int]$response.StatusCode;Content=$content;Source=$source}
}
function Request-C8([string]$Path,[bool]$Authenticated=$true){
 $script:Http=0;$script:Phase='guard';$script:Retried=$false
 Guard-C8 'GET' $Path
 $headers=@{}
 if($Authenticated){Assert-C8 (-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY));$headers.Authorization='Bearer '+$env:NXF_STAGING_KEY}
 # Fixed origin, GET, no body, no redirect, no connection reuse. No signed URL follow.
 $request=@{Uri=($script:C8Base+$Path);Method='GET';Headers=$headers;UseBasicParsing=$true;DisableKeepAlive=$true;MaximumRedirection=0;TimeoutSec=30;ErrorAction='Stop'}
 $status=0;$content='';$source='success';$script:Phase='request'
 for($attempt=0;$attempt -lt 2;$attempt++){
  try{$r=Invoke-WebRequest @request;$status=[int]$r.StatusCode;$content=[string]$r.Content;$source='success'}catch{$e=HttpError-C8 $_;$status=$e.Status;$content=$e.Content;$source=$e.Source}
  if($status -eq 0 -and $attempt -eq 0){$script:Retried=$true;Write-Host 'INFO | GET HTTP=0 | one retry after 500 ms';Start-Sleep -Milliseconds 500;continue};break
 }
 $script:Http=$status;$script:Phase='parse';$json=$null
 if($content){try{$json=ConvertFrom-Json -InputObject $content}catch{throw 'Response was not JSON; withheld'}}
 return [pscustomobject]@{Status=$status;Json=$json;RootArray=$content.TrimStart().StartsWith('[');ErrorSource=$source}
}
function Shape-C8($Value,$Schema,[int]$Depth=0){
 Assert-C8 ($Depth -le 30)
 foreach($s in @(Field-C8 $Schema 'allOf')){if($s){Shape-C8 $Value $s ($Depth+1)}}
 $branches=Field-C8 $Schema 'anyOf';if(-not $branches){$branches=Field-C8 $Schema 'oneOf'}
 if($branches){$valid=$false;foreach($s in $branches){try{Shape-C8 $Value $s ($Depth+1);$valid=$true;break}catch{}};Assert-C8 $valid;return}
 $types=@(Field-C8 $Schema 'type')
 if($null -eq $Value){Assert-C8 (($types -contains 'null') -or -not $types[0]);return}
 if($types -contains 'object'){
  Assert-C8 ($Value -is [pscustomobject])
  foreach($f in @(Field-C8 $Schema 'required')){if($f){Assert-C8 ($null -ne $Value.PSObject.Properties[$f])}}
  $props=Field-C8 $Schema 'properties'
  if($props){foreach($p in $props.PSObject.Properties){if($null -ne $Value.PSObject.Properties[$p.Name]){Shape-C8 $Value.PSObject.Properties[$p.Name].Value $p.Value ($Depth+1)}}}
 }elseif($types -contains 'array'){
  Assert-C8 ($Value -is [array]);$items=Field-C8 $Schema 'items';if($items){foreach($v in $Value){Shape-C8 $v $items ($Depth+1)}}
 }elseif($types -contains 'string'){Assert-C8 ($Value -is [string])}
 elseif($types -contains 'boolean'){Assert-C8 ($Value -is [bool])}
 elseif($types -contains 'integer'){Assert-C8 ($Value -is [int] -or $Value -is [long])}
 elseif($types -contains 'number'){Assert-C8 ($Value -is [ValueType] -and $Value -isnot [bool])}
 $values=Field-C8 $Schema 'enum';if($values){Assert-C8 ($Value -cin $values)}
}
function WireShape-C8($Response,$Schema){
 # PS5 unwraps root JSON arrays. Restore from the wire flag, never treat object as array.
 $value=$Response.Json
 if($Response.RootArray){if($null -eq $value){$value=@()}else{$value=@($value)}}
 Shape-C8 $value $Schema
}
function CallerAbsent-C8($Response){return ($Response.Status -eq 404 -and (Field-C8 (Field-C8 $Response.Json 'error') 'code') -ceq 'caller_not_found')}
function Pending-C8([string]$Name,[string]$Why){$script:Pending++;Write-Output ('PENDING | '+$Name+' | pending manual test: '+$Why)}
function Result-C8([string]$Name,[bool]$Ok){
 $label='FAIL';if($Ok){$script:Pass++;$label='PASS'}else{$script:Fail++}
 Write-Output ($label+' | '+$Name+' | HTTP='+$script:Http+' phase='+$script:Phase+' retried='+$script:Retried.ToString().ToLowerInvariant()+' | values withheld')
}
if($LoadFunctionsOnly){return}
[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
$hasKey=-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)
$fixture=@{agent='';number='';thread='';campaign='';call='';voice='';kb='';topic='';caller=$env:NXF_C8_CALLER_NUMBER;job=$env:NXF_C8_JOB_ID;export=$env:NXF_C8_EXPORT_ID;session=$env:NXF_C8_SESSION_ID}
if(-not $fixture.caller){$fixture.caller='+12025550101'}
$cache=@{}
function Discover-C8([string]$Path){
 try{$r=Request-C8 $Path;$cache[$Path]=$r;if($r.Status -eq 200){return ,$r.Json}}catch{}
 return $null
}
if($hasKey){
 $agents=Discover-C8 '/v1/agents?limit=1'
 if($env:NXF_C8_AGENT_ID){
  $a=Discover-C8 ('/v1/agents/'+[uri]::EscapeDataString($env:NXF_C8_AGENT_ID))
  if($a -and ($a|ConvertTo-Json -Depth 20 -Compress) -notmatch '447861926140|447457401554'){$fixture.agent=[string](Field-C8 $a 'agent_id')}
 }else{
  foreach($a in @($agents)){if($null -ne $a -and ($a|ConvertTo-Json -Depth 20 -Compress) -notmatch '447861926140|447457401554'){$fixture.agent=[string](Field-C8 $a 'agent_id');if($fixture.agent){break}}}
 }
 $numbers=Discover-C8 '/v1/phone-numbers?limit=100'
 # Select only a number proved owned by GET phone-numbers; never take ownership from inbox data.
 foreach($n in @(Field-C8 $numbers 'phone_numbers')){
  $candidate=[string](Field-C8 $n 'phone_number')
  if($candidate -cmatch '^\+[1-9][0-9]{6,14}$' -and $candidate -notmatch '447861926140|447457401554' -and (-not $env:NXF_C8_NUMBER -or $env:NXF_C8_NUMBER -ceq $candidate)){$fixture.number=$candidate;break}
 }
 $voices=Discover-C8 '/v1/voices?limit=1';$rows=@(Field-C8 $voices 'data');if($rows.Count -gt 0){$fixture.voice=[string](Field-C8 $rows[0] 'voice_key')}
 $campaigns=Discover-C8 '/v1/sms/campaigns?limit=2';foreach($c in @(Field-C8 $campaigns 'campaigns')){if($c -and ($c|ConvertTo-Json -Depth 20 -Compress) -notmatch '447861926140|447457401554'){$fixture.campaign=[string](Field-C8 $c 'campaign_id');break}}
 $calls=Discover-C8 '/v1/calls/history?period=all&limit=20'
 foreach($c in @(Field-C8 $calls 'data')){
  if(-not $c -or -not $fixture.number){continue}
  $j=$c|ConvertTo-Json -Depth 20 -Compress
  if($j -notmatch '447861926140|447457401554' -and $j.Contains($fixture.number)){$fixture.call=[string](Field-C8 $c 'call_id');if($fixture.call){break}}
 }
 if($fixture.number){$threads=Discover-C8 ('/v1/agent-inbox/web/'+[uri]::EscapeDataString($fixture.number)+'?limit=2&period=all');$rows=@(Field-C8 $threads 'conversations');if($rows.Count -gt 0){$fixture.thread=[string](Field-C8 $rows[0] 'thread_key')}}
 if($fixture.agent){$scope=Discover-C8 ('/v1/agents/'+[uri]::EscapeDataString($fixture.agent)+'/knowledge-base');$fixture.kb=[string](Field-C8 (Field-C8 $scope 'own') 'id')}
 if($fixture.kb){$topics=Discover-C8 ('/v1/knowledge-bases/'+[uri]::EscapeDataString($fixture.kb)+'/topics?limit=2');$rows=@(Field-C8 $topics 'items');if($rows.Count -gt 0){$fixture.topic=[string](Field-C8 $rows[0] 'id')}}
}
foreach($case in $script:Cases){
 $name='row '+$case.number+' GET shape'
 if(-not $hasKey){Pending-C8 $name 'C8 NXF_STAGING_KEY is absent';continue}
 $path=$case.path;$missing=$false
 foreach($p in [regex]::Matches($path,':([A-Za-z_]+)')){
  $value=''
  switch -CaseSensitive ($p.Groups[1].Value){
   'channel'{$value='web'} 'number'{$value=$fixture.number} 'phoneNumber'{$value=$fixture.number} 'callerNumber'{$value=$fixture.caller}
   'thread'{$value=$fixture.thread} 'target'{$value=$fixture.agent} 'agentId'{$value=$fixture.agent} 'voice_key'{$value=$fixture.voice} 'kb'{$value=$fixture.kb}
   'id'{switch($case.number){63{$value=$fixture.agent} 87{$value=$fixture.call} 89{$value=$fixture.call} 121{$value=$fixture.topic} 128{$value=$fixture.export} 129{$value=$fixture.job} 133{$value=$fixture.session} 178{$value=$fixture.campaign}}}
  }
  if(-not $value -or $value -match '447861926140|447457401554'){$missing=$true;break}
  $path=$path.Replace($p.Value,[uri]::EscapeDataString($value))
 }
 if($missing){Pending-C8 $name 'owned fixture unavailable; no guessed IDs';continue}
 $query=$case.query
 if($case.number -eq 57){if(-not $fixture.number){Pending-C8 $name 'C8 number required';continue};$query='?number='+[uri]::EscapeDataString($fixture.number)}
 try{
  $r=Request-C8 ($path+$query)
  $code=Field-C8 (Field-C8 $r.Json 'error') 'code'
  if($case.number -eq 170 -and -not $env:NXF_C8_CALLER_NUMBER){$script:Phase='caller-absence';Assert-C8 (CallerAbsent-C8 $r);Result-C8 ('row 170 caller_not_found refusal') $true;continue}
  if(($r.Status -eq 404 -and $case.number -in @(66,103,109,111,118,121,123,126,127,128,129,132,133,136,143,145,152,192)) -or ($r.Status -in @(409,503) -and $code -cin @('agent_inbox_disabled','knowledge_not_released','knowledge_unconfigured','knowledge_missing','export_expired'))){Pending-C8 $name ('feature or fixture unavailable; HTTP='+$r.Status);continue}
  $script:Phase='status';Assert-C8 ($r.Status -eq 200);$script:Phase='shape';WireShape-C8 $r $case.schema
  if($case.number -eq 55){Assert-C8 ($r.Json.enabled -is [bool])}
  if($case.number -eq 192){Assert-C8 ($r.Json.knowledge_keyterms_count -eq @($r.Json.knowledge_keyterms).Count -and $r.Json.manual_keyterms_count -eq @($r.Json.manual_keyterms).Count -and $r.Json.manual_keyterms_limit -eq 20)}
  Result-C8 $name $true
 }catch{Result-C8 $name $false}
}
foreach($case in $script:Retired){
 $name='retired GET '+$case.Path
 if($case.Auth -and -not $hasKey){Pending-C8 $name 'C8 key required to reach retirement guard';continue}
 try{
  $r=Request-C8 $case.Path $case.Auth
  if($case.Auth -and $r.Status -in @(404,503)){Pending-C8 $name ('knowledge unavailable; 410 not proven; HTTP='+$r.Status);continue}
  $script:Phase='retirement-status'
  Assert-C8 ($r.Status -eq 410 -and (Field-C8 (Field-C8 $r.Json 'error') 'code') -ceq $case.Code)
  Result-C8 $name $true
 }catch{Result-C8 $name $false}
}
Pending-C8 'row 105 legacy draft GET' 'can save legacy repairs; excluded'
Pending-C8 'row 158 signing secret GET' 'private Owner dashboard retrieval; never collected by this script'
foreach($name in @(__WRITES__)){Pending-C8 $name 'successful write or calculation excluded; GET-only runner'}
Write-Output ('TOTAL | PASS='+$script:Pass+' FAIL='+$script:Fail+' PENDING='+$script:Pending)
if($script:Fail -gt 0){exit 1}
