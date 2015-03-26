_ = require 'underscore'

exports.set =
exports.header = (name, value) ->
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

  @statusCode = status if status

  @end data
  @

exports.status = (status) ->
  @statusCode = status
  @