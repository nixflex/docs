# Read-only row 55 diagnostic. Never prints credentials, response bodies or raw exceptions.
[CmdletBinding()]
param()
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
$base='https://nixflex-voice-engine-staging.up.railway.app'
$hasKey=-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)
$headers=@{Authorization='Bearer nxf_C6_INVALID:nxfs_C6_INVALID'}
if($hasKey){$headers.Authorization='Bearer '+$env:NXF_STAGING_KEY}
$status=0;$code='none';$text='';$phase='request'
try {
  try {
    $r=Invoke-WebRequest -Uri ($base+'/v1/agent-inbox/features') -Method Get -Headers $headers -UseBasicParsing -DisableKeepAlive -MaximumRedirection 0 -TimeoutSec 30 -ErrorAction Stop
    $status=[int]$r.StatusCode;$text=[string]$r.Content
  } catch {
    if($null -eq $_.Exception.Response){throw 'network_or_transport'}
    $status=[int]$_.Exception.Response.StatusCode
    if($_.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($_.ErrorDetails.Message)){$text=[string]$_.ErrorDetails.Message}
    else{$reader=New-Object IO.StreamReader($_.Exception.Response.GetResponseStream());try{$text=$reader.ReadToEnd()}finally{$reader.Dispose()}}
  }
  $phase='parse';$data=$text|ConvertFrom-Json
  if($data -and $data.PSObject.Properties['error']){
    $raw=[string]$data.error.code
    if($raw -cmatch '^[a-z][a-z0-9_]{0,79}$'){$code=$raw}else{$code='unrecognised'}
  }
  if(-not $hasKey){
    if($status -ne 401 -or $code -cne 'unauthorized'){throw 'unexpected_refusal'}
    Write-Output ('PASS | row 55 authentication refusal | HTTP='+$status+' code='+$code)
    Write-Output 'PENDING | row 55 authenticated example | NXF_STAGING_KEY absent'
    exit 0
  }
  $phase='status';if($status -ne 200){throw 'unexpected_status'}
  $phase='shape';if($null -eq $data -or $null -eq $data.PSObject.Properties['enabled'] -or $data.enabled -isnot [bool]){throw 'invalid_shape'}
  Write-Output ('PASS | row 55 example | HTTP='+$status+' code='+$code+' enabled_field=boolean')
} catch {
  Write-Output ('FAIL | row 55 example | HTTP='+$status+' code='+$code+' phase='+$phase+' | response withheld')
  exit 1
}
