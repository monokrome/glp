defaults = require './defaults'
lodash = require 'lodash'


class Configuration
  partitions: [
    'glp'
    'config'
  ]

  normalize: (data) ->
    local = lodash.cloneDeep defaults
    local.files = data.files if data.files?

    lodash.merge local, data
    lodash.merge local, local.tasks[@task]

    return local

  partition: (data) ->
    for partition in @partitions
      subset = data[partition]
      return subset if subset?

    return data

  constructor: (data, @task) ->
    @data = @normalize @partition lodash.cloneDeep data

module.exports = {Configuration}

