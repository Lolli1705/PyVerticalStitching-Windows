@echo off

:: Software version

set PYTHON_VERSION=3.9.12

:: Check for Windows

if exist "%SystemDrive%\Program Files (x86)" (
	set PY_xBIT=-amd64
	set ZIP_xBIT=x64\
	set CURL_xBIT=win64\
	set xBIT=-amd64
	) else (
	set PY_xBIT=
	set ZIP_xBIT=
	set CURL_xBIT=win32\
	set xBIT=-386
	)

:: App Name

set APP_NAME=PyVerticalStitching

:: Git Info

set GIT_HOST=https://github.com/
set GIT_NAME=Lolli1705/
set REPO_NAME=PyVerticalStitching


:: Installer paths

set INSTALLER_DIR=%~dp0
set ERRORS_LOG=%INSTALLER_DIR%err.log
set PYSEG_DIR=%INSTALLER_DIR%%REPO_NAME%.zip

:: Installation Paths

set PYSEG_INSTALLATION_DIR=%SystemDrive%\Program Files\%APP_NAME%
set PYTHON_INSTALLATION_DIR=%PYSEG_INSTALLATION_DIR%\python
set APP_INSTALLATION_DIR=%PYSEG_INSTALLATION_DIR%\PyVerticalStitching-main\
set PYTHON_INSTALLER=%PYSEG_INSTALLATION_DIR%\python_installer.exe
set PYSEG_ICON=%PYSEG_INSTALLATION_DIR%\PyVerticalStitching-main\img\icon.ico
set REQ_PATH=%PYSEG_INSTALLATION_DIR%\PyVerticalStitching-main\requirements
set LOGO=%PYSEG_INSTALLATION_DIR%\PyVerticalStitching-main\img\PyStitching_logo.ico
set LAUNCHER=%PYSEG_INSTALLATION_DIR%\launcher.bat

:: Curl and 7z paths

set CURL=%INSTALLER_DIR%curl\%CURL_xBIT%bin\curl.exe
set ZIP=%INSTALLER_DIR%7z\%ZIP_xBIT%7za.exe
set PYSEG_LAUNCHER_LINK=%USERPROFILE%\Desktop\PyVerticalStitching.lnk

::Check if has admin privilege
net session >nul 2>&1
if not %errorLevel% == 0 (
	echo Run the installer as administrator
	pause
	exit /b 1
)




:: START OF THE INSTALLATION SCRIPT
:: ---------------------------------

echo\
echo This script will install:
echo - %APP_NAME% (at path %APP_INSTALLATION_DIR%)
echo - Python %PYTHON_VERSION% (at path %PYTHON_INSTALLATION_DIR%)





::INSTALL PREPARATION

call :install_preparation

call :install_pyseg

call :install_python

call :install_py_requirements

call :install_finalizing


echo Installation completed successfully!
pause
exit /b 0

:install_preparation


echo/
echo Prepare installation
echo --------------------

::Create PySegmentation installation folder
echo [INFO] - Creating %APP_NAME% installation folder...
mkdir "%PYSEG_INSTALLATION_DIR%" > nul 2>>"%ERRORS_LOG%"
if not %errorlevel% == 0 (
	echo [ FAIL ] - Failed to create %APP_NAME% installation folder
	exit /b %errorlevel%
)

echo [ OK ] - Ready for the installation
exit /b %errorlevel%


:install_pyseg

::Download PySegmentation
echo [ INFO ] - Downloading %APP_NAME% ...

"%CURL%" -L -o "%PYSEG_DIR%" "%GIT_HOST%%GIT_NAME%%REPO_NAME%/archive/refs/heads/main.zip"

::Extract PySegmentation
echo [ INFO ] - Extracting %APP_NAME% archive...

"%ZIP%" x "%PYSEG_DIR%" -o"%PYSEG_INSTALLATION_DIR%" > nul 2>>"%ERRORS_LOG%"
if not %errorlevel% == 0 (
	echo [ FAIL ] - Failed to extract the %APP_NAME% archive
	exit /b %errorlevel%
)

::Remove the archived required software
echo [ INFO ] - Removing %APP_NAME% archive...
if exist "%PYSEG_DIR%" (
	del "%PYSEG_DIR%"> nul 2>>"%ERRORS_LOG%"
)
if exist "%PYSEG_DIR%" (
	if not %errorlevel% == 0 (
		echo [ FAIL ] - Failed remove %APP_NAME% archive
		exit /b %errorlevel%
	)
)


exit /b %errorlevel%


:install_python

echo/
echo Python installation
echo -------------------

::Download installer
echo [ INFO ] - Downloading python installer...
set py_installer_link=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%%PY_xBIT%.exe

"%CURL%" -s -o "%PYTHON_INSTALLER%" "%py_installer_link%"

if not %errorlevel% == 0 (
	echo [ FAIL ] - Failed to download python installer from this link "%py_installer_link%"
	exit /b %errorlevel%
)

echo [ OK ] - Python installer downloaded

::Execute the python installer

echo [ INFO ] - Installing Python (version %PYTHON_VERSION%)...
"%PYTHON_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=0 Include_test=0 Include_pip=1 Include_launcher=0 InstallLauncherAllUsers=0 DefaultJustForMeTargetDir="%PYTHON_INSTALLATION_DIR%" > nul 2>>"%ERRORS_LOG%"

if %errorlevel% == 0 (
	echo [ OK ] - Python ^(version %PYTHON_VERSION%^) installed
) else (
	echo [ FAIL ] - Failed to install Python ^(version %PYTHON_VERSION%^)
)

exit /b %errorlevel%

:install_py_requirements

echo/
echo Python modules installation
echo ---------------------------
:: "%INSTALLER_DIR%requirements"
::Install python modules (pip)
echo [ INFO ] - Installing python modules...
"%PYTHON_INSTALLATION_DIR%\python.exe" -m pip -q install -r "%APP_INSTALLATION_DIR%requirements" > nul 2>>"%ERRORS_LOG%"
if %errorlevel% == 0 (
	echo [ OK ] - Python modules installed
) else (
	echo [ FAIL ] - Failed to install python modules
)

exit /b %errorlevel%

:install_finalizing

echo/
echo Finalize installation
echo ---------------------

::Set launcher
(
	echo /
	echo /
	echo start  "%APP_NAME%" "%PYTHON_INSTALLATION_DIR%\pythonw.exe" "%PYSEG_INSTALLATION_DIR%\PyVerticalStitching-main\main.py"
) >> "%LAUNCHER%"

::Create launcher link on Desktop
echo [ INFO ] - Creating %APP_NAME% link on Desktop...
set MKLINK_SCRIPT="%USERPROFILE%\Desktop\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %MKLINK_SCRIPT%
echo sLinkFile = "%PYSEG_LAUNCHER_LINK%" >> %MKLINK_SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %MKLINK_SCRIPT%
echo oLink.TargetPath = "%LAUNCHER%" >> %MKLINK_SCRIPT%
echo oLink.IconLocation = "%LOGO%" >> %MKLINK_SCRIPT%
echo oLink.Save >> %MKLINK_SCRIPT%
cscript %MKLINK_SCRIPT% /nologo %MKLINK_SCRIPT% > nul 2>>"%ERRORS_LOG%"
if %errorlevel% == 0 (
	echo [ OK ] - %APP_NAME% link created
) else (
	echo [ FAIL ] - Failed to create %APP_NAME%
	exit /b %errorlevel%
)

del %MKLINK_SCRIPT%
exit /b 0