# src/core/config.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# This file handles loading and validation of the application configuration.
#
# License: MIT
#

module Config

using TOML
using JSONSchema

"""
    ConfigError

An exception type for errors related to configuration loading and validation.
"""
struct ConfigError <: Exception
    message::String
end

"""
    validate_config(config::Dict)

Validates the configuration against the schema.

Throws a `ConfigError` if the configuration is invalid.
"""
function validate_config(config::Dict)
    schema_path = "config/config.schema.json"
    schema = Schema(read(schema_path, String))
    is_valid, errors = validate(config, schema)
    if !is_valid
        error_messages = ""
        for error in errors
            error_messages *= "\n - $(error.path): $(error.message)"
        end
        throw(ConfigError("Configuration is invalid:$error_messages"))
    end
end

"""
    load_config(env::Union{String, Nothing}=nothing)

Loads the configuration for the specified environment.

If no environment is specified, it loads the development environment.
The base configuration is loaded from `config/config.toml` and then
merged with the environment-specific configuration from `config/<env>.toml`.
"""
function load_config(env::Union{String, Nothing}=nothing)
    base_config = TOML.parsefile("config/config.toml")

    if env !== nothing
        env_config_path = "config/$env.toml"
        if isfile(env_config_path)
            env_config = TOML.parsefile(env_config_path)
            merge!(base_config, env_config)
        else
            @warn "Environment config file not found at $env_config_path"
        end
    end

    validate_config(base_config)
    return base_config
end

end
