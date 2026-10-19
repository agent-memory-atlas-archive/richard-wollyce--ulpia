@echo off
setlocal enabledelayedexpansion

REM install.bat: copy the release binary from target\release\ into tools\kb\bin\.
REM
REM   cargo build --release --manifest-path tools\kb\Cargo.toml
REM   tools\kb\install.bat
REM
REM Uses rename-aside so running MCP servers holding kb.exe open do not block installation.

set "HERE=%~dp0"
set "SRC=%HERE%target\release\kb.exe"
set "DEST_DIR=%HERE%bin"
set "DEST=%DEST_DIR%\kb.exe"

if "%~1"=="-h" goto help
if "%~1"=="--help" goto help

if not exist "%SRC%" (
    echo install: nothing to install. Build it first: >&2
    echo. >&2
    echo   cargo build --release --manifest-path tools\kb\Cargo.toml >&2
    echo. >&2
    exit /b 1
)

if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%" || exit /b 1
)

if exist "%DEST%" (
    set "ASIDE=%DEST_DIR%\kb.exe.replaced.%RANDOM%"
    move /y "%DEST%" "!ASIDE!" >nul 2>&1
    if errorlevel 1 (
        echo install: could not move the installed binary aside. Nothing changed. >&2
        exit /b 1
    )
)

copy /y "%SRC%" "%DEST%" >nul 2>&1
if errorlevel 1 (
    if defined ASIDE (
        move /y "!ASIDE!" "%DEST%" >nul 2>&1
    )
    echo install: could not copy the new binary into place. The previous one is back. >&2
    exit /b 1
)

REM Cross-platform parity: also provide bin\kb
copy /y "%DEST%" "%DEST_DIR%\kb" >nul 2>&1

if defined ASIDE (
    del /f /q "!ASIDE!" >nul 2>&1
    if exist "!ASIDE!" (
        echo install: a process is still running the previous build, left at !ASIDE!
    )
)

echo installed %SRC% -^> %DEST%
"%DEST%" --version
exit /b 0

:help
echo install: copy the release binary from target\release\ into tools\kb\bin\.
echo.
echo   cargo build --release --manifest-path tools\kb\Cargo.toml
echo   tools\kb\install.bat
echo.
echo tools\kb\bin\ is the path .mcp.json and tracked configs name.
exit /b 0
