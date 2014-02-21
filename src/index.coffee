lr = require 'tiny-lr'
express = require 'express'
connect_livereload = require 'connect-livereload'

prefer = require 'prefer'
http = require 'http'
path = require 'path'
_ = require 'lodash'


concat = require 'gulp-concat'
filter = require 'gulp-filter'
gulp = require 'gulp'
gutil = require 'gulp-util'
livereload = require 'gulp-livereload'
plumber = require 'gulp-plumber'
watch = require 'gulp-watch'


execute = (config) ->
  config.watch ?= no
  config.production ?= no
  config.files ?= {}
  config.plugins ?= {}


  config.static ?=
    path: './lib'
    port: 3333


  config.scriptedTemplateTypes = ['scripts']


  config.filters ?=
    coffee: {}
    sass: {}
    less: {}
    stylus: {}
    jade:
      wrapper: (options, type) ->
        hints:
          client: type in config.scriptedTemplateTypes


  config.liveReload ?=
    port: 35729
    enabled: yes
    types: ['styles']


  config.minifiers ?=
    js: 'uglify'
    css: 'minify-css'


  config.environment ?= 'development'


  config.environments ?=
    development:
      minify: no
      plugins:
        uglify:
          outSourceMap: yes
        jade:
          pretty: yes

    production:
      minify: yes
      plugins:
        uglify:
          outSourceMap: no
        jade:
          pretty: false


  config.extensions ?= {}
  _.merge config.extensions,
    scripts: 'js'
    javascripts: 'js'

    styles: 'css'
    stylesheets: 'css'


  lr_service = lr config.liveReload.port


  isLiveReloadEnabled = (type) ->
    return false if config.environment == 'production'
    return config.liveReload.enabled unless type?

    liveReloadIndex = config.liveReload.types.indexOf type
    return config.watch and liveReloadIndex > -1


  getTransform = (hints) ->
    return (transform) ->
      if _.isString transform
        options = config.plugins[transform] or {}
        transform = require 'gulp-' + transform
        transform = transform _.merge options, hints

      return transform


  getFilterSteps = (type, output) ->
    steps = []

    if _.isArray config.filters
      newFilters = {}
      newFilters[name] = {} for name in config.filters
      config.filters = newFilters

    for name, options of config.filters
      options = options.wrapper options, type, output if options.wrapper?

      options.transform = name unless options.transform?
      options.transform = [options.transform] if _.isString options.transform
      options.transform = [options.transform] unless _.isArray options.transform

      options.matches ?= '**/*.' + name
      options.hints ?= {}

      nextFilter = filter options.matches
      steps.push nextFilter

      transforms = _.map options.transform, getTransform options.hints

      steps = steps.concat transforms
      steps.push nextFilter.restore()

    return steps


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
    steps.push getTransform minifier if config.minify and minifier?
    steps.push gulp.dest destination
    steps.push livereload lr_service if isLiveReloadEnabled type

    input = input.pipe step for step in steps

  compile = (type) -> (output) ->
    inputs = config.files[type]

    for output, input of inputs
      compiler = compilerFactory type, output

      if config.watch
        options =
          glob: input
          name: type

        watch options, compiler

      else
        compiler gulp.src input

  tasks = (type) ->
    environment = config.environments[config.environment]
    config = _.merge environment, config if environment?

    unless type?
      types = _.keys config.files
      return _.map types, tasks

    inputs = config.files[type]
    throw new Error 'No inputs defined for ' + type unless inputs?

    outputs = _.keys inputs
    _.map outputs, compile type

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
      config = _.merge updates, config

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
      watch: yes

    if isLiveReloadEnabled()
      service.use connect_livereload
        port: config.liveReload.port

    service.use express.static config.static.path
    service.use express.directory config.static.path
    service.listen config.static.port

    colorizedPort = gutil.colors.magenta config.static.port
    gutil.log 'Serving static files at http://localhost:' + colorizedPort

    run_tasks configFileName,
