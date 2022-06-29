<#
	OpenJDK Setup Script

	https://docs.tizen.org/application/tizen-studio/setup/openjdk/
	https://taylorial.com/cs1021/Install.htm
	https://www.baeldung.com/java-home-on-windows-7-8-10-mac-os-x-linux
	https://jdk.java.net
	https://gluonhq.com/products/javafx/
	http://eddiejackson.net/lab/2020/05/20/powershell-log-off-and-shutdown/
#>

param(
	[Parameter()]
	[String]$jdkArchive,
	[Parameter()]
	[String]$jfxArchive
)

function Get-Java
{
	param(
		$url,
		$envVar,
		$filter,
		$sub
	)

	$archive = "$env:USERPROFILE\Downloads\programs\" + ([uri]$url).Segments[-1]

	# Download, extract, remove
	Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $archive
	Expand-Archive -LiteralPath $archive -DestinationPath "$env:USERPROFILE\Downloads\programs\"
	Remove-Item $archive

	# JAVA_HOME, PATH_TO_FX
	$javaDir = Get-ChildItem -directory "$env:USERPROFILE\Downloads\programs\" -Filter $filter
	$javaDir = "$env:USERPROFILE\Downloads\programs\$javaDir"
	if(-not([string]::IsNullOrWhiteSpace($sub)))
	{
		$javaDir = "$javaDir\$sub"
	}
	[Environment]::SetEnvironmentVariable($envVar, $javaDir, [EnvironmentVariableTarget]::User)

	return $javaDir
}

if([string]::IsNullOrWhiteSpace($jdkArchive))
{
	$jdkArchive = "https://jdk.java.net"
	$jdkArchive = (Invoke-WebRequest -Uri $jdkArchive -UseBasicParsing).Links.Href[0]
	$jdkArchive = "https://jdk.java.net$jdkArchive"
	$jdkArchive = ((Invoke-WebRequest -Uri $jdkArchive -UseBasicParsing).Links | Where-Object {$_.Href -like "*zip"}).Href	
}

if([string]::IsNullOrWhiteSpace($jfxArchive))
{
	$jfxArchive = "https://gluonhq.com/products/javafx"
	$jfxArchive = (Invoke-WebRequest -Uri $jfxArchive -UseBasicParsing).RawContent -match "[^']*custom-css-js[^']*"
	$jfxArchive = $Matches[0]
	$jfxArchive = "https:$jfxArchive"
	$jfxArchive = (Invoke-WebRequest -Uri $jfxArchive -UseBasicParsing).RawContent -match "REGULAR_.*"
	$jfxArchive = $Matches[0]

	$ver = $jfxArchive -match "(\d+),\s+(\d+),\s+(\d+),"
	$ver = $Matches[1] + "." + $Matches[2] + "." + $Matches[3]

	$arch = if([Environment]::Is64BitOperatingSystem) {"x64"} else {"x86"}

	$jfxArchive = "https://download2.gluonhq.com/openjfx/$ver/openjfx-" + $ver + "_windows-" + $arch + "_bin-sdk.zip"
}

$jdkDir = Get-Java $jdkArchive "JAVA_HOME" "jdk-*"
$jfxDir = Get-Java $jfxArchive "PATH_TO_FX" "javafx-*" "lib"

# USER PATH ENVIRONMENT VARIABLE
$p = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
$p = $p.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
$p += "%JAVA_HOME%\bin"
$p = ($p -join ";") + ";"
# [Environment]::SetEnvironmentVariable("PATH", $p, [EnvironmentVariableTarget]::User)
# setx PATH "$p"
Set-ItemProperty HKCU:\Environment -Name "PATH" -Value "$p" -Type ExpandString

Write-Host "Must sign out to refresh: " -ForegroundColor yellow -NoNewLine
Write-Host "%JAVA_HOME%\bin" -ForegroundColor magenta
Write-Host "SAVE WORK AND CLOSE ALL APPLICATIONS!" -ForegroundColor red
Write-Host "Sign out? [y/n]" -ForegroundColor yellow
if((Read-Host) -match "[yY]")
{
	(Get-WmiObject -Class Win32_OperatingSystem).Win32Shutdown(0)
}