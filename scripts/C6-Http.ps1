# Windows PowerShell 5.1: error content is often already consumed by Invoke-WebRequest.
function Read-C6HttpError($Record) {
    if ($null -eq $Record.Exception.Response) { throw 'Network outcome unknown; do not replay a write.' }
    $response = $Record.Exception.Response
    $content = ''; $source = 'stream'
    if ($Record.ErrorDetails -and -not [string]::IsNullOrWhiteSpace($Record.ErrorDetails.Message)) {
        $content = [string]$Record.ErrorDetails.Message
        $source = 'ErrorDetails.Message'
    } else {
        $reader = New-Object IO.StreamReader($response.GetResponseStream())
        try { $content = $reader.ReadToEnd() } finally { $reader.Dispose() }
    }
    return [pscustomobject]@{Status=[int]$response.StatusCode;Content=$content;Source=$source}
}
