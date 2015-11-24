Import-Module ..\powershell\modules\mklink

new-junction ~\Documents\WindowsPowerShell ..\powershell -ErrorAction SilentlyContinue
new-symlink ~\.gitignore ..\.gitignore -ErrorAction SilentlyContinue

Write-Host "Finding OneDrive Folder"
$oneDriveFolder = (Get-Item -Path HKCU:\SOFTWARE\Microsoft\OneDrive).GetValue("UserFolder")
if($oneDriveFolder)
{
    Write-Host ("OneDrive Folder found at $oneDriveFolder")
}
{
    Write-Host "Unable to find OneDrive folder"
}

#Setup Utils Folder
$targetPath = Join-Path $oneDriveFolder -ChildPath 'DotFiles\Utils'
$sourcePath = Join-Path $env:USERPROFILE -ChildPath '\Utils'
Write-Host ("Setting up Utils junction point $sourcePath => $targetPath")
New-Junction $sourcePath $targetPath

Write-Host "Finding startup.reg"
$startupReg = Get-Item -Path .\startup.reg
Write-Host ("Importing $startupReg.FullName")
cmd /c reg import $startupReg.FullName

Write-Host "Complete"