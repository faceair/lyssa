process.env.NODE_ENV = 'test'

global._ = require 'underscore'
global.fs = require 'fs'
global.chai = require 'chai'
global.supertest = require 'supertest'
global.expect = chai.expect
global.ws = require 'nodejs-websocket'

chai.should()
chai.config.includeStack = true
