chalk = require 'chalk'
gulp = require 'gulp'
lodash = require 'lodash'
path = require 'path'
winston = require 'winston'


filters =
  changed: require 'gulp-changed'
  cached: require 'gulp-cached'
  concat: require 'gulp-concat'
  filter: require 'gulp-filter'
  livereload: require 'gulp-livereload'
  plumber: require 'gulp-plumber'


ensureArray = (value) ->
  value = [value] if lodash.isString value
  value = [value] unless lodash.isArray value
  return value


class Compiler
  constructor: (@glp) ->
    @configuration = lodash.extend {}, @glp.configuration

    for type, filter of @configuration.filters
      if lodash.isArray filter
        newFilter = {}
        newFilter[name] = {} for name in filter
        @configuration.filters[type] = newFilter

  transform: (hints) -> (transform) =>
    options = @configuration.plugins[transform] or {}

    if lodash.isString transform
      transform = require 'gulp-' + transform

    if lodash.isFunction transform
      options = lodash.merge {}, hints, options
      transform = transform options

    return transform

  filteredPipeline: (type, output) ->
    steps = []

    typeFilters = @configuration.filters[type]
    return steps unless typeFilters?

    for name, options of typeFilters
      winston.debug 'Applying ' + name + ' filter for ' + type

      # Allow singular or plural name for options
      options.hints ?= options.hint or {}
      options.hint = undefined if options.hint?

      options.matches ?= options.match or ['**/*.' + name]
      options.match = undefined if options.match?

      options.transforms ?= options.transform or name
      options.transform = undefined if options.transform?

      unless lodash.isFunction options.matches
        options.matches = ensureArray options.matches

      options.transforms = ensureArray options.transforms

      # Filter for only streams matching the requested filter
      nextFilter = filters.filter options.matches
      transforms = lodash.map options.transforms, @transform options.hints

      steps.push nextFilter
      steps = steps.concat transforms
      steps.push nextFilter.restore()

    return steps

  compile: (type, _output, inputs) ->
    relatedUrl = '/' + _output
    output = path.join path.join @configuration.root, _output

    outputText = chalk.white output
    typeText = chalk.white type
    winston.debug 'Compiling to ' + outputText + ' as ' + typeText

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

        output += fullExtension
        relatedUrl += fullExtension

        destination = path.dirname output

      else
        destination = output

      steps = []

      steps.push filters.cached type
      steps.push filters.changed destination

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
      stream = stream.pipe step for step in steps

      return stream
  
    build gulp.src inputs
    return relatedUrl


module.exports = {Compiler}
