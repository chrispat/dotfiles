Import-Module Azure

Function New-AzureSqlDatabaseServerContextFromPlainText
{
    Param(
        [String]$UserName,
        [String]$Password
    )
 
    $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    
    Return New-Object System.Management.Automation.PSCredential($UserName, $securePassword)
}

$SqlDatabaseUserName = "cpdbadmin"
$SqlDatabasePassword = "Pass@word1"
$databaseName = "MembershipDB"
$Location = "East US"

$ipregex = "(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"
$http = New-Object -TypeName System.Net.WebClient
$text = $http.DownloadString('http://www.whatismyip.com/api/wimi.php')
$text -match $ipregex
if($matches)
{
    Write-Host($matches[0])
  $ipaddress = $matches[0]  
}

$ipparts = $ipaddress.Split('.')
$ipparts[3] = 0
$startip = [string]::Join('.',$ipparts)
$ipparts[3] = 255
$endip = [string]::Join('.',$ipparts)
write-host($startip)
Write-Host($endip)


$databaseServer = New-AzureSqlDatabaseServer -AdministratorLogin $SqlDatabaseUserName -AdministratorLoginPassword $SqlDatabasePassword -Location $Location

New-AzureSqlDatabaseServerFirewallRule -ServerName $databaseServer.ServerName -RuleName "MSRule" -StartIpAddress $startip -EndIpAddress $endip -Verbose

$databaseCredential = New-AzureSqlDatabaseServerContextFromPlainText -UserName $SqlDatabaseUserName -Password $SqlDatabasePassword
$databaseContext =  New-AzureSqlDatabaseServerContext -ServerName $databaseServer.ServerName -Credential $databaseCredential
 
Write-Verbose ("[Start] creating database {0} in database server {1}" -f $databaseName, $databaseServer.ServerName)
# Use the database context to create a database
New-AzureSqlDatabase -DatabaseName $databaseName -Context $databaseContext -Verbose
Write-Verbose ("[Finish] creating database {0} in database server {1}" -f $databaseName, $databaseServer.ServerName)
 
