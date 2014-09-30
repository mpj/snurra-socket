socket = require './index'
_ = require 'highland'

stellarSocket = socket 'ws://live.stellar.org:9001'

_(stellarSocket).each console.log

stellarSocket.write
  "command" : "subscribe"
  "streams" :  [ "transactions" ]
