http = require 'http'
util = require 'util'
pluggable = require 'node-pluggable'

exports.use = pluggable.use
exports.on = pluggable.bind
exports.emit = pluggable.emit

exports.handle = (req, res) ->

  pluggable.run req.url, req, res, (err) ->
    pluggable.emit 'error', err, req, res if err

    unless res.finished and res.writable
      res.send 404, "Cannot #{req.method} #{req.url}\n"

  res.on 'finish', ->
    pluggable.emit 'after', req, res

exports.listen = (port, callback) ->
  server = http.createServer @
  server.listen.apply server, [port,
    ->
      pluggable.emit 'start'
      callback() if callback
  ]