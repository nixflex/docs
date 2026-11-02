# C6 staging checks. Windows PowerShell 5.1; no authenticated mutation or signing-secret retrieval.
[CmdletBinding()]
param([switch]$LoadFunctionsOnly)
Set-StrictMode -Version 2
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'C6-Http.ps1')
$script:C6Base='https://nixflex-voice-engine-staging.up.railway.app'
$script:C6Pass=0; $script:C6Fail=0; $script:C6Pending=0
$script:C6Status=0; $script:C6Code='none'; $script:C6Phase='request'
$script:C6FakeId='00000000-0000-4000-8000-000000000000'
$script:C6Cases=@'
[
  {
    "number": 12,
    "method": "PUT",
    "path": "/v1/integrations/calcom/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider",
      "is_active"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string",
      "is_active": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 13,
    "method": "GET",
    "path": "/v1/integrations/calcom/number/:phoneNumber",
    "fields": [
      "phone_number",
      "is_active",
      "username",
      "event_slug",
      "default_timezone",
      "api_key_set"
    ],
    "types": {
      "phone_number": "string",
      "is_active": "boolean",
      "username": "string",
      "event_slug": "string",
      "default_timezone": "string",
      "api_key_set": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 14,
    "method": "DELETE",
    "path": "/v1/integrations/calcom/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 15,
    "method": "PUT",
    "path": "/v1/integrations/slack/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider",
      "is_active"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string",
      "is_active": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 16,
    "method": "GET",
    "path": "/v1/integrations/slack/number/:phoneNumber",
    "fields": [
      "phone_number",
      "is_active",
      "webhook_url_set"
    ],
    "types": {
      "phone_number": "string",
      "is_active": "boolean",
      "webhook_url_set": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 17,
    "method": "DELETE",
    "path": "/v1/integrations/slack/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 18,
    "method": "PUT",
    "path": "/v1/integrations/zapier/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider",
      "is_active"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string",
      "is_active": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 19,
    "method": "GET",
    "path": "/v1/integrations/zapier/number/:phoneNumber",
    "fields": [
      "phone_number",
      "is_active",
      "post_call_url_set"
    ],
    "types": {
      "phone_number": "string",
      "is_active": "boolean",
      "post_call_url_set": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 20,
    "method": "DELETE",
    "path": "/v1/integrations/zapier/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 21,
    "method": "PUT",
    "path": "/v1/integrations/make/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider",
      "is_active"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string",
      "is_active": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 22,
    "method": "GET",
    "path": "/v1/integrations/make/number/:phoneNumber",
    "fields": [
      "phone_number",
      "is_active",
      "post_call_url_set",
      "in_call_url_set",
      "tool_name",
      "tool_description",
      "parameters"
    ],
    "types": {
      "phone_number": "string",
      "is_active": "boolean",
      "post_call_url_set": "boolean",
      "in_call_url_set": "boolean",
      "tool_name": [
        "string",
        "null"
      ],
      "tool_description": [
        "string",
        "null"
      ],
      "parameters": [
        "object",
        "null"
      ]
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 23,
    "method": "DELETE",
    "path": "/v1/integrations/make/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 24,
    "method": "PUT",
    "path": "/v1/integrations/gohighlevel/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider",
      "is_active"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string",
      "is_active": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 25,
    "method": "GET",
    "path": "/v1/integrations/gohighlevel/number/:phoneNumber",
    "fields": [
      "phone_number",
      "is_active",
      "pit_set",
      "location_id",
      "tags"
    ],
    "types": {
      "phone_number": "string",
      "is_active": "boolean",
      "pit_set": "boolean",
      "location_id": "string",
      "tags": "array"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 26,
    "method": "DELETE",
    "path": "/v1/integrations/gohighlevel/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 27,
    "method": "PUT",
    "path": "/v1/integrations/webhook/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 28,
    "method": "GET",
    "path": "/v1/integrations/webhook/number/:phoneNumber",
    "fields": [
      "phone_number",
      "webhook_url",
      "is_set"
    ],
    "types": {
      "phone_number": "string",
      "webhook_url": [
        "string",
        "null"
      ],
      "is_set": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 29,
    "method": "DELETE",
    "path": "/v1/integrations/webhook/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 30,
    "method": "PUT",
    "path": "/v1/integrations/webhook2/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 31,
    "method": "GET",
    "path": "/v1/integrations/webhook2/number/:phoneNumber",
    "fields": [
      "phone_number",
      "webhook_url_2",
      "is_set"
    ],
    "types": {
      "phone_number": "string",
      "webhook_url_2": [
        "string",
        "null"
      ],
      "is_set": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 36,
    "method": "PUT",
    "path": "/v1/integrations/web-calls/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "web_calls_enabled"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "web_calls_enabled": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 37,
    "method": "GET",
    "path": "/v1/integrations/web-calls/number/:phoneNumber",
    "fields": [
      "phone_number",
      "web_calls_enabled"
    ],
    "types": {
      "phone_number": "string",
      "web_calls_enabled": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 38,
    "method": "DELETE",
    "path": "/v1/integrations/web-calls/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "web_calls_enabled"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "web_calls_enabled": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 39,
    "method": "DELETE",
    "path": "/v1/integrations/webhook2/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 40,
    "method": "PUT",
    "path": "/v1/integrations/precall/number/:phoneNumber",
    "fields": [
      "ok",
      "phone_number",
      "provider"
    ],
    "types": {
      "ok": "boolean",
      "phone_number": "string",
      "provider": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 41,
    "method": "GET",
    "path": "/v1/integrations/precall/number/:phoneNumber",
    "fields": [
      "phone_number",
      "precall_webhook_url",
      "is_set"
    ],
    "types": {
      "phone_number": "string",
      "precall_webhook_url": [
        "string",
        "null"
      ],
      "is_set": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 42,
    "method": "DELETE",
    "path": "/v1/integrations/precall/number/:phoneNumber",
    "fields": [
      "ok",
      "deleted",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 43,
    "method": "PUT",
    "path": "/v1/integrations/precall/agent/:agentId",
    "fields": [
      "ok",
      "agent_id",
      "provider"
    ],
    "types": {
      "ok": "boolean",
      "agent_id": "string",
      "provider": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 44,
    "method": "GET",
    "path": "/v1/integrations/precall/agent/:agentId",
    "fields": [
      "agent_id",
      "precall_webhook_url",
      "is_set"
    ],
    "types": {
      "agent_id": "string",
      "precall_webhook_url": [
        "string",
        "null"
      ],
      "is_set": "boolean"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 45,
    "method": "DELETE",
    "path": "/v1/integrations/precall/agent/:agentId",
    "fields": [
      "ok",
      "deleted",
      "agent_id"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "agent_id": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 46,
    "method": "POST",
    "path": "/v1/integrations/custom-functions/number/:phoneNumber",
    "fields": [
      "ok",
      "id",
      "phone_number",
      "name"
    ],
    "types": {
      "ok": "boolean",
      "id": "string",
      "phone_number": "string",
      "name": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 47,
    "method": "GET",
    "path": "/v1/integrations/custom-functions/number/:phoneNumber",
    "fields": [
      "phone_number",
      "functions"
    ],
    "types": {
      "phone_number": "string",
      "functions": "array"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 48,
    "method": "DELETE",
    "path": "/v1/integrations/custom-functions/number/:phoneNumber/:id",
    "fields": [
      "ok",
      "deleted",
      "id",
      "phone_number"
    ],
    "types": {
      "ok": "boolean",
      "deleted": "boolean",
      "id": "string",
      "phone_number": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 49,
    "method": "PATCH",
    "path": "/v1/integrations/custom-functions/number/:phoneNumber/:id",
    "fields": [
      "ok",
      "id",
      "phone_number",
      "name"
    ],
    "types": {
      "ok": "boolean",
      "id": "string",
      "phone_number": "string",
      "name": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 143,
    "method": "GET",
    "path": "/v1/organisation",
    "fields": [
      "organisation_id",
      "key_id",
      "name",
      "role",
      "user_id",
      "membership_version",
      "joined_at",
      "is_active",
      "dashboard_state",
      "permissions"
    ],
    "types": {
      "organisation_id": "string",
      "key_id": "string",
      "name": "string",
      "role": "string",
      "user_id": [
        "string",
        "null"
      ],
      "membership_version": [
        "integer",
        "null"
      ],
      "joined_at": [
        "string",
        "null"
      ],
      "is_active": "boolean",
      "dashboard_state": "string",
      "permissions": "array"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 145,
    "method": "GET",
    "path": "/v1/organisation/activity",
    "fields": [
      "events",
      "next_cursor"
    ],
    "types": {
      "events": "array",
      "next_cursor": [
        "string",
        "null"
      ]
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 146,
    "method": "POST",
    "path": "/v1/organisation/claim-invite",
    "fields": [],
    "types": {},
    "write": true,
    "sensitive": false
  },
  {
    "number": 148,
    "method": "POST",
    "path": "/v1/organisation/invites",
    "fields": [],
    "types": {},
    "write": true,
    "sensitive": false
  },
  {
    "number": 149,
    "method": "DELETE",
    "path": "/v1/organisation/invites/:id",
    "fields": [
      "id",
      "email",
      "role",
      "state"
    ],
    "types": {
      "id": "string",
      "email": "string",
      "role": "string",
      "state": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 150,
    "method": "POST",
    "path": "/v1/organisation/invites/:id/resend",
    "fields": [],
    "types": {},
    "write": true,
    "sensitive": false
  },
  {
    "number": 152,
    "method": "GET",
    "path": "/v1/organisation/members",
    "fields": [
      "members",
      "invites",
      "limits"
    ],
    "types": {
      "members": "array",
      "invites": "array",
      "limits": "object"
    },
    "write": false,
    "sensitive": false
  },
  {
    "number": 153,
    "method": "DELETE",
    "path": "/v1/organisation/members/:id",
    "fields": [
      "user_id",
      "state",
      "live_disconnect_pending"
    ],
    "types": {
      "user_id": "string",
      "state": "string",
      "live_disconnect_pending": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 154,
    "method": "PATCH",
    "path": "/v1/organisation/members/:id",
    "fields": [
      "user_id",
      "state",
      "live_disconnect_pending"
    ],
    "types": {
      "user_id": "string",
      "state": "string",
      "live_disconnect_pending": "boolean"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 155,
    "method": "PATCH",
    "path": "/v1/organisation/name",
    "fields": [
      "name"
    ],
    "types": {
      "name": "string"
    },
    "write": true,
    "sensitive": false
  },
  {
    "number": 158,
    "method": "GET",
    "path": "/v1/organisation/signing-secret",
    "fields": [
      "signing_secret"
    ],
    "types": {
      "signing_secret": "string"
    },
    "write": false,
    "sensitive": true
  },
  {
    "number": 55,
    "method": "GET",
    "path": "/v1/agent-inbox/features",
    "fields": [
      "enabled"
    ],
    "types": {
      "enabled": "boolean"
    },
    "write": false,
    "sensitive": false
  }
]
'@ | ConvertFrom-Json
function Assert-C6($Condition) { if (-not $Condition) { throw 'Contract mismatch; response withheld' } }
function Reason-C6 { return ('HTTP='+$script:C6Status+' code='+$script:C6Code+' phase='+$script:C6Phase) }
function Pending-C6([string]$Name,[string]$Reason) { $script:C6Pending++; Write-Output ('PENDING | '+$Name+' | '+$Reason) }
function Test-C6([string]$Name,[scriptblock]$Action) {
    $script:C6Status=0; $script:C6Code='none'; $script:C6Phase='request'
    try { & $Action | Out-Null; $script:C6Pass++; Write-Output ('PASS | '+$Name+' | '+(Reason-C6)) }
    catch { $script:C6Fail++; Write-Output ('FAIL | '+$Name+' | '+(Reason-C6)+' | response withheld') }
}
function ErrorPath-C6($Case) { return $Case.path.Replace(':phoneNumber','not-a-number').Replace(':agentId','C6_missing_agent').Replace(':id',$script:C6FakeId) }
function Assert-C6Request([string]$Method,[string]$Path,[string]$Body,[string]$Auth) {
    Assert-C6 ($Auth -in @('Real','Invalid'))
    Assert-C6 ($Path -cmatch '^/v1/[A-Za-z0-9_/%+:?.=&,-]+$' -and $Path -notmatch '\.\.|://|%0[ad]')
    $decoded=[uri]::UnescapeDataString($Path)
    Assert-C6 ($decoded -notmatch '\.\.|://|[\r\n]')
    if ($Auth -eq 'Invalid') {
        Assert-C6 ($Body -ceq '' -or $Body -ceq '{}')
        $allowed=$false
        foreach ($case in $script:C6Cases) { if ($case.method -ceq $Method -and (ErrorPath-C6 $case) -ceq $Path) { $allowed=$true } }
        Assert-C6 $allowed
        return
    }
    # No valid-key write can pass this guard. Secrets and personal flows are excluded.
    Assert-C6 ($Method -ceq 'GET' -and $Body -ceq '')
    Assert-C6 ($decoded -cmatch '^/v1/(organisation(?:/(members|activity))?|agent-inbox/features|integrations/(calcom|slack|zapier|make|gohighlevel|webhook2?|web-calls|precall|custom-functions)/number/\+[1-9][0-9]{6,14}|integrations/precall/agent/[A-Za-z0-9_-]{1,200})$')
}
function Invoke-C6Request([string]$Method,[string]$Path,[string]$Body='',[ValidateSet('Real','Invalid')][string]$Auth='Real') {
    $script:C6Status=0; $script:C6Code='none'; $script:C6Phase='request'
    Assert-C6Request $Method $Path $Body $Auth
    $headers=@{}
    if ($Auth -eq 'Real') { Assert-C6 (-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)); $headers.Authorization='Bearer '+$env:NXF_STAGING_KEY }
    else { $headers.Authorization='Bearer nxf_C6_INVALID:nxfs_C6_INVALID' }
    $args=@{Uri=($script:C6Base+$Path);Method=$Method;Headers=$headers;UseBasicParsing=$true;DisableKeepAlive=$true;MaximumRedirection=0;TimeoutSec=30;ErrorAction='Stop'}
    if ($Body) { $args.Body=$Body; $args.ContentType='application/json' }
    $status=0; $content=''; $source='success'
    try { $r=Invoke-WebRequest @args; $status=[int]$r.StatusCode; $content=[string]$r.Content }
    catch { $e=Read-C6HttpError $_; $status=$e.Status; $content=$e.Content; $source=$e.Source }
    $script:C6Status=$status; $script:C6Phase='parse'; $json=$null
    if ($content) { $json=$content | ConvertFrom-Json }
    if ($null -ne $json -and $null -ne $json.PSObject.Properties['error']) {
        $err=$json.PSObject.Properties['error'].Value
        if ($null -ne $err -and $null -ne $err.PSObject.Properties['code']) {
            $candidate=[string]$err.PSObject.Properties['code'].Value; $script:C6Code='unrecognised'
            if ($candidate -cmatch '^[a-z][a-z0-9_]{0,79}$') { $script:C6Code=$candidate }
        }
    }
    $script:C6Phase='status'
    return [pscustomobject]@{Status=$status;Json=$json;ErrorSource=$source}
}
function Assert-C6Fields($Case,$Object) {
    $script:C6Phase='shape'; Assert-C6 ($null -ne $Object)
    foreach ($field in $Case.fields) {
        $prop=$Object.PSObject.Properties[$field]; Assert-C6 ($null -ne $prop)
        $types=@($Case.types.PSObject.Properties[$field].Value); $value=$prop.Value
        if ($null -eq $value) { Assert-C6 ($types -contains 'null'); continue }
        if ($types -contains 'boolean') { Assert-C6 ($value -is [bool]) }
        elseif ($types -contains 'string') { Assert-C6 ($value -is [string]) }
        elseif ($types -contains 'array') { Assert-C6 ($value -is [array]) }
        elseif ($types -contains 'object') { Assert-C6 ($value -is [pscustomobject]) }
        elseif ($types -contains 'integer') { Assert-C6 ($value -is [int] -or $value -is [long]) }
    }
}
if ($LoadFunctionsOnly) { return }
# One documented authentication error for each of the 45 new pages, plus row 55.
foreach ($case in $script:C6Cases) {
    Test-C6 ('row '+$case.number+' documented error') {
        $body=''; if ($case.write) { $body='{}' }
        $r=Invoke-C6Request $case.method (ErrorPath-C6 $case) $body 'Invalid'
        Assert-C6 ($r.Status -eq 401 -and $script:C6Code -ceq 'unauthorized')
        Assert-C6 ($r.ErrorSource -ceq 'ErrorDetails.Message' -or $r.ErrorSource -ceq 'stream')
        foreach ($field in @('code','message','doc_url')) { Assert-C6 ($null -ne $r.Json.error.PSObject.Properties[$field]) }
    }
}
$hasKey=-not [string]::IsNullOrWhiteSpace($env:NXF_STAGING_KEY)
# Existing numbers are read only. Override the read fixture privately if needed.
$number='+447861926140'; if (-not [string]::IsNullOrWhiteSpace($env:NXF_PHONE_NUMBER)) { $number=$env:NXF_PHONE_NUMBER }
$agent=$env:NXF_AGENT_ID
foreach ($case in $script:C6Cases) {
    $name='row '+$case.number+' example'
    if ($case.write) { Pending-C6 $name 'pending manual test: successful write needs a controlled disposable fixture'; continue }
    if ($case.sensitive) { Pending-C6 $name 'pending manual test: private signing-secret read; never automated'; continue }
    if (-not $hasKey) { Pending-C6 $name 'pending staging run: NXF_STAGING_KEY absent'; continue }
    if ($case.path.Contains(':agentId') -and [string]::IsNullOrWhiteSpace($agent)) { Pending-C6 $name 'pending manual test: set NXF_AGENT_ID to an owned read fixture'; continue }
    try {
        $path=$case.path.Replace(':phoneNumber',[uri]::EscapeDataString($number))
        if ($case.path.Contains(':agentId')) { $path=$path.Replace(':agentId',[uri]::EscapeDataString($agent)) }
        $r=Invoke-C6Request 'GET' $path
        if ($r.Status -eq 404 -and $script:C6Code -ceq 'not_found') {
            Pending-C6 $name ('pending manual test: feature or saved owned configuration unavailable; '+(Reason-C6)); continue
        }
        Assert-C6 ($r.Status -eq 200); Assert-C6Fields $case $r.Json
        $script:C6Pass++; Write-Output ('PASS | '+$name+' | '+(Reason-C6))
    } catch { $script:C6Fail++; Write-Output ('FAIL | '+$name+' | '+(Reason-C6)+' | response withheld') }
}
Write-Output ('TOTAL | PASS='+$script:C6Pass+' FAIL='+$script:C6Fail+' PENDING='+$script:C6Pending)
if ($script:C6Fail -gt 0) { exit 1 }
