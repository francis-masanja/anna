# src/modules/debugging.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This module provides debugging capabilities for Julia code.
# It helps users analyze errors, understand stack traces, and find solutions.
#
# License: MIT
#

module Debugging

# Import required modules
using ..AnnaAI: OllamaClient

"""
    ErrorType

Enumeration of common Julia error types.
"""
@enum ErrorType begin
    UNDEFINED_VAR_ERROR
    METHOD_ERROR
    DOMAIN_ERROR
    ARGUMENT_ERROR
    BOUNDS_ERROR
    TYPE_ERROR
    SYNTAX_ERROR
    LOAD_ERROR
    RUNTIME_ERROR
    OTHER_ERROR
end

"""
    ParsedError

A struct to hold parsed error information.
"""
struct ParsedError
    error_type::ErrorType
    message::String
    location::String
    suggestion::String
    related_functions::Vector{String}
end

"""
    StackFrame

A struct to represent a single frame in a stack trace.
"""
struct StackFrame
    file::String
    line::Int
    function_name::String
    module_name::String
end

"""
    StackTraceAnalysis

A struct to hold analyzed stack trace information.
"""
struct StackTraceAnalysis
    frames::Vector{StackFrame}
    error_message::String
    error_line::String
    user_code_frames::Vector{StackFrame}
    library_frames::Vector{StackFrame}
end

"""
    DEBUGGING_TIPS

Common debugging tips for various error types.
"""
const DEBUGGING_TIPS = Dict{ErrorType,Vector{String}}(
    UNDEFINED_VAR_ERROR => [
        "Check if the variable is defined before use",
        "Make sure you haven't made a typo in the variable name",
        "Verify the variable is in scope where you're using it",
    ],
    BOUNDS_ERROR => [
        "Check array bounds - you're accessing an index that doesn't exist",
        "Remember Julia arrays are 1-indexed",
        "Use `length(array)` to check the array size before indexing",
    ],
    METHOD_ERROR => [
        "The function was called with arguments of the wrong type",
        "Check the function's signature with `methods(function_name)`",
        "Make sure all required arguments are provided",
    ],
    TYPE_ERROR => [
        "A variable has an unexpected type",
        "Use `typeof(variable)` to check the actual type",
        "Consider adding type assertions with `::Type`",
    ],
    DOMAIN_ERROR => [
        "The input value is outside the valid domain",
        "Check what values the function accepts",
        "Add input validation before calling the function",
    ],
    ARGUMENT_ERROR => [
        "Invalid arguments were passed to a function",
        "Check the function's docstring for valid arguments",
        "Use `InteractiveUtils.@which` to see the method being called",
    ],
)

"""
    COMMON_ERRORS

Database of common Julia errors and their solutions.
"""
const COMMON_ERRORS = [
    (
        pattern=r"undef_var",
        error_type=UNDEFINED_VAR_ERROR,
        solution="The variable is not defined. Check spelling and scope.",
        related=["variable", "scope"],
    ),
    (
        pattern=r"BoundsError",
        error_type=BOUNDS_ERROR,
        solution="Array index out of bounds. Check array length before indexing.",
        related=["array", "index"],
    ),
    (
        pattern=r"MethodError",
        error_type=METHOD_ERROR,
        solution="No matching method for the function call. Check argument types.",
        related=["method", "function"],
    ),
    (
        pattern=r"TypeError",
        error_type=TYPE_ERROR,
        solution="Type assertion failed. Check variable types.",
        related=["type", "assertion"],
    ),
    (
        pattern=r"DomainError",
        error_type=DOMAIN_ERROR,
        solution="Input value is outside valid domain. Check function requirements.",
        related=["domain", "math"],
    ),
    (
        pattern=r"ArgumentError",
        error_type=ARGUMENT_ERROR,
        solution="Invalid argument provided. Check function documentation.",
        related=["argument", "parameter"],
    ),
]

"""
    parse_error(error_message::String)::ParsedError

Parse a Julia error message and extract useful information.

# Arguments
- `error_message::String`: The error message to parse

# Returns
- `ParsedError`: Parsed error information with suggestions

# Example
```julia
parsed = Debugging.parse_error("UndefVarError: x not defined")
```
"""
function parse_error(error_message::String)::ParsedError
    error_message = strip(error_message)

    # Detect error type
    error_type = detect_error_type(error_message)

    # Extract location info
    location = extract_location(error_message)

    # Get suggestion based on error type
    suggestion = get_suggestion(error_type, error_message)

    # Find related functions
    related = find_related_functions(error_message)

    return ParsedError(error_type, error_message, location, suggestion, related)
end

"""
    analyze_stacktrace(stacktrace::String)::StackTraceAnalysis

Analyze a Julia stack trace.

# Arguments
- `stacktrace::String`: The stack trace to analyze

# Returns
- `StackTraceAnalysis`: Analysis of the stack trace
"""
function analyze_stacktrace(stacktrace::String)::StackTraceAnalysis
    frames = parse_stacktrace(stacktrace)

    # Separate user code from library code
    user_code = filter(f -> !is_library_code(f), frames)
    library_code = filter(f -> is_library_code(f), frames)

    # Extract error message and line
    error_message = extract_error_message(stacktrace)
    error_line = extract_error_line(stacktrace)

    return StackTraceAnalysis(frames, error_message, error_line, user_code, library_code)
end

"""
    get_solution(error_type::ErrorType, error_message::String)::String

Get a detailed solution for an error.

# Arguments
- `error_type::ErrorType`: The type of error
- `error_message::String`: The full error message

# Returns
- `String`: Detailed solution with steps to fix
"""
function get_solution(error_type::ErrorType, error_message::String)::String
    base_solution = get_tips_for_error(error_type)

    # Use AI for more specific guidance
    try
        ai_guidance = OllamaClient.generate(
            """
Provide a step-by-step solution to fix this Julia error:

$error_message

Give specific, actionable steps.
""",
            "llama2",
        )

        if !isempty(ai_guidance)
            return "$base_solution\n\nAI Suggestion:\n$ai_guidance"
        end
    catch e
        # Fall back to base solution
    end

    return base_solution
end

"""
    generate_debugging_guide(error::ParsedError)::String

Generate a step-by-step debugging guide.

# Arguments
- `error::ParsedError`: The parsed error

# Returns
- `String`: A debugging guide
"""
function generate_debugging_guide(error::ParsedError)::String
    guide = """
    # Debugging Guide

    ## Error Summary
    **Type:** $(error.error_type)
    **Message:** $(error.message)

    ## What Happened
    $(error.suggestion)

    ## Steps to Fix

    1. **Understand the Error**
       - Read the error message carefully
       - Note the location where the error occurred

    2. **Check the Code**
       - Look at the line mentioned in the error
       - Check variable definitions and types

    3. **Apply the Fix
       - Identify the exact line causing the error
       - Check the variable types and values at that point
       - Apply the appropriate fix based on error type
       - Test the fix with the same input

    4. **Verify the Fix**
       - Run the code again
       - Check if the error is resolved

    ## Related Functions
       - $(join(error.related_functions, "\n       - "))
    """

    return guide
end

"""
    suggest_tests(error::ParsedError)::Vector{String}

Suggest unit tests that could catch this type of error.

# Arguments
- `error::ParsedError`: The parsed error

# Returns
- `Vector{String}`: Suggested test cases
"""
function suggest_tests(error::ParsedError)::Vector{String}
    tests = String[]

    push!(tests, "# Test for \$(error.error_type)")
    push!(tests, "@testset \"\$(error.error_type) handling\" begin")
    push!(tests, "    # Add test case that would catch this error")
    push!(tests, "end")

    return tests
end

"""
    find_performance_bottlenecks(code::String)::Vector{String}

Analyze code and suggest performance improvements.

# Arguments
- `code::String`: The Julia code to analyze

# Returns
- `Vector{String}`: Performance improvement suggestions
"""
function find_performance_bottlenecks(code::String)::Vector{String}
    suggestions = String[]

    # Check for common performance issues
    if occursin("append!", code)
        push!(suggestions, "Consider using pre-allocation instead of append! in loops")
    end

    if occursin(r"\[.*\] for .* in", code)
        push!(suggestions, "List comprehensions are faster than manual loops in Julia")
    end

    if occursin("println", code) && occursin("for ", code)
        push!(
            suggestions,
            "Printing in loops can significantly slow down performance. Consider accumulating output.",
        )
    end

    if occursin("global", code)
        push!(
            suggestions,
            "Avoid global variables - use function arguments and return values instead",
        )
    end

    # Use AI for detailed analysis
    try
        ai_analysis = OllamaClient.generate(
            """
Analyze this Julia code for performance bottlenecks:

```julia
\$code
```

List specific performance issues and improvements.
""",
            "llama2",
        )

        if !isempty(ai_analysis)
            for line in split(ai_analysis, "\n")
                if length(line) > 10
                    push!(suggestions, line)
                end
            end
        end
    catch e
        # Continue with basic analysis
    end

    return suggestions
end

# Helper functions

function detect_error_type(error_message::String)::ErrorType
    error_lower = lowercase(error_message)

    for common in COMMON_ERRORS
        if occursin(common.pattern, error_lower)
            return common.error_type
        end
    end

    return OTHER_ERROR
end

function extract_location(error_message::String)::String
    # Look for file:line patterns
    patterns = [
        r"at (.+):(\d+)" => "File",
        r"in .+ at (.+):(\d+)" => "File",
        r"(.+\.jl):(\d+)" => "File",
    ]

    for (pattern, prefix) in patterns
        match = match(pattern, error_message)
        if match !== nothing
            return "\$(prefix): \$(match[1]):\$(match[2])"
        end
    end

    return "Location not found in error message"
end

function get_suggestion(error_type::ErrorType, error_message::String)::String
    if haskey(DEBUGGING_TIPS, error_type)
        tips = DEBUGGING_TIPS[error_type]
        return join(tips, "\n")
    end

    return "This is a less common error type. Check the Julia documentation for more information."
end

function find_related_functions(error_message::String)::Vector{String}
    functions = String[]

    # Look for function names in error message
    pattern = r"`(\w+)`|function (\w+)|in (\w+) at"
    for match in eachmatch(pattern, error_message)
        for cap in match
            if cap !== nothing && length(cap) > 2
                push!(functions, cap)
            end
        end
    end

    return unique(functions)
end

function parse_stacktrace(stacktrace::String)::Vector{StackFrame}
    frames = StackFrame[]

    # Parse stack trace lines
    for line in split(stacktrace, "\n")
        if isempty(line) || startswith(line, "Stacktrace:")
            continue
        end

        # Look for patterns like " [1] foo() at file.jl:10"
        match = match(r"\s*\[(\d+)\]\s+(\w+)\(.*\)\s+at\s+(.+):(\d+)", line)
        if match !== nothing
            push!(frames, StackFrame(match[3], parse(Int, match[4]), match[2], "Main"))
            continue
        end

        # Try alternative pattern
        match = match(r"\s*\[(\d+)\]\s+(.+)\.(.+)\(.*\)\s+at\s+(.+):(\d+)", line)
        if match !== nothing
            push!(frames, StackFrame(match[4], parse(Int, match[5]), match[3], match[2]))
            continue
        end
    end

    return frames
end

function is_library_code(frame::StackFrame)::Bool
    # Consider stdlib and package code as library code
    library_indicators = ["julia/base", ".julia/packages", ".julia/stdlib"]

    for indicator in library_indicators
        if occursin(indicator, frame.file)
            return true
        end
    end

    return false
end

function extract_error_message(stacktrace::String)::String
    # First line or first non-empty line
    for line in split(stacktrace, "\n")
        if !isempty(strip(line))
            return strip(line)
        end
    end
    return "Unknown error"
end

function extract_error_line(stacktrace::String)::String
    # Look for "ERROR: LoadError:" pattern
    match = match(r"ERROR: .* at (.+):(\d+)", stacktrace)
    if match !== nothing
        return "Line \$(match[2]) in \$(match[1])"
    end
    return "Unknown line"
end

function get_tips_for_error(error_type::ErrorType)::String
    if error_type == UNDEFINED_VAR_ERROR
        return """
        The variable you're trying to use hasn't been defined.

        Common causes:
        - Typos in variable names
        - Variable defined in a different scope
        - Using a variable before it's assigned

        Check:
        1. Variable spelling matches exactly
        2. Variable is defined in the same or outer scope
        3. Variable is defined before use
        """
    elseif error_type == BOUNDS_ERROR
        return """
        You're trying to access an array element that doesn't exist.

        Common causes:
        - Using 0-based indexing (Julia is 1-indexed)
        - Array index exceeds array length
        - Modifying array while iterating

        Check:
        1. Use `length(arr)` to get array size
        2. Remember indices start at 1, not 0
        3. Use `eachindex(arr)` for safe iteration
        """
    elseif error_type == METHOD_ERROR
        return """
        No method matches the function call with these argument types.

        Common causes:
        - Wrong argument types
        - Missing required arguments
        - Function not defined for these types

        Check:
        1. Use `methods(function_name)` to see available methods
        2. Check argument types with `typeof(arg)`
        3. Ensure all required arguments are provided
        """
    elseif error_type == TYPE_ERROR
        return """
        A type assertion failed or types are incompatible.

        Common causes:
        - Variable has unexpected type
        - Type assertion doesn't match actual type
        - Type inference failed

        Check:
        1. Use `typeof(var)` to check actual type
        2. Use `isa(var, Type)` to check type
        3. Add type assertions with `::Type`
        """
    elseif error_type == DOMAIN_ERROR
        return """
        Input value is outside the valid domain for the operation.

        Common causes:
        - Negative number for square root
        - Division by zero
        - Invalid index

        Check:
        1. Check what values the function accepts
        2. Add input validation before calling
        3. Use `isvalid()` or similar checks
        """
    else
        return """
        An error occurred that needs investigation.

        Steps:
        1. Read the full error message
        2. Check the line number mentioned
        3. Look up the error type in Julia documentation
        4. Try to reproduce with a minimal example
        """
    end
end

"""
    get_error_types()::Vector{String}

Return the list of supported error types.
"""
function get_error_types()::Vector{String}
    return [
        "UndefinedVar",
        "MethodError",
        "DomainError",
        "ArgumentError",
        "BoundsError",
        "TypeError",
        "SyntaxError",
        "LoadError",
        "RuntimeError",
        "Other",
    ]
end

end  # End of Debugging module
