# Windows PowerShell 5.1 can consume the response stream before catch runs.
function Read-C7HttpError($Record) {
    $response = $Record.Exception.Response
    if ($null -eq $response) { return [pscustomobject]@{Status=0;Content='';Source='transport'} }
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
