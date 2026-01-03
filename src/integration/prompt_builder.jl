# src/integration/prompt_builder.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This file provides functions for building prompts to send to the Ollama API.
#
# License: MIT
#

module PromptBuilder

"""
    build_prompt(context::String, new_prompt::String)

Builds a new prompt by combining the conversation context with a new prompt.
"""
function build_prompt(context::String, new_prompt::String)
    # Implementation to be added
    return context * "\n" * new_prompt
end

end
