$global:promptTheme = @{
	prefixColor = [ConsoleColor]::Blue
	pathColor = [ConsoleColor]::Blue
	pathBracesColor = [ConsoleColor]::DarkBlue
	hostNameColor = ? : { get-isAdminUser } { [ConsoleColor]::DarkRed } { [ConsoleColor]::DarkGreen }
}

# Load up the VS Command prompt stuff
$script:vsdir = $dte.FullName | split-path | split-path
invoke-batchfile (join-path $vsdir "Tools\vsvars32.bat")

function add-existingProject([string] $projFile) {
	$dte.Solution.AddFromFile($projFile, $false)
}

function open-file([string] $path) {
	$dte.ItemOperations.OpenFile( $(resolve-path $path) ) | out-null
}

function get-solutionDir {
	$dte.Solution.FullName
}

function build-solution {
	$dte.ExecuteCommand("Build.BuildSolution", "")
}

function clean-solution {
	$dte.ExecuteCommand("Build.CleanSolution", "")
}
