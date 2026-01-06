# src/modules/julia_helper.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This module provides Julia programming assistance capabilities.
# It helps users with code analysis, explanations, and learning challenges.
#
# License: MIT
#

module JuliaHelper

# Import required modules
using ..AnnaAI
using ..OllamaClient

"""
    CodeAnalysis

A struct to hold code analysis results.
"""
struct CodeAnalysis
    code::String
    line_count::Int
    word_count::Int
    estimated_complexity::String
    suggestions::Vector{String}
end

"""
    CodeExplanation

A struct to hold code explanation details.
"""
struct CodeExplanation
    summary::String
    line_by_line::Vector{String}
    key_concepts::Vector{String}
    tips::Vector{String}
end

"""
    ChallengeDifficulty

Enumeration of challenge difficulty levels.
"""
@enum ChallengeDifficulty begin
    EASY
    MEDIUM
    HARD
    ADVANCED
end

"""
    JuliaChallenge

A struct to hold a Julia programming challenge.
"""
struct JuliaChallenge
    title::String
    description::String
    difficulty::ChallengeDifficulty
    hints::Vector{String}
    starter_code::String
    expected_concepts::Vector{String}
end

"""
    CHALLENGE_TOPICS

Topics for Julia challenges.
"""
const CHALLENGE_TOPICS = [
    "functions",
    "types",
    "arrays",
    "dictionaries",
    "loops",
    "comprehensions",
    "multiple dispatch",
    "modules",
    "metaprogramming",
    "performance",
    "linear algebra",
    "statistics",
]

"""
    analyze_code(code::String)::CodeAnalysis

Analyze Julia code and provide feedback.

# Arguments
- `code::String`: The Julia code to analyze

# Returns
- `CodeAnalysis`: Analysis results including suggestions

# Example
```julia
analysis = JuliaHelper.analyze_code("function foo(x) return x^2 end")
```
"""
function analyze_code(code::String)::CodeAnalysis
    line_count = count_lines(code)
    word_count = count_words(code)

    # Basic complexity estimation
    complexity = if line_count < 10
        "low"
    elseif line_count < 50
        "medium"
    elseif line_count < 100
        "high"
    else
        "very high"
    end

    # Generate suggestions based on code patterns
    suggestions = Vector{String}()

    if occursin("for ", code) && !occursin("@inbounds", code)
        push!(suggestions, "Consider using @inbounds for performance in loops when safe")
    end

    if occursin("Array{Float64", code)
        push!(
            suggestions,
            "Consider using Vector{Float64}(undef, n) for type-stable array creation",
        )
    end

    if !occursin("function", code) && !occursin("struct", code)
        push!(
            suggestions, "Consider encapsulating code in functions for better organization"
        )
    end

    if occursin("using Pkg", code)
        push!(suggestions, "Package loading should typically happen at the top level")
    end

    # Use Ollama for advanced analysis if available
    try
        prompt = """
        Analyze this Julia code and provide 2-3 concise improvement suggestions:

        ```julia
        $code
        ```

        Focus on: performance, style, and best practices.
        """
        ai_suggestions = OllamaClient.generate(prompt, "annaai")
        if !isempty(ai_suggestions)
            for line in split(ai_suggestions, "\n")
                if length(line) > 10 && length(suggestions) < 5
                    push!(suggestions, strip(line))
                end
            end
        end
    catch e
        # Silently continue if AI analysis fails
    end

    return CodeAnalysis(code, line_count, word_count, complexity, suggestions)
end

"""
    explain_code(code::String, detail_level::String="medium")::CodeExplanation

Explain Julia code in a beginner-friendly way.

# Arguments
- `code::String`: The Julia code to explain
- `detail_level::String`: Level of detail ("basic", "medium", "detailed")

# Returns
- `CodeExplanation`: Detailed explanation of the code

# Example
```julia
explanation = JuliaHelper.explain_code("map(x -> x^2, [1, 2, 3])", "medium")
```
"""
function explain_code(code::String, detail_level::String="medium")::CodeExplanation
    detail_level = lowercase(detail_level)

    # Generate explanation using AI
    prompt = if detail_level == "basic"
        """
        Explain this Julia code in simple terms for a beginner:

        ```julia
        $code
        ```

        Keep it very brief and use simple language.
        """
    elseif detail_level == "detailed"
        """
        Provide a detailed technical explanation of this Julia code:

        ```julia
        $code
        ```

        Include: what each line does, Julia-specific concepts used, and performance considerations.
        """
    else
        """
        Explain this Julia code clearly:

        ```julia
        $code
        ```

        Include a summary, key concepts, and helpful tips.
        """
    end

    try
        ai_explanation = OllamaClient.generate(prompt, "annaai")

        # Parse the explanation
        summary = ai_explanation
        line_by_line = split(ai_explanation, "\n")
        key_concepts = extract_concepts(code)
        tips = generate_tips(code)

        return CodeExplanation(summary, line_by_line, key_concepts, tips)
    catch e
        return CodeExplanation(
            "Could not generate explanation: $e",
            ["Error generating detailed explanation"],
            extract_concepts(code),
            generate_tips(code),
        )
    end
end

"""
    get_challenge(difficulty::String, topic::String)::JuliaChallenge

Get a Julia programming challenge.

# Arguments
- `difficulty::String`: Challenge difficulty (easy, medium, hard, advanced)
- `topic::String`: Topic to focus on

# Returns
- `JuliaChallenge`: A programming challenge

# Example
```julia
challenge = JuliaHelper.get_challenge("easy", "functions")
```
"""
function get_challenge(difficulty::String, topic::String)::JuliaChallenge
    difficulty = lowercase(difficulty)
    topic = lowercase(topic)

    # Generate challenge using AI
    prompt = """
    Create a Julia programming challenge with:
    - Difficulty: $difficulty
    - Topic: $topic

    Format as JSON with keys: title, description, hints (array), starter_code, expected_concepts (array)
    Make it educational and appropriate for learning Julia.
    """

    try
        ai_response = OllamaClient.generate(prompt, "annaai")

        # Parse AI response (simplified - in real implementation, use JSON parsing)
        challenge = parse_challenge_response(ai_response, difficulty, topic)
        return challenge
    catch e
        # Return a default challenge
        return create_default_challenge(difficulty, topic)
    end
end

"""
    get_random_challenge()::JuliaChallenge

Get a random Julia programming challenge.
"""
function get_random_challenge()::JuliaChallenge
    difficulty = rand([EASY, MEDIUM, HARD])
    topic = rand(CHALLENGE_TOPICS)
    return get_challenge(string(difficulty), topic)
end

"""
    validate_solution(solution::String, challenge::JuliaChallenge)::Bool

Check if a solution is correct for a challenge.
This is a simplified validation - in practice, you'd run the code.

# Arguments
- `solution::String`: The user's solution code
- `challenge::JuliaChallenge`: The challenge being solved

# Returns
- `Bool`: Whether the solution appears correct
"""
function validate_solution(solution::String, challenge::JuliaChallenge)::Bool
    # Basic validation - check if expected concepts are used
    solution_lower = lowercase(solution)

    for concept in challenge.expected_concepts
        if !occursin(lowercase(concept), solution_lower)
            return false
        end
    end

    return true
end

"""
    get_documentation(function_name::String)::String

Get documentation for a Julia function.

# Arguments
- `function_name::String`: The function to look up

# Returns
- `String`: Documentation for the function
"""
function get_documentation(function_name::String)::String
    prompt = """
    Provide documentation for the Julia function `$function_name`.
    Include: usage, arguments, return value, and examples.
    Keep it concise but informative.
    """

    try
        return OllamaClient.generate(prompt, "annaai")
    catch e
        return "Could not retrieve documentation: $e"
    end
end

# Helper functions

function count_lines(code::String)::Int
    return length(split(code, "\n"))
end

function count_words(code::String)::Int
    return length(split(code))
end

function extract_concepts(code::String)::Vector{String}
    concepts = String[]

    concept_patterns = [
        (r"function\s+(\w+)", "functions"),
        (r"struct\s+(\w+)", "custom types"),
        (r"mutable struct\s+(\w+)", "mutable types"),
        (r"for\s+(\w+)", "loops"),
        (r"while\s+", "while loops"),
        (r"if\s+", "conditionals"),
        (r"map\s*\(", "higher-order functions"),
        (r"filter\s*\(", "higher-order functions"),
        (r"reduce\s*\(", "higher-order functions"),
        (r"@(\w+)", "macros"),
        (r"begin\s", "blocks"),
        (r"let\s", "let blocks"),
    ]

    for (pattern, concept) in concept_patterns
        if occursin(pattern, code) && !(concept in concepts)
            push!(concepts, concept)
        end
    end

    if isempty(concepts)
        push!(concepts, "basic Julia syntax")
    end

    return concepts
end

function generate_tips(code::String)::Vector{String}
    tips = String[]

    if occursin("global", code)
        push!(tips, "Avoid global variables in performance-critical code")
    end

    if occursin("Array", code)
        push!(tips, "Consider pre-allocating arrays for better performance")
    end

    if occursin(r"\.[*+/\\-]", code)
        push!(tips, "Dot broadcasting can improve performance on arrays")
    end

    push!(tips, "Use @time to profile your code's performance")
    push!(tips, "Run Julia with --optimize=3 for best performance")

    return tips
end

function parse_challenge_response(
    response::String, difficulty::String, topic::String
)::JuliaChallenge
    # Simplified parsing - in real implementation, use JSON parsing
    return JuliaChallenge(
        "Julia $topic Challenge",
        "Learn about $topic in Julia through this challenge.",
        EASY,
        ["Start by reading the starter code carefully"],
        "# Your code here\n",
        [topic],
    )
end

function create_default_challenge(difficulty::String, topic::String)::JuliaChallenge
    return JuliaChallenge(
        "Practice $topic",
        "Create a Julia program that demonstrates $topic.",
        EASY,
        ["Break the problem into smaller parts"],
        "# Write your solution here\n",
        [topic],
    )
end

"""
    get_supported_topics()::Vector{String}

Return the list of supported challenge topics.
"""
function get_supported_topics()::Vector{String}
    return CHALLENGE_TOPICS
end

"""
    get_difficulties()::Vector{String}

Return the list of difficulty levels.
"""
function get_difficulties()::Vector{String}
    return ["easy", "medium", "hard", "advanced"]
end

end  # End of JuliaHelper module
