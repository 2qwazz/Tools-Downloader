Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root="C:\"
$name="SS"
$i=1
while(Test-Path "$root$name$i"){ $i++ }
$folder="$root$name$i"
New-Item -Path $folder -ItemType Directory | Out-Null
Set-Location $folder

function Add-Def {
    try {
        if(Get-Command Get-MpPreference -ErrorAction SilentlyContinue){
            $e=(Get-MpPreference).ExclusionPath
            if($e -notcontains $folder){ Add-MpPreference -ExclusionPath $folder }
            return
        }
    } catch {}
    try {
        $p="HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths"
        if(Test-Path $p){ New-ItemProperty -Path $p -Name $folder -Value 0 -PropertyType DWORD -Force | Out-Null }
    } catch {}
}

function Download-File {
    param($url)
    $n=Split-Path $url -Leaf
    $d=Join-Path $folder $n
    $wc=New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent","Mozilla/5.0")
    try {
        $wc.DownloadFile($url,$d)
        if($n.ToLower().EndsWith(".zip")){
            $o=Join-Path $folder ([IO.Path]::GetFileNameWithoutExtension($n))
            if(-not(Test-Path $o)){ New-Item -Path $o -ItemType Directory | Out-Null }
            [IO.Compression.ZipFile]::ExtractToDirectory($d,$o)
            Remove-Item $d -Force
        }
    } catch {}
}

$Zimmerman=@(
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

$Nirsoft=@(
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

$Spok=@(
"https://github.com/spokwn/JournalTrace/releases/latest/download/JournalTrace.exe",
"https://github.com/spokwn/PathsParser/releases/latest/download/PathsParser.exe",
"https://github.com/spokwn/BAM-parser/releases/latest/download/BAMParser.exe",
"https://github.com/spokwn/prefetch-parser/releases/latest/download/PrefetchParser.exe",
"https://github.com/spokwn/pcasvc-executed/releases/latest/download/pcasvc-executed.exe",
"https://github.com/spokwn/ActivitiesCache-execution/releases/latest/download/ActivitiesCache-execution.exe",
"https://github.com/spokwn/Replaceparser/releases/latest/download/Replaceparser.exe",
"https://github.com/spokwn/BamDeletedKeys/releases/latest/download/BamDeletedKeys.exe",
"https://github.com/spokwn/Tool/releases/latest/download/espouken.exe"
)

$Other=@(
"https://www.voidtools.com/Everything-1.4.1.1029.x64-Setup.exe",
"https://d1kpmuwb7gvu1i.cloudfront.net/Imgr/4.7.3.81%20Release/Exterro_FTK_Imager_%28x64%29-4.7.3.81.exe",
"https://download.ccleaner.com/rcsetup154.exe",
"https://github.com/horsicq/DIE-engine/releases/latest/download/DIE-x64.zip",
"https://mh-nexus.de/downloads/HxDPortableSetup.zip",
"https://www.winitor.com/tools/pestudio/current/pestudio.zip",
"https://download.sysinternals.com/files/Strings.zip",
"https://files1.majorgeeks.com/400376550b320e37264e5ab1318d2973a41a3689/office/bintext303.zip",
"https://github.com/deathmarine/Luyten/releases/latest/download/luyten.zip",
"https://github.com/Col-E/Recaf/releases/latest/download/Recaf.zip",
"https://download.sysinternals.com/files/ProcessExplorer.zip",
"https://download.sysinternals.com/files/Autoruns.zip",
"https://download.sysinternals.com/files/ProcessMonitor.zip",
"https://download.sysinternals.com/files/TCPView.zip",
"https://github.com/Yamato-Security/hayabusa/releases/latest/download/hayabusa-win-x64.zip"
)

$form=New-Object System.Windows.Forms.Form
$form.Text="Tool Downloader"
$form.Size=New-Object System.Drawing.Size(460,450)
$form.StartPosition="CenterScreen"
$form.BackColor=[Drawing.Color]::Black

$font=New-Object System.Drawing.Font("Consolas",11)

$lbl=New-Object System.Windows.Forms.Label
$lbl.Text="Select Tool Categories"
$lbl.ForeColor="Cyan"
$lbl.Font=$font
$lbl.AutoSize=$true
$lbl.Location=New-Object Drawing.Point(20,20)
$form.Controls.Add($lbl)

$chk1=New-Object System.Windows.Forms.CheckBox
$chk1.Text="Zimmerman Tools"
$chk1.ForeColor="Red"
$chk1.Location=New-Object Drawing.Point(20,60)
$form.Controls.Add($chk1)

$chk2=New-Object System.Windows.Forms.CheckBox
$chk2.Text="Nirsoft Tools"
$chk2.ForeColor="Red"
$chk2.Location=New-Object Drawing.Point(20,90)
$form.Controls.Add($chk2)

$chk3=New-Object System.Windows.Forms.CheckBox
$chk3.Text="Spok Tools"
$chk3.ForeColor="Red"
$chk3.Location=New-Object Drawing.Point(20,120)
$form.Controls.Add($chk3)

$chk4=New-Object System.Windows.Forms.CheckBox
$chk4.Text="Other Tools"
$chk4.ForeColor="Red"
$chk4.Location=New-Object Drawing.Point(20,150)
$form.Controls.Add($chk4)

$chkAV=New-Object System.Windows.Forms.CheckBox
$chkAV.Text="Bypass Windows Defender"
$chkAV.ForeColor="Yellow"
$chkAV.Location=New-Object Drawing.Point(20,190)
$form.Controls.Add($chkAV)

$btn=New-Object System.Windows.Forms.Button
$btn.Text="Download"
$btn.Size=New-Object Drawing.Size(120,40)
$btn.Location=New-Object Drawing.Point(20,240)
$btn.BackColor="DarkCyan"
$btn.ForeColor="Black"
$form.Controls.Add($btn)

$btn.Add_Click({
    if($chkAV.Checked){ Add-Def }
    $list=@()
    if($chk1.Checked){ $list+=$Zimmerman }
    if($chk2.Checked){ $list+=$Nirsoft }
    if($chk3.Checked){ $list+=$Spok }
    if($chk4.Checked){ $list+=$Other }
    foreach($u in $list){ Download-File $u }
    Start-Process explorer.exe $folder
})

$form.ShowDialog()
