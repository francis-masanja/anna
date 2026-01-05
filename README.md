# Anna AI

Anna AI is an intelligent assistant created for Annie Love of Blue, built with Ollama and Julia Programming Language.

## ✨ Core Abilities
- 📖 **Storytelling** - Engaging narrative generation and creative writing
- 💕 **Love & Companionship** - Kind, supportive, and caring interactions
- 🐢 **Julia Helper & Challenger** - Programming assistance and challenges
- 🐛 **Debugging** - Bug detection and resolution for Julia code
- 📚 **Julia Programming Q&A** - Answering programming questions
- 🦸 **Kindness** - Compassionate and positive interactions
- 🚫 **Dismissing Negativity** - Filtering out negative inputs

## 🚀 Quick Start

To run Anna AI, you need to have Julia and Ollama installed.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/AnnaAI.jl.git
   cd AnnaAI.jl
   ```
2. **Install the dependencies:**
   ```bash
   julia -e 'using Pkg; Pkg.instantiate()'
   ```
3. **Run the application in interactive mode:**
   ```bash
   julia main.jl --interactive
   ```
   You can also specify the environment:
   ```bash
   julia main.jl --interactive --env production
   ```
4. **Generate a story:**
   ```bash
   julia main.jl --story --prompt "A brave knight on a quest" --genre fantasy --length medium --tone adventurous
   ```
   You can also specify the environment for story generation:
   ```bash
   julia main.jl --story --prompt "A detective solving a mystery" --genre mystery --length short --tone suspenseful --env production
   ```
