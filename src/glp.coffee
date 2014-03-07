async = require 'async'
chalk = require 'chalk'
defaults = require './defaults'
gulp = require 'gulp'
lodash = require 'lodash'
winston = require 'winston'

{Compiler} = require './compiler'
{serve} = require './service'


class GLP
  constructor: (task, @configurator) ->
    @configure task

  configure: (@task) ->
    @configurator.get (err, configuration) =>
      if err
        winston.err 'Configuration error: ' + err.toString()

      else
        # Partition a subset of the config if one of these names exists
        for partition in ['glp', 'config']
          subset = configuration[partition]
          configuration = subset if subset?

        # Inherit default options
        nextConfiguration = lodash.merge {}, defaults
        configuration = lodash.merge nextConfiguration, configuration

        lodash.merge configuration, configuration.tasks[@task]

        @initialize configuration

  eventWatched: (filetype) -> (options) =>
    {type, path} = options

    if @configuration.static.enabled
      relatedFiles = @outputs[filetype]
    else
      relatedFiles = [path]

    @liveReload?.changed
      body:
        files: relatedFiles

  initialize: (@configuration) ->
    watchStatus = chalk.white 'enabled' if @configuration.watch
    watchStatus ?= chalk.white 'disabled'
    winston.debug 'watch mode is ' + watchStatus

    serve.call @, @ if @configuration.static.enabled

    @run()

  run: ->
    @outputs = {}
    types = lodash.keys @configuration.files
    lodash.map types, @compile

  compile: (type) =>
    @outputs[type] = []
    allInputs = []

    gulp.task type, =>
      winston.info 'Running task: ' + chalk.white type

      outputs = @configuration.files[type]
      throw new Error 'No inputs defined for ' + type unless outputs?

      compiler = new Compiler @

      for output, inputs of outputs
        @outputs[type].push compiler.compile type, output, inputs
        allInputs = lodash.unique lodash.flatten allInputs.concat inputs

    gulp.start type

    if @configuration.watch
      stream = gulp.watch allInputs, [type]
      stream.on 'change', @eventWatched type


module.exports = {GLP}
