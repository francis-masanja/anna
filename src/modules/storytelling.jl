# src/modules/storytelling.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This module provides storytelling capabilities for Anna AI.
# It generates stories in various genres with customizable parameters.
#
# License: MIT
#

module Storytelling

export StoryParameters, StoryResult, generate_story, get_supported_genres, get_supported_lengths, get_supported_tones, count_words, analyze_story

# Import required modules
using ..AnnaAI: OllamaClient

"""
    StoryParameters

A struct to hold story generation parameters.
"""
struct StoryParameters
    prompt::String
    genre::String
    length::String
    tone::String
end

"""
    StoryResult

A struct to hold the result of story generation.
"""
struct StoryResult
    story::String
    word_count::Int
    genre::String
    tone::String
end

"""
    SUPPORTED_GENRES

List of supported story genres.
"""
const SUPPORTED_GENRES = [
    "fantasy", "sci-fi", "science_fiction", "romance", "mystery", 
    "horror", "adventure", "comedy", "drama", "thriller"
]

"""
    STORY_LENGTHS

Valid story length options.
"""
const STORY_LENGTHS = ["short", "medium", "long"]

"""
    STORY_TONES

Valid story tone options.
"""
const STORY_TONES = ["happy", "sad", "mysterious", "exciting", "neutral", "dark", "light"]

"""
    generate_story(prompt::String, genre::String, length::String, tone::String, model::String)::String

Generate a story based on a prompt, genre, length, and tone.

# Arguments
- `prompt::String`: The story prompt/idea
- `genre::String`: The genre of the story
- `length::String`: The length of the story (short, medium, long)
- `tone::String`: The tone of the story
- `model::String`: The Ollama model to use

# Returns
- `String`: The generated story

# Example
```julia
story = Storytelling.generate_story(
    "A brave knight on a quest",
    "fantasy",
    "medium",
    "adventurous",
    "llama2"
)
```
"""
function generate_story(prompt::String, genre::String, length::String, tone::String, model::String, generator::Function)
    # Normalize inputs to lowercase for consistent validation
    genre = lowercase(genre)
    length = lowercase(length)
    tone = lowercase(tone)
    
    # DEBUG: Validation warnings (commented out for production)
    # if !(genre in SUPPORTED_GENRES)
    #     @warn "Genre '$genre' not explicitly supported, proceeding anyway"
    # end
    
    # Set default values if inputs are not recognized
    if !(length in STORY_LENGTHS)
        @warn "Length '$length' not recognized, using 'medium' instead"
        length = "medium"
    end
    
    if !(tone in STORY_TONES)
        @warn "Tone '$tone' not recognized, using 'neutral' instead"
        tone = "neutral"
    end
    
    # Build the story prompt with specific instructions based on length and tone
    # Length instructions tell the AI how long the story should be
    length_instructions = if length == "short"
        "a brief story (100-200 words)"
    elseif length == "medium"
        "a moderate-length story (300-500 words)"
    else
        "a long, detailed story (800+ words)"
    end
    
    # Tone instructions tell the AI what emotional tone to use
    tone_instructions = if tone == "happy"
        "with a cheerful, uplifting ending"
    elseif tone == "sad"
        "with a bittersweet or emotional ending"
    elseif tone == "mysterious"
        "leaving some elements mysterious and unresolved"
    elseif tone == "exciting"
        "with suspenseful and action-packed scenes"
    elseif tone == "dark"
        "with a darker, more serious tone"
    elseif tone == "light"
        "with a lighthearted and fun atmosphere"
    else
        "with a balanced narrative"
    end
    
    # Construct the full prompt to send to the LLM
    full_prompt = """
    Please write $length_instructions in the $(genre) genre $tone_instructions.
    
    Story prompt: $prompt
    
    Make the story engaging, well-structured, and creative. Include vivid descriptions and compelling characters.
    """
    
    try
        # Call the generator function (defaults to OllamaClient.generate)
        response = generator(full_prompt, model)
        if !isnothing(response) && !isempty(response)
            return response
        else
            return "Could not generate a story. The model returned an empty response."
        end
    catch e
        # Handle errors gracefully - distinguish between API errors and other errors
        if e isa OllamaClient.OllamaError
            return "Error generating story: $(e.message)"
        else
            return "An unexpected error occurred during story generation: $e"
        end
    end
end

"""
    generate_story(prompt::String, genre::String, length::String, tone::String, model::String)::String

Generate a story based on a prompt, genre, length, and tone.

# Arguments
- `prompt::String`: The story prompt/idea
- `genre::String`: The genre of the story
- `length::String`: The length of the story (short, medium, long)
- `tone::String`: The tone of the story
- `model::String`: The Ollama model to use

# Returns
- `String`: The generated story

# Example
```julia
story = Storytelling.generate_story(
    "A brave knight on a quest",
    "fantasy",
    "medium",
    "adventurous",
    "llama2"
)
```
"""
function generate_story(prompt::String, genre::String, length::String, tone::String, model::String)::String
    return generate_story(prompt, genre, length, tone, model, OllamaClient.generate)
end

"""
    generate_story(params::StoryParameters, model::String)::String

Generate a story using StoryParameters struct.

# Arguments
- `params::StoryParameters`: The story parameters
- `model::String`: The Ollama model to use

# Returns
- `String`: The generated story
"""
function generate_story(params::StoryParameters, model::String, generator::Function)::String
    return generate_story(params.prompt, params.genre, params.length, params.tone, model, generator)
end

"""
    generate_story(params::StoryParameters, model::String)::String

Generate a story using StoryParameters struct.

# Arguments
- `params::StoryParameters`: The story parameters
- `model::String`: The Ollama model to use

# Returns
- `String`: The generated story
"""
function generate_story(params::StoryParameters, model::String)::String
    return generate_story(params, model, OllamaClient.generate)
end

"""
    get_supported_genres()::Vector{String}

Return the list of supported story genres.
"""
function get_supported_genres()::Vector{String}
    return SUPPORTED_GENRES
end

"""
    get_supported_lengths()::Vector{String}

Return the supported story lengths.
"""
function get_supported_lengths()::Vector{String}
    return STORY_LENGTHS
end

"""
    get_supported_tones()::Vector{String}

Return the supported story tones.
"""
function get_supported_tones()::Vector{String}
    return STORY_TONES
end

"""
    count_words(text::String)::Int

Count the number of words in a text string.

# Arguments
- `text::String`: The text to count words in

# Returns
- `Int`: The word count
"""
function count_words(text::String)::Int
    return length(split(strip(text)))
end

"""
    analyze_story(story::String)::StoryResult

Analyze a generated story and return a StoryResult.

# Arguments
- `story::String`: The story text

# Returns
- `StoryResult`: Analysis of the story
"""
function analyze_story(story::String)::StoryResult
    word_count = count_words(story)
    return StoryResult(story, word_count, "general", "neutral")
end

end  # End of Storytelling module