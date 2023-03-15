$adapterName = 'WLAN'

Write-Output "Disable $adapterName adapter"
Disable-NetAdapter -Name $adapterName -Confirm:$False
start-sleep -s 3
Write-Output "Enable $adapterName adapter"
Enable-NetAdapter -Name $adapterName
start-sleep -s 3
		
Do {
	$wifiUp = (Get-NetAdapter | where Name -eq $adapterName | where MediaConnectionState -ne 'Connected')
	If ($wifiUp) { Write-Output "$adapterName connected." }
}
Until ($wifiUp)
	
Write-Output (Get-NetAdapter | where Name -eq $adapterName)
