
module.exports = (domain) ->
  return (req, res, next) ->
    console.log domain
    next()