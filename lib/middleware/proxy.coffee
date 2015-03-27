url = require 'url'
http = require 'http'
https = require 'https'
_ = require 'underscore'
BufferHelper = require 'bufferhelper'

module.exports = (domain) ->
  return (req, res, next) ->
    {protocol, host, port, hostname} = url.parse domain

    option =
      hostname: hostname
      port: port ? 80
      path: req.url
      method: req.method
      headers: _.extend req.headers,
        host: host

    switch protocol
      when 'https:'
        httpLib = https
      else
        httpLib = http

    httpReq = httpLib.request option, (httpRes) ->
      bufferHelper = new BufferHelper
      bufferHelper.load httpRes, (err, buffer) ->

        res.status httpRes.statusCode
        for key, value of httpRes.headers
          res.set key, value

        res.end buffer

    httpReq.on 'error', (err) ->
      next err

    httpReq.end()
