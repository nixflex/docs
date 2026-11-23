[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^\+[1-9]\d{6,14}$')][string]$BusinessNumber,
    [string]$TicketId,
    [ValidatePattern('^[a-zA-Z0-9._:-]{1,128}$')][string]$PersonalRequestKey
)
Set-StrictMode -Version 2
$ErrorActionPreference = 'Stop'
$origin = 'https://nixflex-voice-engine-staging.up.railway.app/v1'
if (-not $env:NIXFLEX_STAGING_API_KEY) { throw 'Supply the staging-only organisation credential in the process environment.' }
if ($TicketId -and -not ($TicketId -as [Guid])) { throw 'Supply a disposable staging ticket UUID.' }
if ($PersonalRequestKey -and (-not $env:NIXFLEX_STAGING_PERSONAL_TOKEN -or -not $env:NIXFLEX_STAGING_ORIGINAL_ACCOUNT_ID)) {
    throw 'Personal receipt checks need the original staging session and original public workspace ID.'
}
function Check-Read($Label,$Path,$Headers,$AssertShape) {
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Method Get -Uri ($origin + $Path) -Headers $Headers -MaximumRedirection 0 -TimeoutSec 20 -ErrorAction Stop
        $value = ConvertFrom-Json -InputObject $response.Content
        if (-not (& $AssertShape $value)) { throw 'Shape mismatch' }
    } catch {
        $http = 'unavailable'
        if ($_.Exception.PSObject.Properties['Response'] -and $_.Exception.Response) { $http = [int]$_.Exception.Response.StatusCode }
        throw ("FAIL {0} (HTTP {1}). Credentials and response details withheld." -f $Label,$http)
    }
    Write-Output ("PASS " + $Label)
}
$auth = @{Authorization=("Bearer " + $env:NIXFLEX_STAGING_API_KEY)}
$number = [Uri]::EscapeDataString($BusinessNumber)
Check-Read 'Number timezone' ("/phone-numbers/" + $number) $auth {param($v) $v.phone_number.phone_number -eq $BusinessNumber -and ($v.phone_number.PSObject.Properties.Name -contains 'calcom_timezone_override')}
Check-Read 'Cal.com booking status' ("/integrations/calcom/number/" + $number) $auth {param($v) $v.phone_number -eq $BusinessNumber -and ($v.PSObject.Properties.Name -contains 'booking_available')}
Check-Read 'Number voice totals' ("/campaigns?business_number=" + $number + "&include_totals=true") $auth {param($v) ($v.campaigns -is [array]) -and @($v.campaigns | Where-Object { $_.from_number -ne $BusinessNumber -or $_.PSObject.Properties.Name -notcontains 'total_answered' }).Count -eq 0}
Check-Read 'Number SMS campaigns' ("/sms/campaigns?business_number=" + $number) $auth {param($v) ($v.campaigns -is [array]) -and @($v.campaigns | Where-Object { $_.from_number -ne $BusinessNumber }).Count -eq 0}
Check-Read 'Attributed opt-outs' ("/contact-suppressions?channel=all&source=attributed&business_number=" + $number) $auth {param($v) ($v.entries -is [array]) -and @($v.entries | Where-Object { $_.opted_out_business_number -ne $BusinessNumber -or $_.source -notin @('sms_optout','ai_optout') }).Count -eq 0}
Check-Read 'Ticket list' '/support/tickets?limit=5' $auth {param($v) $v.tickets -is [array] -and ($v.PSObject.Properties.Name -contains 'next_cursor')}
if ($TicketId) {
    Check-Read 'Ticket thread' ("/support/tickets/"+$TicketId) $auth {param($v) $v.ticket.id -eq $TicketId -and $v.messages -is [array] -and $v.events -is [array]}
}
if ($PersonalRequestKey) {
    $personal = @{Authorization=("Bearer "+$env:NIXFLEX_STAGING_PERSONAL_TOKEN); 'X-Nixflex-Expected-Account'=$env:NIXFLEX_STAGING_ORIGINAL_ACCOUNT_ID}
    Check-Read 'Original receipt' ("/support/tickets/requests/"+[Uri]::EscapeDataString($PersonalRequestKey)) $personal {param($v) $v.receipt.operation -in @('create','reply','solve') -and $v.receipt.version -le $v.ticket.version -and ($v.PSObject.Properties.Name -notcontains 'messages')}
}
