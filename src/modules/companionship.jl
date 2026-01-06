# src/modules/companionship.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This module provides companionship features for Anna AI.
# It handles conversation memory, personality, and emotional responses.
#
# License: MIT
#

module Companionship

# Import required modules
using ..AnnaAI: OllamaClient
using Dates

"""
    PersonalityType

Enumeration of personality types.
"""
@enum PersonalityType begin
    FRIENDLY
    PROFESSIONAL
    CASUAL
    ENCOURAGING
    PLAYFUL
end

"""
    EmotionalState

Enumeration of emotional states.
"""
@enum EmotionalState begin
    NEUTRAL
    HAPPY
    SAD
    EXCITED
    CALM
    CONCERNED
    SUPPORTIVE
end

"""
    UserPreferences

A struct to hold user preferences.
"""
struct UserPreferences
    name::String
    personality::PersonalityType
    favorite_genres::Vector{String}
    daily_check_in::Bool
    memory_enabled::Bool
end

"""
    ConversationMemory

A struct to hold conversation memory.
"""
struct ConversationMemory
    messages::Vector{Dict{String,Any}}
    important_facts::Vector{String}
    topics_discussed::Vector{String}
    last_topics::Vector{String}
end

"""
    DailyCheckIn

A struct to hold daily check-in data.
"""
struct DailyCheckIn
    date::String
    mood::String
    note::String
    activities::Vector{String}
end

"""
    DEFAULT_PERSONALITIES

Default personality presets.
"""
const DEFAULT_PERSONALITIES = Dict{String,String}(
    "friendly" => "warm, caring, and approachable",
    "professional" => "knowledgeable, helpful, and clear",
    "casual" => "relaxed, easy-going, and conversational",
    "encouraging" => "supportive, motivating, and positive",
    "playful" => "cheerful, fun, and lighthearted",
)

"""
    MOOD_RESPONSES

Responses based on detected mood.
"""
const MOOD_RESPONSES = Dict{EmotionalState,Vector{String}}(
    HAPPY => [
        "I'm so glad to hear that!",
        "That's wonderful! I'd love to hear more.",
        "Your happiness makes me happy too!",
    ],
    SAD => [
        "I'm sorry you're feeling down. I'm here for you.",
        "That sounds tough. Would you like to talk about it?",
        "It's okay to feel sad sometimes. I'm here to listen.",
    ],
    EXCITED => [
        "That's amazing! I love your enthusiasm!",
        "Wow, tell me more! I'm curious!",
        "Your excitement is contagious!",
    ],
    CALM => [
        "There's a peaceful energy about you.",
        "That sounds lovely and serene.",
        "I appreciate your calm presence.",
    ],
    CONCERNED => [
        "I can sense something's on your mind. Do you want to share?",
        "I'm here to help if you'd like to talk.",
        "Take your time, I'm listening.",
    ],
    SUPPORTIVE => [
        "Thank you for sharing that with me.",
        "I appreciate your openness.",
        "Let's work through this together.",
    ],
    NEUTRAL => [
        "I'm here whenever you want to chat.",
        "How can I help you today?",
        "What's on your mind?",
    ],
)

"""
    MOTIVATIONAL_QUOTES

Collection of motivational quotes.
"""
const MOTIVATIONAL_QUOTES = [
    "Every day is a new opportunity to grow and learn.",
    "You are capable of amazing things!",
    "Small steps lead to big changes.",
    "Be kind to yourself - you're doing great.",
    "Your potential is limitless.",
    "Every challenge is a chance to grow stronger.",
    "Believe in yourself and all that you are.",
    "The best time to start is now.",
]

"""
    NEGATIVE_CONTENT_RESPONSES

Polite redirections for negative content.
"""
const NEGATIVE_CONTENT_RESPONSES = [
    "I'd prefer to focus on positive topics. Is there something nice I can help you with?",
    "Let's talk about something more uplifting! What are you interested in?",
    "I'm here to help and support you. What constructive topic can we explore together?",
]

"""
    init_memory()::ConversationMemory

Initialize conversation memory.
"""
function init_memory()::ConversationMemory
    return ConversationMemory(Dict{String,Any}[], String[], String[], String[])
end

"""
    init_preferences()::UserPreferences

Initialize default user preferences.
"""
function init_preferences()::UserPreferences
    return UserPreferences("Friend", FRIENDLY, String[], true, true)
end

"""
    personalize_response(preferences::UserPreferences, base_response::String)::String

Personalize a response based on user preferences.
"""
function personalize_response(preferences::UserPreferences, base_response::String)::String
    personality_desc = get(
        DEFAULT_PERSONALITIES, lowercase(string(preferences.personality)), ""
    )

    try
        prompt = """
        Rewrite this response to match a $(preferences.personality) personality style ($personality_desc):

        $base_response

        Keep the same meaning but adjust the tone and style.
        """
        personalized = OllamaClient.generate(prompt, "annaai")
        if !isempty(personalized)
            return personalized
        end
    catch e
    end

    return base_response
end

"""
    analyze_sentiment(text::String)::EmotionalState

Analyze the sentiment of text to detect emotional state.
"""
function analyze_sentiment(text::String)::EmotionalState
    text_lower = lowercase(text)

    happy_words = ["happy", "great", "wonderful", "amazing", "excited", "love", "awesome"]
    sad_words = ["sad", "down", "upset", "depressed", "disappointed", "lonely", "hurt"]
    excited_words = ["excited", "thrilled", "can't wait", "amazing", "incredible"]
    concerned_words = ["worried", "concerned", "anxious", "nervous", "scared", "afraid"]

    happy_count = count(w -> occursin(w, text_lower), happy_words)
    sad_count = count(w -> occursin(w, text_lower), sad_words)
    excited_count = count(w -> occursin(w, text_lower), excited_words)
    concerned_count = count(w -> occursin(w, text_lower), concerned_words)

    if excited_count > 0 && excited_count >= max(happy_count, sad_count)
        return EXCITED
    elseif happy_count > sad_count && happy_count > 0
        return HAPPY
    elseif sad_count > 0 && sad_count >= happy_count
        return SAD
    elseif concerned_count > 0
        return CONCERNED
    end

    return NEUTRAL
end

"""
    get_emotional_response(state::EmotionalState, user_input::String)::String

Get an emotionally appropriate response.
"""
function get_emotional_response(state::EmotionalState, user_input::String)::String
    if haskey(MOOD_RESPONSES, state)
        responses = MOOD_RESPONSES[state]
        return rand(responses)
    end

    return rand(MOOD_RESPONSES[NEUTRAL])
end

"""
    detect_negative_content(text::String)::Bool

Detect if text contains negative content that should be redirected.
"""
function detect_negative_content(text::String)::Bool
    text_lower = lowercase(text)

    negative_patterns = [
        r"hate", r"kill", r"hurt", r"destroy", r"terrible", r"awful", r"horrible", r"worst"
    ]

    for pattern in negative_patterns
        if occursin(pattern, text_lower)
            return true
        end
    end

    return false
end

"""
    get_negative_redirect()::String

Get a polite redirection for negative content.
"""
function get_negative_redirect()::String
    return rand(NEGATIVE_CONTENT_RESPONSES)
end

"""
    add_to_memory(memory::ConversationMemory, role::String, content::String)::ConversationMemory

Add a message to conversation memory.
"""
function add_to_memory(
    memory::ConversationMemory, role::String, content::String
)::ConversationMemory
    message = Dict{String,Any}(
        "role" => role, "content" => content, "timestamp" => string(now())
    )

    push!(memory.messages, message)

    new_topics = extract_topics(content)
    for topic in new_topics
        if !(topic in memory.topics_discussed)
            push!(memory.topics_discussed, topic)
        end
    end

    if length(memory.messages) > 50
        memory.messages = memory.messages[(end - 49):end]
    end

    return memory
end

"""
    extract_topics(text::String)::Vector{String}

Extract topics from text.
"""
function extract_topics(text::String)::Vector{String}
    topics = String[]

    topic_patterns = [
        (r"julia programming", "julia"),
        (r"programming", "programming"),
        (r"story|storytelling", "storytelling"),
        (r"debug|bug|error", "debugging"),
        (r"feeling|mood|day", "personal"),
        (r"work|job|career", "work"),
        (r"family|friends|relationships", "relationships"),
        (r"hobby|interest|fun", "hobbies"),
    ]

    text_lower = lowercase(text)
    for (pattern, topic) in topic_patterns
        if occursin(pattern, text_lower) && !(topic in topics)
            push!(topics, topic)
        end
    end

    return topics
end

"""
    get_memory_context(memory::ConversationMemory)::String

Get a context string from conversation memory for LLM prompts.
"""
function get_memory_context(memory::ConversationMemory)::String
    if isempty(memory.messages)
        return ""
    end

    recent_messages = memory.messages[max(1, end - 4):end]

    context_parts = ["Previous conversation:"]
    for msg in recent_messages
        push!(
            context_parts,
            "- $(msg["role"]): $(msg["content"][1:min(100, length(msg["content"]))])...",
        )
    end

    if !isempty(memory.topics_discussed)
        push!(
            context_parts,
            "Topics discussed: $(join(memory.topics_discussed[max(1, end-4):end], ", "))",
        )
    end

    return join(context_parts, "\n")
end

"""
    save_important_fact(memory::ConversationMemory, fact::String)::ConversationMemory

Save an important fact about the user.
"""
function save_important_fact(memory::ConversationMemory, fact::String)::ConversationMemory
    if !(fact in memory.important_facts)
        push!(memory.important_facts, fact)
    end

    return memory
end

"""
    get_important_facts(memory::ConversationMemory)::Vector{String}

Get saved important facts.
"""
function get_important_facts(memory::ConversationMemory)::Vector{String}
    return memory.important_facts
end

"""
    get_motivational_quote()::String

Get a random motivational quote.
"""
function get_motivational_quote()::String
    return rand(MOTIVATIONAL_QUOTES)
end

"""
    create_daily_check_in()::String

Generate a daily check-in prompt.
"""
function create_daily_check_in()::String
    prompts = [
        "Good morning! How are you feeling today?",
        "Hey! It's a new day. What's on your mind?",
        "Hi there! How has your day been so far?",
        "Hello! I'm here to check in. How are you doing?",
        "Good day! What's something you're looking forward to?",
    ]

    return rand(prompts)
end

"""
    set_personality(preferences::UserPreferences, personality::String)::UserPreferences

Set the personality type.
"""
function set_personality(preferences::UserPreferences, personality::String)::UserPreferences
    personality_upper = uppercase(personality)

    if personality_upper == "FRIENDLY"
        new_personality = FRIENDLY
    elseif personality_upper == "PROFESSIONAL"
        new_personality = PROFESSIONAL
    elseif personality_upper == "CASUAL"
        new_personality = CASUAL
    elseif personality_upper == "ENCOURAGING"
        new_personality = ENCOURAGING
    elseif personality_upper == "PLAYFUL"
        new_personality = PLAYFUL
    else
        new_personality = preferences.personality
    end

    return UserPreferences(
        preferences.name,
        new_personality,
        preferences.favorite_genres,
        preferences.daily_check_in,
        preferences.memory_enabled,
    )
end

"""
    get_personality_traits()::Vector{String}

Return available personality types.
"""
function get_personality_traits()::Vector{String}
    return ["friendly", "professional", "casual", "encouraging", "playful"]
end

"""
    build_system_prompt(preferences::UserPreferences, memory::ConversationMemory)::String

Build the system prompt for the LLM based on preferences and memory.
"""
function build_system_prompt(
    preferences::UserPreferences, memory::ConversationMemory
)::String
    personality_desc = get(
        DEFAULT_PERSONALITIES,
        lowercase(string(preferences.personality)),
        "helpful and friendly",
    )

    prompt = """
    You are Anna AI, a kind and supportive AI companion for $(preferences.name).
    Your personality is: $personality_desc.

    You are helpful, caring, and provide excellent assistance with:
    - Creative storytelling
    - Julia programming questions
    - Debugging help
    - General conversation

    Guidelines:
    - Be warm and supportive
    - Provide clear, helpful responses
    - Ask follow-up questions to understand better
    - If the user seems upset, offer support
    - Keep responses conversational but informative

    """

    if !isempty(memory.important_facts)
        prompt *= "\nRemember these important facts about the user:\n"
        for fact in memory.important_facts
            prompt *= "- $fact\n"
        end
    end

    return prompt
end

end  # End of Companionship module
