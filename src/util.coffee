path = require 'path'


module.exports =
  localRequire: (module) ->
    try
      modulePath = path.join process.cwd(), 'node_modules', module
      return require modulePath

    catch userError
      throw userError unless userError.code is 'MODULE_NOT_FOUND'

      try
        return require module

      catch localError
        throw localError
