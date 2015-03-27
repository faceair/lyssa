url = require 'url'
zlib = require 'zlib'
http = require 'http'
https = require 'https'
_ = require 'underscore'
iconv = require 'iconv-lite'
BufferHelper = require 'bufferhelper'

module.exports = ({domain, charset, self_domain}) ->
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

        encoding = httpRes.headers['content-encoding']

        res.status httpRes.statusCode
        for key, value of httpRes.headers
          res.set key, value

        unless /image\//i.test httpRes.headers['content-type']
          if encoding is 'gzip'
            buffer = zlib.gunzipSync buffer

          buffer = iconv.encode(iconv.decode(buffer, charset).replace(new RegExp(domain, 'ig'), self_domain), charset)

          if encoding is 'gzip'
            buffer = zlib.gzipSync buffer

        res.send buffer

    httpReq.on 'error', (err) ->
      next err

    httpReq.end()
