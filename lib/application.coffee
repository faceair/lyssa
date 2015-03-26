http = require 'http'
util = require 'util'
pluggable = require 'node-pluggable'

exports.use = pluggable.use

exports.handle = (req, res) ->
  pluggable.on req.url, req, res, (err) ->
    if err
      res.statusCode = 500
      res.send util.inspect err

exports.listen = (port, callback) ->
  server = http.createServer @
  return server.listen.apply server, arguments