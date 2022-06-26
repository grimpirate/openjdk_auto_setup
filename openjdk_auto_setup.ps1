<#
	OpenJDK Setup Script

	https://docs.tizen.org/application/tizen-studio/setup/openjdk/
	https://taylorial.com/cs1021/Install.htm
	https://www.baeldung.com/java-home-on-windows-7-8-10-mac-os-x-linux
	https://jdk.java.net
	https://gluonhq.com/products/javafx/
#>

param(
	[Parameter(Mandatory)]
	[String]$openjdk_url,
	[Parameter(Mandatory)]
	[String]$openjfx_url
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

$jdk_dir = Get-Java $openjdk_url "JAVA_HOME" "jdk-*"
$jfx_dir = Get-Java $openjfx_url "PATH_TO_FX" "javafx-*" "lib"

<# USER PATH ENVIRONMENT VARIABLE #>
$p = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("PATH", $p + ";$jdk_dir\bin", [EnvironmentVariableTarget]::User)