chalk = require 'chalk'
express = require 'express'
liveReload = require 'connect-livereload'
lr = require 'tiny-lr'
path = require 'path'
winston = require 'winston'


enableLiveReload = (glp) ->
  # TODO: Recreate service in order to reflect configuration changes.
  return if glp.liveReload?

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
  # TODO: Recreate service in order to reflect configuration changes.
  return if glp.service?

  {configuration} = glp

  glp.service = express()

  # Enable live-reload server if requested
  enableLiveReload glp if configuration.liveReload.enabled

  # Set up static file serving
  glp.service.use express.static configuration.root

  if configuration.static.directories
    glp.service.use express.directory configuration.root

  glp.service.listen configuration.static.port

  if configuration.static.catchAll?
    glp.service.all '*', (request, response, next) ->
      response.sendfile configuration.static.catchAll,
        root: configuration.root

  address = chalk.white 'http://localhost:' + configuration.static.port
  winston.info 'Serving static files at ' + address

  return glp.service


module.exports = {serve}

