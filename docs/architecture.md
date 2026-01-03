# Architecture

## High-Level Overview

Anna AI is a modular application built with Julia. It is designed to be extensible and easy to maintain. The application is divided into several layers:

- **Core Layer**: This layer contains the core data types, state management, and configuration loading.
- **Integration Layer**: This layer provides clients for interacting with external services like the Ollama API.
- **Module Layer**: This layer contains the core features of the application, such as storytelling and Julia programming assistance.
- **Utility Layer**: This layer provides common utility functions, such as logging and file I/O.
- **Presentation Layer**: This layer is responsible for the user interface. Currently, it is a command-line interface.

## Data Flow

1. The user interacts with the presentation layer (CLI).
2. The presentation layer calls the appropriate module in the module layer.
3. The module layer uses the integration layer to interact with external services.
4. The integration layer returns data to the module layer.
5. The module layer processes the data and returns it to the presentation layer.
6. The presentation layer displays the data to the user.

## Module Dependencies

- `AnnaAI.jl` (main module) depends on `ArgParse.jl`, `Config`, `Logger`, and `OllamaClient`.
- `Config.jl` depends on `TOML.jl` and `JSONSchema.jl`.
- `OllamaClient.jl` depends on `HTTP.jl` and `JSON.jl`.
- `Logger.jl` depends on `Logging.jl`.
