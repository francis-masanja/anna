module Logger

using Logging

function setup_logger(level::String)
    log_level = getproperty(Logging, Symbol(level))
    global_logger(ConsoleLogger(stderr, log_level))
end

end
