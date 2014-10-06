_ = require 'highland'
socket = require('./index')()

_(socket('message')).each console.log

socket('connect').write 'ws://live.stellar.org:9001'

setTimeout ->
  socket('send').write
    "command" : "subscribe"
    "streams" :  [ "transactions" ]
,100
