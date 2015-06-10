_ = require 'underscore'

Application = require './lib/application'

proxy = require './lib/middleware/proxy/index'
rawBody = require './lib/middleware/rawBody'

module.exports = (options) ->
  app = new Application()

  app.use rawBody options?.limit or '1mb'

  proxy app, options if options

  app.on 'start', ->
    unless process.env.NODE_ENV is 'test'
      console.log 'lyssa is runing ...'

  app.on 'error', (err, req, res) ->
    res.send 500, 'Internal Server Error' if res
    unless process.env.NODE_ENV is 'test'
      console.error err.stack or err.toString()

  app.on 'after', (req, res) ->
    unless process.env.NODE_ENV is 'test'
      console.log "#{req.method} #{req.url} #{res.statusCode} #{_.now() - req.timestamp}ms"

  return app
