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
        configuration = lodash.merge {}, defaults, configuration

        # Wrap into orchestrator
        for name, _ of configuration.tasks
          gulp.task name, =>
            winston.info 'Running task: ' + chalk.white @task
            @initialize lodash.merge {}, configuration, configuration.tasks[@task]

        gulp.start @task

  initialize: (@configuration) ->
    watchStatus = chalk.white 'enabled' if @configuration.watch
    watchStatus ?= chalk.white 'disabled'
    winston.debug 'watch mode is ' + watchStatus

    serve.call @, @ if @configuration.static.enabled

    @run()

    gulp.watch '**/*.coffee', [@task] if @configuration.watch

  run: ->
    types = lodash.keys @configuration.files
    lodash.map types, @compile

  compile: (type) =>
    outputs = @configuration.files[type]
    throw new Error 'No inputs defined for ' + type unless outputs?

    compiler = new Compiler @

    for output, inputs of outputs
      compiler.compile type, output, inputs


module.exports = {GLP}
