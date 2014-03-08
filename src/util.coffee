path = require 'path'


module.exports =
  localRequire: (module) ->
    try
      return require module
    catch e
      throw e unless e.code is 'MODULE_NOT_FOUND'

      try
        modulePath = path.join process.cwd(), 'node_modules', module
        return require modulePath
      catch _e
        throw _e unless e.code is 'MODULE_NOT_FOUND'
        throw e
