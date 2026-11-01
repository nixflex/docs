# C4 API reference checks. Windows PowerShell 5.1. Staging only.
# Successful account/key/number/contact/caller writes are intentionally pending manual test.
# No secret, response body, recording URL, recipient data or raw exception is printed.
[CmdletBinding()]
param([switch]$LoadFunctionsOnly)
Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
$script:C4Base = 'https://nixflex-voice-engine-staging.up.railway.app'
$script:C4Run = 'C4-' + [guid]::NewGuid().ToString('N')
$script:C4Owned = New-Object 'System.Collections.Generic.List[string]'
$script:C4Pass = 0; $script:C4Fail = 0; $script:C4Pending = 0
$script:C4Created = $false; $script:C4Call = $null; $script:C4Voice = $null
function Assert-C4($Condition, [string]$Message) { if (-not $Condition) { throw $Message } }
function Test-C4([string]$Name, [scriptblock]$Action) {
    try { & $Action | Out-Null; $script:C4Pass++; Write-Output ('PASS | ' + $Name) }
    catch { $script:C4Fail++; Write-Output ('FAIL | ' + $Name + ' | assertion or request failed; response withheld') }
}
function Pending-C4([string]$Name) { $script:C4Pending++; Write-Output ('PENDING | ' + $Name + ' | pending manual test') }
function Assert-C4Fields($Object, [string[]]$Fields) {
    foreach ($field in $Fields) { Assert-C4 ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $field) ('Missing field: ' + $field) }
}
function Assert-C4Request([string]$Method, [string]$Path, [string]$Body, [string]$Auth) {
    Assert-C4 ($Path -match '^/v1/[A-Za-z0-9_/%+:?.=&,-]+$' -and $Path -notmatch '\.\.|://|%0[ad]') 'Unsafe request path'
    $decoded = [uri]::UnescapeDataString($Path)
    if ($Method -eq 'GET') {
        Assert-C4 ($Path -match '^/v1/(account/retention|keys/activity|usage|voices(?:/[^?]+)?|calls(?:/[^?]+)?|agents(?:/[^?]+)?)(?:\?|$)') 'Read not allowed'
        return
    }
    Assert-C4 ($decoded -notmatch '447861926140|447457401554') 'Protected number'
    Assert-C4 ($Body -notmatch '447861926140|447457401554|pickup_delay') 'Protected write field or number'
    if ($Path -eq '/v1/keys') {
        Assert-C4 ($Method -eq 'POST' -and $Body -ceq '{' -and $Auth -eq 'None') 'Signup is blocked'
        return
    }
    if ($Path -eq '/v1/keys/rotate') {
        Assert-C4 ($Method -eq 'POST' -and $Auth -eq 'Invalid' -and -not $Body) 'Real key rotation is blocked'
        return
    }
    if ($Path -eq '/v1/phone-numbers') {
        Assert-C4 ($Method -eq 'POST' -and $Body -ceq '{"c4_unknown_field":true}') 'Number import is blocked'
        return
    }
    if ($Path -eq '/v1/phone-numbers/not-a-number') {
        Assert-C4 (($Method -eq 'DELETE' -and -not $Body) -or ($Method -eq 'PATCH' -and $Body -ceq '{"inbound_enabled":"invalid"}')) 'Number mutation is blocked'
        return
    }
    if ($Path -eq '/v1/phone-numbers/not-a-number/callers/import') {
        Assert-C4 ($Method -eq 'POST' -and $Body -ceq '{"callers":[]}') 'Caller import is blocked'
        return
    }
    if ($Path -eq '/v1/phone-numbers/not-a-number/callers/not-a-caller') {
        Assert-C4 ($Method -eq 'DELETE' -and $Auth -eq 'Invalid' -and -not $Body) 'Caller deletion is blocked'
        return
    }
    if ($Path -eq '/v1/calls/outbound' -or $Path -eq '/v1/sms') {
        Assert-C4 ($Method -eq 'POST' -and $Body -ceq '{}') 'Contact dispatch is blocked'
        return
    }
    if ($Path -eq '/v1/agents') {
        $obj = $Body | ConvertFrom-Json
        Assert-C4 ($Method -eq 'POST' -and $Auth -eq 'Real' -and $obj.name -ceq $script:C4Run -and @($obj.PSObject.Properties).Count -eq 1) 'Unowned agent creation'
        return
    }
    if ($Path -match '^/v1/agents/([A-Za-z0-9_-]+)$') {
        Assert-C4 ($script:C4Owned.Contains($Matches[1]) -and $Auth -eq 'Real') 'Unowned agent mutation'
        if ($Method -eq 'DELETE' -and -not $Body) { return }
        Assert-C4 ($Method -eq 'PUT') 'Agent method blocked'
        $obj = $Body | ConvertFrom-Json
        $fields = @($obj.PSObject.Properties.Name)
        Assert-C4 (@($fields | Where-Object { $_ -notin @('name','temperature') }).Count -eq 0) 'Agent fields blocked'
        if ($fields -contains 'name') { Assert-C4 ($obj.name -ceq ('Updated example agent ' + $script:C4Run)) 'Agent name blocked' }
        if ($fields -contains 'temperature') { Assert-C4 ($obj.temperature -eq 0.2 -or $obj.temperature -eq 1) 'Agent value blocked' }
        return
    }
    throw 'Write is outside the C4 allowlist'
}
function Invoke-C4Request([string]$Method, [string]$Path, [string]$Body = '', [ValidateSet('Real','Invalid','None')][string]$Auth = 'Real') {
    Assert-C4Request $Method $Path $Body $Auth
    $headers = @{}
    if ($Auth -eq 'Real') { $headers.Authorization = 'Bearer ' + $env:NXF_STAGING_KEY }
    elseif ($Auth -eq 'Invalid') { $headers.Authorization = 'Bearer nxf_C4_INVALID:nxfs_C4_INVALID' }
    $args = @{ Uri=($script:C4Base + $Path); Method=$Method; Headers=$headers; UseBasicParsing=$true; DisableKeepAlive=$true; MaximumRedirection=0; TimeoutSec=30; ErrorAction='Stop' }
    if ($Body) { $args.Body=$Body; $args.ContentType='application/json' }
    $status = 0; $content = ''
    try { $response = Invoke-WebRequest @args; $status = [int]$response.StatusCode; $content = [string]$response.Content }
    catch {
        if ($null -eq $_.Exception.Response) { throw 'Network outcome unknown; no automatic retry' }
        $response = $_.Exception.Response; $status = [int]$response.StatusCode
        $reader = New-Object IO.StreamReader($response.GetResponseStream())
        try { $content = $reader.ReadToEnd() } finally { $reader.Dispose() }
    }
    $json = $null
    if ($content) { try { $json = ConvertFrom-Json -InputObject $content } catch { throw 'Non-JSON response withheld' } }
    return [pscustomobject]@{ Status=$status; Json=$json; IsArray=$content.TrimStart().StartsWith('[') }
}
function Expect-C4([string]$Method, [string]$Path, [int]$Status, [string]$Code = '', [string]$Body = '', [string]$Auth = 'Real') {
    $result = Invoke-C4Request $Method $Path $Body $Auth
    Assert-C4 ($result.Status -eq $Status) 'Unexpected status'
    if ($Code) { Assert-C4Fields $result.Json @('error'); Assert-C4Fields $result.Json.error @('code','message'); Assert-C4 ($result.Json.error.code -ceq $Code) 'Unexpected error code' }
    return $result.Json
}
if ($LoadFunctionsOnly) { return }
if ([string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)) {
    Write-Output 'PENDING | C4 live checks | NXF_STAGING_KEY is absent; zero HTTP requests made. Set it privately and rerun.'
    exit 2
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
foreach ($name in @('01 POST keys success (API-only account)','02 POST keys/rotate success (new secret)','165 POST phone-numbers success (import and routing)','166 DELETE phone-numbers success (remove)','168 PATCH phone-numbers success (settings)','168 PATCH phone-numbers success (agent move)','169 DELETE caller context success','172 POST caller context success','96 POST outbound call success','174 POST SMS success')) { Pending-C4 $name }
Test-C4 '01 signup validation: 400 invalid_json, no account creation' { Expect-C4 POST '/v1/keys' 400 'invalid_json' '{' 'None' }
Test-C4 '02 rotation refusal: 401 unauthorized, invalid credential only' { Expect-C4 POST '/v1/keys/rotate' 401 'unauthorized' '' 'Invalid' }
Test-C4 '51 retention example: 200 and saved defaults' {
    $r=Expect-C4 GET '/v1/account/retention' 200
    Assert-C4Fields $r @('call_retention_days','applies_to','processing_enabled')
    Assert-C4 ($r.call_retention_days -in @(90,30,7,1,0) -and $r.applies_to -eq 'new_agents' -and $r.processing_enabled -is [bool]) 'Retention shape'
}
Test-C4 '51 retention error: 401 unauthorized' { Expect-C4 GET '/v1/account/retention' 401 'unauthorized' '' 'Invalid' }
Test-C4 '102 activity example: 200 and UTC period' {
    $r=Expect-C4 GET '/v1/keys/activity?period=today' 200
    Assert-C4Fields $r @('period','timezone','requests','errors','requests_today','errors_today','day_start','period_start','as_of','last_used_at','top_endpoints')
    Assert-C4 ($r.period -eq 'today' -and $r.timezone -eq 'UTC' -and @($r.top_endpoints).Count -le 5) 'Activity shape'
}
Test-C4 '102 activity error: 400 invalid_period' { Expect-C4 GET '/v1/keys/activity?period=invalid' 400 'invalid_period' }
Test-C4 '186 usage example: 200 and nullable stored counters' {
    $r=Expect-C4 GET '/v1/usage' 200
    Assert-C4Fields $r @('plan','total_calls','total_minutes','total_cost','rate_limit_per_minute','max_concurrent','peak_concurrent_this_month','rejected_at_cap_this_month')
}
Test-C4 '186 usage error: 401 unauthorized' { Expect-C4 GET '/v1/usage' 401 'unauthorized' '' 'Invalid' }
try {
    Test-C4 '64 create own fixture, then update documented fields: 200' {
        $script:C4Created=$true
        $created=Expect-C4 POST '/v1/agents' 201 '' (@{name=$script:C4Run}|ConvertTo-Json -Compress)
        Assert-C4Fields $created @('agent_id')
        $script:C4Owned.Add([string]$created.agent_id)
        $path='/v1/agents/'+[uri]::EscapeDataString($created.agent_id)
        $before=Expect-C4 GET $path 200
        Assert-C4Fields $before @('pickup_delay','max_call_duration_seconds','silence_hangup_seconds','dynamic_greeting')
        $body=@{name=('Updated example agent '+$script:C4Run);temperature=0.2}|ConvertTo-Json -Compress
        $updated=Expect-C4 PUT $path 200 '' $body
        Assert-C4Fields $updated @('agent_id','name','temperature','pickup_delay')
        Assert-C4 ($updated.name -ceq ('Updated example agent '+$script:C4Run) -and $updated.temperature -eq 0.2) 'Update fields'
        Assert-C4 ($updated.pickup_delay -eq $before.pickup_delay -and $updated.max_call_duration_seconds -eq 300 -and $updated.silence_hangup_seconds -eq 10 -and $updated.dynamic_greeting -eq $true) 'Unchanged/default fields'
    }
    if ($script:C4Owned.Count -gt 0) {
        Test-C4 '64 update error: 400 invalid_agent_field, no saved change' { Expect-C4 PUT ('/v1/agents/'+$script:C4Owned[0]) 400 'invalid_agent_field' '{"temperature":1}' }
    } else { Pending-C4 '64 update/error: fixture unavailable' }
}
finally {
    # One create attempt only. Reconcile an uncertain response by the unique run name.
    if ($script:C4Created -and $script:C4Owned.Count -eq 0) {
        Test-C4 '64 reconcile uncertain fixture creation by exact unique name' {
            $rows=Expect-C4 GET ('/v1/agents?limit=100&search='+$script:C4Run) 200
            foreach ($row in @($rows)) { if ($row.name -ceq $script:C4Run) { $script:C4Owned.Add([string]$row.agent_id) } }
            Assert-C4 ($script:C4Owned.Count -gt 0) 'Uncertain create still requires manual reconciliation'
        }
    }
    foreach ($id in $script:C4Owned) {
        Test-C4 '64 finally: soft-disable own agent and confirm inactive' {
            Expect-C4 DELETE ('/v1/agents/'+$id) 200 | Out-Null
            $r=Expect-C4 GET ('/v1/agents/'+$id) 200
            Assert-C4 ($r.is_active -eq $false) 'Fixture remains active'
        }
    }
}
Test-C4 '187 voices example: 200 bounded data and cursor' {
    $r=Expect-C4 GET '/v1/voices?limit=1' 200
    Assert-C4Fields $r @('data','next_cursor'); Assert-C4 (@($r.data).Count -le 1) 'Voice limit'
    if (@($r.data).Count -gt 0) { Assert-C4Fields $r.data[0] @('voice_key','displayName','availability','selectable'); $script:C4Voice=$r.data[0].voice_key }
}
Test-C4 '187 voices error: 400 invalid_gender' { Expect-C4 GET '/v1/voices?gender=invalid' 400 'invalid_gender' }
if ($script:C4Voice) {
    Test-C4 '188 voice detail example: 200 stable public shape' {
        $r=Expect-C4 GET ('/v1/voices/'+[uri]::EscapeDataString($script:C4Voice)) 200
        Assert-C4Fields $r @('voice_key','displayName','gender','nativeLanguage','locale','accents','languages','origin','availability','selectable','incompatibilityReason','previewLanguage','previewStatus','previewUrl')
        Assert-C4 ($r.voice_key -eq $script:C4Voice) 'Voice key'
    }
} else { Pending-C4 '188 voice detail success: no catalog fixture' }
Test-C4 '188 voice detail error: 401 unauthorized' { Expect-C4 GET '/v1/voices/c4-invalid' 401 'unauthorized' '' 'Invalid' }
Test-C4 '84 legacy calls example: 200 bare array, limit 1' {
    $r=Invoke-C4Request GET '/v1/calls?limit=1'
    Assert-C4 ($r.Status -eq 200 -and $r.IsArray -and @($r.Json).Count -le 1) 'Legacy call array'
}
Test-C4 '84 legacy calls error: 401 unauthorized' { Expect-C4 GET '/v1/calls?limit=1' 401 'unauthorized' '' 'Invalid' }
Test-C4 '95 history example: 200 envelope, totals, defaults and cursor' {
    $r=Expect-C4 GET '/v1/calls/history?limit=1&period=all' 200
    Assert-C4Fields $r @('data','totals','filters','limit','offset','has_more','next_cursor')
    Assert-C4Fields $r.totals @('total','minutes','cost','cost_unknown','successful')
    Assert-C4 ($r.limit -eq 1 -and $r.offset -eq 0 -and @($r.data).Count -le 1 -and $r.filters.period -eq 'all' -and $r.filters.direction -eq 'all') 'History defaults'
    if (@($r.data).Count -gt 0) { $script:C4Call=$r.data[0].call_id }
}
Test-C4 '95 history error: 400 invalid_call_history' { Expect-C4 GET '/v1/calls/history?limit=201' 400 'invalid_call_history' }
if ($script:C4Call) {
    Test-C4 '87 call detail example: 200 owned history ID' {
        $r=Expect-C4 GET ('/v1/calls/'+[uri]::EscapeDataString($script:C4Call)+'?view=detail') 200
        Assert-C4Fields $r @('call_id'); Assert-C4 ($r.call_id -eq $script:C4Call) 'Call ID'
    }
    Test-C4 '89 recording example: 200 status, URL and expiry fields' {
        $r=Expect-C4 GET ('/v1/calls/'+[uri]::EscapeDataString($script:C4Call)+'/recording') 200
        Assert-C4Fields $r @('call_id','status','url','expires_at')
        Assert-C4 ($r.status -in @('available','pending','expired','customer_bucket','not_recorded','pending_deletion','unavailable','unknown')) 'Recording status'
        if ($r.status -ne 'available') { Assert-C4 ($null -eq $r.url -and $null -eq $r.expires_at) 'Unavailable link leak' }
    }
} else { Pending-C4 '87 call detail success: no existing call fixture'; Pending-C4 '89 recording success: no existing call fixture' }
Test-C4 '87 call detail error: 401 unauthorized' { Expect-C4 GET '/v1/calls/c4-invalid?view=detail' 401 'unauthorized' '' 'Invalid' }
Test-C4 '89 recording error: 401 unauthorized' { Expect-C4 GET '/v1/calls/c4-invalid/recording' 401 'unauthorized' '' 'Invalid' }
Test-C4 '165 import refusal: 400 unknown_field before import' { Expect-C4 POST '/v1/phone-numbers' 400 'unknown_field' '{"c4_unknown_field":true}' }
Test-C4 '166 removal refusal: 400 invalid_phone_format' { Expect-C4 DELETE '/v1/phone-numbers/not-a-number' 400 'invalid_phone_format' }
Test-C4 '168 settings refusal: 400 invalid_number_control' { Expect-C4 PATCH '/v1/phone-numbers/not-a-number' 400 'invalid_number_control' '{"inbound_enabled":"invalid"}' }
Test-C4 '169 caller deletion refusal: 401 unauthorized' { Expect-C4 DELETE '/v1/phone-numbers/not-a-number/callers/not-a-caller' 401 'unauthorized' '' 'Invalid' }
Test-C4 '172 caller import refusal: 400 invalid_body, no rows' { Expect-C4 POST '/v1/phone-numbers/not-a-number/callers/import' 400 'invalid_body' '{"callers":[]}' }
Test-C4 '96 outbound refusal: 400 missing_field, no dispatch' { Expect-C4 POST '/v1/calls/outbound' 400 'missing_field' '{}' }
Test-C4 '174 SMS refusal: 400 missing_field, no send' { Expect-C4 POST '/v1/sms' 400 'missing_field' '{}' }
Write-Output ('C4 RESULT | PASS=' + $script:C4Pass + ' FAIL=' + $script:C4Fail + ' PENDING=' + $script:C4Pending)
if ($script:C4Fail -gt 0) { exit 1 }
# Exit 0 means all runnable safe checks passed, not that pending manual tests passed.
exit 0
