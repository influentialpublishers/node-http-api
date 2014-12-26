request         = require 'request'
Queue           = require 'pipeline-queue'
OptionsParser   = require __dirname + '/parser/options'

isJson          = (res) ->
  content_type  = res.headers['content-type']
  
  return /json/.test(content_type)

module.exports  = (config) ->
  agent           = config.agent || request
  headers         = config.headers || {}
  queue           = config.queue || Queue()
  options_parser  = OptionsParser(config)

  handler = (done) ->
    return (err, httpResponse, body) ->
      is_json_response  = /json/.test httpResponse.headers['content-type']
      is_body_string    = typeof body is 'string'
      
      if is_json_response and is_body_string
        console.log("PARSING BODY")
        try
          body    = JSON.parse body
        catch parse_err
          err     = parse_err
            
      if not err
        status = httpResponse.statusCode
        if status isnt 200
          err =
            message: body or httpResponse.body or httpResponse.text
            code: status
            
      return done err, httpResponse, body


  call    = (options, done) ->
    parsed  = options_parser options
    return agent parsed, handler(done)

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

  return {
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
      imgReq  = agent reqUrl

      imgReq.on 'error', next
      return imgReq.pipe res
  }
