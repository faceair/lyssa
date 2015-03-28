http = require 'http'
util = require 'util'
Pluggable = require('node-pluggable')
pluggable = new Pluggable()

exports.use = pluggable.use
exports.on = pluggable.bind
exports.emit = pluggable.emit

exports.handle = (req, res) ->

  pluggable.run req.url, req, res, (err) ->
    pluggable.emit 'error', err, req, res if err

  res.on 'finish', ->
    pluggable.emit 'after', req, res

exports.listen = (port, callback) ->
  server = http.createServer @
  server.listen.apply server, [port,
    ->
      pluggable.emit 'start'
      callback() if callback
  ]