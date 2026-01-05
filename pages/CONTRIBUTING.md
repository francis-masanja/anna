# Contributing to Anna AI

We welcome contributions to Anna AI! By participating in this project, you agree to abide by its [code of conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on our [GitHub Issues page](https://github.com/am3lue/AnnaAI.jl/issues). Please include:

*   A clear and concise description of the bug.
*   Steps to reproduce the behavior.
*   Expected behavior.
*   Screenshots if helpful.
*   Your operating system, Julia version, and Ollama version.

### Suggesting Enhancements

If you have an idea for a new feature or an improvement, please open an issue on our [GitHub Issues page](https://github.com/am3lue/AnnaAI.jl/issues). Describe your suggestion in detail and explain why you think it would be a valuable addition.

### Code Contributions

1.  **Fork the repository** and clone it to your local machine.
2.  **Create a new branch** for your feature or bug fix: `git checkout -b feature/your-feature-name` or `git checkout -b bugfix/issue-description`.
3.  **Make your changes**, ensuring they adhere to the project's coding style and conventions.
4.  **Write tests** for your changes.
5.  **Run tests** to ensure everything passes: `julia test/runtests.jl`.
6.  **Update documentation** if your changes affect any user-facing features or APIs.
7.  **Commit your changes** with a clear and concise commit message.
8.  **Push your branch** to your forked repository.
9.  **Open a Pull Request** to the `main` branch of the original repository. Provide a detailed description of your changes.

### Code Style

Anna AI uses `JuliaFormatter.jl` for code formatting. Please ensure your code is formatted correctly by running `julia -e 'using JuliaFormatter; format(".")'` before submitting a pull request.

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project, you agree to abide by its terms. (Note: `CODE_OF_CONDUCT.md` doesn't exist yet, but can be added later.)

Thank you for contributing to Anna AI!
