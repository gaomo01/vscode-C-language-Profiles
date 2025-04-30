@echo off
setlocal enabledelayedexpansion

REM Dynamically get code directory (ensure it ends with backslash)
set "CODE_DIR=%~dp1"
if not "%CODE_DIR:~-1%"=="\" set "CODE_DIR=%CODE_DIR%\"
echo CODE_DIR: %CODE_DIR%

REM Create temp directory if not exists
set "TEMP_DIR=%CODE_DIR%temp"
if not exist "%TEMP_DIR%" (
    mkdir "%TEMP_DIR%"
    echo Created temp directory: %TEMP_DIR%
)

REM Set environment variables
set "TMP=%TEMP_DIR%"
set "TEMP=%TEMP_DIR%"

REM Compiler paths (adjust based on your installation)
set "GCC_COMPILER=C:\msys64\ucrt64\bin\gcc.exe"
set "GPP_COMPILER=C:\msys64\ucrt64\bin\g++.exe"

REM Source and executable file paths
set "SOURCE_FILE=%~1"
set "EXE_FILE=%CODE_DIR%%~n1.exe"

echo SOURCE_FILE: %SOURCE_FILE%
echo EXE_FILE: %EXE_FILE%

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
"%COMPILER%" -g -Wall -Wextra -pedantic "%SOURCE_FILE%" -o "%EXE_FILE%"

REM Check compilation result
if %errorlevel% neq 0 (
    echo Compilation failed with error code: %errorlevel%
    timeout /t 2 /nobreak >nul
    exit /b %errorlevel%
)

REM Run the executable
echo Running %EXE_FILE%...
if exist "%EXE_FILE%" (
    "%EXE_FILE%"
) else (
    echo Error: No executable generated at "%EXE_FILE%"
    timeout /t 2 /nobreak >nul
    exit /b 1
)

REM Handle exit code
echo Program exited with code: %errorlevel%
timeout /t 2 /nobreak >nul
exit /b %errorlevel%
