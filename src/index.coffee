Promise = require('es6-promise').Promise
_ = require 'highland'

constructStream = (ws, bus) ->

  _(bus('connect')).each (uri) ->
    conn = ws.createConnection uri

    opened = new Promise (resolve) -> conn.on 'open', resolve
    opened.then ->
      _('message', conn).map(JSON.parse).pipe(bus('message'))
      _('close', conn).pipe(bus('close'))

    errors = _()
    errors.map((x) -> message: x.message).pipe bus('error')

    _(bus('send')).each (x) -> opened.then ->
      try
        conn.send JSON.stringify x
      catch error
        errors.write error

    _('error', conn).pipe(errors)


module.exports = constructStream
