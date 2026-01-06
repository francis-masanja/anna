# src/utils/tui.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This module provides terminal user interface enhancements for Anna AI.
# It includes colored output, loading animations, and menu-driven interfaces.
#
# License: MIT
#

module TUI

using Crayons
using Dates
using JuliaSyntaxHighlighting
using Base.Threads

# Mapping from string names to Crayon objects
const CRAYON_MAP = Dict{String,Crayon}(
    "reset" => Crayon(; reset=true),
    "bold" => Crayon(; bold=true),
    "dim" => Crayon(; faint=true),
    "black" => Crayon(; foreground=:black),
    "red" => Crayon(; foreground=:red),
    "green" => Crayon(; foreground=:green),
    "yellow" => Crayon(; foreground=:yellow),
    "blue" => Crayon(; foreground=:blue),
    "magenta" => Crayon(; foreground=:magenta),
    "cyan" => Crayon(; foreground=:cyan),
    "white" => Crayon(; foreground=:white),
    "bright_black" => Crayon(; foreground=:dark_gray),
    "bright_red" => Crayon(; foreground=:light_red),
    "bright_green" => Crayon(; foreground=:light_green),
    "bright_yellow" => Crayon(; foreground=:light_yellow),
    "bright_blue" => Crayon(; foreground=:light_blue),
    "bright_magenta" => Crayon(; foreground=:light_magenta),
    "bright_cyan" => Crayon(; foreground=:light_cyan),
    "bright_white" => Crayon(; foreground=:white),
    "bg_black" => Crayon(; background=:black),
    "bg_red" => Crayon(; background=:red),
    "bg_green" => Crayon(; background=:green),
    "bg_yellow" => Crayon(; background=:yellow),
    "bg_blue" => Crayon(; background=:blue),
    "bg_magenta" => Crayon(; background=:magenta),
    "bg_cyan" => Crayon(; background=:cyan),
    "bg_white" => Crayon(; background=:white),
)

"""
    colorize(text::String, color::String)::String

Apply a Crayon to text for colored terminal output.
If the color name is not found, returns the original text.
"""
function colorize(text::String, color::String)::String
    crayon = get(CRAYON_MAP, color, nothing)
    if !isnothing(crayon)
        return string(crayon, text, Crayon(; reset=true))
    end
    return text
end

"""
    print_header(text::String)::Nothing

Print a styled header.
"""
function print_header(text::String)::Nothing
    println()
    println(colorize("━" ^ 50, "dim"))
    println(colorize("  $text", "bright_cyan"))
    println(colorize("━" ^ 50, "dim"))
    println()
    return nothing
end

"""
    print_success(text::String)::Nothing

Print a success message.
"""
function print_success(text::String)::Nothing
    println(colorize("✓ ", "bright_green") * text)
    return nothing
end

"""
    print_error(text::String)::Nothing

Print an error message.
"""
function print_error(text::String)::Nothing
    println(colorize("✗ ", "bright_red") * text)
    return nothing
end

"""
    print_warning(text::String)::Nothing

Print a warning message.
"""
function print_warning(text::String)::Nothing
    println(colorize("⚠ ", "bright_yellow") * text)
    return nothing
end

"""
    print_info(text::String)::Nothing

Print an info message.
"""
function print_info(text::String)::Nothing
    println(colorize("$text ", "bright_blue"))
    return nothing
end

"""
    print_step(step::Int, total::Int, text::String)::Nothing

Print a step indicator.
"""
function print_step(step::Int, total::Int, text::String)::Nothing
    println(colorize("[$step/$total] ", "bright_magenta") * text)
    return nothing
end

"""
    spinner_frames()::Vector{String}

Return animation frames for a spinner.
"""
function spinner_frames()::Vector{String}
    return ["⢿", "⣻", "⣽", "⣾", "⣷", "⣯", "⣟", "⡿"]
end

"""
    with_loading(message::String, fn::Function)::Any

Execute a function with a loading spinner animation.
Shows a spinning animation while the function executes, then displays success message.

# Arguments
- `message::String`: The message to display during loading
- `fn::Function`: The function to execute

# Returns
- The result of the executed function
"""
function with_loading(fn::Function, message::String)::Any
    # Create a channel to control the spinner thread
    stop_spinner = Channel{Bool}(1)

    # Run spinner animation in a separate thread
    spinner = Threads.@spawn begin
        frames = spinner_frames()
        i = 1
        while !isready(stop_spinner)
            # Clear line and print spinner with message
            print("\r" * colorize(frames[i], "bright_cyan") * " $message")
            sleep(0.1)  # Animate at 10fps
            i = (i % length(frames)) + 1  # Cycle through frames
        end
    end

    # Execute the actual function
    result = fn()

    # Stop the spinner
    put!(stop_spinner, true)
    wait(spinner)

    # Clear the spinner line and print success
    print("\r" * " " ^ (length(message) + 2) * "\r")
    print_success(message)

    return result
end

"""
    print_table(headers::Vector{String}, rows::Vector{Vector{String}})::Nothing

Print data in a formatted table with headers and rows.
Automatically calculates column widths based on content.

# Arguments
- `headers::Vector{String}`: Column headers
- `rows::Vector{Vector{String}}`: Table data rows
"""
function print_table(headers::Vector{String}, rows::Vector{Vector{String}})::Nothing
    # Calculate the maximum width needed for each column
    col_widths = [length.(headers)...]
    for row in rows
        for (i, cell) in enumerate(row)
            col_widths[i] = max(col_widths[i], length(cell))
        end
    end

    # Print header row with colored headers
    print("  ")
    for (i, header) in enumerate(headers)
        print(colorize(rpad(header, col_widths[i]), "bright_yellow"))
        print("  ")
    end
    println()

    # Print separator line
    print("  ")
    for width in col_widths
        print("─" ^ (width + 2))
    end
    println()

    # Print each data row
    for row in rows
        print("  ")
        for (i, cell) in enumerate(row)
            print(rpad(cell, col_widths[i]))
            print("  ")
        end
        println()
    end

    return nothing
end

"""
    print_panel(content::String, title::String="", border_color::String="cyan")::Nothing

Print content in a panel with border.
"""

"""
    wrap_text(text::String, width::Int)

Helper function that wraps text to fit within the specified width.
Breaks text into lines at word boundaries.
"""
function wrap_text(text::String, width::Int)
    words = split(text)
    lines = String[]
    current = ""

    for word in words
        if isempty(current)
            # Start a new line with the first word
            current = word
        elseif length(current) + length(word) + 1 ≤ width
            # Add word to current line if it fits
            current *= " " * word
        else
            # Current line is full, start a new one
            push!(lines, current)
            current = word
        end
    end

    # Don't forget the last line
    !isempty(current) && push!(lines, current)
    return lines
end

function print_panel(content::String; title::String="", border_color::String="cyan")
    wrapped_lines = String[]
    width = 80  # Fixed width for the panel
    for paragraph in split(content, "\n")
        if isempty(strip(paragraph))
            push!(wrapped_lines, "")
        else
            append!(wrapped_lines, wrap_text(paragraph, width))
        end
    end

    inner_width = width
    # Define border characters
    top = "┏" * repeat("━", inner_width + 2) * "┓"
    mid = "┣" * repeat("━", inner_width + 2) * "┫"
    bottom = "┗" * repeat("━", inner_width + 2) * "┛"

    # Print top border
    println(colorize(top, border_color))

    # Print title section if title is provided
    if !isempty(title)
        title_line = "┃ " * rpad(title, inner_width) * " ┃"
        println(colorize(title_line, "bright_cyan"))
        println(colorize(mid, border_color))
    end

    for line in wrapped_lines
        println(
            colorize("┃ ", border_color) *
            rpad(line, inner_width) *
            colorize(" ┃", border_color),
        )
    end

    println(colorize(bottom, border_color))
    println()
end

"""
    MenuOption

A struct representing a menu option.
"""
struct MenuOption
    key::String
    description::String
    action::Function
end

"""
    print_menu(title::String, options::Vector{MenuOption})::String

Print a menu and return the selected option key.
"""
function print_menu(title::String, options::Vector{MenuOption})::String
    print_header(title)

    for (i, option) in enumerate(options)
        key = colorize("[$(option.key)]", "bright_magenta")
        desc = option.description
        println("  $key $desc")
    end

    println()
    print(colorize("› ", "bright_green"))

    return readline()
end

"""
    confirm(prompt::String)::Bool

Ask for confirmation.
"""
function confirm(prompt::String)::Bool
    print(colorize("$prompt [y/n]: ", "bright_yellow"))
    response = lowercase(readline())
    return response == "y" || response == "yes"
end

"""
    prompt_input(prompt::String, default::String="")::String

Prompt for input with a default value.
"""
function prompt_input(prompt::String, default::String="")::String
    default_text = isempty(default) ? "" : " [$default]"
    print(colorize("$prompt$default_text: ", "bright_cyan"))
    input = readline()
    return isempty(input) ? default : input
end

"""
    select_option(prompt::String, options::Vector{String})::String

Let user select from a list of options.
"""
function select_option(prompt::String, options::Vector{String})::String
    println(prompt)
    for (i, option) in enumerate(options)
        println("  $(colorize("[$i]", "bright_magenta")) $option")
    end
    println()

    while true
        print(colorize("Select [1-$(length(options))]: ", "bright_cyan"))
        try
            selection = parse(Int, readline())
            if 1 <= selection <= length(options)
                return options[selection]
            end
        catch e
        end
        print_warning("Invalid selection. Please try again.")
    end
end

"""
    print_ascii_art(art::Vector{String}, color::String="bright_cyan")::Nothing

Print ASCII art with optional coloring.
"""
function print_ascii_art(art::Vector{String}, color::String="bright_cyan")::Nothing
    for line in art
        println(colorize(line, color))
    end
    return nothing
end

"""
    highlight_julia_code(code::AbstractString)::AbstractString

Highlight Julia code using JuliaSyntaxHighlighting.
"""
function highlight_julia_code(code::AbstractString)::AbstractString
    return sprint(highlight, code; lexer=JuliaLexer)
end

"""
    clear_screen()::Nothing

Clear the terminal screen.
"""
function clear_screen()::Nothing
    print("\033c")
    return nothing
end

"""
    print_banner()::Nothing

Print the Anna AI banner.
"""
function print_banner()::Nothing
    banner = [
        "    ███   ██     ██ ██     ██   ███   ",
        "  ██   ██ ████   ██ ████   ██ ██   ██  ",
        "  ███████ ██ ██  ██ ██ ██  ██ ███████  ",
        "  ██   ██ ██  ██ ██ ██  ██ ██ ██   ██  ",
        "  ██   ██ ██   ████ ██   ████ ██   ██  ",
        "                                       ",
        "",
        "                                       ",
        "   ✨ Intelligent AI Assistant ✨      ",
        "",
    ]

    print_ascii_art(banner, "bright_cyan")
    return nothing
end

"""
    LoadingProgress

A struct for tracking progress of operations.
"""
struct LoadingProgress
    total::Int
    current::Int
    start_time::Dates.DateTime
    description::String
end

"""
    start_progress(total::Int, description::String)::LoadingProgress

Start a progress tracker.
"""
function start_progress(total::Int, description::String)::LoadingProgress
    return LoadingProgress(total, 0, now(), description)
end

"""
    update_progress(progress::LoadingProgress, current::Int)::LoadingProgress

Update progress and redraw the progress bar.
"""
function update_progress(progress::LoadingProgress, current::Int)::LoadingProgress
    progress.current = current
    percent = (current / progress.total) * 100
    filled = Int(floor(percent / 5))
    bar = "█" ^ filled * "░" ^ (20 - filled)

    elapsed = Dates.now() - progress.start_time
    elapsed_ms = Dates.Millisecond(elapsed).value
    eta = if current > 0
        total_ms = (elapsed_ms / current) * progress.total
        remaining = total_ms - elapsed_ms
        seconds = round(Int, remaining / 1000)
        " (ETA: $(seconds)s)"
    else
        ""
    end

    print(
        "\r$(colorize("│", "dim")) $(colorize(bar, "bright_green")) $(colorize("│", "dim")) ",
    )
    print(colorize("$percent%", "bright_cyan") * " $progress.description$eta")

    if current == progress.total
        total_time = round(
            (Dates.now() - progress.start_time) / Dates.Millisecond(1000); digits=1
        )
        println()
        print_success("Completed in $(total_time)s")
    end

    return progress
end

"""
    format_duration(seconds::Float64)::String

Format duration in human-readable format.
"""
function format_duration(seconds::Float64)::String
    if seconds < 60
        return "$(round(seconds, digits=1))s"
    elseif seconds < 3600
        minutes = floor(Int, seconds / 60)
        secs = round(Int, seconds % 60)
        return "$(minutes)m $(secs)s"
    else
        hours = floor(Int, seconds / 3600)
        minutes = round(Int, (seconds % 3600) / 60)
        return "$(hours)h $(minutes)m"
    end
end

"""
    print_help()::Nothing

Print help information.
"""
function print_help()::Nothing
    headers = ["Command", "Description"]
    rows = [
        ["-i, --interactive", "Start interactive chat"],
        ["--story", "Generate a story"],
        ["--prompt 'text'", "Story idea"],
        ["--genre fantasy", "Genre (fantasy, sci-fi, romance, mystery, horror, adventure)"],
        ["--length short", "Length (short, medium, long)"],
        ["--tone happy", "Tone (happy, mysterious, exciting, etc.)"],
        ["/help", "Show this help (in chat)"],
        ["/quit", "Exit chat"],
    ]
    print_panel("Here are the available commands:", "Help", "cyan")
    print_table(headers, rows)
end

end  # End of TUI module
