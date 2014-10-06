sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect
chai.should()
snurra = require 'snurra'
_ = require 'highland'
deepMatches = require 'mout/object/deepMatches'
assert = require 'assert'
constructor = require '../src/index'

streamIt = (name, fn) -> it name, (done) -> fn().each -> done()
deepMatcher = (pattern) -> (target) -> deepMatches target, pattern

describe 'ws-json-client-stream', ->
  ws = null
  connection = null
  instance = null
  bus = null
  log = null
  beforeEach ->
    log = _()
    bus = snurra()
    bus.envelopes().pipe(log)
    connection =
      _handlers: {}
      on: sinon.spy (eventName, fn) -> connection._handlers[eventName] = fn
      emit: (eventName, value)      -> connection._handlers[eventName](value)
      send: sinon.stub()
    ws =
      createConnection: sinon.spy -> connection


  describe 'given an instance', ->
    beforeEach ->
      instance = constructor ws, bus

    it 'has not called createConnection yet', ->
      expect(ws.createConnection.callCount).to.equal 0

    it 'waits to subscribe to messages', ->
      expect(connection.on.calledWith('message')).to.be.false

    describe 'given that we open a connection', ->
      beforeEach (done) ->
        bus('connect').write 'ws://live.stellar.org:9001'
        setTimeout done, 10

      it 'should have called createConnection', ->
        assert ws.createConnection.calledWith('ws://live.stellar.org:9001')

      describe 'given an open event (before write)', ->
        beforeEach ->
          connection.emit 'open'

        it 'triggers the subscribe to messages', (done) ->
          process.nextTick ->
            expect(connection.on.calledWith('message')).to.be.true
            done()

        describe 'given that we write to the stream (after open)', ->
          beforeEach -> bus('send').write
            "command": "subscribe"

          it 'sends the written value', (done) ->
            setTimeout ->
              expect(connection.send.calledWith JSON.stringify
                "command": "subscribe"
              ).to.be.true
              done()
            , 10

          describe 'given that ws emits a message event', ->
            beforeEach (done) ->
              connection.emit 'message', JSON.stringify
                "property": 123
              setTimeout done, 10

            streamIt 'pushed it out on the stream', (done) ->
              log.filter deepMatcher
                topic: 'message'
                message:
                  "property": 123

        describe 'given that sending will throw an error', ->
          fakeError = new Error('I am a fake error')
          beforeEach ->
            connection.send.throws(fakeError)

          describe 'given that we write to the stream (after open)', ->
            beforeEach ->
              bus('send').write
                "command": "subscribe"

            streamIt 'streams the error', (done) ->
              log.filter deepMatcher
                topic: 'error'
                message:
                  message: 'I am a fake error'

        describe 'given that we emits a close event (after open)', ->
          beforeEach ->
            connection.emit 'close'

          streamIt 'output stream emits it', ->
            log.filter deepMatcher
              topic: 'close'

      describe 'given that ws emits an error', ->
        fakeError = null
        beforeEach ->
          fakeError = new Error("This is a fake error")
          connection.emit 'error', fakeError

        streamIt 'output stream emits it as error', ->
          log.filter deepMatcher
            topic: 'error'
            message:
              message: "This is a fake error"

      describe 'given that we write to the stream (before open)', ->
        beforeEach -> bus('send').write
          "command": "subscribe"

        describe 'given an open event (after write)', ->
          beforeEach -> connection.emit 'open'

          it 'sends a the written value', ->
            connection.send.calledWith
              "command": "subscribe"
