::===-- msbuild/install.bat - Clang Integration in MSBuild ----------------===::
::
::                     The LLVM Compiler Infrastructure
::
:: This file is distributed under the University of Illinois Open Source
:: License. See LICENSE.TXT for details.
::
::===----------------------------------------------------------------------===::
::
:: This file is an executable script for use on Microsoft Windows.
:: Providing the installation and removal of the configuration files,
:: required to support the integration of LLVM/Clang-CL, in the directory
:: structure of Microsoft Visual Studio.
::
::===----------------------------------------------------------------------===::
@echo off
setlocal
pushd "%~dp0" & REM Set current directory to the location of this batch file.
if /i [%1]==[--uninstall] ( set _Uninstall=1
  echo Uninstalling MSVC integration...
) else (
  if not [%1]==[] echo ERROR: Unknown input parameter. & exit /b 1
  echo Installing MSVC integration...
)
set /a "_SuccessCnt=0"
set /a "_FailCnt=0"

:: Legacy installations. Detection by explicit directory structure.
if defined ProgramFiles(x86) call :fn_legacy "%ProgramFiles(x86)%"
if not %ERRORLEVEL%==0 goto FINISHED
call :fn_legacy "%ProgramFiles%"
if not %ERRORLEVEL%==0 goto FINISHED
:: VS2017 (VC++ toolset v141) and later.
call :fn_vswhere

:FINISHED
if not %ERRORLEVEL%==0 echo ERROR: Internal script error.
if not defined _Uninstall (
  if not %_FailCnt%==0 (
    echo WARNING: Copy operation failed for %_FailCnt% installations.
    echo:         Verify write access. (Run as administrator.^)
  )
  if %_SuccessCnt%==0 ( echo WARNING: Failed to install any toolset.
  ) else ( echo Installed integation for %_SuccessCnt% toolsets. )
  goto END_ALL
)
set /a "_Removed=_SuccessCnt - _FailCnt"
echo Removed %_Removed% of %_SuccessCnt% LLVM configurations.

:END_ALL
echo Done!
popd & REM Reset current directory.
endlocal
pause
exit /b

::===----------------------------------------------------------------------===::
:: Function Definitions
::===----------------------------------------------------------------------===::

:: Try known values for $(VCTargetsPath) to find MSVC toolsets.
:fn_legacy
setlocal
  if [%1]==[] echo ERROR: fn_legacy - no input & goto:eof
  set "_BaseDir=%~1"
  :: VS2010 (v100).
  call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0"
  :: VS2012 (v110).
  call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V110"
  :: VS2013 (v120).
  call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V120"
  :: VS2015 (v140).
  call :fn_platforms "%_BaseDir%\MSBuild\Microsoft.Cpp\v4.0\V140"
endlocal & set "_SuccessCnt=%_SuccessCnt%" & set "_FailCnt=%_FailCnt%"
goto:eof

:: Find MSVC toolsets since VS2017 with the Visual Studio Locator tool.
:fn_vswhere
setlocal
  if DEFINED ProgramFiles(x86) (
    set "_Vswhere=%ProgramFiles(x86)%") else (set "_Vswhere=%ProgramFiles%")
  set _Vswhere="%_Vswhere%\Microsoft Visual Studio\Installer\vswhere.exe"
  if not exist %_Vswhere% goto:eof
  for /f "usebackq tokens=*" %%i in (
    `%_Vswhere% -all -prerelease -products * -property installationPath`
  ) do ( REM Construct path equal to $(VCTargetsPath).
    echo Found VS: %%i
    call :fn_platforms "%%i\Common7\IDE\VC\VCTargets"
  )
endlocal & set "_SuccessCnt=%_SuccessCnt%" & set "_FailCnt=%_FailCnt%"
goto:eof

:: Find supported platforms by folder name.
:fn_platforms
setlocal
  if [%1]==[] echo ERROR: fn_platforms - no input & goto:eof
  set "_VCTargetsPath=%~1"
  if not exist "%_VCTargetsPath%\Platforms" goto:eof
  setlocal EnableDelayedExpansion
  for /f "usebackq tokens=*" %%P in (`dir "!_VCTargetsPath!\Platforms" /a:d /b`
  ) do (
    if exist ".\%%P" (
      if not defined _Uninstall (
        call :fn_toolsets "!_VCTargetsPath!\Platforms\%%P\PlatformToolsets" %%P
      ) else (
        call :fn_remove "!_VCTargetsPath!\Platforms\%%P\PlatformToolsets" %%P
      )
      if not !ERRORLEVEL!==0 set /a "_FailCnt+=1"
    )
  )
  endlocal & ( REM /EnableDelayedExpansion
           set "_SuccessCnt=%_SuccessCnt%" & set "_FailCnt=%_FailCnt%" )
endlocal & set "_SuccessCnt=%_SuccessCnt%" & set "_FailCnt=%_FailCnt%"
exit /b 0 & REM Contain ERRORLEVEL.

:: Install Clang integration for each supported toolset that is present.
:fn_toolsets
setlocal DisableDelayedExpansion
  if [%2]==[] echo ERROR: fn_toolsets - no input & goto:eof
  set "_ToolsetDir=%~1"
  set "_Platform=%~2"
  ::===---------- configurations ------------------------------------------===::
  :: _Name      Name for the LLVM toolset.
  :: _Props     Predefined property file.
  :: _Targets   Predefined targets file.
  :: _NoRename  Set to TRUE to keep the predefined file names. (v100, v110)

  :: Installing the v100 toolchain.
  setlocal
    set     _Name=LLVM-vs2010
    set    _Props=Microsoft.Cpp.%_Platform%.LLVM-vs2010.props
    set  _Targets=Microsoft.Cpp.%_Platform%.LLVM-vs2010.targets
    set _NoRename=TRUE
    if exist "%_ToolsetDir%\v100" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof

  :: Installing the v110 toolchain.
  setlocal
    set     _Name=LLVM-vs2012
    set    _Props=Microsoft.Cpp.%_Platform%.LLVM-vs2012.props
    set  _Targets=Microsoft.Cpp.%_Platform%.LLVM-vs2012.targets
    set _NoRename=TRUE
    if exist "%_ToolsetDir%\v110" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof
  :: Installing the v110_xp toolchain.
  setlocal
    set    _Name=LLVM-vs2012_xp
    set   _Props=Microsoft.Cpp.%_Platform%.LLVM-vs2012_xp.props
    set _Targets=Microsoft.Cpp.%_Platform%.LLVM-vs2012_xp.targets
    set _NoRename=TRUE
  if exist "%_ToolsetDir%\v110_xp" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof

  :: Installing the v120 toolchain.
  setlocal
    set    _Name=LLVM-vs2013
    set   _Props=toolset-vs2013.props
    set _Targets=toolset-vs2013.targets
    if exist "%_ToolsetDir%\v120" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof
  :: Installing the v120_xp toolchain.
  setlocal
    set    _Name=LLVM-vs2013_xp
    set   _Props=toolset-vs2013_xp.props
    set _Targets=toolset-vs2013_xp.targets
    if exist "%_ToolsetDir%\v120_xp" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof

  :: Installing the v140 toolchain.
  setlocal
    set    _Name=LLVM-vs2014
    set   _Props=toolset-vs2014.props
    set _Targets=toolset-vs2014.targets
    if exist "%_ToolsetDir%\v140" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof
  :: Installing the v140_xp toolchain.
  setlocal
    set    _Name=LLVM-vs2014_xp
    set   _Props=toolset-vs2014_xp.props
    set _Targets=toolset-vs2014_xp.targets
    if exist "%_ToolsetDir%\v140_xp" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof

  :: Installing the v141 toolchain.
  setlocal
    set    _Name=LLVM-vs2017
    set   _Props=toolset-vs2017.props
    set _Targets=toolset-vs2017.targets
    if exist "%_ToolsetDir%\v141" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof
  :: Installing the v141_xp toolchain.
  setlocal
    set    _Name=LLVM-vs2017_xp
    set   _Props=toolset-vs2017_xp.props
    set _Targets=toolset-vs2017_xp.targets
    if exist "%_ToolsetDir%\v141_xp" call :fn_copy
  endlocal & set "_SuccessCnt=%_SuccessCnt%" & if not %ERRORLEVEL%==0 goto:eof
  ::===--------------------------------------------------------------------===::
endlocal & set "_SuccessCnt=%_SuccessCnt%"
goto:eof

:: Perform the copy operations.
:fn_copy
setlocal
  if not defined _ToolsetDir goto:eof
  if not defined _Props goto:eof
  if not defined _Targets goto:eof
  if not defined _Name goto:eof

  echo:  %_Name% (%_Platform%)
  set _PropsFile=".\%_Platform%\%_Props%"
  set _TargetsFile=".\%_Platform%\%_Targets%"
  set "_Dir=%_ToolsetDir%\%_Name%"

  if not exist "%_Dir%" mkdir "%_Dir%"
  if not %ERRORLEVEL%==0 goto:eof
  if [%_NoRename%]==[TRUE] goto doNotRename
    if exist %_PropsFile% copy %_PropsFile% "%_Dir%\toolset.props" > NUL
    if not %ERRORLEVEL%==0 goto:eof
    if exist %_TargetsFile% copy %_TargetsFile% "%_Dir%\toolset.targets" > NUL
    if not %ERRORLEVEL%==0 goto:eof
  goto CopyEnd
  :doNotRename & REM VS2010 and VS2012.
    if exist %_PropsFile% copy %_PropsFile% "%_Dir%" > NUL
    if not %ERRORLEVEL%==0 goto:eof
    if exist %_TargetsFile% copy %_TargetsFile% "%_Dir%" > NUL
    if not %ERRORLEVEL%==0 goto:eof
  :CopyEnd
endlocal & set /a "_SuccessCnt+=1"
goto:eof

:: Remove toolset configurations that follow the LLVM naming format.
:fn_remove
setlocal DisableDelayedExpansion
  if [%2]==[] echo ERROR: fn_remove - no input & goto:eof
  set "_ToolsetDir=%~1"
  set "_Platform=%2"
  if not exist "%_ToolsetDir%\LLVM-*" goto:eof
  setlocal EnableDelayedExpansion
  for /f "usebackq tokens=*" %%D in (`dir "!_ToolsetDir!\LLVM-*" /a:d /b`) do (
    set /a "_SuccessCnt+=1"
    set _File="!_ToolsetDir!\%%D\toolset.props"
    if exist !_File! del !_File! > NUL
    set _File="!_ToolsetDir!\%%D\toolset.targets"
    if exist !_File! del !_File! > NUL
    :: VS2010 and VS2012:
    set _File="!_ToolsetDir!\%%D\Microsoft.Cpp.%_Platform%.LLVM-vs201*.props"
    if exist !_File! del !_File! > NUL
    set _File="!_ToolsetDir!\%%D\Microsoft.Cpp.%_Platform%.LLVM-vs201*.targets"
    if exist !_File! del !_File! > NUL
    :: Remove folder if empty, else report.
    rmdir "!_ToolsetDir!\%%D" || (echo !_ToolsetDir!\%%D & set /a "_FailCnt+=1")
  )
  endlocal & ( REM /EnableDelayedExpansion
           set "_SuccessCnt=%_SuccessCnt%" & set "_FailCnt=%_FailCnt%" )
endlocal & set "_SuccessCnt=%_SuccessCnt%" & set "_FailCnt=%_FailCnt%"
exit /b 0 & REM Contain ERRORLEVEL.
