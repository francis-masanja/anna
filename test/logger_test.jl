using Test
using AnnaAI.Logger
using Logging

@testset "Logger" begin
    # Test case 1: Test logger initialization
    @testset "Logger Initialization" begin
        setup_logger("INFO")
        @test global_logger() isa ConsoleLogger
    end

    # Test case 2: Test logging levels
    @testset "Logging Levels" begin
        setup_logger("DEBUG")
        @test global_logger().min_level == Logging.Debug

        setup_logger("INFO")
        @test global_logger().min_level == Logging.Info

        setup_logger("WARN")
        @test global_logger().min_level == Logging.Warn

        setup_logger("ERROR")
        @test global_logger().min_level == Logging.Error

        # Test default case
        setup_logger("INVALID_LEVEL")
        @test global_logger().min_level == Logging.Info
    end
end
