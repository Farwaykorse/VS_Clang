<!-------------------------------------------------------------><a id="top"></a>
# Clang Integration for Visual Studio, stand-alone
<!----------------------------------------------------------------------------->
Users of VS2017 (and later) should try the Visual Studio extension
[LLVM Compiler Toolchain](https://marketplace.visualstudio.com/items?itemName=LLVMExtensions.llvm-toolchain).
It is more configurable, contains some bug-fixes and is supported by LLVM.

Users of VS2015 and earlier, or who want to compile with LLVM/Clang using the
older toolsets, can try this implementation.
Or try extracting the new implementation, see a
[solution by CFSworks at stackoverflow](https://stackoverflow.com/a/52582414/2504346)

This is an reimplementation of the legacy integration method, as used by the
LLVM installer up to v6.0.1.
Originally created to test an update for the LLVM/Clang integration, adding
support for Visual Studio 2017.

This adds LLVM toolset configurations for any installed legacy toolsets since
VS2010 (including the Windows XP toolsets).
Allowing building these toolset with the targeted version of LLVM/Clang.

Target: Clang for Windows, stable release **v6.0.1**  

Expected to work with:  
Visual Studio versions: VS2010, VS2013, VS2015 and VS2017.  
Visual C++ Build Tools: 2017 and 2015.


<!----------------------------------------------------><a id="instructions"></a>
## Instructions
<!----------------------------------------------------------------------------->
### Installation
1. Extract all files in an empty directory.
2. Run `install.bat`.
   As Administrator when needed. The script requires write access to the
   MSBuild and VS2017 install directories.
   *Note*: Currently the install script stops on the first error.

### Removal
1. Run the supplied `uninstall.bat` (as Administrator, when needed.)
2. (For LLVM v6.01 and earlier) Restore the original configuration.
   `{LLVM install dir.}\tools\msbuild\install.bat`


<!---------------------------------------------------------><a id="changes"></a>
## Changes
<!----------------------------------------------------------------------------->
- `install.bat` / `uninstall.bat`  
  - Total rewrite, to support user defined install locations for VS2017
    Using the [Visual Studio Locator Tool](https://github.com/Microsoft/vswhere)
  - Accepting other platform types, when defined,
    based on directory structure.
  - Only installing toolsets when the base MSVC toolset is installed.
  - Apply redefined install method for older versions. *(Needs more testing.)*
  - Use `pushd` and `popd` to switch the working directory back when the
    script finishes.
  - On a copy error, try for the next VS installation.
    This allows for installs and updates without admin rights.
    E.g. when VS2017 is installed on a users' personal drive.
  - Combined the install and uninstall script.
    Reducing code duplication, from the shared path generation.
  - Improved progress reporting.
- `*.props` files
  - Add vs2017 versions.
  - Fixed `LibraryPath` version number.
- `*.targets` files
  - Add vs2017 versions.
  - For toolset versions `140(_xp)` and `141_(xp)`, inherit from the Microsoft
    supplied configuration, to stay up to date. (As the `*.props` do.)
  - *Note*: no changes have been made to the files for older compilers.
    These have been included for proper operation of the install script.


<!---------------------------------------------------------><a id="license"></a>
## License
<!----------------------------------------------------------------------------->
This project contains code from, and based on the LLVM project.

LLVM is open source software. You may freely distribute it under the terms of
the license agreement found in LICENSE.TXT.



-----------
[Top](#top)
