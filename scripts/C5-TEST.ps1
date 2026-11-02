# C5 staging contract checks. Windows PowerShell 5.1. No dispatch or real-number writes.
# Auth refusal checks run even without the real key. Success writes stay pending manual test.
[CmdletBinding()]
param([switch]$LoadFunctionsOnly)
Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'C5-Http.ps1')
$script:C5Base = 'https://nixflex-voice-engine-staging.up.railway.app'
$script:C5Pass = 0; $script:C5Fail = 0; $script:C5Pending = 0
$script:C5LastStatus=0; $script:C5LastCode='none'; $script:C5LastPhase='request'
$script:C5Run = 'C5_missing_' + [guid]::NewGuid().ToString('N')
$script:C5Cases = @'
[
  {
    "number": 52,
    "method": "GET",
    "path": "/v1/agent-inbox/:channel/:number",
    "query": "?limit=1&period=all",
    "fields": [
      "conversations",
      "total",
      "archived_new",
      "unread_total"
    ],
    "write": false
  },
  {
    "number": 53,
    "method": "GET",
    "path": "/v1/agent-inbox/:channel/:number/thread/:thread",
    "query": "?limit=1",
    "fields": [
      "messages",
      "read_version",
      "has_more"
    ],
    "write": false
  },
  {
    "number": 54,
    "method": "PATCH",
    "path": "/v1/agent-inbox/:channel/:number/thread/:thread",
    "query": "",
    "fields": [
      "ok",
      "archived"
    ],
    "write": true
  },
  {
    "number": 55,
    "method": "GET",
    "path": "/v1/agent-inbox/features",
    "query": "",
    "fields": [
      "enabled"
    ],
    "write": false
  },
  {
    "number": 56,
    "method": "GET",
    "path": "/v1/agent-inbox/numbers",
    "query": "?offset=0",
    "fields": [
      "numbers",
      "agents",
      "has_more"
    ],
    "write": false
  },
  {
    "number": 57,
    "method": "GET",
    "path": "/v1/agent-inbox/retention",
    "query": "",
    "fields": [
      "call_retention_days",
      "web_days",
      "web_expiry_confirmed",
      "applies_to",
      "legacy_web_policy",
      "zero_days_means",
      "archive_changes_retention",
      "sms_days",
      "sms_processing_enabled",
      "web_processing_enabled"
    ],
    "write": false
  },
  {
    "number": 58,
    "method": "GET",
    "path": "/v1/agent-web/:number",
    "query": "",
    "fields": [
      "phone_number",
      "agent_id",
      "web_prompt",
      "web_appearance",
      "appearance_version",
      "web_design",
      "web_color",
      "web_name",
      "web_chips",
      "web_calls_enabled",
      "web_agent_enabled",
      "revision",
      "install_id",
      "first_seen_at",
      "last_seen_at"
    ],
    "write": false
  },
  {
    "number": 59,
    "method": "PATCH",
    "path": "/v1/agent-web/:number",
    "query": "",
    "fields": [
      "phone_number",
      "agent_id",
      "web_prompt",
      "web_appearance",
      "appearance_version",
      "web_design",
      "web_color",
      "web_name",
      "web_chips",
      "web_calls_enabled",
      "web_agent_enabled",
      "revision",
      "install_id",
      "first_seen_at",
      "last_seen_at"
    ],
    "write": true
  },
  {
    "number": 90,
    "method": "POST",
    "path": "/v1/calls/batch",
    "query": "",
    "fields": [],
    "write": true
  },
  {
    "number": 91,
    "method": "POST",
    "path": "/v1/calls/batch/:id/cancel",
    "query": "",
    "fields": [
      "campaign_id",
      "status",
      "in_progress_may_finish"
    ],
    "write": true
  },
  {
    "number": 92,
    "method": "POST",
    "path": "/v1/calls/batch/:id/consent",
    "query": "",
    "fields": [
      "campaign_id",
      "recorded"
    ],
    "write": true
  },
  {
    "number": 93,
    "method": "POST",
    "path": "/v1/calls/batch/:id/launch",
    "query": "",
    "fields": [
      "campaign_id",
      "status",
      "total_recipients",
      "enqueued",
      "failed_to_enqueue",
      "message"
    ],
    "write": true
  },
  {
    "number": 94,
    "method": "POST",
    "path": "/v1/calls/batch/:id/resume",
    "query": "",
    "fields": [
      "campaign_id",
      "status",
      "page_result",
      "safe_to_retry",
      "message"
    ],
    "write": true
  },
  {
    "number": 97,
    "method": "GET",
    "path": "/v1/campaigns",
    "query": "?limit=1",
    "fields": [
      "campaigns"
    ],
    "write": false
  },
  {
    "number": 98,
    "method": "POST",
    "path": "/v1/contact-hours/preview",
    "query": "",
    "fields": [
      "preview_only",
      "mode",
      "policy_version",
      "runtime_timezone_version",
      "as_of",
      "expires_at",
      "agent_timezone",
      "rows"
    ],
    "write": false
  },
  {
    "number": 99,
    "method": "DELETE",
    "path": "/v1/contact-suppressions",
    "query": "",
    "fields": [
      "removed",
      "phone_number",
      "channel"
    ],
    "write": true
  },
  {
    "number": 100,
    "method": "GET",
    "path": "/v1/contact-suppressions",
    "query": "?channel=all",
    "fields": [
      "entries",
      "next_cursor"
    ],
    "write": false
  },
  {
    "number": 101,
    "method": "POST",
    "path": "/v1/contact-suppressions",
    "query": "",
    "fields": [
      "added",
      "submitted",
      "channel"
    ],
    "write": true
  },
  {
    "number": 175,
    "method": "GET",
    "path": "/v1/sms/campaigns",
    "query": "?limit=1",
    "fields": [
      "campaigns",
      "next_cursor"
    ],
    "write": false
  },
  {
    "number": 176,
    "method": "POST",
    "path": "/v1/sms/campaigns",
    "query": "",
    "fields": [],
    "write": true
  },
  {
    "number": 177,
    "method": "DELETE",
    "path": "/v1/sms/campaigns/:id",
    "query": "",
    "fields": [
      "message"
    ],
    "write": true
  },
  {
    "number": 178,
    "method": "GET",
    "path": "/v1/sms/campaigns/:id",
    "query": "?limit=1",
    "fields": [
      "campaign",
      "recipients",
      "messages",
      "pagination"
    ],
    "write": false
  },
  {
    "number": 179,
    "method": "PATCH",
    "path": "/v1/sms/campaigns/:id",
    "query": "",
    "fields": [
      "campaign_id",
      "agent_id",
      "name",
      "from_number",
      "schedule_type",
      "scheduled_date",
      "window_start_minutes",
      "window_end_minutes",
      "window_days",
      "timezone",
      "source",
      "status",
      "total_count",
      "started_at",
      "completed_at",
      "created_at",
      "updated_at",
      "allow_wider_hours",
      "id",
      "api_key_id",
      "message_template",
      "reply_context_prompt",
      "reply_window_hours",
      "is_active",
      "claimed_at",
      "sent_count",
      "delivered_count",
      "failed_count",
      "reply_count",
      "total_segments"
    ],
    "write": true
  },
  {
    "number": 180,
    "method": "POST",
    "path": "/v1/sms/campaigns/:id/cancel",
    "query": "",
    "fields": [
      "campaign_id",
      "status",
      "in_progress_may_finish"
    ],
    "write": true
  },
  {
    "number": 181,
    "method": "POST",
    "path": "/v1/sms/campaigns/:id/consent",
    "query": "",
    "fields": [
      "campaign_id",
      "recorded"
    ],
    "write": true
  },
  {
    "number": 182,
    "method": "POST",
    "path": "/v1/sms/campaigns/:id/launch",
    "query": "",
    "fields": [
      "campaign_id",
      "status",
      "sent",
      "failed",
      "total_segments",
      "held",
      "reason",
      "safe_to_retry",
      "stopped",
      "stop_reason",
      "not_sent"
    ],
    "write": true
  },
  {
    "number": 183,
    "method": "POST",
    "path": "/v1/sms/campaigns/:id/resume",
    "query": "",
    "fields": [
      "campaign_id",
      "status",
      "page_result",
      "safe_to_retry",
      "message"
    ],
    "write": true
  }
]
'@ | ConvertFrom-Json
function Assert-C5($Condition) { if (-not $Condition) { throw 'C5 assertion failed; response withheld' } }
function Pending-C5([string]$Name, [string]$Reason) { $script:C5Pending++; Write-Output ('PENDING | ' + $Name + ' | ' + $Reason) }
function Test-C5([string]$Name, [scriptblock]$Action) {
    try { & $Action | Out-Null; $script:C5Pass++; Write-Output ('PASS | ' + $Name) }
    catch { $script:C5Fail++; Write-Output ('FAIL | ' + $Name + ' | '+(Get-C5SafeReason)+' | response withheld') }
}
function Assert-C5Request([string]$Method, [string]$Path, [string]$Body, [string]$Auth) {
    Assert-C5 ($Auth -in @('Real','Invalid'))
    Assert-C5 ($Path -match '^/v1/[A-Za-z0-9_/%+:?.=&,-]+$' -and $Path -notmatch '\.\.|://|%0[ad]')
    $decoded = [uri]::UnescapeDataString($Path)
    Assert-C5 ($decoded -notmatch '\.\.|://|[\r\n]')
    if ($Auth -eq 'Invalid') {
        # No valid payload and no existing mutable identifier is ever sent with a fake credential.
        Assert-C5 ($Body -eq '' -or $Body -ceq '{}')
        $allowed = $false
        foreach ($case in $script:C5Cases) {
            $candidate = $case.path.Replace(':id',$script:C5Run).Replace(':number','not-a-number').Replace(':thread',$script:C5Run).Replace(':channel','sms')
            if ($case.method -ceq $Method -and $candidate -ceq $Path) { $allowed = $true }
        }
        Assert-C5 $allowed
        return
    }
    if ($Method -eq 'GET') {
        # The decoded route is rechecked: encoded separators cannot escape this read allowlist.
        Assert-C5 ($decoded -match '^/v1/(campaigns|sms/campaigns(?:/[A-Za-z0-9_-]+)?|contact-suppressions|agent-web/\+[1-9][0-9]{6,14}|agent-inbox/(features|numbers|retention|(?:sms|web)/\+[1-9][0-9]{6,14}(?:/thread/[^/?#]+)?))(?:\?|$)')
        return
    }
    # The only authenticated POST is the display-only preview. All real mutation methods are blocked.
    Assert-C5 ($Method -ceq 'POST' -and $Path -ceq '/v1/contact-hours/preview')
    $obj = $Body | ConvertFrom-Json
    Assert-C5 (@($obj.PSObject.Properties.Name).Count -eq 2 -and $obj.agent_id -match '^[A-Za-z0-9_-]{1,64}$')
    Assert-C5 (@($obj.recipients).Count -eq 1)
    $r = $obj.recipients[0]
    Assert-C5 (@($r.PSObject.Properties.Name).Count -eq 3 -and $r.phone -ceq '+12025550101' -and $r.country -ceq 'US' -and $r.timezone -ceq 'America/New_York')
    Assert-C5 ($Body -notmatch '447861926140|447457401554|pickup_delay')
}
function Invoke-C5Request([string]$Method, [string]$Path, [string]$Body = '', [ValidateSet('Real','Invalid')][string]$Auth = 'Real') {
    $script:C5LastStatus=0; $script:C5LastCode='none'; $script:C5LastPhase='request'
    Assert-C5Request $Method $Path $Body $Auth
    $headers = @{}
    if ($Auth -eq 'Real') { Assert-C5 (-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)); $headers.Authorization = 'Bearer ' + $env:NXF_STAGING_KEY }
    else { $headers.Authorization = 'Bearer nxf_C5_INVALID:nxfs_C5_INVALID' }
    $args = @{Uri=($script:C5Base+$Path);Method=$Method;Headers=$headers;UseBasicParsing=$true;DisableKeepAlive=$true;MaximumRedirection=0;TimeoutSec=30;ErrorAction='Stop'}
    if ($Body) { $args.Body=$Body; $args.ContentType='application/json' }
    $status=0; $content=''; $source='success'
    try { $r=Invoke-WebRequest @args; $status=[int]$r.StatusCode; $content=[string]$r.Content }
    catch { $e=Read-C5HttpError $_; $status=$e.Status; $content=$e.Content; $source=$e.Source }
    $script:C5LastStatus=$status; $script:C5LastPhase='parse'
    $json=$null
    if ($content) { try { $json=$content | ConvertFrom-Json } catch { throw 'Non-JSON response withheld' } }
    if ($null -ne $json -and $null -ne $json.PSObject.Properties['error']) {
        $errorObject=$json.PSObject.Properties['error'].Value
        if ($null -ne $errorObject -and $null -ne $errorObject.PSObject.Properties['code']) {
            $candidate=[string]$errorObject.PSObject.Properties['code'].Value
            $script:C5LastCode='unrecognised'
            if ($candidate -cmatch '^[a-z][a-z0-9_]{0,79}$') { $script:C5LastCode=$candidate }
        }
    }
    $script:C5LastPhase='status'
    return [pscustomobject]@{Status=$status;Json=$json;ErrorSource=$source}
}
function Assert-C5Fields($Object, [string[]]$Fields) {
    foreach ($field in $Fields) { Assert-C5 ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $field) }
}
function Assert-C5FeatureResponse($Response) {
    Assert-C5 ($Response.Status -eq 200)
    $script:C5LastPhase='shape'
    Assert-C5 ($null -ne $Response.Json)
    $field=$Response.Json.PSObject.Properties['enabled']
    Assert-C5 ($null -ne $field -and $field.Value -is [bool])
}
function Get-C5SafeReason { return ('HTTP='+$script:C5LastStatus+' code='+$script:C5LastCode+' phase='+$script:C5LastPhase) }
function Resolve-C5Path($Case, [string]$Number, [string]$Thread, [string]$Campaign) {
    return $Case.path.Replace(':channel','sms').Replace(':number',[uri]::EscapeDataString($Number)).Replace(':thread',[uri]::EscapeDataString($Thread)).Replace(':id',[uri]::EscapeDataString($Campaign)) + $Case.query
}
if ($LoadFunctionsOnly) { return }
# Every page documents unauthorized. This is a real HTTP error-body test, not route success coverage.
foreach ($case in $script:C5Cases) {
    Test-C5 ('row ' + $case.number + ' documented error: 401 unauthorized') {
        $path=$case.path.Replace(':id',$script:C5Run).Replace(':number','not-a-number').Replace(':thread',$script:C5Run).Replace(':channel','sms')
        $body=''; if ($case.method -ne 'GET') { $body='{}' }
        $r=Invoke-C5Request $case.method $path $body 'Invalid'
        Assert-C5 ($r.Status -eq 401 -and $r.Json.error.code -ceq 'unauthorized')
        Assert-C5Fields $r.Json.error @('code','message','doc_url')
        Assert-C5 ($r.ErrorSource -ceq 'ErrorDetails.Message')
    }
}
$hasKey=-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)
$number=''; $thread=''; $campaign=''; $agent=''
# Read-only fixture discovery. Existing content is kept in memory and never printed or saved.
if ($hasKey) {
    try {
        $r=Invoke-C5Request 'GET' '/v1/agent-inbox/numbers?offset=0'
        if ($r.Status -eq 200) {
            if (@($r.Json.numbers).Count) { $number=[string]$r.Json.numbers[0].phone_number; $agent=[string]$r.Json.numbers[0].agent_id }
            if (-not $agent -and @($r.Json.agents).Count) { $agent=[string]$r.Json.agents[0].agent_id }
        }
        $r=Invoke-C5Request 'GET' '/v1/sms/campaigns?limit=1'
        if ($r.Status -eq 200 -and @($r.Json.campaigns).Count) { $campaign=[string]$r.Json.campaigns[0].campaign_id }
        if ($number) {
            $r=Invoke-C5Request 'GET' ('/v1/agent-inbox/sms/'+[uri]::EscapeDataString($number)+'?limit=1&period=all')
            if ($r.Status -eq 200 -and @($r.Json.conversations).Count) { $thread=[string]$r.Json.conversations[0].thread_key }
        }
    } catch { Write-Output 'INFO | Read fixture discovery incomplete; dependent examples stay pending' }
}
foreach ($case in $script:C5Cases) {
    $name='row '+$case.number+' example'
    if ($case.write) { Pending-C5 $name 'pending manual test: successful mutation requires a controlled disposable fixture; no campaign draft-only API'; continue }
    if (-not $hasKey) { Pending-C5 $name 'pending staging run: NXF_STAGING_KEY absent'; continue }
    if (($case.path.Contains(':number') -and -not $number) -or ($case.path.Contains(':thread') -and -not $thread) -or ($case.path.Contains(':id') -and -not $campaign) -or ($case.number -eq 98 -and -not $agent)) {
        Pending-C5 $name 'pending manual test: required owned read fixture unavailable'; continue
    }
    try {
        $path=Resolve-C5Path $case $number $thread $campaign; $body=''
        if ($case.number -eq 98) { $body=@{agent_id=$agent;recipients=@(@{phone='+12025550101';country='US';timezone='America/New_York'})} | ConvertTo-Json -Depth 6 -Compress }
        $r=Invoke-C5Request $case.method $path $body 'Real'
        if ($r.Status -eq 503 -and $r.Json.error.code -ceq 'agent_inbox_disabled') { Pending-C5 $name 'pending manual test: inbox feature disabled'; continue }
        if ($case.number -eq 98 -and $r.Status -eq 422 -and $r.Json.error.code -ceq 'agent_timezone_required') { Pending-C5 $name 'pending manual test: agent with configured time zone required'; continue }
        if ($case.number -eq 55) { Assert-C5FeatureResponse $r }
        else { Assert-C5 ($r.Status -eq 200); $script:C5LastPhase='shape'; Assert-C5Fields $r.Json $case.fields }
        if ($case.number -eq 98) { Assert-C5 ($r.Json.preview_only -eq $true -and @($r.Json.rows).Count -eq 1) }
        $script:C5Pass++; Write-Output ('PASS | '+$name+' | '+(Get-C5SafeReason)+' | read/preview wire example')
    } catch { $script:C5Fail++; Write-Output ('FAIL | '+$name+' | '+(Get-C5SafeReason)+' | response withheld') }
}
Write-Output ('TOTAL | PASS='+$script:C5Pass+' FAIL='+$script:C5Fail+' PENDING='+$script:C5Pending)
if ($script:C5Fail -gt 0) { exit 1 }
