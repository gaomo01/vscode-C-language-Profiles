@echo off
setlocal enabledelayedexpansion

REM Dynamically get code directory
set "CODE_DIR=%~dp1"
set "TEMP_DIR=%CODE_DIR%temp"

REM Create temp directory if not exists
if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%"
    echo Created temp directory: %TEMP_DIR%
)

REM Set environment variables
set "TMP=%TEMP_DIR%"
set "TEMP=%TEMP_DIR%"

REM Get script directory
set "SCRIPT_PATH=%~dp0"

REM Compiler paths (adjust based on your installation)
set "GCC_COMPILER=C:\msys64\ucrt64\bin\gcc.exe"
set "GPP_COMPILER=C:\msys64\ucrt64\bin\g++.exe"

REM Source and executable file paths
set "SOURCE_FILE=%~1"
set "EXE_FILE=%~n1.exe"

REM Check if source file is provided
if "%SOURCE_FILE%"=="" (
    echo Error: No source file provided.
    echo Usage: debug_wrapper.bat "your_file.c" or "your_file.cpp"
    timeout /t 2 /nobreak >nul
    exit /b 1
)

REM Check if source file exists
if not exist "%SOURCE_FILE%" (
    echo Error: Source file "%SOURCE_FILE%" does not exist.
    timeout /t 2 /nobreak >nul
    exit /b 1
)

REM Select compiler based on file extension
set "FILE_EXT=%~x1"
if /i "%FILE_EXT%"==".c" (
    set "COMPILER=%GCC_COMPILER%"
) else (
    set "COMPILER=%GPP_COMPILER%"
)

REM Compile with dynamic temp directory
echo Using temp directory: %TEMP_DIR%
echo Compiling: %~nx1
"%COMPILER%" -B "%TEMP_DIR%" -g -Wall -Wextra -pedantic "%SOURCE_FILE%" -o "%EXE_FILE%"

REM Check compilation result
if %errorlevel% neq 0 (
    echo Compilation failed with error code: %errorlevel%
    timeout /t 2 /nobreak >nul
    exit /b %errorlevel%
)

REM Run
echo Running %EXE_FILE%...
if exist "%EXE_FILE%" (
    "%EXE_FILE%" %*
) else (
    echo No executable generated
    timeout /t 2 /nobreak >nul
    exit /b 1
)

REM Handle exit code
echo Exit code: %errorlevel%
timeout /t 2 /nobreak >nul
exit /b %errorlevel%