http = require 'http'
util = require 'util'
pluggable = require 'node-pluggable'

exports.use = pluggable.use

exports.handle = (req, res) ->
  pluggable.on req.url, req, res, (err) ->
    if err
      res.statusCode = 500
      res.send util.inspect err
    else
      unless res.finished and ! res.socket.writable
        res.statusCode = 404
        res.header 'Content-Type', 'text/html; charset=utf-8'
        res.end "Cannot #{req.method} #{req.url}\n"

exports.listen = (port, callback) ->
  server = http.createServer @
  return server.listen.apply server, arguments