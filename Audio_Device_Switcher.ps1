 $device1 = "G9 Monitor"
 $device2 = "HyperX Headset"
 $device3 = "TV"

 
 $Audio = Get-AudioDevice -playback
 
 if ($Audio.Name.StartsWith($device1)) {
     (Get-AudioDevice -list | Where-Object Name -like ("$device2*") | Set-AudioDevice).Name
     $NewDevice=$device2
 }

 elseif ($Audio.Name.StartsWith($device2)) {
     (Get-AudioDevice -list | Where-Object Name -like ("$device3*") | Set-AudioDevice).Name
     $NewDevice=$device3
 }
 else {
     (Get-AudioDevice -list | Where-Object Name -like ("$device1*") | Set-AudioDevice).Name
     $NewDevice=$device1
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
    <TextBlock Name="DeviceSelectedText" FontSize="130" HorizontalAlignment="Center" Foreground="White"
    Text="Test Text"
    ></TextBlock>
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

$output.Text=$NewDevice

$Script:Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = 1000

Function Timer_Tick()
{
--$Script:CountDown
If ($Script:CountDown -lt 0)
    {
    $Timer.Stop();
    $Form.Close();
    $Timer.Dispose();
    $Script:CountDown = 5
    }
}

$Script:CountDown = 1
$Timer.Add_Tick({ Timer_Tick})
$Timer.Start()

(New-Object Media.SoundPlayer 'C:\Users\tomwe\Documents\Audio Device Changed.wav').PlaySync()

$form.Topmost = "True"

$Form.ShowDialog() | out-null
