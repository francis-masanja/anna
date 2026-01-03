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

"""
    julia_main()::Cint

The main entry point for the Anna AI application.

This function parses command-line arguments, loads the configuration,
initializes the logger, and starts the application in the specified mode.

# Arguments

- `ARGS`: The command-line arguments passed to the application.

# Returns

- `0` on success.
- `1` on error.

# Example

```
\$ julia main.jl interactive --env production
```
"""
function julia_main()::Cint
    try
        s = ArgParseSettings()
        @add_arg_table s begin
            "--interactive", "-i"
                help = "Start Anna AI in interactive mode"
                action = :store_true
            "--env"
                help = "Specify the environment (development, staging, production)"
                arg_type = String
                default = "development"
        end

        parsed_args = parse_args(ARGS, s)
        env = parsed_args["env"]

        config = Config.load_config(env)
        model = config["ollama"]["model"]
        log_level = config["logging"]["level"]

        Logger.setup_logger(log_level)

        if parsed_args["interactive"]
            banner = read("banner.txt", String)
            println(banner)
            @info "Starting Anna AI in interactive mode with model: $model in $env environment"
            # Interactive mode implementation to be added
        else
            @info "Anna AI: No command specified. Use 'interactive' to start."
        end
    catch e
        if e isa Config.ConfigError || e isa OllamaClient.OllamaError
            @error e.message
        else
            @error "An unexpected error occurred: $e"
        end
        return 1
    end
    return 0
end

end
