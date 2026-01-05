module Config

export load_config, ConfigError

using TOML
using JSONSchema

struct ConfigError <: Exception
    message::String
end

"""
    validate_config(config::Dict)

Validates the configuration against a JSON schema to ensure all required
fields are present and have the correct types.
"""
function validate_config(config::Dict)
    schema_path = "config/config.schema.json"
    schema = Schema(read(schema_path, String))
    result = validate(config, schema)
    if result !== nothing
        throw(ConfigError("Configuration is invalid: $result"))
    end
end

"""
    load_config(env::Union{String, Nothing}=nothing)

Loads the base configuration from config.toml and optionally merges in
environment-specific settings from a separate config file.

# Arguments
- `env::Union{String, Nothing}`: Optional environment name (e.g., "development", "production")

# Returns
- `Dict`: The merged configuration dictionary
"""
function load_config(env::Union{String, Nothing}=nothing)
    # Load the base configuration from the main config file
    base_config = TOML.parsefile("config/config.toml")

    # If an environment is specified, load and merge environment-specific config
    if env !== nothing
        env_config_path = "config/$env.toml"
        if isfile(env_config_path)
            env_config = TOML.parsefile(env_config_path)
            merge!(base_config, env_config)  # Override base config with env-specific values
        else
            # @warn "Environment config file not found at $env_config_path"
        end
    end

    # Validate the final configuration against the schema
    validate_config(base_config)
    return base_config
end

end