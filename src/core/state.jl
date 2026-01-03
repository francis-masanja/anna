# src/core/state.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This file manages the global state of the Anna AI application.
#
# License: MIT
#

"""
The global state of the application.
"""
mutable struct AppState
    "The current conversation."
    conversation::Union{Conversation, Nothing}
    "The name of the user."
    user_name::String
end

"""
    init_state()::AppState

Initializes the global application state.
"""
function init_state()::AppState
    return AppState(nothing, "User")
end
