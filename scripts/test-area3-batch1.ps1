# Offline/local fake checks only. No credentials, live calls, installs or publishing.
[CmdletBinding()]
param([string]$RepoRoot = 'D:\Nixflex Voice Engine')
$ErrorActionPreference = 'Stop'
function Invoke-Gate {
    param([string]$Repo, [string]$Suffix, [scriptblock]$Steps)
    $taskRoot = Join-Path $RepoRoot $Repo
    Push-Location -LiteralPath $taskRoot
    try {
        $taskBranch = git branch --show-current
        if ($LASTEXITCODE -ne 0 -or $taskBranch -ne "codex/area3-batch1-$Suffix") {
            throw "Expected codex/area3-batch1-$Suffix in $Repo. No tests run there."
        }
        Write-Host "Checking $Repo on $taskBranch (offline fakes only)"
        & $Steps
        git diff --check
        if ($LASTEXITCODE -ne 0) { throw "$Repo whitespace check failed" }
    } finally { Pop-Location }
}
Invoke-Gate 'nixflex-python' 'python' {
    # Explicit local source: a separately installed Python SDK must not shadow this checkout.
    python -m pytest -q -o pythonpath=src
    if ($LASTEXITCODE -ne 0) { throw 'Python tests failed' }
}
Invoke-Gate 'nixflex-sdk' 'node' {
    npm run build
    if ($LASTEXITCODE -ne 0) { throw 'Node build failed' }
    npm run check
    if ($LASTEXITCODE -ne 0) { throw 'Node/CLI tests failed' }
}
Invoke-Gate 'nixflex-mcp' 'mcp' {
    npm run check
    if ($LASTEXITCODE -ne 0) { throw 'MCP tests failed' }
    npm run check:calls-packed
    if ($LASTEXITCODE -ne 0) { throw 'Packed MCP calls check failed' }
}
Invoke-Gate 'nixflex-docs' 'docs' {
    node --test tests/*.test.mjs
    if ($LASTEXITCODE -ne 0) { throw 'Docs tests failed' }
}
Write-Host 'PASS: Area 3 batch 1. No real paid calls needed. No live API/carrier requests made.'
