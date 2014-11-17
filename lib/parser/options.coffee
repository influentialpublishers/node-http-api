PathParser      = require __dirname + '/path'
DEFAULT_METHOD  = 'GET'

module.exports  = (config) ->
    path_parser = PathParser { url: config.url }
    
    return (opts) ->
        opts.method = opts.method || DEFAULT_METHOD
        options =
            method: opts.method.toUpperCase()
            url: path_parser opts.path
            headers: opts.headers || config.headers
            
        if typeof opts.params isnt 'function'
            if options.method is 'GET'
                options.qs      = opts.params
            else
                options.body    = opts.params
                options.json    = true
                
        return options