rewire  = require 'rewire'
API     = rewire __dirname + '/../../lib/api'

describe 'API', ->
  fakeAgent  = null
  api        = null

  beforeEach ->
    fakeAgent = sinon.stub()
    api       = API { url: 'http://test.com', agent: fakeAgent }
  
  it 'should be a function with an arity of 1', ->
    API.should.be.a 'function'
    API.length.should.eql 1

  describe '::get()', ->

    it 'should make a call to the agent with the proper options set', (done) ->
      fakeAgent.callsArgWith 1,  null, {}, "test" 
      api.get ['test','path'], { thing: 'one' }, (err, httpResponse, body) ->
        expected_options  =
          url: "http://test.com/test/path"
          method: "GET"
          qs: { thing: 'one' }
          headers: undefined

        fakeAgent.calledWith(expected_options).should.be.true
        body.should.eql 'test'
        done()
        
    it 'should return a parse error if the given body is not a valid JSON', (done) ->
      fakeAgent.callsArgWith 1, null, { statusCode: 200 }, "something; { else: 'test\"))"
      api.get ['test', 'path'], { thing: 'two' }, (err, httpResponse, body) ->
        err.name.should.eql "SyntaxError"
        err.message.should.eql "Unexpected token s"
        done()

    it 'should return the body text if an error occurs without a response `body`', (done) ->
      fakeAgent.callsArgWith 1, null, { statusCode: 500, text: 'uh oh' }, undefined
      api.get ['test', 'path'], { thing: 'three' }, (err, httpResponse, body) ->
        expect(body).to.be.undefined
        err.message.should.eql 'uh oh'
        err.code.should.eql 500
        done()

    it 'should pass an error through and not parse the body', (done) ->
      fakeAgent.callsArgWith 1, 'bad juju', { statusCode: 200 }, '{ "test": "value" }'
      api.get ['test', 'path'], { thing: 'four' }, (err, httpResponse, body) ->
        body.should.eql '{ "test": "value" }'
        err.should.eql 'bad juju'
        done()
