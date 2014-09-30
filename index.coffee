constructor = require './src/index'
WebSocket = require 'ws'

module.exports = (uri) ->
  ws = new WebSocket(uri)
  constructor ws
