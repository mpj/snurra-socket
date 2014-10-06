sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect
chai.should()
snurra = require 'snurra'
_ = require 'highland'
deepMatches = require 'mout/object/deepMatches'

constructor = require '../src/index'

streamIt = (name, fn) -> it name, (done) -> fn().each -> done()
deepMatcher = (pattern) -> (target) -> deepMatches target, pattern

describe 'ws-json-client-stream', ->
  ws = null
  instance = null
  bus = null
  log = null
  beforeEach ->
    log = _()
    bus = snurra()
    bus.envelopes().pipe(log)
    ws =
      _handlers: {}
      on: sinon.spy (eventName, fn) -> ws._handlers[eventName] = fn
      emit: (eventName, value)      -> ws._handlers[eventName](value)
      send: sinon.stub()

  describe 'given an instance', ->
    beforeEach ->
      instance = constructor ws, bus

    it 'waits to subscribe to messages', ->
      expect(ws.on.calledWith('message')).to.be.false

    describe 'given an open event (before write)', ->
      beforeEach ->
        ws.emit 'open'

      it 'triggers the subscribe to messages', (done) ->
        process.nextTick ->
          expect(ws.on.calledWith('message')).to.be.true
          done()

      describe 'given that we write to the stream (after open)', ->
        beforeEach -> bus('send').write
          "command": "subscribe"

        it 'sends the written value', (done) ->
          setTimeout ->
            expect(ws.send.calledWith JSON.stringify
              "command": "subscribe"
            ).to.be.true
            done()
          , 10

        describe 'given that ws emits a message event', ->
          beforeEach (done) ->
            ws.emit 'message', JSON.stringify
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
          ws.send.throws(fakeError)

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
          ws.emit 'close'

        streamIt 'output stream emits it', ->
          log.filter deepMatcher
            topic: 'close'

    describe 'given that ws emits an error', ->
      fakeError = null
      beforeEach ->
        fakeError = new Error("This is a fake error")
        ws.emit 'error', fakeError

      streamIt 'output stream emits it as error', ->
        log.filter deepMatcher
          topic: 'error'
          message:
            message: "This is a fake error"

    describe 'given that we write to the stream (before open)', ->
      beforeEach -> bus('send').write
        "command": "subscribe"

      describe 'given an open event (after write)', ->
        beforeEach -> ws.emit 'open'

        it 'sends a the written value', ->
          ws.send.calledWith
            "command": "subscribe"
