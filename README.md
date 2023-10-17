# OpenJDK PowerShell Setup Script
## Requirements
* Windows OS
* PS > Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -File .\openjdk_auto_setup.ps1
## Usage
Run script and get urls to JDK archive(s) from:
* https://jdk.java.net
* https://gluonhq.com/products/javafx/
```
PS > & .\openjdk_auto_setup.ps1
```
User environment variable(s) created/affected:
```
JAVA_HOME   %UserProfile%\Downloads\programs\jdk-*\
PATH_TO_FX  %UserProfile%\Downloads\programs\javafx-*\lib\
PATH        ...;%JAVA_HOME%\bin\;
```
