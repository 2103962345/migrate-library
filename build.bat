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
if exist "%programfiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\15.0\Bin\MSBuild.exe" (
    set msbuild="%programfiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\15.0\Bin\MSBuild.exe"
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


REM Restore
:call "C:\temp\nuget.exe" restore Vehicle.sln
call "C:\temp\nuget.exe" restore "src\Car\packages.config" -OutputDirectory %cd%\packages -NonInteractive
call "C:\temp\nuget.exe" restore "tests\Car.Tests\packages.config" -OutputDirectory %cd%\packages -NonInteractive
:if not "%errorlevel%"=="0" goto failure

REM Build
call "%msbuild%" Vehicle.sln /p:Configuration="%config%" /m /v:M /fl /flp:LogFile=msbuild.log;Verbosity=Normal /nr:false
if not "%errorlevel%"=="0" goto failure

cd tests\Car.Tests
REM Unit tests
call "C:\temp\nuget.exe" install xunit.runner.console -Version 2.4.1 -OutputDirectory packages\xunit.runner.console.2.4.1\tools\net452\xunit.console.exe /config:%config% /framework:net-4.5 bin\%config%\Car.Tests.dll

cd ..\..

mkdir Build
call %nuget% pack "migrate-library\src\Car\Car.csproj" -symbols -o Build -p Configuration=%config% %version%
if not "%errorlevel%"=="0" goto failure

:success
exit 0

:failure
exit -1
