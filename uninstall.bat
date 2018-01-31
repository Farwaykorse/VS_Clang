::===-- msbuild/uninstall.bat - Clang Integration in MSBuild --------------===::
::
::                     The LLVM Compiler Infrastructure
::
:: This file is distributed under the University of Illinois Open Source
:: License. See LICENSE.TXT for details.
::
::===----------------------------------------------------------------------===::
::
:: This file is an executable script for use on Microsoft Windows.
:: Calling the accompaning install.bat, to remove the LLVM/Clang-CL
:: configuration files from the directory structure of Microsoft Visual Studio.
::
::===----------------------------------------------------------------------===::
@echo off
pushd "%~dp0" &REM Set current directory to the location of this batch file.

if exist install.bat (call .\install.bat --uninstall
) else (
  echo ERROR: File not found:
  echo:       %~dp0install.bat
)
popd
exit /b
