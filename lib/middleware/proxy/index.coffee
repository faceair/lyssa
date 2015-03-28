module.exports = (app, options) ->
  {target, forward} = options
  unless target and forward
    throw new Error 'domain should not be empty.'

  app.use require('./web')(options)