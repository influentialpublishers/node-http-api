PathParser  = require __dirname + '/../../../lib/parser/path'

describe 'PathParser', ->
    test_url    = 'http://test.com'
    parser      = null
    
    beforeEach ->
        parser  = PathParser { url: test_url }
    
    it 'should be a function with an arity of 1', ->
        PathParser.should.be.a 'function'
        PathParser.length.should.eql 1
        
    it 'should combine the base url and given url parts.', ->
        actual  = parser [ 'one', 'two', 'three' ]
        actual.should.eql 'http://test.com/one/two/three'