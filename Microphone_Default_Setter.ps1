
 $CurrentDefaultComMic = (Get-AudioDevice -list | Where-Object DefaultCommunication -eq "True" | Where-Object Type -eq ("Recording")).Name
 $CurrentDefaultComMic = ($CurrentDefaultComMic.Split("(")[0]).TrimEnd()


 $DeviceName = (Get-AudioDevice -list | Where-Object Name -like ("TONOR TC30*") | Set-AudioDevice).Name
 $DeviceName = ($DeviceName.Split("(")[0]).TrimEnd()

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
            <TextBlock Name="DeviceSelectedText" FontSize="140" TextAlignment="Center" HorizontalAlignment="Center" Foreground="White" Text="Placeholder"/>
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

$OutputText = $Form.FindName("DeviceSelectedText")

if ($CurrentDefaultComMic -eq $DeviceName) {
    $OutputText.Text = "Already Default" 
    $MaxLineLength = $OutputText.Text.length
    $NumberOfLines = 1
    $DisplayTime = 800
}
else {
    $PreviousText = ("Was set to: "+$CurrentDefaultComMic)
    $CurrentText = ("Now set to: "+$DeviceName)
    $MaxLineLength = ($PreviousText.length,$CurrentText.length | Measure-Object -Maximum).Maximum
    $OutputText.Text=($PreviousText+"`n"+$CurrentText)
    $NumberOfLines = 2
    $DisplayTime = 5000
}




$TextLength = $OutputText.Text.length
$OutputText.FontSize=100

$WindowProperties = $Form.FindName("WindowProperties")
$WindowProperties.Width = ($OutputText.FontSize/1.8*$MaxLineLength)
$WindowProperties.Height = ($OutputText.FontSize*$NumberOfLines*1.5)
$WindowProperties.WindowStartupLocation="Manual"
$WindowProperties.Top=$DisplaySize.Height/40
$WindowProperties.Left=($DisplaySize.Width/2)-($WindowProperties.Width/2)

$Script:Timer = New-Object System.Windows.Forms.Timer
$Timer.Interval = $DisplayTime

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
