async = require 'async'
defaults = require './defaults'
lodash = require 'lodash'
winston = require 'winston'

{Compiler} = require './compiler'
{serve} = require './service'


class GLP
  constructor: (@configurator) -> @configure()

  configure: ->
    @configurator.get (err, configuration) =>
      if err
        winston.err 'Configuration error: ' + err.toString()

      else
        # Partition a subset of the config if one of these names exists
        for partition in ['glp', 'config']
          subset = configuration[partition]
          configuration = subset if subset?

        @initialize lodash.merge {}, defaults, configuration

  initialize: (@configuration) ->
    serve.call @, @ if @configuration.static.enabled

    @run()

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
