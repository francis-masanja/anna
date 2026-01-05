# Architecture

## High-Level Overview

Anna AI follows a modular, layered architecture designed for extensibility and maintainability. This structure separates concerns, making it easier to develop, test, and scale individual components of the application.

```
+---------------------+
|  Presentation Layer | (TUI, CLI)
+---------------------+
          |
+---------------------+
|    Module Layer     | (Storytelling, JuliaHelper, etc.)
+---------------------+
          |
+---------------------+
|  Integration Layer  | (OllamaClient)
+---------------------+
          |
+---------------------+
|      Core Layer     | (Config, State, Types)
+---------------------+
          |
+---------------------+
|    Utility Layer    | (Logger, FileIO)
+---------------------+
```

### Core Layer

This is the foundation of the application. It includes:

-   **`core/config.jl`**: Manages configuration loading from TOML files, providing a centralized way to manage application settings.
-   **`core/state.jl`**: (If present) Manages the application's state, such as the current conversation history or user preferences.
-   **`core/types.jl`**: Defines the core data structures used throughout the application, such as `StoryParameters` and `StoryResult`.

### Integration Layer

This layer is responsible for communication with external services.

-   **`integration/ollama_client.jl`**: A client for the Ollama API, handling HTTP requests and parsing responses. It abstracts the details of the API, providing a simple interface for the rest of the application.
-   **`integration/prompt_builder.jl`**: Constructs the prompts sent to the Ollama API, incorporating user input and any additional context or instructions.
-   **`integration/response_parser.jl`**: Parses the JSON responses from the Ollama API, extracting the relevant information and converting it into Julia data structures.

### Module Layer

This layer contains the application's core features or "skills." Each module is responsible for a specific set of tasks.

-   **`modules/storytelling.jl`**: Generates stories based on user prompts.
-   **`modules/julia_helper.jl`**: Provides assistance with Julia programming, such as explaining code or offering challenges.
-   **`modules/debugging.jl`**: Helps debug Julia code.
-   **`modules/companionship.jl`**: Provides kind and supportive interactions.

### Utility Layer

This layer provides common functionality used across the application.

-   **`utils/logger.jl`**: A simple logging utility for recording application events.
-   **`utils/file_io.jl`**: Helper functions for reading and writing files.
-   **`utils/tui.jl`**: A terminal user interface toolkit for creating interactive command-line interfaces with colored output, menus, and loading spinners.

### Presentation Layer

This is the top layer of the application, responsible for user interaction.

-   **`main.jl`**: The main entry point of the application, which parses command-line arguments and dispatches to the appropriate modules.
-   The TUI components from `utils/tui.jl` are used here to create the user interface.

## Data Flow

The data flow in Anna AI is unidirectional, ensuring a clear and predictable application state.

1.  The user interacts with the **Presentation Layer** (e.g., by running a command in the CLI).
2.  The Presentation Layer parses the user's input and invokes the relevant function in the **Module Layer**.
3.  The Module Layer uses the **Integration Layer** to construct a prompt and send it to the Ollama API.
4.  The Integration Layer makes an HTTP request to the Ollama API and receives a response.
5.  The Integration Layer parses the response and returns it to the Module Layer.
6.  The Module Layer processes the data and returns a result to the Presentation Layer.
7.  The Presentation Layer formats the result and displays it to the user.