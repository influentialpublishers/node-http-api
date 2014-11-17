OptionsParser   = require __dirname + '/../../../lib/parser/options'

describe 'OptionsParser', ->
    test_url    = "http://my.url.test"
    headers     = { test: 'value' }
    parser      = null
    
    beforeEach ->
        parser  = OptionsParser { url: test_url, headers: headers }
    
    it 'should be a function with an arity of 1', ->
        OptionsParser.should.be.a 'function'
        OptionsParser.length.should.eql 1
        
    it 'should uppercase the given method', ->
        actual  = parser { method: 'get' }
        actual.method.should.equal 'GET'
        
    it 'should default to a GET request', ->
        actual  = parser { }
        actual.method.should.eql 'GET'
        
    it 'should set the URL as the parsed URL plus path', ->
        actual  = parser { path: [ 'test', 'two', 'three'] }
        actual.method.should.eql 'GET'
        actual.url.should.equal test_url + '/test/two/three'
        
    it 'should use the configuration headers if they are not given in the options', ->
        actual  = parser { }
        actual.headers.should.eql headers
        
    it 'should set the headers to the given headers', ->
        expected    = { my_test: 'my_value' }
        actual      = parser { headers: expected }
        actual.headers.should.eql expected
        
    it 'should set the `qs` if the method is `GET`', ->
        expected    = { my_params: { thing: 'one' } }
        actual      = parser { params: expected }
        actual.qs.should.eql expected
        expect(actual.body).to.be.undefined
        expect(actual.json).to.be.undefined

    it 'should set the `body` and `json` if the method isn\'t `GET`', ->
        expected    = { my_params: { thing: 'two' } }
        actual      = parser { method: 'POST', params: expected }
        actual.json.should.be.true
        actual.body.should.eql expected
        expect(actual.qs).to.be.undefined