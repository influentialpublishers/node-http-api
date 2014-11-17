request         = require 'request'
Queue           = require 'pipeline-queue'
OptionsParser   = require __dirname + '/parser/options'

module.exports  = (config) ->
    headers         = config.headers
    queue           = config.queue || Queue()
    options_parser  = OptionsParser(config)
    
    handler = (done) ->
        return (err, httpResponse, body) ->
            if not err
                status = httpResponse.statusCode
                if status isnt 200
                    err = 
                        message: body or httpResponse.body or httpResponse.text
                        code: status
                        
                else if typeof body is 'string'
                    try 
                        body    = JSON.parse body
                    catch parse_err
                        err     = parse_err
            return done err, httpResponse, body
                
    
    call    = (options, done) ->
        return request options_parser(options), handler(done)
        
    method_factory  = (method) ->
        return (path, params, done) ->
            options =
                method: method
                path: path
                params: params
                headers: headers
                
            if method is 'GET'
                task        = call.bind call, options
                key_text    = JSON.stringify [ method, path ]
                key         = new Buffer(key_text).toString 'base64'
                
                return queue.run key, task, done or params
                
            else
                return call options, done or params
    
    return
        'setHeader': (key, value) ->
            headers[key]    = value
            return @
            
        'get': method_factory 'GET'
        'post': method_factory 'POST'
        'put': method_factory 'PUT'
        'del': method_factory 'DELETE'
        
        # Initialize a streaming request for an image
        # example:
        # ```
        # router.get('/image/:id', function (req, res, next) {
        #   var imgReq  = api.image(req.params.id);
        #   imgReq.on('error', next);
        #   return imgReq.pipe(res);
        # }
        # ```
        'image': (id, req, res, next) ->
            reqUrl  = [ url, 'image', id ].join '/'
            imgReq  = request reqUrl
            
            imgReq.on 'error', next
            return imgReq.pipe res