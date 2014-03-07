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
    steps.push gulp.dest destination

