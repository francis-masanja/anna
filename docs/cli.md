# Command-Line Interface

Anna AI can be controlled via a command-line interface (CLI) to access its various features directly.

## General Usage

The basic syntax for running Anna AI from the command line is:

```bash
julia main.jl [command] [options]
```

If you run `julia main.jl` with no arguments, it will start in an interactive menu mode.

## Commands and Options

### Interactive Mode

Starts an interactive chat session with Anna.

**Command:** `--interactive` or `-i`

**Example:**
```bash
julia main.jl --interactive
```

### Story Generation

Generates a story based on a prompt and other parameters.

**Command:** `--story`

**Options:**

-   `--prompt <text>`: The prompt or idea for the story.
-   `--genre <genre>`: The genre of the story (e.g., `fantasy`, `sci-fi`). Defaults to `fantasy`.
-   `--length <length>`: The desired length of the story (`short`, `medium`, `long`). Defaults to `short`.
-   `--tone <tone>`: The emotional tone of the story (e.g., `happy`, `mysterious`). Defaults to `neutral`.

**Example:**
```bash
julia main.jl --story --prompt "A robot who discovers music" --genre "sci-fi" --length "medium"
```

### Julia Helper

The CLI also provides access to the Julia Helper module for code analysis and challenges.

#### Code Analysis

Analyzes a Julia file and provides suggestions for improvement.

**Command:** `--analyze-code <file_path>`

**Example:**
```bash
julia main.jl --analyze-code "src/utils/tui.jl"
```

#### Code Explanation

Explains a Julia file, summarizing its key concepts and providing tips.

**Command:** `--explain-code <file_path>`

**Example:**
```bash
julia main.jl --explain-code "src/modules/storytelling.jl"
```

#### Programming Challenges

Gets a Julia programming challenge.

**Command:** `--get-challenge`

**Options:**

-   `--difficulty <level>`: The difficulty of the challenge (e.g., `easy`, `medium`, `hard`).
-   `--topic <topic>`: The topic of the challenge (e.g., `data_structures`, `algorithms`).

**Example:**
```bash
julia main.jl --get-challenge --difficulty "medium" --topic "algorithms"
```

### Global Options

-   `--env <environment>`: Specifies the environment to use (`development`, `staging`, or `production`). Defaults to `development`.

**Example:**
```bash
julia main.jl --interactive --env production
```