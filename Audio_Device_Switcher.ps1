
 $AudioCurrent = (Get-AudioDevice -playback).Name
 $AudioList =  (Get-AudioDevice -list | Where-Object Type -eq "Playback").Name
 $AudioCurrentIndex = $AudioList.IndexOf($AudioCurrent)

 If ($AudioCurrentIndex -eq ($AudioList.length-1)){
    (Get-AudioDevice -list | Where-Object Name -eq ($AudioList[0]) | Set-AudioDevice).Name
     $DeviceName = ($AudioList[0].Split("(")[0]).TrimEnd()
 }

 else {
    (Get-AudioDevice -list | Where-Object Name -eq ($AudioList[$AudioCurrentIndex+1]) | Set-AudioDevice).Name
    $DeviceName = ($AudioList[$AudioCurrentIndex+1].Split("(")[0]).TrimEnd()
    
 }

[xml]$xaml = @'
    <Window 
        Name="WindowProperties"
        WindowStartupLocation="CenterScreen" 
        Top="100" Left="1000"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" 
        Height="200" Width="1200" 
        HorizontalAlignment="Center"   
        VerticalAlignment="Top"
        WindowStyle = "None"
        AllowsTransparency = "true"
        Background="Black"
        Opacity="0.75">
        <Grid Background="Transparent">
            <TextBlock Name="DeviceSelectedText" FontSize="140" HorizontalAlignment="Center" Foreground="White" Text="Placeholder"/>
        </Grid>
    </Window>
'@
Add-Type -AssemblyName presentationCore
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
$xaml.SelectNodes("//*[@Name]") | %{ $Elements[$_.Name] = $Form.FindName($_.Name)}

$DisplaySize=[System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
$NameLength = $DeviceName.length

$OutputText = $Form.FindName("DeviceSelectedText")
$OutputText.Text=$DeviceName
$OutputText.FontSize=140

$WindowProperties = $Form.FindName("WindowProperties")
$WindowProperties.Width = ($OutputText.FontSize/1.8*$NameLength)
$WindowProperties.Height = ($OutputText.FontSize*1.5)
$WindowProperties.WindowStartupLocation="Manual"
$WindowProperties.Top=$DisplaySize.Height/40
$WindowProperties.Left=($DisplaySize.Width/2)-($WindowProperties.Width/2)

$mediaPlayer = New-Object System.Windows.Media.MediaPlayer
$mediaPlayer.open('C:\Windows\Media\Speech On.wav')
$mediaPlayer.Play()

$Script:Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 1800

Function Timer_Tick()
{
--$Script:CountDown


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
