# src/integration/ollama_client.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This file provides a client for interacting with the Ollama API.
#
# License: MIT
#
module OllamaClient

using JSON

"""
    OllamaError

An exception type for errors related to the Ollama API.
"""
struct OllamaError <: Exception
    message::String
end

"""
    generate(prompt::String, model::String)

Generates text using the specified model and prompt.

This function uses the Ollama CLI to generate text and returns the
generated response.
"""
function generate(prompt::String, model::String)
    try
        # Escape quotes in prompt for command line
        escaped_prompt = replace(prompt, "\"" => "\\\"")

        # Run ollama run command with prompt as argument
        cmd = `ollama run $model $escaped_prompt`
        result = read(cmd, String)

        return strip(result)
    catch e
        throw(OllamaClient.OllamaError("Error running Ollama command: $e"))
    end
end

end
