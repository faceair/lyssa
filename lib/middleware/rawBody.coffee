getRawBody = require 'raw-body'

module.exports = (limit) ->
  return (req, res, next) ->
    getRawBody req,
      length: req.headers['content-length'],
      limit: limit
    , (err, bodyContent) ->
      return next err if err
      req.bodyContent = bodyContent
      next()
