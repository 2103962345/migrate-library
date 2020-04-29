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
call dotnet restore
if not "%errorlevel%"=="0" goto failure

REM Build
:call "%msbuild%" MSTestMoqExample.sln /p:Configuration="%config%" /m /v:M /fl /flp:LogFile=msbuild.log;Verbosity=Normal /nr:false
call dotnet build --configuration %config%
if not "%errorlevel%"=="0" goto failure

cd tests\Car.Tests
REM Unit tests
call dotnet test 
if not "%errorlevel%"=="0" goto failure

cd ..\..
:REM Package
mkdir %cd%\..\artifacts
cd src\Car
call dotnet pack PrimeService --configuration %config% %packversionsuffix% --output %cd%\..\artifacts
if not "%errorlevel%"=="0" goto failure

:success
exit 0

:failure
exit -1
