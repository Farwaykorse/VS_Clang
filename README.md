<!-------------------------------------------------------------><a id="top"></a>
# Clang Integration for Visual Studio, stand-alone
<!----------------------------------------------------------------------------->

Implementation to test an update for the LLVM/Clang integration.
To support Visual Studio 2017.

Target: Clang for Windows, stable release v5.0.1

For the progress on an LLVM patch and to report issues go to:
[Farwaykorse/llvm](https://github.com/Farwaykorse/llvm)  
*Note*: This version is for testing, and might contain changes not yet published
to the patch repository.


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
2. Restore the original configuration.
   `{LLVM instal dir.}\tools\msbuild\install.bat`


<!---------------------------------------------------------><a id="changes"></a>
## Changes
<!----------------------------------------------------------------------------->
- `install.bat` / `uninstall.bat`  
  - Total rewrite, to support user defined install locations for VS2017
    Using the [Visual Studio Locator Tool](https://github.com/Microsoft/vswhere)
  - Accepting other platform platform types, when defined,
    based on directory structure.
  - Only installing toolsets when the base MSVC toolset is installed.
  - Add basic progress reporting.
  - Apply redefined install method for older versions. (Needs more testing.)
  - This gist only: add `pause` to end of 
- `*.props` files
  - Add vs2017 versions.
  - Fixed `LibraryPath` version number.
- `*.targets` files
  - Add vs2017 versions.
  - For toolset versions 140(_xp) and 141_(xp), inherit from the Microsoft
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
