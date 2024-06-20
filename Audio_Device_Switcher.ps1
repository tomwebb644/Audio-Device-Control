 $device1 = "HyperX Headset"
 $device2 = "G9 Monitor"
 $device3 = "TV"

 $DeviceList = "HyperX Headset", "G9 Monitor", "TV"
 
 $AudioCurrent = (Get-AudioDevice -playback).Name
 $AudioList =  (Get-AudioDevice -list | Where-Object Type -eq "Playback").Name
 $AudioCurrentIndex = $AudioList.IndexOf($AudioCurrent)

 If ($AudioCurrentIndex -eq ($AudioList.length-1)){
    (Get-AudioDevice -list | Where-Object Name -eq ($AudioList[0]) | Set-AudioDevice).Name
     $DeviceSplit = $AudioList[0].Split(" ")[0]
     $DisplayName = $DeviceList -like $DeviceSplit+"*"
 }

 else {
    (Get-AudioDevice -list | Where-Object Name -eq ($AudioList[$AudioCurrentIndex+1]) | Set-AudioDevice).Name
    $DeviceSplit = $AudioList[$AudioCurrentIndex+1].Split(" ")[0]
    $DisplayName = $DeviceList -like $DeviceSplit+"*"
 }

[xml]$xaml = @'
    <Window 
        WindowStartupLocation="CenterScreen" 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Height="200" Width="1200" 
        HorizontalAlignment="Center"   
        VerticalAlignment="Top"
        WindowStyle = "None"
        AllowsTransparency = "true"
        Background="Black"
        Opacity="0.7">
        <Grid Background="Transparent">
            <TextBlock Name="DeviceSelectedText" FontSize="130" HorizontalAlignment="Center" Foreground="White" Text="Test Text"/>
        </Grid>
    </Window>
'@

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
$reader=(New-Object System.Xml.XmlNodeReader $xaml)

try
{
        $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch
{
    Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."t
}

$Elements = @{}
$xaml.SelectNodes("//*[@Name]") | %{ $Elements[$_.Name] = $Form.FindName($_.Name) }

$output = $Form.FindName("DeviceSelectedText")
$output.Text=$DisplayName

$Script:Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 100

Function Timer_Tick()
{
--$Script:CountDown

(New-Object Media.SoundPlayer 'C:\Users\tomwe\Documents\Audio Device Changed.wav').PlaySync()

If ($Script:CountDown -lt 0)
    {
    $Timer.Stop();
    $Form.Close();
    $Timer.Dispose();
    }
}

$Script:CountDown = 0
$Timer.Add_Tick({ Timer_Tick})
$Timer.Start()

$form.Topmost = "True"
$Form.ShowDialog() | out-null
