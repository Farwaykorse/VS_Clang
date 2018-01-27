@echo off

echo Installing MSVC integration...
set /a "_SCount=0"
set /a "_FCount=0"


REM Set current directory to the location of this batch file.
pushd "%~dp0"

:: Legacy installations.
if defined ProgramFiles(x86) call :fn_legacy "%ProgramFiles(x86)%"
if not %ERRORLEVEL%==0 goto FINISHED
call :fn_legacy "%ProgramFiles%"
if not %ERRORLEVEL%==0 goto FINISHED
:: VS2017 (VC++ toolset v141) and later.
call :fn_vswhere

popd
goto FINISHED


:fn_legacy
:: Search for the VC toolsets == $(VCTargetsPath)
setlocal
if [%1]==[] echo DEBUG: fn_legacy - no input & goto:eof
set "_BaseDir=%~1"
:: VS2010 (v100)
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0"
:: VS2012 (v110)
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V110"
:: VS2013 (v120)
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V120"
:: VS2015 (v140)
call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V140"
endlocal & set "_SCount=%_SCount%" & set "_FCount=%_FCount%"
goto:eof


:fn_vswhere
:: Install integration for VS2017 and later.
:: Uses vswhere to find the install directories.
setlocal
if DEFINED ProgramFiles(x86) (
  set "_Vswhere=%ProgramFiles(x86)%") else (set "_Vswhere=%ProgramFiles%")
set _Vswhere="%_Vswhere%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist %_Vswhere% goto:eof
for /f "usebackq tokens=*" %%i in (
  `%_Vswhere% -all -prerelease -products * -property installationPath`
) do (
  :: Construct path equal to $(VCTargetsPath)
  call :fn_platforms "%%i\Common7\IDE\VC\VCTargets"
)
endlocal & set "_SCount=%_SCount%" & set "_FCount=%_FCount%"
goto:eof


:fn_platforms
:: Find supported platforms by folder name
setlocal
if [%1]==[] echo DEBUG: fn_platforms - no input & goto:eof
set "_VCTargetsPath=%~1"
if not exist "%_VCTargetsPath%\Platforms" goto:eof
setlocal EnableDelayedExpansion
for /f "usebackq tokens=*" %%P in (`dir "!_VCTargetsPath!\Platforms" /a:d /b`
) do (
  :: check for matching platform in LLVM install at .\
  if exist ".\%%P" (
    call :fn_toolsets "!_VCTargetsPath!\Platforms\%%P\PlatformToolsets" %%P
    if not !ERRORLEVEL!==0 set /a "_FCount+=1"
  )
)
endlocal & set "_SCount=%_SCount%" & set "_FCount=%_FCount%" &REM /EnableDelayedExpansion
endlocal & set "_SCount=%_SCount%" & set "_FCount=%_FCount%"
exit /b 0 &:: Contain ERRORLEVEL.


:fn_toolsets
:: Install Clang integration for each supported toolset that is present
setlocal DisableDelayedExpansion
if [%2]==[] echo DEBUG: fn_toolsets - no input & goto:eof
set "_ToolsetDir=%~1"
set "_Platform=%2"
:: Supported Toolsets
:: -------------- configurations --------------
:: Installing the v100 toolchain.
set   _MSname=v100           &REM folder names
set _LLVMname=LLVM-vs2010
set    _Props=Microsoft.Cpp.%_Platform%.LLVM-vs2010.props
set  _Targets=Microsoft.Cpp.%_Platform%.LLVM-vs2010.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets% "doNotRename")
if not %ERRORLEVEL%==0 goto:eof

:: Installing the v110 toolchain.
set   _MSname=v110
set _LLVMname=LLVM-vs2012
set    _Props=Microsoft.Cpp.%_Platform%.LLVM-vs2012.props
set  _Targets=Microsoft.Cpp.%_Platform%.LLVM-vs2012.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets% "doNotRename")
if not %ERRORLEVEL%==0 goto:eof
set   _MSname=v110_xp
set _LLVMname=Microsoft.Cpp.%_Platform%.LLVM-vs2012_xp
set    _Props=Microsoft.Cpp.%_Platform%.LLVM-vs2012_xp.props
set  _Targets=Microsoft.Cpp.%_Platform%.LLVM-vs2012_xp.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets% "doNotRename")
if not %ERRORLEVEL%==0 goto:eof

:: Installing the v120 toolchain.
set   _MSname=v120
set _LLVMname=LLVM-vs2013
set    _Props=toolset-vs2013.props
set  _Targets=toolset-vs2013.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets%)
if not %ERRORLEVEL%==0 goto:eof
set   _MSname=v120_xp
set _LLVMname=LLVM-vs2013_xp
set    _Props=toolset-vs2013_xp.props
set  _Targets=toolset-vs2013_xp.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets%)
if not %ERRORLEVEL%==0 goto:eof

:: Installing the v140 toolchain.
set   _MSname=v140
set _LLVMname=LLVM-vs2014
set    _Props=toolset-vs2014.props
set  _Targets=toolset-vs2014.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets%)
if not %ERRORLEVEL%==0 goto:eof
set   _MSname=v140_xp
set _LLVMname=LLVM-vs2014_xp
set    _Props=toolset-vs2014_xp.props
set  _Targets=toolset-vs2014_xp.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets%)
if not %ERRORLEVEL%==0 goto:eof

:: Installing the v141 toolchain.
set   _MSname=v141           &REM folder name
set _LLVMname=LLVM-vs2017    &REM folder name in .\
set    _Props=toolset-vs2017.props
set  _Targets=toolset-vs2017.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets%)
if not %ERRORLEVEL%==0 goto:eof
set   _MSname=v141_xp
set _LLVMname=LLVM-vs2017_xp
set    _Props=toolset-vs2017_xp.props
set  _Targets=toolset-vs2017_xp.targets
if exist "%_ToolsetDir%\%_MSname%" (
  call :fn_copy "%_ToolsetDir%" %_LLVMname% %_Platform% %_Props% %_Targets%)
if not %ERRORLEVEL%==0 goto:eof
:: --------------------------------------------
endlocal & set "_SCount=%_SCount%"
goto:eof


:fn_copy
:: Performs the copy operations
setlocal
:: arguments: 1 ToolsetDir, 2 Folder, 3 platform 4 .props, 5 .targets, 6 doNotRename
if [%5]==[] echo DEBUG: fn_copy - no input & goto:eof
if not exist %1 echo DEBUG: fn_copy - input error & goto:eof
if not exist ".\%3\%4" goto:eof &:: No LLVM config. for platform/toolset
echo Install: %2(%3)
set "_Dir=%~1\%2"
if not exist "%_Dir%" mkdir "%_Dir%" & echo make dir
if not %ERRORLEVEL%==0 goto:eof
if not [%6]==[] goto doNotRename
  if exist ".\%3\%4" copy %3\%4 "%_Dir%\toolset.props" > NUL
  if not %ERRORLEVEL%==0 goto:eof
  if exist ".\%3\%5" copy %3\%5 "%_Dir%\toolset.targets" > NUL
  if not %ERRORLEVEL%==0 goto:eof
goto CopyEnd
:doNotRename &:: VS2010 & VS2012
  if exist ".\%3\%4" copy %3\%4 "%_Dir%" > NUL
  if not %ERRORLEVEL%==0 goto:eof
  if exist ".\%3\%5" copy %3\%5 "%_Dir%" > NUL
  if not %ERRORLEVEL%==0 goto:eof
:CopyEnd
endlocal & set /a "_SCount+=1"
goto:eof


:: Status reports.
:FINISHED
if not %ERRORLEVEL%==0 echo ERROR: Internal script error.
if not %_FCount%==0 (
	echo WARNING: Copy operation failed for %_FCount% installations.
	echo:         Verify write access. (Run as administrator.^)
)
if %_SCount%==0 ( echo WARNING: Failed to install any toolset.
) else ( echo Installed integation for %_SCount% toolsets. )
echo Done!
goto:eof
