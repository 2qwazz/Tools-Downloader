#Requires -RunAsAdministrator

$ErrorActionPreference = 'SilentlyContinue'

Clear-Host
Write-Host ""
Write-Host "  ============================================================================" -ForegroundColor Red
Write-Host "                          REDLOTUS DOWNLOADER                                " -ForegroundColor Red
Write-Host "  ============================================================================" -ForegroundColor Red
Write-Host ""
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host "                            Made By 2qwa                                     " -ForegroundColor Cyan
Write-Host "                        Inspired By ItzIce                                   " -ForegroundColor DarkCyan
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host ""

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Host "  [!] Restarting as administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    exit
}

$root = "C:\"
$name = "SS"
$i = 1
while (Test-Path "$root$name$i") { $i++ }
$folder = "$root$name$i"
[void](New-Item -Path $folder -ItemType Directory -Force)
Set-Location $folder

function Add-DefenderExclusion {
    try {
        if (Get-Command Get-MpPreference -ErrorAction SilentlyContinue) {
            $existing = (Get-MpPreference -ErrorAction SilentlyContinue).ExclusionPath
            if ($null -eq $existing -or $existing -notcontains $folder) {
                Add-MpPreference -ExclusionPath $folder -ErrorAction SilentlyContinue | Out-Null
            }
        }
    } catch {
        try {
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"
            if (Test-Path $regPath) {
                [void](New-ItemProperty -Path $regPath -Name $folder -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue)
            }
        } catch { }
    }
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Download-File {
    param ([string]$url)
    
    $fileName = Split-Path $url -Leaf
    $dest = Join-Path $folder $fileName
    
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $wc.DownloadFile($url, $dest)
        
        if ($fileName -match '\.zip$') {
            $outDir = Join-Path $folder ([IO.Path]::GetFileNameWithoutExtension($fileName))
            if (-not (Test-Path $outDir)) {
                [void](New-Item -Path $outDir -ItemType Directory -Force)
            }
            [System.IO.Compression.ZipFile]::ExtractToDirectory($dest, $outDir)
            Remove-Item $dest -Force
        }
        
        return $true
    } catch {
        Write-Host "  [X] Failed: $fileName" -ForegroundColor Red
        return $false
    }
}

Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host "                          ANTIVIRUS OPTIONS                                  " -ForegroundColor Cyan
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [1] Add Defender Exclusion " -ForegroundColor Yellow -NoNewline
Write-Host "(Recommended)" -ForegroundColor Green
Write-Host "  [2] Skip Exclusion" -ForegroundColor White
Write-Host ""

$av = Read-Host "  Choose"

if ($av -eq "1") {
    Write-Host ""
    Write-Host "  [*] Adding Defender exclusion..." -ForegroundColor Cyan
    Add-DefenderExclusion
    Write-Host "  [+] Exclusion applied successfully" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  [!] Skipping Defender exclusion" -ForegroundColor Yellow
    Write-Host ""
}

$toolCategories = @{
    "1" = @{
        Name = "Zimmerman Tools"
        URLs = @(
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
    }
    "2" = @{
        Name = "Nirsoft Tools"
        URLs = @(
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
    }
    "3" = @{
        Name = "Spok's Tools"
        URLs = @(
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
    }
    "4" = @{
        Name = "Other Tools"
        URLs = @(
            "https://github.com/winsiderss/si-builds/releases/download/3.2.25275.112/systeminformer-build-canary-setup.exe",
            "https://www.voidtools.com/Everything-1.4.1.1029.x64-Setup.exe",
            "https://d1kpmuwb7gvu1i.cloudfront.net/AccessData_FTK_Imager_4.7.1.exe",
            "https://download.ccleaner.com/rcsetup154.exe",
            "https://github.com/horsicq/DIE-engine/releases/download/3.10/die_win64_portable_3.10_x64.zip",
            "https://mh-nexus.de/downloads/HxDPortableSetup.zip",
            "https://www.winitor.com/tools/pestudio/current/pestudio.zip",
            "https://download.sysinternals.com/files/Strings.zip",
            "https://github.com/deathmarine/Luyten/releases/download/v0.5.4_Rebuilt_with_Latest_depenencies/luyten-0.5.4.jar",
            "https://github.com/Col-E/Recaf/releases/download/2.21.14/recaf-2.21.14-J8-jar-with-dependencies.jar",
            "https://download.sysinternals.com/files/ProcessExplorer.zip",
            "https://download.sysinternals.com/files/Autoruns.zip",
            "https://download.sysinternals.com/files/ProcessMonitor.zip",
            "https://download.sysinternals.com/files/TCPView.zip",
            "https://github.com/Yamato-Security/hayabusa/releases/download/v3.7.0/hayabusa-3.7.0-win-aarch64.zip"
        )
    }
}

Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host "                        SELECT TOOL CATEGORIES                               " -ForegroundColor Cyan
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  [1] " -ForegroundColor Red -NoNewline
Write-Host "Zimmerman Tools" -ForegroundColor White
Write-Host "  [2] " -ForegroundColor Red -NoNewline
Write-Host "Nirsoft Tools" -ForegroundColor White
Write-Host "  [3] " -ForegroundColor Red -NoNewline
Write-Host "Spok's Tools" -ForegroundColor White
Write-Host "  [4] " -ForegroundColor Red -NoNewline
Write-Host "Other Tools" -ForegroundColor White
Write-Host ""
Write-Host "  Enter numbers separated by commas (e.g. 1,2,4)" -ForegroundColor DarkGray
Write-Host ""

$userInput = Read-Host "  Selection"
$choices = $userInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }

$downloadList = @()
foreach ($c in $choices) {
    if ($toolCategories.ContainsKey($c)) {
        $downloadList += $toolCategories[$c].URLs
    }
}

if ($downloadList.Count -eq 0) {
    Write-Host ""
    Write-Host "  [!] No valid selections made. Exiting..." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

$total = $downloadList.Count
$counter = 0
$successCount = 0

Write-Host ""
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host "                           DOWNLOADING FILES                                 " -ForegroundColor Cyan
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Total files to download: " -ForegroundColor White -NoNewline
Write-Host "$total" -ForegroundColor Yellow
Write-Host ""

foreach ($url in $downloadList) {
    $counter++
    $fileName = Split-Path $url -Leaf
    Write-Host "  [$counter/$total] " -ForegroundColor Cyan -NoNewline
    Write-Host "$fileName" -ForegroundColor White
    
    if (Download-File $url) {
        $successCount++
    }
}

Write-Host ""
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host "                          DOWNLOAD COMPLETE!                                 " -ForegroundColor Green
Write-Host "  ============================================================================" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Successfully downloaded: " -ForegroundColor White -NoNewline
Write-Host "$successCount" -ForegroundColor Green -NoNewline
Write-Host "/" -ForegroundColor White -NoNewline
Write-Host "$total" -ForegroundColor Yellow -NoNewline
Write-Host " files" -ForegroundColor White
Write-Host "  Location: " -ForegroundColor White -NoNewline
Write-Host "$folder" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Opening folder..." -ForegroundColor DarkGray
Write-Host ""

Start-Process explorer.exe $folder
