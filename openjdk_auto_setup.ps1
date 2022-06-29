<#
	OpenJDK Setup Script

	https://docs.tizen.org/application/tizen-studio/setup/openjdk/
	https://taylorial.com/cs1021/Install.htm
	https://www.baeldung.com/java-home-on-windows-7-8-10-mac-os-x-linux
	https://jdk.java.net
	https://gluonhq.com/products/javafx/
#>

param(
	[Parameter()]
	[String]$jdk_archive,
	[Parameter()]
	[String]$jfx_archive
)

function Get-Java
{
	param(
		$url,
		$env_var,
		$filter,
		$sub
	)

	$archive = "$env:USERPROFILE\Downloads\programs\" + ([uri]$url).Segments[-1]

	<# Download, extract, remove #>
	Invoke-WebRequest -Uri $url -UseBasicParsing -OutFile $archive
	Expand-Archive -LiteralPath $archive -DestinationPath "$env:USERPROFILE\Downloads\programs\"
	Remove-Item $archive

	<# JAVA HOME #>
	$java_dir = Get-ChildItem -directory "$env:USERPROFILE\Downloads\programs\" -Filter $filter
	$java_dir = "$env:USERPROFILE\Downloads\programs\$java_dir"
	if(-not([string]::IsNullOrWhiteSpace($sub)))
	{
		$java_dir = "$java_dir\$sub"
	}
	[Environment]::SetEnvironmentVariable($env_var, $java_dir, [EnvironmentVariableTarget]::User)

	return $java_dir
}

if([string]::IsNullOrWhiteSpace($jdk_archive))
{
	$jdk_archive = "https://jdk.java.net"
	$jdk_archive = (Invoke-WebRequest -Uri $jdk_archive -UseBasicParsing).Links.Href[0]
	$jdk_archive = "https://jdk.java.net$jdk_archive"
	$jdk_archive = ((Invoke-WebRequest -Uri $jdk_archive -UseBasicParsing).Links | Where-Object {$_.Href -like "*zip"}).Href	
}

if([string]::IsNullOrWhiteSpace($jfx_archive))
{
	$jfx_archive = "https://gluonhq.com/products/javafx"
	$jfx_archive = (Invoke-WebRequest -Uri $jfx_archive -UseBasicParsing).RawContent -match "[^']*custom-css-js[^']*"
	$jfx_archive = $Matches[0]
	$jfx_archive = "https:$jfx_archive"
	$jfx_archive = (Invoke-WebRequest -Uri $jfx_archive -UseBasicParsing).RawContent -match "REGULAR_.*"
	$jfx_archive = $Matches[0]

	$ver = $jfx_archive -match "(\d+),\s+(\d+),\s+(\d+),"
	$ver = $Matches[1] + "." + $Matches[2] + "." + $Matches[3]

	$arch = if([Environment]::Is64BitOperatingSystem) {"x64"} else {"x86"}

	$jfx_archive = "https://download2.gluonhq.com/openjfx/$ver/openjfx-" + $ver + "_windows-" + $arch + "_bin-sdk.zip"
}

$jdk_dir = Get-Java $jdk_archive "JAVA_HOME" "jdk-*"
$jfx_dir = Get-Java $jfx_archive "PATH_TO_FX" "javafx-*" "lib"

<# USER PATH ENVIRONMENT VARIABLE #>
$p = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("PATH", $p + ";%JAVA_HOME%\bin", [EnvironmentVariableTarget]::User)
