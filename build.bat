@echo Off
set config=%1
if "%config%" == "" (
    set config=Release
)

set version=
if not "%BuildCounter%" == "" (
   set packversionsuffix=--version-suffix ci-%BuildCounter%
)

REM Detect MSBuild 15.0 path
if exist "%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe" (
    set msbuild="%programfiles(x86)%\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
REM %msbuild%
)
if exist "%programfiles(x86)%\Microsoft Visual Studio\2019\Professional\MSBuild\15.0\Bin\MSBuild.exe" (
    set msbuild="%programfiles(x86)%\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\MSBuild.exe"
REM %msbuild%
)
if exist "%programfiles(x86)%\Microsoft Visual Studio\2019\Enterprise\MSBuild\15.0\Bin\MSBuild.exe" (
    set msbuild="%programfiles(x86)%\Microsoft Visual Studio\2019\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
REM %msbuild%
)

REM (optional) build.bat is in the root of our repo, cd to the correct folder where sources/projects are


echo Restore
call nuget restore Vehicle.sln
if not "%errorlevel%"=="0" goto failure

echo Build
call msbuild Vehicle.sln /p:Configuration="%config%" /m /v:M /fl /flp:LogFile=msbuild.log;Verbosity=Normal /nr:false
if not "%errorlevel%"=="0" goto failure

cd tests\Car.Tests
echo Unit tests
call nuget install xunit.runner.console -Version 2.4.1 -OutputDirectory packages 
packages\xunit.runner.console.2.4.1\tools\net47\xunit.console.exe bin\%config%\Car.Tests.dll

cd ..\..

echo Pack
mkdir Build
call nuget pack "src\Car\Car.csproj" -Symbols -OutputDirectory Build -Properties Configuration=%config%;version="%version%"
if not "%errorlevel%"=="0" goto failure

:success
exit 0

:failure
exit -1
