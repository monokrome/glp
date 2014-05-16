chalk = require 'chalk'
gulp = require 'gulp'
lodash = require 'lodash'
path = require 'path'
winston = require 'winston'
defaults = require './defaults'


{localRequire} = require './util'


filters =
  cache: require 'gulp-cached'
  changed: require 'gulp-changed'
  concat: require 'gulp-concat'
  filter: require 'gulp-filter'
  livereload: require 'gulp-livereload'
  plumber: require 'gulp-plumber'
  remember: require 'gulp-remember'
  order: require 'gulp-order'


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

    if lodash.isArray options
      args = options

      if args.length > 0
        options = args[args.length - 1]
      else
        options = {}

    if lodash.isObject options
      options = lodash.merge {}, hints, options

    args ?= []
    args.push options

    if lodash.isString transform
      transform = localRequire 'gulp-' + transform

    if lodash.isFunction transform
      transform = transform.apply @, args

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
      minifiers = @configuration.minifiers[extension]

      minifiers = [] unless minifiers?
      minifiers = ensureArray minifiers

      # Currently supports legacy usage.
      # DEPRECATED Will be removed for v0.4.0
      if lodash.isBoolean @configuration.minify
        # TODO: Better documentation for structure
        winston.warn 'Configuring "minify" as a boolean is deprecated.'

        @configuration.minify = lodash.assign {}, defaults.minify,
          enabled: @configuration.minify

      if extension? and shouldConcat
        fullExtension = '.' + extension

        if @configuration.minify.enabled and minifiers.length
          fullExtension = @configuration.minify.extension + fullExtension

        output += fullExtension
        relatedUrl += fullExtension

        destination = path.dirname output

      else
        destination = output

      steps = []

      if @configuration.cache.enabled
        cacheOptions = @configuration.plugins.cache or {}
        steps.push filters.cache output, cacheOptions

      unless shouldConcat
        steps.push filters.changed output,
          extension: extension

      if @configuration.watch
        steps.push filters.plumber()

      steps = steps.concat @filteredPipeline type, output

      if shouldConcat
        steps.push filters.remember output
        # steps.push filters.order type, inputs

        transformConcat = @transform {}

        concatWith = @configuration.concatenators[type]
        concatWith ?= filters.concat

        if lodash.isString concatWith
          concatOptions = @configuration.plugins[concatWith]
          concatWith = localRequire 'gulp-' + concatWith
        else
          concatOptions = @configuration.plugins.concat

        concatOptions ?= {}
        concatenatePath = path.basename output

        steps.push concatWith concatenatePath, concatOptions

      if @configuration.minify.enabled
        minifierTransform = @transform {}
        steps.push minifierTransform minifier for minifier in minifiers

      steps.push gulp.dest destination

      if @configuration.liveReload.enabled
        steps.push filters.livereload @glp.liveReload

      stream = stream.pipe step for step in steps

      return stream

    globOptions = lodash.first lodash.filter [
      @configuration.globOptions[type]
      @configuration.globOptions.default
    ]

    build gulp.src inputs, globOptions

    return relatedUrl


module.exports = {Compiler}

