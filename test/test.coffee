
require 'coffee-errors'

sinon = require 'sinon'
chai = require 'chai'
expect = chai.expect
chai.should()

constructor = require '../src/index'

describe 'ws-json-client-stream', ->
  clock = null
  ws = null
  instance = null
  output = null
  outputErrors = null
  beforeEach ->
    outputErrors = []
    output = []
    ws =
      _handlers: {}
      on: sinon.spy (eventName, fn) -> ws._handlers[eventName] = fn
      emit: (eventName, value)      -> ws._handlers[eventName](value)
      send: sinon.stub()
    clock = sinon.useFakeTimers()

  afterEach  ->
    clock.restore()

  describe 'given an instance', ->
    beforeEach ->
      instance = constructor ws
      instance.on 'data', output.push.bind(output)
      instance.on 'error', outputErrors.push.bind(outputErrors)

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
        beforeEach -> instance.write
          "command": "subscribe"

        it 'sends the written value', ->
          ws.send.calledWith
            "command": "subscribe"

        describe 'given that ws emits a message event', ->
          beforeEach ->
            ws.emit 'message', JSON.stringify
              "property": 123

          it 'pushed it out on the stream', ->
            expect(output[0]).to.deep.equal
              "property": 123

      describe 'given that sending will throw an error', ->
        fakeError = new Error('I am a fake error')
        beforeEach ->
          ws.send.throws(fakeError)

        describe 'given that we write to the stream (after open)', ->
          beforeEach ->
            instance.write
              "command": "subscribe"

          it 'streams the error', (done) ->
            process.nextTick ->
              expect(outputErrors[0]).to.equal(fakeError)
              done()


    describe 'given that ws emits an error', ->
      fakeError = null
      beforeEach ->
        fakeError = new Error("This is a fake error")
        ws.emit 'error', fakeError

      it 'output stream emits it as error', ->
        expect(outputErrors[0]).to.equal(fakeError)

    describe 'given that we write to the stream (before open)', ->
      beforeEach -> instance.write
        "command": "subscribe"

      describe 'given an open event (after write)', ->
        beforeEach -> ws.emit 'open'

        it 'sends a the written value', ->
          ws.send.calledWith
            "command": "subscribe"
