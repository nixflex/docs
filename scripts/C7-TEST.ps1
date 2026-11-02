# C7 safe staging checks. Windows PowerShell 5.1. Never run the successful-write examples.
[CmdletBinding()]
param([switch]$LoadFunctionsOnly)
Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'C7-Http.ps1')
$script:C7Base = 'https://nixflex-voice-engine-staging.up.railway.app'
$script:C7Cases = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'C7-cases.json') -Raw | ConvertFrom-Json
$script:C7Pass=0; $script:C7Fail=0; $script:C7Pending=0
$script:C7Status=0; $script:C7Code='none'; $script:C7Phase='request'; $script:C7Retried=$false
$script:C7Run='C7_missing_'+[guid]::NewGuid().ToString('N')
$script:C7Terms=(1..21 | ForEach-Object { $script:C7Run+'_'+$_ }) -join ','
$script:C7Agent=''
function Assert-C7($Condition) { if (-not $Condition) { throw 'C7 assertion failed; response withheld' } }
function Get-C7Reason { return ('HTTP='+$script:C7Status+' code='+$script:C7Code+' phase='+$script:C7Phase+' retried='+$script:C7Retried.ToString().ToLowerInvariant()) }
function Pending-C7($Name,$Reason) { $script:C7Pending++; Write-Output ('PENDING | '+$Name+' | '+$Reason) }
function Test-C7($Name,[scriptblock]$Action) {
    $script:C7Status=0; $script:C7Code='none'; $script:C7Phase='request'; $script:C7Retried=$false
    try { & $Action | Out-Null; $script:C7Pass++; Write-Output ('PASS | '+$Name+' | '+(Get-C7Reason)) }
    catch { $script:C7Fail++; Write-Output ('FAIL | '+$Name+' | '+(Get-C7Reason)+' | response withheld') }
}
function Assert-C7Fields($Object,[string[]]$Fields) {
    foreach ($field in $Fields) { Assert-C7 ($null -ne $Object -and $null -ne $Object.PSObject.Properties[$field]) }
}
function Get-C7RefusalPath($Case) {
    return $Case.path.Replace(':id',$script:C7Run).Replace(':channel','web').Replace(':number','not-a-number').Replace(':thread',$script:C7Run)
}
function Assert-C7Request([string]$Method,[string]$Path,[string]$Body,[string]$Auth) {
    Assert-C7 ($Auth -cin @('Real','Invalid'))
    Assert-C7 ($Path -cmatch '^/v1/[A-Za-z0-9_/%+:?.=&,-]+$' -and $Path -notmatch '\.\.|://|%0[ad]')
    $decoded=[uri]::UnescapeDataString($Path)
    Assert-C7 (($decoded+$Body) -notmatch '447861926140|447457401554|pickup_delay|[\r\n]')
    Assert-C7 ($decoded -notmatch '\.\.|://')
    if ($Auth -ceq 'Invalid') {
        Assert-C7 ($Body -ceq '' -or $Body -ceq '{}')
        $allowed=$false
        foreach ($case in $script:C7Cases) {
            if ($case.method -ceq $Method -and (Get-C7RefusalPath $case) -ceq $Path) { $allowed=$true }
        }
        Assert-C7 $allowed
        return
    }
    if ($Method -ceq 'GET') {
        Assert-C7 ($Body -ceq '')
        Assert-C7 ($decoded -cmatch '^/v1/(agents(?:/[A-Za-z0-9_-]+)?|campaigns|sms/campaigns(?:/[A-Za-z0-9_-]+)?|contact-suppressions|agent-web/\+[1-9][0-9]{6,14}|agent-inbox/(features|numbers|retention|web/\+[1-9][0-9]{6,14}(?:/thread/[^?#]+)?))(?:\?[^#]*)?$')
        return
    }
    if ($Method -ceq 'POST' -and $Path -ceq '/v1/contact-hours/preview') {
        $obj=$Body | ConvertFrom-Json
        Assert-C7 (@($obj.PSObject.Properties.Name).Count -eq 2 -and $obj.agent_id -cmatch '^[A-Za-z0-9_-]{1,64}$')
        Assert-C7 (@($obj.recipients).Count -eq 1)
        $r=$obj.recipients[0]
        Assert-C7 (@($r.PSObject.Properties.Name).Count -eq 3 -and $r.phone -ceq '+12025550101' -and $r.country -ceq 'US' -and $r.timezone -ceq 'America/New_York')
        return
    }
    # Refusal only: exact 21-term payload PLUS invalid name object, so an older limit
    # or a concurrent exact-match list can never turn this into a successful save.
    Assert-C7 (($Method -ceq 'POST' -and $Path -ceq '/v1/agents') -or ($Method -ceq 'PUT' -and $script:C7Agent -cmatch '^[A-Za-z0-9_-]{1,64}$' -and $Path -ceq ('/v1/agents/'+$script:C7Agent)))
    $obj=$Body | ConvertFrom-Json
    Assert-C7 (@($obj.PSObject.Properties.Name).Count -eq 2 -and $obj.PSObject.Properties.Name[0] -ceq 'boosted_keywords')
    Assert-C7 ($obj.boosted_keywords -ceq $script:C7Terms -and $script:C7Terms.Split(',').Count -eq 21)
    Assert-C7 ($obj.name -is [pscustomobject] -and @($obj.name.PSObject.Properties).Count -eq 0)
}
function Invoke-C7Request([string]$Method,[string]$Path,[string]$Body='', [ValidateSet('Real','Invalid')][string]$Auth='Real') {
    $script:C7Status=0; $script:C7Code='none'; $script:C7Phase='guard'; $script:C7Retried=$false
    Assert-C7Request $Method $Path $Body $Auth
    $headers=@{}
    if ($Auth -ceq 'Real') { Assert-C7 (-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)); $headers.Authorization='Bearer '+$env:NXF_STAGING_KEY }
    else { $headers.Authorization='Bearer nxf_C7_INVALID:nxfs_C7_INVALID' }
    $args=@{Uri=($script:C7Base+$Path);Method=$Method;Headers=$headers;UseBasicParsing=$true;DisableKeepAlive=$true;MaximumRedirection=0;TimeoutSec=30;ErrorAction='Stop'}
    if ($Body) { $args.Body=$Body; $args.ContentType='application/json' }
    $script:C7Phase='request'; $status=0; $content=''; $source='success'
    for ($attempt=0; $attempt -lt 2; $attempt++) {
        try { $r=Invoke-WebRequest @args; $status=[int]$r.StatusCode; $content=[string]$r.Content; $source='success' }
        catch { $e=Read-C7HttpError $_; $status=$e.Status; $content=$e.Content; $source=$e.Source }
        if ($status -eq 0 -and $Method -ceq 'GET' -and $attempt -eq 0) {
            $script:C7Retried=$true
            Write-Host 'INFO | read transport HTTP=0 | retried once after 500 ms'
            Start-Sleep -Milliseconds 500
            continue
        }
        break
    }
    $script:C7Status=$status; $script:C7Phase='parse'; $json=$null
    if ($content) { try { $json=$content | ConvertFrom-Json } catch { throw 'Non-JSON response withheld' } }
    if ($null -ne $json -and $null -ne $json.PSObject.Properties['error']) {
        $err=$json.PSObject.Properties['error'].Value
        if ($null -ne $err -and $null -ne $err.PSObject.Properties['code']) {
            # Print only the known test codes, never arbitrary response content.
            $script:C7Code='unrecognised'
            if ($err.code -cin @('unauthorized','invalid_agent_field','agent_inbox_disabled','agent_timezone_required','agent_not_found','not_found','inbox_not_found','web_agent_not_found','agent_store_unavailable','prompt_check_unavailable')) { $script:C7Code=[string]$err.code }
        }
    }
    $script:C7Phase='status'
    return [pscustomobject]@{Status=$status;Json=$json;ErrorSource=$source}
}
if ($LoadFunctionsOnly) { return }
foreach ($case in $script:C7Cases) {
    Test-C7 ('row '+$case.number+' documented error: 401 unauthorized') {
        $body=''; if ($case.method -cne 'GET') { $body='{}' }
        $r=Invoke-C7Request $case.method (Get-C7RefusalPath $case) $body 'Invalid'
        Assert-C7 ($r.Status -eq 401 -and $r.Json.error.code -ceq 'unauthorized')
        Assert-C7Fields $r.Json.error @('code','message','doc_url')
        Assert-C7 ($r.ErrorSource -ceq 'ErrorDetails.Message')
    }
}
$hasKey=-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)
$number=''; $thread=''; $campaign=''; $agent=''
if ($hasKey) {
    try {
        $r=Invoke-C7Request 'GET' '/v1/agent-inbox/numbers?offset=0'
        if ($r.Status -eq 200) {
            foreach ($item in @($r.Json.numbers)) {
                if ($item.phone_number -cmatch '^\+[1-9][0-9]{6,14}$' -and $item.phone_number -cnotin @('+447861926140','+447457401554')) { $number=[string]$item.phone_number; break }
            }
        }
    } catch { Write-Output 'INFO | number discovery incomplete; dependent examples stay pending' }
    try {
        $r=Invoke-C7Request 'GET' '/v1/agents?limit=1'
        if ($r.Status -eq 200 -and @($r.Json).Count) { $agent=[string]$r.Json[0].agent_id }
        if ($agent -cmatch '^[A-Za-z0-9_-]{1,64}$') { $script:C7Agent=$agent }
    } catch { Write-Output 'INFO | agent discovery incomplete; dependent checks stay pending' }
    try {
        $r=Invoke-C7Request 'GET' '/v1/sms/campaigns?limit=1'
        if ($r.Status -eq 200 -and @($r.Json.campaigns).Count) { $campaign=[string]$r.Json.campaigns[0].campaign_id }
    } catch { Write-Output 'INFO | campaign discovery incomplete; detail stays pending' }
    if ($number) {
        try {
            $r=Invoke-C7Request 'GET' ('/v1/agent-inbox/web/'+[uri]::EscapeDataString($number)+'?limit=1&period=all')
            if ($r.Status -eq 200 -and @($r.Json.conversations).Count) { $thread=[string]$r.Json.conversations[0].thread_key }
        } catch { Write-Output 'INFO | thread discovery incomplete; detail stays pending' }
    }
}
foreach ($case in $script:C7Cases) {
    $name='row '+$case.number+' example'
    if ($case.write) { Pending-C7 $name 'pending manual test: successful write requires an approved disposable fixture'; continue }
    if (-not $hasKey) { Pending-C7 $name 'pending staging run: NXF_STAGING_KEY absent'; continue }
    if (($case.needsNumber -and -not $number) -or ($case.path.Contains(':thread') -and -not $thread) -or ($case.path.Contains(':id') -and -not $campaign) -or ($case.number -eq 98 -and -not $agent)) {
        Pending-C7 $name 'pending manual test: unprotected owned read fixture unavailable'; continue
    }
    $path=$case.path.Replace(':channel','web').Replace(':number',[uri]::EscapeDataString($number)).Replace(':thread',[uri]::EscapeDataString($thread)).Replace(':id',[uri]::EscapeDataString($campaign))+$case.query.Replace('%2B12025550123',[uri]::EscapeDataString($number))
    # The suppression cursor is an example marker, not a number being contacted or changed.
    if ($case.number -eq 100) { $path='/v1/contact-suppressions'+$case.query }
    $body=''
    if ($case.number -eq 98) { $body=@{agent_id=$agent;recipients=@(@{phone='+12025550101';country='US';timezone='America/New_York'})} | ConvertTo-Json -Depth 6 -Compress }
    try {
        $r=Invoke-C7Request $case.method $path $body
        if (($r.Status -eq 503 -and $script:C7Code -ceq 'agent_inbox_disabled') -or ($r.Status -eq 422 -and $script:C7Code -ceq 'agent_timezone_required') -or $r.Status -eq 404) { Pending-C7 $name ('pending manual test: read fixture or feature unavailable; '+(Get-C7Reason)); continue }
        Assert-C7 ($r.Status -eq 200); $script:C7Phase='shape'; Assert-C7Fields $r.Json $case.fields
        if ($case.number -eq 55) { Assert-C7 ($r.Json.enabled -is [bool]) }
        if ($case.number -eq 98) { Assert-C7 ($r.Json.preview_only -eq $true -and @($r.Json.rows).Count -eq 1) }
        if ($case.number -eq 58) { Assert-C7 ($r.Json.revision -is [string]) }
        $script:C7Pass++; Write-Output ('PASS | '+$name+' | '+(Get-C7Reason)+' | read/preview wire example')
    } catch { $script:C7Fail++; Write-Output ('FAIL | '+$name+' | '+(Get-C7Reason)+' | response withheld') }
}
foreach ($method in @('POST','PUT')) {
    $name='keyterms 21-term '+$method+' validation refusal'
    if (-not $hasKey) { Pending-C7 $name 'pending staging run: NXF_STAGING_KEY absent'; continue }
    if ($method -ceq 'PUT' -and -not $script:C7Agent) { Pending-C7 $name 'pending manual test: owned agent unavailable'; continue }
    Test-C7 $name {
        $path='/v1/agents'; if ($method -ceq 'PUT') { $path+='/'+$script:C7Agent }
        $body=[ordered]@{boosted_keywords=$script:C7Terms;name=[pscustomobject]@{}} | ConvertTo-Json -Depth 3 -Compress
        $r=Invoke-C7Request $method $path $body
        Assert-C7 ($r.Status -eq 400 -and $r.Json.error.code -ceq 'invalid_agent_field')
        Assert-C7 ($r.Json.error.message -ceq 'Keep up to 20 words - remove some to save' -and $r.Json.error.details.field -ceq 'boosted_keywords')
        Assert-C7 ($r.ErrorSource -ceq 'ErrorDetails.Message')
    }
}
Write-Output ('TOTAL | PASS='+$script:C7Pass+' FAIL='+$script:C7Fail+' PENDING='+$script:C7Pending)
if ($script:C7Fail -gt 0) { exit 1 }
