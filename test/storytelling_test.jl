using Test
using AnnaAI
using AnnaAI.Storytelling

@testset "Storytelling" begin
    @testset "Supported Lists" begin
        @test get_supported_genres() == [
            "fantasy",
            "sci-fi",
            "science_fiction",
            "romance",
            "mystery",
            "horror",
            "adventure",
            "comedy",
            "drama",
            "thriller",
        ]
        @test get_supported_lengths() == ["short", "medium", "long"]
        @test get_supported_tones() ==
            ["happy", "sad", "mysterious", "exciting", "neutral", "dark", "light"]
    end

    @testset "Word Count" begin
        @test count_words("This is a test.") == 4
        @test count_words("  This is another test.  ") == 4
        @test count_words("") == 0
        @test count_words("OneWord") == 1
    end

    @testset "Story Generation" begin
        # Mock generator function that captures the full_prompt
        captured_prompt = Ref("")
        mock_generator = (prompt, model) -> begin
            captured_prompt[] = prompt
            return "This is a mock story."
        end

        # Test successful generation
        story = generate_story(
            "A test prompt", "fantasy", "short", "happy", "test_model", mock_generator
        )
        @test story == "This is a mock story."
        @test contains(captured_prompt[], "a brief story (100-200 words)")
        @test contains(captured_prompt[], "with a cheerful, uplifting ending")

        # Test invalid length
        story = generate_story(
            "A test prompt",
            "fantasy",
            "invalid_length",
            "happy",
            "test_model",
            mock_generator,
        )
        @test story == "This is a mock story."
        @test contains(captured_prompt[], "a moderate-length story (300-500 words)") # Default to medium
        @test contains(captured_prompt[], "with a cheerful, uplifting ending")

        # Test invalid tone
        story = generate_story(
            "A test prompt",
            "fantasy",
            "short",
            "invalid_tone",
            "test_model",
            mock_generator,
        )
        @test story == "This is a mock story."
        @test contains(captured_prompt[], "a brief story (100-200 words)")
        @test contains(captured_prompt[], "with a balanced narrative") # Default to neutral

        # Test invalid length and tone
        story = generate_story(
            "A test prompt",
            "fantasy",
            "invalid_length",
            "invalid_tone",
            "test_model",
            mock_generator,
        )
        @test story == "This is a mock story."
        @test contains(captured_prompt[], "a moderate-length story (300-500 words)") # Default to medium
        @test contains(captured_prompt[], "with a balanced narrative") # Default to neutral

        # Mock generator that throws OllamaError
        error_generator =
            (prompt, model) -> throw(AnnaAI.OllamaClient.OllamaError("Test error"))
        story = generate_story(
            "A test prompt", "fantasy", "short", "happy", "test_model", error_generator
        )
        @test story == "Error generating story: Test error"

        # Mock generator that throws other exception
        exception_generator = (prompt, model) -> throw(ErrorException("Test exception"))
        story = generate_story(
            "A test prompt", "fantasy", "short", "happy", "test_model", exception_generator
        )
        @test story ==
            "An unexpected error occurred during story generation: ErrorException(\"Test exception\")"
    end
end
