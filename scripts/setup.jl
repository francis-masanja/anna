# setup.jl - AnnaAI Setup Script for Windows
# This script helps set up AnnaAI with Ollama on Windows
# Run this in PowerShell or Command Prompt with: julia setup.jl

using Downloads
using Base: UUID
using Pkg

println("=" ^ 60)
println("  AnnaAI Setup Script for Windows")
println("  Created by Annie Love of Blue")
println("=" ^ 60)
println()

# Colors for output (Windows-compatible)
const COLORS = Dict{String,String}(
    "reset" => "\033[0m",
    "green" => "\033[32m",
    "yellow" => "\033[33m",
    "cyan" => "\033[36m",
    "bright_green" => "\033[92m",
)

colorize(text::String, color::String) = COLORS[color] * text * COLORS["reset"]

function print_status(msg::String)
    println("  " * colorize("✓", "bright_green") * " $msg")
end

function print_warning(msg::String)
    println("  " * colorize("⚠", "yellow") * " $msg")
end

function print_info(msg::String)
    println("  " * colorize("ℹ", "cyan") * " $msg")
end

# Helper function to run shell commands
function run_cmd(cmd::String)
    try
        run(`cmd /c $cmd`)
        return true
    catch e
        return false
    end
end

# Step 1: Check Julia version
println(colorize("Step 1: Checking Julia installation...", "cyan"))
try
    v = VERSION
    if v.major >= 1 && v.minor >= 9
        print_status("Julia $v is installed")
    else
        print_warning("Julia version $v may be older than expected")
    end
catch e
    print_warning("Could not determine Julia version")
end
println()

# Step 2: Check for Ollama
println(colorize("Step 2: Checking for Ollama...", "cyan"))
ollama_installed = false
try
    ollama_path = Sys.which("ollama")
    if ollama_path !== nothing
        print_status("Ollama is installed")
        ollama_installed = true
    else
        # Check common installation paths
        program_files_ollama = joinpath(ENV["PROGRAMFILES"], "Ollama", "ollama.exe")
        local_appdata_ollama = joinpath(ENV["LOCALAPPDATA"], "Ollama", "ollama.exe")

        if isfile(program_files_ollama) || isfile(local_appdata_ollama)
            print_status("Ollama is installed")
            ollama_installed = true
        else
            print_warning("Ollama not found")
            println()
            print_info("Downloading Ollama for Windows...")
            println()

            ollama_url = "https://ollama.com/download/OllamaSetup.exe"
            ollama_installer = joinpath(pwd(), "OllamaSetup.exe")

            try
                println("  Downloading Ollama from: $ollama_url")
                Downloads.download(ollama_url, ollama_installer)
                print_status("Ollama installer downloaded: $ollama_installer")
                println()
                print_info("Installing Ollama...")
                println()
                run_cmd("\"$ollama_installer\" /S")
                print_status("Ollama installed successfully")
                ollama_installed = true

                # Give Ollama a moment to start
                print_info("Waiting for Ollama service to start...")
                sleep(3)
            catch e
                print_warning("Could not download/install Ollama automatically")
                print_info("Please download manually from: https://ollama.com")
            end
        end
    end
catch e
    print_warning("Error checking for Ollama: $e")
end
println()

# Step 3: Install Julia packages
println(colorize("Step 3: Installing Julia packages...", "cyan"))
println()
print_info("Installing required packages...")

packages = ["HTTP", "JSON", "Dates", "julia_agent", "JuliaSyntaxHighlighting"]

try
    # Activate the project if Project.toml exists
    if isfile("Project.toml")
        Pkg.activate(".")
    end

    for pkg in packages
        print("  Installing $pkg...")
        try
            Pkg.add(pkg)
            print_status(" done")
        catch e
            print_warning(" failed: $e")
        end
    end
catch e
    print_warning("Could not install packages: $e")
end
println()

# Step 4: Create the batch file on Desktop
println(colorize("Step 4: Creating batch file on Desktop...", "cyan"))
try
    desktop_path = joinpath(ENV["USERPROFILE"], "Desktop")
    batch_content = [
        "@echo off",
        "REM run-annaai.bat - Run AnnaAI from Desktop",
        "REM Created by Annie Love of Blue",
        "",
        "cls",
        "echo ============================================",
        "echo   AnnaAI - Your Romantic Julia Assistant",
        "echo   Created by Annie Love of Blue",
        "echo ============================================",
        "echo.",
        "echo Starting AnnaAI...",
        "echo.",
        "",
        "REM Get the directory where this batch file is located",
        "set SCRIPT_DIR=%~dp0",
        "",
        "REM Change to the AnnaAI directory",
        "cd /d \"%SCRIPT_DIR%\"",
        "",
        "REM Run Julia with main.jl",
        "julia main.jl",
        "",
        "echo.",
        "echo Thank you for using AnnaAI!",
        "echo.",
        "echo Press any key to exit...",
        "pause >nul",
    ]

    batch_path = joinpath(desktop_path, "run-annaai.bat")
    open(batch_path, "w") do f
        for line in batch_content
            println(f, line)
        end
    end
    print_status("Created: run-annaai.bat on Desktop")
catch e
    print_warning("Could not create batch file: $e")
end
println()

# Step 5: Create Ollama model
println(colorize("Step 5: Creating AnnaAI model in Ollama...", "cyan"))
if ollama_installed
    if isfile("Modelfile")
        print_status("Modelfile found")
        println()
        print_info("Creating AnnaAI model (this may take a few minutes)...")

        # Pull base model first
        print("  Pulling llama3.2 base model...")
        pull_success = run_cmd("ollama pull llama3.2")
        if pull_success
            print_status(" done")
        else
            print_warning(" failed (model may already exist)")
        end

        # Create the AnnaAI model
        print("  Creating AnnaAI model from Modelfile...")
        create_success = run_cmd("ollama create annaai -f Modelfile")
        if create_success
            print_status(" AnnaAI model created successfully!")
        else
            print_warning(" failed")
            println()
            print_info("Please run manually: ollama create annaai -f Modelfile")
        end
    else
        print_warning("Modelfile not found")
    end
else
    print_warning("Ollama not installed - skipping model creation")
end
println()

# Step 6: Verify setup
println(colorize("Step 6: Verifying setup...", "cyan"))
try
    all_good = true

    # Check if main.jl exists
    if isfile("main.jl")
        print_status("main.jl found")
    else
        print_warning("main.jl not found")
        all_good = false
    end

    # Check if Modelfile exists
    if isfile("Modelfile")
        print_status("Modelfile found")
    else
        print_warning("Modelfile not found")
        all_good = false
    end

    # Check for Project.toml
    if isfile("Project.toml")
        print_status("Project.toml found")
    else
        print_warning("Project.toml not found")
        all_good = false
    end

    # Check if model exists
    if ollama_installed
        model_check = run_cmd("ollama list | findstr annaai")
        if model_check
            print_status("AnnaAI model installed")
        else
            print_warning("AnnaAI model not found")
        end
    end
catch e
    print_warning("Could not verify setup: $e")
end
println()

# Final instructions
println("=" ^ 60)
if all_good
    println(colorize("  Setup Complete! 💕", "green"))
    println("=" ^ 60)
    println()
    println("You can now start AnnaAI by:")
    println("  1. Double-clicking: run-annaai.bat on your Desktop")
    println()
    print_info("Enjoy your time with AnnaAI!")
else
    println(colorize("  Setup Incomplete", "yellow"))
    println("=" ^ 60)
    println()
    println("Please address the warnings above.")
    println()
    print_info("Contact Annie Love of Blue for support.")
end
println()

# Optional: Print quote
quotes = [
    "Love is the poetry of the senses. - Honore de Balzac",
    "The best way to predict the future is to create it. - Peter Drucker",
    "In Julia, as in love, multiple dispatch finds the perfect match.",
    "Every bug you fix makes your code stronger, just like love.",
    "Programming is poetry written in logic. Julia makes it beautiful.",
]
println()
println("  \"$(rand(quotes))\"")
println()
