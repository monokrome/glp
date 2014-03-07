lr = require 'tiny-lr'
chalk = require 'chalk'
express = require 'express'
liveReload = require 'connect-livereload'
winston = require 'winston'


enableLiveReload = (glp) ->
  {configuration} = glp

  glp.liveReload = lr()
  glp.liveReload.listen configuration.liveReload.port

  if glp.service? and configuration.liveReload.inject
    glp.service.use liveReload
      port: configuration.liveReload.port

    suffix = 'enabled'

  suffix ?= 'disabled'

  address = chalk.white 'http://localhost:' + configuration.liveReload.port
  winston.info 'LiveReload available at ' + address + ' (HTML injection: ' + suffix + ')'

  return lr


serve = (glp) ->
  {configuration} = glp

  glp.service = express()

  # Set up static file serving
  glp.service.use express.static configuration.root
  glp.service.use express.directory configuration.root

  # Enable live-reload server if requested
  enableLiveReload glp if configuration.liveReload.enabled

  glp.service.listen configuration.static.port

  address = chalk.white 'http://localhost:' + configuration.static.port
  winston.info 'Serving static files at ' + address

  return glp.service


module.exports = {serve}