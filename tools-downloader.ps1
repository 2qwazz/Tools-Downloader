cls
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "          TOOL DOWNLOADER            " -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "               Made By 2qwa          " -ForegroundColor DarkGray
Write-Host ""

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting as administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb runAs -ArgumentList ('-ExecutionPolicy Bypass -File "' + $myInvocation.MyCommand.Definition + '"')
    exit
}

$root = "C:\"
$name = "SS"
$i = 1
while (Test-Path -Path ("$root$name$i")) { $i++ }
$folder = "$root$name$i"
New-Item -Path $folder -ItemType Directory | Out-Null
Write-Host "[+] Created folder: $folder" -ForegroundColor Cyan
Set-Location $folder

function Add-DefenderExclusion {
    Write-Host "[*] Adding Windows Defender exclusion..." -ForegroundColor Cyan
    $success = $false
    try {
        if (Get-Command Get-MpPreference -ErrorAction SilentlyContinue) {
            $existing = (Get-MpPreference).ExclusionPath
            if ($existing -notcontains $folder) {
                Add-MpPreference -ExclusionPath $folder
            }
            Write-Host "[✓] Added Defender exclusion for $folder" -ForegroundColor Green
            $success = $true
        }
    } catch {}
    
    if (-not $success) {
        try {
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"
            if (Test-Path $regPath) {
                New-ItemProperty -Path $regPath -Name $folder -Value 0 -PropertyType DWORD -Force | Out-Null
                Write-Host "[✓] Added Defender exclusion via registry" -ForegroundColor Green
                $success = $true
            }
        } catch {}
    }
}

Add-DefenderExclusion

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Download-File {
    param ([string]$url, [string]$name = $null)
    $fileName = $name
    if (-not $fileName) { $fileName = Split-Path $url -Leaf }
    $dest = Join-Path $folder $fileName
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add('User-Agent','Mozilla/5.0')

    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $wc.DownloadFile($url, $dest)
        $sw.Stop()
        Write-Host "[✓] Downloaded: $fileName ($($sw.Elapsed.TotalSeconds)s)" -ForegroundColor Green

        if ($fileName.ToLower().EndsWith(".zip")) {
            $outDir = Join-Path $folder ([System.IO.Path]::GetFileNameWithoutExtension($fileName))
            if (-not (Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory | Out-Null }
            [System.IO.Compression.ZipFile]::ExtractToDirectory($dest, $outDir)
            Remove-Item $dest -Force
            Write-Host "    Extracted → $outDir" -ForegroundColor DarkCyan
        }
    }
    catch {
        Write-Host "[✗] Failed: $url" -ForegroundColor Red
    }
}

# =========================
#   NEW URL LIST
# =========================
$urls = @(
    "https://www.voidtools.com/Everything-1.4.1.1029.x64-Setup.exe",
    "https://github.com/Col-E/Recaf/releases/download/2.21.14/recaf-2.21.14-J8-jar-with-dependencies.jar",
    "https://www.nirsoft.net/utils/usbdrivelog.zip",
    "https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip",
    "https://github.com/spokwn/BAM-parser/releases/download/v1.2.9/BAMParser.exe",
    "https://github.com/spokwn/Tool/releases/download/v1.1.3/espouken.exe",
    "https://github.com/spokwn/KernelLiveDumpTool/releases/download/v1.1/KernelLiveDumpTool.exe",
    "https://github.com/spokwn/PathsParser/releases/download/v1.2/PathsParser.exe",
    "https://github.com/spokwn/prefetch-parser/releases/download/v1.5.5/PrefetchParser.exe",
    "https://github.com/spokwn/JournalTrace/releases/download/1.2/JournalTrace.exe",
    "https://www.nirsoft.net/utils/winprefetchview-x64.zip",
    "https://github.com/winsiderss/si-builds/releases/download/3.2.25275.112/systeminformer-build-canary-setup.exe",
    "https://www.nirsoft.net/utils/usbdeview-x64.zip",
    "https://www.nirsoft.net/utils/networkusageview-x64.zip",
    "https://d1kpmuwb7gvu1i.cloudfront.net/AccessData_FTK_Imager_4.7.1.exe",
    "https://github.com/Yamato-Security/hayabusa/releases/download/v3.6.0/hayabusa-3.6.0-win-x64.zip",
    "https://download.ericzimmermanstools.com/AmcacheParser.zip",
    "https://github.com/NotRequiem/InjGen/releases/download/v2.0/InjGen.exe",
    "https://download.ericzimmermanstools.com/AppCompatCacheParser.zip",
    "https://download.ericzimmermanstools.com/bstrings.zip",
    "https://download.ericzimmermanstools.com/net6/JumpListExplorer.zip",
    "https://download.ericzimmermanstools.com/MFTECmd.zip",
    "https://download.ericzimmermanstools.com/PECmd.zip",
    "https://download.ericzimmermanstools.com/net6/RegistryExplorer.zip",
    "https://download.ericzimmermanstools.com/SrumECmd.zip",
    "https://github.com/spokwn/BamDeletedKeys/releases/download/v1.0/BamDeletedKeys.exe"
)

# Download all
$counter = 0
$total = $urls.Count
foreach ($url in $urls) {
    $counter++
    Write-Host "`n[$counter/$total] Starting: $(Split-Path $url -Leaf)" -ForegroundColor Cyan
    Download-File $url
}

Start-Process explorer.exe $folder
