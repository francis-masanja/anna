# Configuration

Anna AI uses a hierarchical configuration system, allowing you to set default values and override them for different environments (e.g., `development`, `production`).

## Configuration Files

The configuration is loaded from TOML files located in the `config/` directory.

-   **`config.toml`**: This file contains the default configuration for the application.
-   **`development.toml`**: This file contains configuration overrides for the `development` environment.
-   **`production.toml`**: This file contains configuration overrides for the `production` environment.
-   **`staging.toml`**: This file contains configuration overrides for the `staging` environment.

The application loads the `config.toml` file first, and then merges the environment-specific configuration file on top of it.

## Configuration Options

The configuration is validated against the `config/config.schema.json` file. Here are the available options:

### `ollama`

This section contains settings for the Ollama client.

-   **`model`** (string, required): The name of the Ollama model to use for generating responses (e.g., `"llama2"`).

### `logging`

This section contains settings for the application logger.

-   **`level`** (string, required): The minimum logging level to display. Possible values are:
    -   `"DEBUG"`
    -   `"INFO"`
    -   `"WARN"`
    -   `"ERROR"`

## Example Configuration

Here is an example of a `config/production.toml` file:

```toml
[ollama]
model = "llama2:7b-chat"

[logging]
level = "INFO"
```

This configuration will use the `llama2:7b-chat` model and set the logging level to `INFO` when the application is run in the `production` environment.

## Environment Variables

You can also override configuration settings using environment variables.

-   **`OLLAMA_API_ENDPOINT`**: The endpoint of the Ollama API. Defaults to `http://localhost:11434`.