API     = require __dirname + '/api'
Queue   = require 'pipeline-queue'

DEFAULT_CACHE_CLEAR_INTERVAL    = 30 * 1000 # default to thirty seconds.

module.exports  = (config) ->
    config.queue    = config.queue || Queue()
    timeout         = config.cacheClearTimeout || DEFAULT_CACHE_CLEAR_INTERVAL
    
    clearCache      = () ->
        run = () -> config.queue.cache.clear clearCache
        setTimeout(run, timeout)
        
    clearCache()
    
    return (req, res, next) ->
        req.api = API(config)
        return next()
