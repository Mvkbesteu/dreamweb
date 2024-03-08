@shift /0
@echo off
setlocal enabledelayedexpansion
chcp 65001
mode 50, 25
set color1=[38;2;59;120;254m
set color2=[38;2;58;149;220m
set text=[38;2;170;170;170m
set red=[38;2;157;7;7m

:: Get the Hardware ID using Windows Management Instrumentation (WMIC)
for /f "tokens=2 delims==" %%A in ('wmic csproduct get uuid /value') do (
    set "HWID=%%A"
)

:: Trim any leading or trailing spaces
set "HWID=!HWID:~0,-1!"

:: Save only the first 8 characters of the HWID
set "HWID=!HWID:~0,28!"


rem SET PATH
set main.path=
cd %main.path%
rem set your path above.

:: Colorcodes
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")
:: Check for administrative privileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' (
    goto :pycheck
) else (
    echo You must run this script as an administrator.
    echo Please restart the dream with administrative privileges.
    pause
    exit /b
)

:pycheck

rem Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed. Installing...
    
    rem Download and install the latest version of Python
    powershell -Command "(New-Object Net.WebClient).DownloadFile('https://www.python.org/ftp/python/latest/python-x64.exe', '%temp%\python-x64.exe')"
    if %errorlevel% neq 0 (
        echo Failed to download Python installer. Please check your internet connection or try again later.
        exit /b 1
    )
    
    echo Installing Python...
    start /wait %temp%\python-x64.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    if %errorlevel% neq 0 (
        echo Failed to install Python.
        pause>nul
        exit /b 1
    )
    
    echo Python has been installed successfully.
    rem Cleanup downloaded Python installer
    del /q %temp%\python-x64.exe
    goto requirements
) else (
    echo Python is already installed.
    rem Cleanup downloaded Python installer
    del /q %temp%\python-x64.exe
    goto requirements
)

:requirements

rem Check if FastAPI and uvicorn are installed
python -c "import pkgutil; exit(0 if pkgutil.find_loader('fastapi') and pkgutil.find_loader('uvicorn') else 1)"
if %errorlevel% equ 0 (
    echo FastAPI and uvicorn are already installed. Skipping installation.
) else (
    echo Installing FastAPI and uvicorn from requirements.txt...
    pip install -r requirements.txt
    if %errorlevel% neq 0 (
        echo Failed to install FastAPI and uvicorn.
        ping localhost -n 3 >nul
        exit /b 1
    )
    echo FastAPI and uvicorn have been installed successfully.
    ping localhost -n 3 >nul
    goto menu
)

:menu
cls
echo.  [38;2;59;120;254m
echo.  ██████╗ ██████╗ ███████╗ █████╗ ███╗   ███╗
echo.  ██╔══██╗██╔══██╗██╔════╝██╔══██╗████╗ ████║
echo.  ██║  ██║██████╔╝█████╗  ███████║██╔████╔██║
echo.  ██║  ██║██╔══██╗██╔══╝  ██╔══██║██║╚██╔╝██║
echo.  ██████╔╝██║  ██║███████╗██║  ██║██║ ╚═╝ ██║
echo.  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
echo. %color2%█-%text%Establishing connection with server...   
set /p "choice=%DEL% %color1%%color2%█-%text%Username:%red% "
ping localhost -n 3 >nul
echo. %color2%█-%text%Password: ******
echo. %color2%█-%text%HWID Detected: %hwid%
echo. %color2%█-%text%Welcome back [admin] %choice%
ping localhost -n 1 >nul
echo. %color2%█-%text%Server connected to [4m[38;2;0;200;9mlocalhost:5555[0m
start server.bat
start http://localhost:5555/dashboard
ping localhost -n 99999999999999999999999999999999999999999999999999999999999 >nul
