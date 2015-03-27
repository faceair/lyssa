getRawBody = require 'raw-body'

module.exports = (limit = '1mb') ->
  return (req, res, next) ->
    getRawBody req,
      length: req.headers['content-length'],
      limit: limit
    , (err, bodyContent) ->
      return next err if err
      req.bodyContent = bodyContent
      next()