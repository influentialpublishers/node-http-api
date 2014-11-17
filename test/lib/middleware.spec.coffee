Middleware  = require __dirname + '/../../lib/middleware.coffee'

describe "Middleware", ->

  it "should be a function with an arity of 1", ->
    Middleware.should.be.a 'function'
    Middleware.length.should.eql 1
