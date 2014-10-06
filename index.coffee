constructor = require './src/index'
ws = require 'ws'
snurra = require 'snurra'

module.exports = ->
  bus = snurra()
  constructor ws, bus
  bus
