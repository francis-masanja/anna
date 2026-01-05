using Test
using AnnaAI.Config

@testset "Config" begin
    # Test case 1: Test loading of default configuration
    @testset "Default Config Loading" begin
        config = load_config()
        @test config["ollama"]["model"] == "llama2"
        @test config["logging"]["level"] == "INFO"
    end

    # Test case 2: Test loading of a specific environment
    @testset "Environment Specific Config Loading" begin
        config = load_config("development")
        @test config["ollama"]["model"] == "llama2"
        @test config["logging"]["level"] == "DEBUG"
    end

    # Test case 3: Test invalid configuration
    @testset "Invalid Config" begin
        # Create a temporary invalid config file
        invalid_config_path = "config/invalid.toml"
        open(invalid_config_path, "w") do f
            write(f, "ollama = {}\n")
        end

        @test_throws ConfigError load_config("invalid")

        # Clean up the temporary file
        rm(invalid_config_path)
    end
end
