# Configuration

Anna AI is configured using a `config.toml` file. The configuration is validated against a JSON schema.

## Configuration Options

### `ollama.model`

The name of the Ollama model to use.

### `logging.level`

The logging level. The possible values are:

- `DEBUG`
- `INFO`
- `WARN`
- `ERROR`

## Environment Variables

### `OLLAMA_API_ENDPOINT`

The endpoint of the Ollama API. Defaults to `http://localhost:11434`.
