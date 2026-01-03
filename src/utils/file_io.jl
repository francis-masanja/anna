module FileIO

function read_file(path::String)
    try
        return read(path, String)
    catch e
        rethrow(e)
    end
end

function write_file(path::String, content::String)
    try
        write(path, content)
    catch e
        rethrow(e)
    end
end

end
