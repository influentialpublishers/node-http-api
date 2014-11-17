isArray = require('util').isArray

module.exports  = (config) ->
    url = config.url
    
    return (path) ->
        path    = [path] if !isArray path
        path.unshift url
        
        return path.join '/'