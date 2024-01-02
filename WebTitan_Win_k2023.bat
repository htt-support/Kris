@echo off

:: Check for administrative privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    timeout /t 3 >nul
    cscript "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" (
        del "%temp%\getadmin.vbs"
    )
    pushd "%CD%"
    CD /D "%~dp0"

:: Download the zip file using PowerShell
PowerShell.exe -Command "Invoke-WebRequest -Uri https://hilltowntech.com/wp-content/uploads/2023/10/otg2_setup.zip -OutFile otg2_setup.zip"

:: Extract the zip file using PowerShell
PowerShell.exe -Command "Expand-Archive -Path otg2_setup.zip -DestinationPath otg2_setup"

:: Define the paths for the MSI and certificate
set msiFilePath=otg2_setup\otg2_setup.msi
set certFilePath=otg2_setup\ca.der

:: Install the MSI
msiexec /i "%msiFilePath%" /qn /passive /L* wt_installer_log.log RPC_URL=hilltowntech.webtitancloud.com:7771 INSTALL_KEY=88d0c6f2-e240-426a-a946-efaf71caf4b9

:: Import the certificate
certutil -f -addstore CA "%certFilePath%"

:: Optionally, remove the downloaded and extracted files
:: del otg2_setup.zip
:: rd /s /q otg2_setup

:: Exit
exit /B
