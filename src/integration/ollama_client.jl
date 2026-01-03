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

using HTTP
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

This function sends a request to the Ollama API and returns the
generated text. It handles streaming responses and combines them
into a single string.
"""
function generate(prompt::String, model::String)
    api_endpoint = get(ENV, "OLLAMA_API_ENDPOINT", "http://localhost:11434")
    url = "$api_endpoint/api/generate"

    headers = ["Content-Type" => "application/json"]
    body = Dict("model" => model, "prompt" => prompt)

    full_response = ""
    buffer = IOBuffer()
    try
        r = HTTP.post(url, headers, JSON.json(body), response_stream=buffer)
        response_text = String(take!(buffer))
        
        for line in split(response_text, "\n")
            if !isempty(line)
                json_line = JSON.parse(line)
                if haskey(json_line, "response")
                    full_response *= json_line["response"]
                end
            end
        end
        return full_response
    catch e
        throw(OllamaClient.OllamaError("Error communicating with Ollama API: $e"))
    end
end

end