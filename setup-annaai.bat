@echo off
REM setup-annaai.bat - Run AnnaAI Setup Script
REM Created by Annie Love of Blue

cls
echo ============================================
echo   AnnaAI Setup Script
echo   Created by Annie Love of Blue
echo ============================================
echo.
echo Starting AnnaAI setup...
echo.
echo This will install Ollama, Julia packages, and set up AnnaAI.
echo.

REM Check if Julia is available
julia --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Julia is not installed or not in PATH.
    echo Please install Julia from https://julialang.org/downloads/
    echo.
    pause
    exit /b 1
)

echo Running setup script...
echo.

REM Run the Julia setup script
julia scripts/setup.jl

echo.
echo Setup script completed.
echo.
echo Press any key to exit...
pause >nul
