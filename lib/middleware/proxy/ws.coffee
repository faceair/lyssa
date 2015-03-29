_ = require 'underscore'

setupSocket = (socket) ->
  socket.setTimeout 0
  socket.setNoDelay true
  socket.setKeepAlive true, 0

module.exports = (app, options)->
  return (req, socket) ->
    req.timestamp = _.now()

    for fn in [
      (req, socket) ->
        if req.method isnt 'GET' or ! req.headers.upgrade or req.headers.upgrade.toLowerCase() isnt 'websocket'
          socket.destroy()

      (req, socket, options) ->
        setupSocket socket
        proxyConf = require('./lib/proxyConf')(options)
        proxyConf req, (httpLib, httpConf) ->
          proxyReq = httpLib.request httpConf

          proxyReq.on 'error', (err) ->
            app.emit 'error', err

          proxyReq.on 'upgrade', (proxyRes, proxySocket) ->

            proxySocket.on 'error', (err) ->
              app.emit 'error', err

            setupSocket proxySocket

            socket.write 'HTTP/1.1 101 Switching Protocols\r\n'
            headersArr = []
            for key, value of proxyRes.headers
              headersArr.push "#{key}: #{value}"
            socket.write headersArr.join('\r\n') + '\r\n\r\n'
            socket.pipe(proxySocket).pipe socket

            app.emit 'after', req, proxyRes

          req.pipe proxyReq
    ]
      fn(req, socket, options)