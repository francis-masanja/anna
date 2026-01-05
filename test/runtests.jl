using Test

@testset "AnnaAI.jl" begin
    # TODO: Add tests for each module
    include("ollama_client_test.jl")
    include("config_test.jl")
    include("logger_test.jl")
    include("storytelling_test.jl")
end
