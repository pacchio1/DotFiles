param(
    [Parameter(Mandatory = $true)][string]$Url,
    [int]$TimeoutSec = 30
)

$deadline = (Get-Date).AddSeconds($TimeoutSec)
while ((Get-Date) -lt $deadline) {
    $code = & curl.exe -s -o NUL -w "%{http_code}" --max-time 5 $Url 2>$null
    if ($LASTEXITCODE -eq 0 -and $code -match '^[23]') {
        Write-Output "UP $code"
        exit 0
    }
    Start-Sleep -Seconds 1
}
Write-Output "DOWN dopo $TimeoutSec s"
exit 1
