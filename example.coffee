client = require './index'
_ = require 'highland'

stellarSocket = client 'ws://live.stellar.org:9001'

_(stellarSocket).each console.log

stellarSocket.write
  "command" : "subscribe"
  "streams" :  [ "transactions" ]
