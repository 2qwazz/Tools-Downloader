cls
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "          TOOL DOWNLOADER            " -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "               Made By 2qwa          " -ForegroundColor Green
Write-Host "           Inspired By ItzIce         " -ForegroundColor Cyan
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
Set-Location $folder

function Add-DefenderExclusion {
    $success = $false
    try {
        if (Get-Command Get-MpPreference -ErrorAction SilentlyContinue) {
            $existing = (Get-MpPreference).ExclusionPath
            if ($existing -notcontains $folder) { Add-MpPreference -ExclusionPath $folder }
            $success = $true
        }
    } catch {}
    if (-not $success) {
        try {
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"
            if (Test-Path $regPath) { New-ItemProperty -Path $regPath -Name $folder -Value 0 -PropertyType DWORD -Force | Out-Null }
        } catch {}
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Download-File {
    param ($url)
    $fileName = Split-Path $url -Leaf
    $dest = Join-Path $folder $fileName
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent","Mozilla/5.0")

    Write-Progress -Activity "Downloading Tools" -Status $fileName -PercentComplete 0

    try {
        $wc.DownloadFile($url,$dest)
        Write-Progress -Activity "Downloading Tools" -Completed
        if ($fileName.ToLower().EndsWith(".zip")) {
            $outDir = Join-Path $folder ([IO.Path]::GetFileNameWithoutExtension($fileName))
            if (-not (Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory | Out-Null }
            [IO.Compression.ZipFile]::ExtractToDirectory($dest,$outDir)
            Remove-Item $dest -Force
        }
    } catch {
        Write-Host "[✗] Failed: $url" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Antivirus Options:" -ForegroundColor Cyan
Write-Host "1. Add Defender Exclusion (Recommended)" -ForegroundColor Yellow
Write-Host "2. Skip Exclusion" -ForegroundColor Green
Write-Host ""

$av = Read-Host "Choose (1 or 2)"

if ($av -eq "1") {
    Write-Host "[*] Adding Defender exclusion..." -ForegroundColor Cyan
    Add-DefenderExclusion
    Write-Host "[✓] Exclusion applied" -ForegroundColor Green
} else {
    Write-Host "[!] Skipping Defender exclusion" -ForegroundColor Red
}

$Zimmerman = @(
"https://download.ericzimmermanstools.com/net9/TimelineExplorer.zip",
"https://download.ericzimmermanstools.com/net9/JumpListExplorer.zip",
"https://download.ericzimmermanstools.com/net9/ShellBagsExplorer.zip",
"https://download.ericzimmermanstools.com/net9/RegistryExplorer.zip",
"https://download.ericzimmermanstools.com/net9/PECmd.zip",
"https://download.ericzimmermanstools.com/net9/MFTECmd.zip",
"https://download.ericzimmermanstools.com/net9/JLECmd.zip",
"https://download.ericzimmermanstools.com/net9/SrumECmd.zip",
"https://download.ericzimmermanstools.com/net9/bstrings.zip",
"https://download.ericzimmermanstools.com/net9/RecentFileCacheParser.zip"
)

$Nirsoft = @(
"https://www.nirsoft.net/utils/winprefetchview-x64.zip",
"https://www.nirsoft.net/utils/lastactivityview.zip",
"https://www.nirsoft.net/utils/executedprogramslist.zip",
"https://www.nirsoft.net/utils/userassistview.zip",
"https://www.nirsoft.net/utils/alternatestreamview-x64.zip",
"https://www.nirsoft.net/utils/hashmyfiles-x64.zip",
"https://www.nirsoft.net/utils/jumplistsview.zip",
"https://www.nirsoft.net/utils/opensavefilesview-x64.zip",
"https://www.nirsoft.net/utils/usbdeview-x64.zip",
"https://www.nirsoft.net/utils/turnedontimesview.zip",
"https://www.nirsoft.net/utils/regscanner-x64.zip",
"https://www.nirsoft.net/utils/browserdownloadsview-x64.zip",
"https://www.nirsoft.net/utils/clipboardic.zip",
"https://www.nirsoft.net/utils/driverview-x64.zip",
"https://www.nirsoft.net/utils/fileaccesserrorview-x64.zip",
"https://www.nirsoft.net/utils/previousfilesrecovery-x64.zip",
"https://www.nirsoft.net/utils/recentfilesview.zip",
"https://www.nirsoft.net/utils/shellbagsview.zip",
"https://www.nirsoft.net/utils/taskschedulerview-x64.zip",
"https://www.nirsoft.net/utils/uninstallview-x64.zip",
"https://www.nirsoft.net/utils/usbdrivelog.zip"
)

$Spok = @(
"https://github.com/spokwn/JournalTrace/releases/latest/download/JournalTrace.exe",
"https://github.com/spokwn/PathsParser/releases/latest/download/PathsParser.exe",
"https://github.com/spokwn/BAM-parser/releases/latest/download/BAMParser.exe",
"https://github.com/spokwn/prefetch-parser/releases/latest/download/PrefetchParser.exe",
"https://github.com/spokwn/pcasvc-executed/releases/download/v0.8.7/PcaSvcExecuted.exe",
"https://github.com/spokwn/ActivitiesCache-execution/releases/download/v0.6.5/ActivitiesCacheParser.exe",
"https://github.com/spokwn/Replaceparser/releases/latest/download/Replaceparser.exe",
"https://github.com/spokwn/BamDeletedKeys/releases/latest/download/BamDeletedKeys.exe",
"https://github.com/spokwn/Tool/releases/latest/download/espouken.exe"
)

$Other = @(
"https://github.com/winsiderss/si-builds/releases/download/3.2.25275.112/systeminformer-build-canary-setup.exe",
"https://www.voidtools.com/Everything-1.4.1.1029.x64-Setup.exe",
"https://d1kpmuwb7gvu1i.cloudfront.net/Imgr/4.7.3.81%20Release/Exterro_FTK_Imager_%28x64%29-4.7.3.81.exe",
"https://download.ccleaner.com/rcsetup154.exe",
"https://github.com/horsicq/DIE-engine/releases/latest/download/die_win64_portable.zip",
"https://mh-nexus.de/downloads/HxDPortableSetup.zip",
"https://www.winitor.com/tools/pestudio/current/pestudio.zip",
"https://download.sysinternals.com/files/Strings.zip",
"https://github.com/deathmarine/Luyten/releases/latest/download/luyten.jar",
"https://github.com/Col-E/Recaf/releases/download/2.21.14/recaf-2.21.14-J8-jar-with-dependencies.jar",
"https://download.sysinternals.com/files/ProcessExplorer.zip",
"https://download.sysinternals.com/files/Autoruns.zip",
"https://download.sysinternals.com/files/ProcessMonitor.zip",
"https://download.sysinternals.com/files/TCPView.zip",
"https://github.com/Yamato-Security/hayabusa/releases/latest/download/hayabusa-win-x64.zip"
)

Write-Host ""
Write-Host "Select tool categories to download (comma separated):" -ForegroundColor Cyan
Write-Host "1. Zimmerman Tools" -ForegroundColor Red
Write-Host "2. Nirsoft Tools" -ForegroundColor Red
Write-Host "3. Spok's Tools" -ForegroundColor Red
Write-Host "4. Other Tools" -ForegroundColor Red
Write-Host ""

$input = Read-Host "Enter numbers"
$choices = $input -split "," | ForEach-Object { $_.Trim() }

$downloadList = @()

foreach ($c in $choices) {
    switch ($c) {
        "1" { $downloadList += $Zimmerman }
        "2" { $downloadList += $Nirsoft }
        "3" { $downloadList += $Spok }
        "4" { $downloadList += $Other }
    }
}

$counter = 0
$total = $downloadList.Count

foreach ($url in $downloadList) {
    $counter++
    Write-Host "`n[$counter/$total] Downloading: $(Split-Path $url -Leaf)" -ForegroundColor Cyan
    Download-File $url
}

Start-Process explorer.exe $folder
