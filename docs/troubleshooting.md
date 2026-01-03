# Troubleshooting

## Ollama Connection Issues

### Error: "Ollama API request failed"

This error occurs when Anna AI cannot connect to the Ollama API.

**Solutions:**

- Make sure Ollama is running. You can check by running `ollama` in your terminal.
- Make sure the `OLLAMA_API_ENDPOINT` environment variable is set correctly. The default value is `http://localhost:11434`.

## Model Not Found

### Error: "model '<model_name>' not found"

This error occurs when the model specified in the configuration is not available in Ollama.

**Solution:**

- Pull the model using the `ollama pull <model_name>` command.
