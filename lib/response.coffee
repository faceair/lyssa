_ = require 'underscore'

exports.get = (field) ->
 @getHeader field

exports.status = (status) ->
  @statusCode = status
  @

exports.set = exports.header = (name, value) ->
  headers = name

  unless _.isObject headers
    headers = {}
    headers[name] = value

  for name, value of headers
    @setHeader name, value
  @

exports.send = (status, data) ->
  unless _.isNumber status
    [status, data] = [null, status]

  unless @get('Content-Type')
    @set 'Content-Type', 'text/html; charset=utf-8'
  @status = status if status

  @end data
  @
