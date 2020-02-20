<powershell>
#Create variables for ADDS installation
$DomainName = "${DomainName}"
$NetBIOSName = $DomainName.Split(".") | Select -First 1
$ForestMode = "{ForestMode}"
$DomainMode = "{DomainMode}"
$DatabasePath = "{DatabasePath}"
$SYSVOLPath = "{SYSVOLPath}"
$LogPath = "{LogPath}"
$ADRestorePassword = "{ADRestorePassword}"

# Create a user account to interact with WinRM
$Username = "terraform"
$Password = "${password}"
$group = "Administrators"

# Creating new local user
& NET USER $Username $Password /add /y /expires:never
# Adding local user to group
& NET LOCALGROUP $group $Username /add
# Ensuring password never expires
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE

# Enable WinRM Basic auth
winrm set winrm/config/service/auth '@{Basic="true"}'
# Create a self-signed cert
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "parsec-aws"
# Enable PSRemoting
Enable-PSRemoting -SkipNetworkProfileCheck -Force
# Disable HTTP Listener
Get-ChildItem WSMan:\Localhost\listener | Where -Property Keys -eq "Transport=HTTP" | Remove-Item -Recurse
# Enable HTTPS listener with certificate
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force
# Open firewall for HTTPS WinRM traffic
New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP
# Installation of Active Directory Domain Services
Install-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools
# Promoting Server to Domain Controller
Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "Win2012R2" `
-DomainName "example.com" `
-DomainNetbiosName "EXAMPLE" `
-ForestMode "Win2012R2" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL"
-SafeModeAdministratorPassword $ADRestorePassword `
-Force:$true `
</powershell>
<persist>true</persist>
