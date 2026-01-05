# main.jl
#
# Author: Annie Love of Blue
# Date: 2026-01-03
#
# Entry point for Anna AI application.
#
# License: MIT
#

push!(LOAD_PATH, "src")
using AnnaAI

function main()
    # Parse arguments
    AnnaAI.julia_main()
end

main()

