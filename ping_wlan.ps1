$targets = 'o2.box', 'google.de', 'google.com', 'bacherik.be', 'bacherik.de', '45.142.115.165', 'twitch.tv', 'youtube.com', 'discord.gg'
$adapterName = 'WLAN'
$pingTimeout = 1000 #ms
$checkInterval = 5 #sec
$highLatency =  100 #ms
$pingTimeout = 1000 #ms
$outFileName = 'C:\rtrchk\rtrlogs\pt_erik_' + (Get-Date -Format "yyyy-MM-dd") + '.txt'

while ($true)
{
	$timeStamp = (Get-Date).ToLongTimeString()
	$host.ui.RawUI.ForegroundColor = "White"
	Write-Output $timeStamp
	
	$targets | foreach {
		$Ping = New-Object System.Net.NetworkInformation.Ping
		Try
		{
			$rechner = $_
			$Response = $Ping.Send($rechner,$pingTimeout)
			
			if ($Response.Status -ne 'Success') {

				$host.ui.RawUI.ForegroundColor = "Magenta"
				Write-Output "$($Response.Status)  $($Response.RoundtripTime)ms  $_"
			}
			else {
				if ($Response.RoundtripTime -ge $highLatency) {

					$host.ui.RawUI.ForegroundColor = "Yellow"
					Write-Output "$($Response.Status)  $($Response.RoundtripTime)ms  $_"
				}
				else {
					$host.ui.RawUI.ForegroundColor = "Green"
					Write-Output "$($Response.Status)  $($Response.RoundtripTime)ms  $_"
				}
			}
			
			$output = [pscustomobject]@{
				time=$timeStamp
				;target=$rechner
				;ping=$Response.RoundtripTime
				;adminStatus=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty AdminStatus)
				;MediaConnectionState=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty MediaConnectionState)
				;ReceiveLinkSpeed=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty ReceiveLinkSpeed)
				;TransmitLinkSpeed=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty TransmitLinkSpeed)}
			$output | export-csv -delimiter "`t" -path $outFileName -notype -append
		}
		Catch
		{
			$rechner = $_
			
			$host.ui.RawUI.ForegroundColor = "Red"
			Write-Output "$($_.Exception.Message)"
			
			$output = [pscustomobject]@{
				time=$timeStamp
				;target=$rechner
				;ping=$_.Exception.Message
				;adminStatus=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty AdminStatus)
				;MediaConnectionState=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty MediaConnectionState)
				;ReceiveLinkSpeed=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty ReceiveLinkSpeed)
				;TransmitLinkSpeed=(Get-NetAdapter | where Name -eq $adapterName | Select -ExpandProperty TransmitLinkSpeed)}
			$output | export-csv -delimiter "`t" -path $outFileName -notype -append

		}				
			
    }

	Write-Output("")
    Start-Sleep $checkInterval

}
