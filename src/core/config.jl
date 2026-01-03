module Config

using TOML
using JSONSchema

struct ConfigError <: Exception
    message::String
end

function validate_config(config::Dict)
    schema_path = "config/config.schema.json"
    schema = Schema(read(schema_path, String))
    try
        validate(config, schema)
    catch e
        throw(ConfigError("Configuration is invalid: $e"))
    end
end

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