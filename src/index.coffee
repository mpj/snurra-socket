duplexify = require 'duplexify'
Promise = require('es6-promise').Promise
_ = require 'highland'

constructStream = (ws) ->

  opened = new Promise (resolve) -> ws.on 'open', resolve
  opened.then ->
    ws.on 'message', (msg) ->
      readable.write JSON.parse msg

  writeError = (x) -> output.emit 'error', x

  readable  = _()
  writeable = _()

  writeable.each (x) -> opened.then ->
    try
      ws.send JSON.stringify x
    catch error
      writeError error

  output = duplexify writeable, readable, objectMode: true
  writeable.resume()
  ws.on 'error', writeError

  readable.resume()
  output

module.exports = constructStream
