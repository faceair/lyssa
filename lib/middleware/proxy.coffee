url = require 'url'
http = require 'http'
https = require 'https'
_ = require 'underscore'
BufferHelper = require 'bufferhelper'
zlib = require 'zlib'

module.exports = (domain) ->
  return (req, res, next) ->
    {protocol, host, port, hostname} = url.parse domain

    option =
      hostname: hostname
      port: port or 80
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

        unless /image\//i.test httpRes.headers['content-type']
          if httpRes.headers['content-encoding'] is 'gzip'
            html = zlib.gzipSync(zlib.gunzipSync(buffer).toString().replace(new RegExp(domain, 'ig'), ''))
          else
            html = buffer.toString().replace(new RegExp(domain, 'ig'), '')

        res.send html

    httpReq.on 'error', (err) ->
      next err

    httpReq.end()
