# AnnaAI.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This file is the main entry point for the Anna AI application.
# It handles command-line argument parsing, configuration loading,
# and initializes the main application logic.
#
# License: MIT
#
module AnnaAI

using ArgParse

include("core/config.jl")
include("utils/logger.jl")
include("integration/ollama_client.jl")
include("integration/prompt_builder.jl")
include("integration/response_parser.jl")
include("utils/file_io.jl")
include("utils/tui.jl")
include("modules/storytelling.jl")
include("modules/julia_helper.jl")
include("modules/debugging.jl")
include("modules/companionship.jl")

function run_challenge(model::String, parsed_args)
    difficulty = parsed_args["difficulty"]
    topic = parsed_args["topic"]

    challenge = if topic == "random"
        JuliaHelper.get_random_challenge()
    else
        JuliaHelper.get_challenge(difficulty, topic)
    end

    TUI.print_header("Julia Challenge: $(challenge.title)")
    println(TUI.colorize("Difficulty: ", "bright_cyan") * string(challenge.difficulty))
    println(TUI.colorize("Topic: ", "bright_cyan") * challenge.expected_concepts[1])
    println()

    TUI.print_panel(challenge.description, "Description", "cyan")

    TUI.print_header("Starter Code")
    println(TUI.highlight_julia_code(challenge.starter_code))

    TUI.print_header("Hints")
    for hint in challenge.hints
        println(TUI.colorize("• ", "bright_yellow") * hint)
    end
end

function run_code_explanation(model::String, parsed_args)
    file_path = parsed_args["explain-code"]
    if !isfile(file_path)
        TUI.print_error("File not found: $file_path")
        return nothing
    end
    code = read(file_path, String)
    explanation = JuliaHelper.explain_code(code)

    TUI.print_header("Code Explanation")
    TUI.print_panel(TUI.highlight_julia_code(code), "Code", "cyan")

    TUI.print_header("Summary")
    println(explanation.summary)

    TUI.print_header("Key Concepts")
    for concept in explanation.key_concepts
        println(TUI.colorize("• ", "bright_yellow") * concept)
    end

    TUI.print_header("Tips")
    for tip in explanation.tips
        println(TUI.colorize("• ", "bright_yellow") * tip)
    end
end

function run_code_analysis(model::String, parsed_args)
    file_path = parsed_args["analyze-code"]
    if !isfile(file_path)
        TUI.print_error("File not found: $file_path")
        return nothing
    end
    code = read(file_path, String)
    analysis = JuliaHelper.analyze_code(code)

    TUI.print_header("Code Analysis")
    println(TUI.colorize("File: ", "bright_cyan") * file_path)
    println(TUI.colorize("Lines: ", "bright_cyan") * string(analysis.line_count))
    println(TUI.colorize("Words: ", "bright_cyan") * string(analysis.word_count))
    println(TUI.colorize("Complexity: ", "bright_cyan") * analysis.estimated_complexity)
    println()

    TUI.print_panel(TUI.highlight_julia_code(code), "Code", "cyan")

    TUI.print_header("Suggestions")
    for suggestion in analysis.suggestions
        println(TUI.colorize("• ", "bright_yellow") * suggestion)
    end
end

function run_story_generation(model::String, parsed_args)
    prompt = parsed_args["prompt"]
    if isnothing(prompt) || isempty(prompt)
        TUI.print_error("Please provide a prompt: --prompt 'your story idea'")
        return nothing
    end
    genre = parsed_args["genre"]
    len = parsed_args["length"]
    tone = parsed_args["tone"]

    story = TUI.with_loading("Generating your story...") do
        Storytelling.generate_story(prompt, genre, len, tone, model)
    end
    println()

    paragraphs = split(story, "\n")
    formatted_story = ""
    for p in paragraphs
        formatted_story *= "  " * p * "\n"
    end

    TUI.print_panel(formatted_story, "Your Story", "cyan")
    println("\n\nThe End!\n\n Did you want to generate another story? [y/n]")
    answer = readline()
    if lowercase(strip(answer)) == "y"
        run_story_generation_menu(model)
    else
        TUI.print_info("Returning to main menu...")
    end
end

function run_interactive_mode(model::String)
    TUI.print_banner()
    println()

    while true
        print(TUI.colorize("› ", "bright_green"))
        user_input = readline()

        if user_input == "/exit" || user_input == "/quit"
            break
        elseif user_input == "/help"
            TUI.print_help()
        elseif isempty(strip(user_input))
            continue
        end

        try
            response = TUI.with_loading("Anna is thinking...") do
                OllamaClient.generate(user_input, model)
            end
            if !isnothing(response) && !isempty(response)
                println()
                println(TUI.colorize("Anna: ", "bright_cyan") * response)
                println()
            end
        catch e
            if e isa OllamaClient.OllamaError
                TUI.print_error("Ollama: $(e.message)")
            else
                TUI.print_error("Error: $e")
            end
        end
    end
    TUI.print_info("Goodbye!")
end

function run_story_generation_menu(model::String)
    prompt = TUI.prompt_input("Enter a prompt for your story:")
    if isempty(prompt)
        TUI.print_warning("Prompt cannot be empty.")
        return nothing
    end
    genre = TUI.select_option("Select a genre:", Storytelling.get_supported_genres())
    len = TUI.select_option("Select a length:", Storytelling.get_supported_lengths())
    tone = TUI.select_option("Select a tone:", Storytelling.get_supported_tones())

    parsed_args = Dict(
        "prompt" => prompt, "genre" => genre, "length" => len, "tone" => tone
    )
    run_story_generation(model, parsed_args)
end

function run_julia_helper_menu(model::String)
    while true
        options = [
            TUI.MenuOption("1", "Analyze Code", () -> run_code_analysis_menu(model)),
            TUI.MenuOption("2", "Explain Code", () -> run_code_explanation_menu(model)),
            TUI.MenuOption("3", "Get a Challenge", () -> run_challenge_menu(model)),
            TUI.MenuOption("b", "Back to Main Menu", () -> return nothing),
        ]
        choice = TUI.print_menu("Julia Helper", options)

        if choice == "1"
            run_code_analysis_menu(model)
        elseif choice == "2"
            run_code_explanation_menu(model)
        elseif choice == "3"
            run_challenge_menu(model)
        elseif choice == "b"
            break
        else
            TUI.print_warning("Invalid choice, please try again.")
        end
    end
end

function run_code_analysis_menu(model::String)
    file_path = TUI.prompt_input("Enter the path to the Julia file to analyze:")
    parsed_args = Dict("analyze-code" => file_path)
    run_code_analysis(model, parsed_args)
end

function run_code_explanation_menu(model::String)
    file_path = TUI.prompt_input("Enter the path to the Julia file to explain:")
    parsed_args = Dict("explain-code" => file_path)
    run_code_explanation(model, parsed_args)
end

function run_challenge_menu(model::String)
    difficulty = TUI.select_option("Select a difficulty:", JuliaHelper.get_difficulties())
    topic = TUI.select_option("Select a topic:", JuliaHelper.get_supported_topics())
    parsed_args = Dict("difficulty" => difficulty, "topic" => topic)
    run_challenge(model, parsed_args)
end

"""
    julia_main()::Cint

The main entry point for the Anna AI application.
"""
function julia_main()::Cint
    try
        s = ArgParseSettings()
        @add_arg_table s begin
            "--interactive", "-i"
            help = "Start interactive chat"
            action = :store_true
            "--story"
            help = "Generate a story"
            action = :store_true
            "--prompt"
            help = "Story prompt"
            arg_type = String
            "--genre"
            help = "Story genre"
            arg_type = String
            default = "fantasy"
            "--length"
            help = "Story length"
            arg_type = String
            default = "short"
            "--tone"
            help = "Story tone"
            arg_type = String
            default = "neutral"
            "--env"
            help = "Environment"
            arg_type = String
            default = "development"
        end

        parsed_args = parse_args(ARGS, s)

        env = parsed_args["env"]
        config = Config.load_config(env)
        model = config["ollama"]["model"]
        log_level = config["logging"]["level"]
        Logger.setup_logger(log_level)

        # If any arguments other than --env or no arguments are provided, run in CLI mode
        cli_mode = length(ARGS) > 0 && any(arg -> !startswith(arg, "--env"), ARGS)

        if cli_mode
            if parsed_args["interactive"]
                run_interactive_mode(model)
            elseif parsed_args["story"]
                run_story_generation(model, parsed_args)
            elseif parsed_args["analyze-code"] !== nothing
                run_code_analysis(model, parsed_args)
            elseif parsed_args["explain-code"] !== nothing
                run_code_explanation(model, parsed_args)
            elseif parsed_args["get-challenge"]
                run_challenge(model, parsed_args)
            else
                # No command specified - show brief help
                TUI.print_banner()
                println()
                TUI.print_info("Use --help to see available commands.")
            end
        else
            # Run in interactive menu mode
            while true
                TUI.clear_screen()
                TUI.print_banner()
                println()
                options = [
                    TUI.MenuOption(
                        "1", "Interactive Chat", () -> run_interactive_mode(model)
                    ),
                    TUI.MenuOption(
                        "2", "Story Generation", () -> run_story_generation_menu(model)
                    ),
                    TUI.MenuOption("3", "Julia Helper", () -> run_julia_helper_menu(model)),
                    TUI.MenuOption("q", "Quit", () -> return nothing),
                ]
                choice = TUI.print_menu("Main Menu", options)

                if choice == "1"
                    run_interactive_mode(model)
                elseif choice == "2"
                    run_story_generation_menu(model)
                elseif choice == "3"
                    run_julia_helper_menu(model)
                elseif choice == "q"
                    break
                else
                    TUI.print_warning("Invalid choice, please try again.")
                end
            end
            TUI.print_info("Goodbye!")
        end
    catch e
        if e isa Config.ConfigError || e isa OllamaClient.OllamaError
            TUI.print_error(e.message)
        else
            TUI.print_error("Error: $e")
        end
        return 1
    end
    return 0
end

end
