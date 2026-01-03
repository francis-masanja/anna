# src/core/types.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This file defines the core data types used throughout the Anna AI application.
#
# License: MIT
#

"""
    Message

Represents a single message in a conversation.
"""
struct Message
    "The text of the message."
    text::String
    "The timestamp of the message."
    timestamp::Int
    "The sender of the message."
    sender::String
end

"""
    Conversation

Represents a conversation between the user and Anna AI.
"""
struct Conversation
    "A list of messages in the conversation."
    messages::Vector{Message}
end
