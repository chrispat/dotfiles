########################################################
# Helper Functions
function Get-LargestFixedDisk {
    $disks = Get-WmiObject -Class Win32_LogicalDisk | Select -Property DeviceID, @{Name=’FreeSpaceMB’;Expression={$_.FreeSpace/1MB} } | Sort-Object -Property FreeSpaceMB -Descending;
    return $disks[0];
}


########################################################
filter Format-Bytes {
	$units = 'B  ', 'KiB', 'MiB', 'GiB', 'TiB';
	$ln = [Int64]0 + $_;
	$u = 0;

	if($ln -eq 0) {
		return '0    ';
	}

	while(($ln -gt 1024) -and ($u -lt $units.Length)) {
		$ln /= 1024;
		$u++;
	}

	'{0,7:0.###} {1}' -f $ln, $units[$u];
}


function du ($path = '.\', $unit="MB", $round=0) 
{ 
	get-childitem $path -force | ? { 
		$_.Attributes -like '*Directory*' } | %{ 
			dir $_.FullName -rec -force | 
			measure-object -sum -prop Length | 
			add-member -name Path -value $_.Fullname -member NoteProperty -pass | 
			select Path,Count,@{ expr={[math]::Round($_.Sum/"1$unit",$round)}; Name="Size($unit)"} 
		} 
}


function up ([int] $count = 1)
{
	1..$count | % { set-location .. }
	$global:PWD = get-location;
	$global:CDHIST.Insert(0, $global:PWD)
}


