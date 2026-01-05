# Troubleshooting

## Ollama Connection Issues

### Error: "Ollama API request failed"

This error occurs when Anna AI cannot connect to the Ollama API.

**Solutions:**

-   Make sure Ollama is running. You can check by running `ollama serve` in your terminal.
-   Verify that the `OLLAMA_API_ENDPOINT` environment variable is set correctly. The default value is `http://localhost:11434`.
-   Check your firewall settings to ensure Julia can communicate with the Ollama API endpoint.

## Model Not Found

### Error: "model '<model_name>' not found"

This error occurs when the model specified in your configuration is not available in Ollama.

**Solution:**

-   Pull the required model using the `ollama pull <model_name>` command. For example, `ollama pull llama2`.

## General Julia Issues

### Package Precompilation Errors

Sometimes, Julia packages might fail to precompile, leading to `LoadError` messages during `Pkg.instantiate()` or when running the application.

**Solutions:**

-   **Clean Build:** Try clearing Julia's package caches and re-instantiating:
    ```bash
    julia -e 'using Pkg; Pkg.build("AnnaAI"); Pkg.empty_scratchspaces(); Pkg.resolve(); Pkg.instantiate()'
    ```
-   **Update Packages:** Ensure all your Julia packages are up to date:
    ```julia
    julia -e 'using Pkg; Pkg.update()'
    ```
-   **Environment Issues:** If you are using a specific Julia environment, ensure it is activated correctly.

### `UndefVarError`

This error indicates that a variable or function name could not be found.

**Solutions:**

-   **Typo:** Check for spelling errors in your code or configuration.
-   **Missing `using` statement:** Ensure all necessary modules are imported using `using ModuleName`.
-   **Scope Issues:** Verify that the variable or function is accessible in the current scope.

### Slow Performance

Anna AI might run slowly on some systems.

**Solutions:**

-   **Hardware:** Ensure your system meets the recommended hardware requirements for running Ollama models. More RAM and a powerful GPU can significantly improve performance.
-   **Ollama Model Size:** Smaller Ollama models (`7b` versions) will generally run faster than larger ones (`13b`, `70b`).
-   **Julia Version:** Ensure you are using a recent, stable version of Julia.

## Still Having Trouble?

If you've gone through these steps and are still experiencing issues, please open an issue on the [GitHub repository](https://github.com/your-username/AnnaAI.jl/issues) with a detailed description of your problem, including:

-   Your operating system.
-   Julia version (`julia --version`).
-   Ollama version (`ollama --version`).
-   The full error message or unexpected behavior.
-   Steps to reproduce the issue.