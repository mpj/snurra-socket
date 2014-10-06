Promise = require('es6-promise').Promise
_ = require 'highland'

constructStream = (ws, bus) ->

  opened = new Promise (resolve) -> ws.on 'open', resolve
  opened.then ->
    _('message', ws).map(JSON.parse).pipe(bus('message'))
    _('close', ws).pipe(bus('close'))

  errors = _()
  errors.map((x) -> message: x.message).pipe bus('error')

  _(bus('send')).each (x) -> opened.then ->
    try
      ws.send JSON.stringify x
    catch error
      errors.write error

  _('error', ws).pipe(errors)


module.exports = constructStream
