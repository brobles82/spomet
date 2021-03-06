assert = require 'assert'

suite 'Client Find', () ->
    test 'find something', (done, server, client) ->
        server.eval () ->
            Spomet.reset()
            
            e1 = new Spomet.Findable 'this should be easily found', '/', 'OID1', 1
            e2 = new Spomet.Findable 'much more harder to find', '/', 'OID2', 1
            e3 = new Spomet.Findable 'more harder to find, is that really the case', '/', 'OID3', 1
            
            Spomet.add e1
            Spomet.add e2
            Spomet.add e3
            
        client.eval () ->
            Spomet.Searches.find().observe
                added: (result) ->
                    emit 'result', result
                            
            e = Spomet.Searches.find().fetch()
            emit 'empty', e
            Spomet.defaultSearch.find 'much more'
            
            checkEmpty = () ->
                e = Spomet.Searches.find().fetch()
                emit 'emptyAgain', e
            Meteor.setTimeout checkEmpty, 50
        
        client.once 'empty', (r) ->
            assert.equal 0, r.length
        
        client.once 'emptyAgain', (r) ->
            assert.equal 0, r.length
            done()
        count = 0
        client.on 'result', (result) ->
            if count is 0
                assert.equal result.base, 'OID2'
            if count is 1
                assert.equal result.base, 'OID3'
                done()
            count += 1
  
        
                    