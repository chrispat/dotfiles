function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        Set-Item -path env:$p -value $v
    }
}
  
function Invoke-VsVars32 {
  param (
    [String] $version = "12.0"
  )
    if (Test-Path "HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7") 
    {
        $vcdirkey = Get-ItemProperty "HKLM:SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7"
    }
    else
    {
        $vcdirkey = Get-ItemProperty "HKLM:SOFTWARE\Microsoft\VisualStudio\SxS\VC7"
    }
    $vcdir = Get-Member -Name "$version" -InputObject $vcdirkey
    $vcdir = $vcdir.Definition.Split('=')[1]
    $BatchFile = [System.IO.Path]::Combine($vcdir, "bin\vcvars32.bat")
    Get-Batchfile $BatchFile
    $global:WindowTitlePrefix =  ("VS " + $version + " - ")
    #Set-ConsoleIcon ($env:userprofile + "\utils\resources\vspowershell.ico")
}

function clean-vsextcache {
	param( $ver = "10.0exp" )

	$dir = "$home\AppData\Local\Microsoft\VisualStudio\$ver\ComponentModelCache"
	if (test-path $dir) {
		write-host "Removing $dir"
		remove-item -recurse -force $dir
	}

	$dir = "$home\AppData\Local\Microsoft\VisualStudio\$ver\Extensions"
	if (test-path $dir) {
		write-host "Removing $dir"
		remove-item -recurse -force $dir
	}
}

Export-ModuleMember Invoke-Vsvars32 Get-BatchFile
