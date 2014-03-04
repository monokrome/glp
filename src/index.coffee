lr = require 'tiny-lr'
express = require 'express'
connect_livereload = require 'connect-livereload'

prefer = require 'prefer'
http = require 'http'
path = require 'path'
lodash = require 'lodash'


concat = require 'gulp-concat'
filter = require 'gulp-filter'
gulp = require 'gulp'
gutil = require 'gulp-util'
livereload = require 'gulp-livereload'
plumber = require 'gulp-plumber'
watch = require 'gulp-watch'

defaults = require './defaults'


execute = (config) ->
  config = lodash.merge {}, defaults, config


  if config.static.path[0..1] = './' and config.static.path.length > 2
    config.static.path = config.static.path[2..]


  isLiveReloadEnabled = (type) ->
    return false if config.environment == 'production'
    return config.liveReload.enabled unless type?

    liveReloadIndex = config.liveReload.types.indexOf type
    return config.watch and liveReloadIndex > -1


  getTransform = (hints) ->
    return (transform) ->
      if lodash.isString transform
        options = config.plugins[transform] or {}
        transform = require 'gulp-' + transform
        transform = transform lodash.merge options, hints

      return transform


  getFilterSteps = (type, output) ->
    steps = []

    if lodash.isArray config.filters
      newFilters = {}
      newFilters[name] = {} for name in config.filters
      config.filters = newFilters

    for name, options of config.filters
      options = options.wrapper options, type, config, output if options.wrapper?

      options.transform = name unless options.transform?
      options.transform = [options.transform] if lodash.isString options.transform
      options.transform = [options.transform] unless lodash.isArray options.transform

      options.matches ?= '**/*.' + name
      options.hints ?= {}

      nextFilter = filter options.matches
      steps.push nextFilter

      transforms = lodash.map options.transform, getTransform options.hints

      steps = steps.concat transforms
      steps.push nextFilter.restore()

    return steps


  triggerLiveReload = (output, type) -> (filename) ->
    if config.static?.path?
      index = output.indexOf config.static.path
      output = output[config.static.path.length..] if index is 0

    if config.extensions[type]?
      index = output.indexOf config.extensions[type]
      output += '.' + config.extensions[type] if index is -1

    config.liveReload.service?.changed
      body:
        files: [
          output
          filename
        ]


  compilerFactory = (type, output) -> (input) ->
    # Referece output separately so that it doesn't get modified directly
    finalFileName = output

    # When the finalFileName is a directory, concatenation will not occur.
    ignoreConcat = finalFileName[finalFileName.length - 1] == '/'

    extension = config.extensions[type]
    minifier = config.minifiers?[extension]

    if extension? and not ignoreConcat
      fullExtension = '.' + extension
      fullExtension = '.min' + fullExtension if config.minify and minifier?
      finalFileName += fullExtension
      destination = path.dirname finalFileName

    destination ?= finalFileName

    steps = []
    steps.push plumber() if config.watch

    steps = steps.concat getFilterSteps type, output
    steps.push concat path.basename finalFileName unless ignoreConcat

    if config.minify and minifier?
      minifierTransform = getTransform  {}
      steps.push minifierTransform minifier

    steps.push gulp.dest destination

    if config.service? and isLiveReloadEnabled type
      steps.push livereload config.liveReload.service

    input = input.pipe step for step in steps

  compile = (type) -> (output) ->
    inputs = config.files[type]

    for output, input of inputs
      compiler = compilerFactory type, output

      if config.watch
        options =
          glob: input
          name: type

        watcher = watch options, compiler
        watcher.gaze.on 'changed', (filename) ->
          if isLiveReloadEnabled type
            reloadMethod = triggerLiveReload output, type
            reloadMethod filename

      else
        compiler gulp.src input

  tasks = (type) ->
    environment = config.environments[config.environment]
    config = lodash.merge environment, config if environment?

    unless type?
      if config.service?
        if isLiveReloadEnabled()
          config.liveReload.service = lr()
          config.liveReload.service.listen config.liveReload.port

          colorizedPort = gutil.colors.magenta config.liveReload.port
          gutil.log 'LiveReload enabled at http://localhost:' + colorizedPort

          if config.liveReload.inject
            config.service.use connect_livereload
              port: config.liveReload.port

        config.service.use express.static config.static.path
        config.service.use express.directory config.static.path

        config.service.listen config.static.port

        colorizedPort = gutil.colors.magenta config.static.port
        gutil.log 'Serving static files at http://localhost:' + colorizedPort


      types = lodash.keys config.files
      return lodash.map types, tasks

    inputs = config.files[type]
    throw new Error 'No inputs defined for ' + type unless inputs?

    outputs = lodash.keys inputs
    lodash.map outputs, compile type

  tasks()


run_tasks = (configFileName, updates) ->
  updates ?= {}

  prefer.load configFileName, (err, configurator) ->
    throw new Error 'Could not load configuration file: ' + configFileName if err

    configurator.get (err, config) ->
      # Allows users to also use this file for other configuration needs.
      config = config.glp if config.glp?

      # Provides support for the silly brunch-style configurations.
      config = config.config if config.config?
      config = lodash.merge updates, config

      execute config


# WTF! Gulp requires that we pass gulp from the actual gulpfile?!
module.exports = (gulp, configFileName) ->
  configFileName ?= process.env.GLP_FILENAME or 'glp.yml'

  gulp.task 'default', -> run_tasks configFileName
  gulp.task 'develop', -> run_tasks configFileName


  gulp.task 'watch', ->
    run_tasks configFileName,
      watch: yes


  gulp.task 'release', ->
    run_tasks configFileName,
      environment: 'production'


  gulp.task 'serve', ->
    service = express()

    run_tasks configFileName,
      watch: yes
      service: service
