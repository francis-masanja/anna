<div align="center">
  <img src="https://raw.githubusercontent.com/am3lue/AnnaAI.jl/main/docs/assets/logo.png" alt="Anna AI Logo" width="200">
  <h1>Anna AI</h1>
  <p><i>An intelligent assistant for creative and technical tasks, built with Julia and Ollama.</i></p>
  
  <p>
    <a href="https://github.com/am3lue/AnnaAI.jl/actions/workflows/CI.yml">
      <img src="https://github.com/am3lue/AnnaAI.jl/actions/workflows/CI.yml/badge.svg" alt="CI">
    </a>
    <a href="https://codecov.io/gh/am3lue/AnnaAI.jl">
      <img src="https://codecov.io/gh/am3lue/AnnaAI.jl/branch/main/graph/badge.svg" alt="Codecov">
    </a>
    <a href="https://github.com/am3lue/AnnaAI.jl/blob/main/LICENSE">
      <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License">
    </a>
  </p>
</div>

Anna AI is an intelligent assistant created for Annie Love of Blue, built with the Julia Programming Language and powered by [Ollama](https://ollama.ai/). She is designed to be a versatile and kind companion, capable of assisting with a wide range of creative and technical tasks.

## ✨ Core Abilities

- 📖 **Storytelling**: Engaging narrative generation and creative writing.
- 💕 **Love & Companionship**: Kind, supportive, and caring interactions.
- 🐢 **Julia Helper & Challenger**: Programming assistance and challenges for Julia developers.
- 🐛 **Debugging**: Bug detection and resolution for Julia code.
- 📚 **Julia Programming Q&A**: Answering questions about the Julia language.
- 🦸 **Kindness**: Compassionate and positive interactions.
- 🚫 **Dismissing Negativity**: Filtering out negative inputs to maintain a positive environment.

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Julia**: Anna AI is built on Julia. You can download it from the [official Julia website](https://julialang.org/downloads/).
- **Ollama**: The AI is powered by Ollama. Follow the instructions on the [Ollama website](https://ollama.ai/) to install and run it. Make sure you have a model pulled, for example, `ollama pull llama2`.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/AnnaAI.jl.git
    cd AnnaAI.jl
    ```

2.  **Install the dependencies:**
    Open a Julia REPL in the project directory and run:
    ```julia
    using Pkg
    Pkg.instantiate()
    ```

### Configuration

Anna AI uses a configuration file to manage settings. You can create a `config/development.toml` or `config/production.toml` file to override the default settings in `config/config.toml`. See the `config.schema.json` file for the available options.

## usage

You can run Anna AI in interactive mode or use it to perform specific tasks directly from the command line.

### Interactive Mode

To start a conversation with Anna, run:
```bash
julia main.jl --interactive
```

You can also specify the environment:
```bash
julia main.jl --interactive --env production
```

### Story Generation

To generate a story, use the `--story` flag:
```bash
julia main.jl --story --prompt "A brave knight on a quest" --genre fantasy --length medium --tone adventurous
```

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.