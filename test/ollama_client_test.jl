using Test
include("../src/integration/ollama_client.jl")

@testset "OllamaClient" begin
    @testset "generate" begin
        # This test requires Ollama to be running with the 'llama2' model
        prompt = "Why is the sky blue?"
        model = "llama2"
        response = OllamaClient.generate(prompt, model)
        @test !isempty(response)
    end
end
