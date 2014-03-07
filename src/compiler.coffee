chalk = require 'chalk'
gulp = require 'gulp'
lodash = require 'lodash'
path = require 'path'
winston = require 'winston'


filters =
  concat: require 'gulp-concat'
  filter: require 'gulp-filter'
  livereload: require 'gulp-livereload'
  plumber: require 'gulp-plumber'


class Compiler
  constructor: (@glp) ->
    @configuration = lodash.extend {}, @glp.configuration

    if lodash.isArray @configuration.filters
      newFilters = {}
      newFilters[name] = {} for name in @configuration.filters

      @configuration.filters = newFilters

  transform: (hints) -> (transform) =>
    if lodash.isString transform
      options = @configuration.plugins[transform] or {}
      transform = require 'gulp-' + transform

    if lodash.isFunction transform
      transform = transform lodash.merge options, hints

    return transform

  filteredPipeline: (type, output) ->
    steps = []

    for name, options of @configuration.filters
      winston.debug 'Applying ' + name + ' filter for ' + type

      if options.wrapper?
        options = options.wrapper options, type, @configuration, output

      # Initialize transform option and guarantee that it's an array.
      options.transform = name unless options.transform?

      if lodash.isString options.transform
        options.transform = [options.transform]

      unless lodash.isArray options.transform
        options.transform = [options.transform]

      # Initialize matches by using name as default extension
      options.matches ?= ['**/*.' + name]
      options.hints ?= {}

      # Filter for only streams matching the requested filter
      nextFilter = filters.filter options.matches
      steps.push nextFilter

      # Apply any filters for this specific transform
      transforms = lodash.map options.transform, @transform options.hints

      # Restore filter fater applying filter-specific transformations
      steps = steps.concat transforms
      steps.push nextFilter.restore()

    return steps

  compile: (type, _output, inputs) ->
    output = path.join path.join @configuration.root, _output

    outputText = chalk.white output
    typeText = chalk.white type
    winston.info 'Compiling to ' + outputText + ' as ' + typeText

    inputs = [inputs] if lodash.isString inputs

    build = (stream) =>
      # We don't concat if the output is a directory
      shouldConcat = output[output.length - 1] isnt '/'

      extension = @configuration.extensions[type]
      minifier = @configuration.minifiers[extension]

      if extension? and shouldConcat
        fullExtension = '.' + extension

        if @configuration.minify and minifier?
          fullExtension = '.min' + fullExtension

        output += output
        destination = path.dirname output

      else
        destination = output

      steps = []

      steps.push filters.plumber() if @configuration.watch
      steps = steps.concat @filteredPipeline type, output

      if shouldConcat
        steps.push filters.concat path.basename output

      if @configuration.minify and minifier?
        minifierTransform = @transform {}
        steps.push minifierTransform minifier

      if @configuration.liveReload.enabled
        steps.push filters.livereload @glp.liveReload

      steps.push gulp.dest destination
      stream.pipe step for step in steps

    watchText = 'watch mode is '

    if @configuration.watch
      watchText += 'enabled'
      stream = gulp.watch inputs

    else
      watchText += 'disabled'
      stream = gulp.src inputs

    stream.setMaxListeners 99

    build stream
    winston.debug watchText


module.exports = {Compiler}
