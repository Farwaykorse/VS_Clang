@echo off

echo Uninstalling MSVC integration...

REM Set current directory to the location of this batch file.
pushd "%~dp0"

:: Legacy installations.
if defined ProgramFiles(x86) call :fn_legacy "%ProgramFiles(x86)%"
call :fn_legacy "%ProgramFiles%"
:: VS2017 (VC++ toolset v141) and later.
call :fn_vswhere

echo Done!
popd
exit /b

::===----------------------------------------------------------------------===::
:: Function Definitions
::===----------------------------------------------------------------------===::

:fn_legacy
:: Try known values for $(VCTargetsPath) to find MSVC toolsets.
setlocal
if [%1]==[] echo DEBUG: fn_legacy - no input & goto:eof
set "_BaseDir=%~1"
:: VS2010 (v100).
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0"
:: VS2012 (v110).
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V110"
:: VS2013 (v120).
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V120"
:: VS2015 (v140).
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V140"
endlocal
goto:eof


:fn_vswhere
:: Remove integration since VS2017. Using the Visual Studio Locator tool.
setlocal
if DEFINED ProgramFiles(x86) (
  set "_VSWhere=%ProgramFiles(x86)%") else (set "_VSWhere=%ProgramFiles%")
set _VSWhere="%_VSWhere%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist %_VSWhere% goto:eof
for /f "usebackq tokens=*" %%i in (
  `%_VSWhere% -all -prerelease -products * -property installationPath`
) do ( :: Construct path equal to $(VCTargetsPath).
  call :fn_platforms "%%i\Common7\IDE\VC\VCTargets"
)
endlocal
goto:eof


:fn_platforms
:: Find supported platforms by folder name.
setlocal
if [%1]==[] echo DEBUG: fn_platforms - no input & goto:eof
set "_VCTargetsPath=%~1"
if not exist "%_VCTargetsPath%\Platforms" goto:eof
for /f "usebackq tokens=*" %%P in (`dir "%_VCTargetsPath%\Platforms" /a:d /b`
) do (
  if exist ".\%%P" (
    call :fn_remove "%_VCTargetsPath%\Platforms\%%P\PlatformToolsets"
  )
)
endlocal
goto:eof


:fn_remove
:: Remove integrations that follow the LLVM naming format.
setlocal
if [%1]==[] echo DEBUG: fn_remove: no input & goto:eof
set "_ToolsetDir=%~1"
set "_Platform=%~2"
if not exist "%_ToolsetDir%\LLVM-*" goto:eof
setlocal EnableDelayedExpansion
for /f "usebackq tokens=*" %%D in (`dir "%_ToolsetDir%\LLVM-*" /a:d /b`) do (
  echo "%_ToolsetDir%\%%D"
  set _File="%_ToolsetDir%\%%D\toolset.props"
  if exist !_File! del !_File!
  set _File="%_ToolsetDir%\%%D\toolset.targets"
  if exist !_File! del !_File!
  :: For VS2010 / VS2012.
  set _File="%_ToolsetDir%\%%D\Microsoft.Cpp.%_Platform%.LLVM-vs201*.props"
  if exist !_File! del !_File!
  set _File="%_ToolsetDir%\%%D\Microsoft.Cpp.%_Platform%.LLVM-vs201*.targets"
  if exist !_File! del !_File!
  :: Remove folder, if empty
  rmdir "%_ToolsetDir%\%%D"
)
endlocal &REM /EnableDelayedExpansion
endlocal
goto:eof
