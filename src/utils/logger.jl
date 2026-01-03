module Logger

using Logging

function setup_logger(level::String)
    log_level = if level == "DEBUG"
        Logging.Debug
    elseif level == "INFO"
        Logging.Info
    elseif level == "WARN"
        Logging.Warn
    elseif level == "ERROR"
        Logging.Error
    else
        Logging.Info
    end
    global_logger(ConsoleLogger(stderr, log_level))
end

end
