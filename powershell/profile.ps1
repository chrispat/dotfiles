#
# Profile.ps1 - main powershell profile script
# 
# Applies to all hosts, so only put things here that are global
#


# Setup the $home directory correctly
if (-not $global:home) { $global:home = (resolve-path ~) }

# A couple of directory variables for convenience

$dotfiles = resolve-path -Path (Join-Path -Path $env:USERPROFILE -ChildPath "dotfiles")
$scripts = join-path $dotfiles "powershell"

# Modules are stored here
$env:PSModulePath = $env:PSModulePath + ';' + (join-path $scripts modules)

# Update Path
$env:Path = $env:Path + ';' + (Join-Path -Path $env:USERPROFILE -ChildPath "utils\bin")

# Remove unnecessary built in alias
Remove-Item Alias:\curl

function get-isAdminUser() {
	$id = [Security.Principal.WindowsIdentity]::GetCurrent()
	$wp = new-object Security.Principal.WindowsPrincipal($id)
	return $wp.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

$global:promptTheme = @{
	prefixColor = [ConsoleColor]::Cyan
	pathColor = [ConsoleColor]::Cyan
	pathBracesColor = [ConsoleColor]::DarkCyan
	hostNameColor = if ( get-isAdminUser ) { [ConsoleColor]::Red } else { [ConsoleColor]::Green }
}

# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE

    $prefix = [char]0x221e + " "
    $hostName = [net.dns]::GetHostName().ToLower()
    
    write-host $prefix -noNewLine -foregroundColor $promptTheme.prefixColor
    write-host $hostName -noNewLine -foregroundColor $promptTheme.hostNameColor
    write-host ' {' -noNewLine -foregroundColor $promptTheme.pathBracesColor
    Write-Host($pwd.ProviderPath) -nonewline -foregroundColor $promptTheme.pathColor
    write-host '}' -noNewLine -foregroundColor $promptTheme.pathBracesColor

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

# UNIX friendly environment variables
$env:EDITOR = "code"
$env:VISUAL = $env:EDITOR
$env:GIT_EDITOR = $env:EDITOR




