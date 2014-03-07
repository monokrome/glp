{GLP} = require '../src/glp'
{argv} = require 'yargs'

chalk = require 'chalk'
lodash = require 'lodash'
prefer = require 'prefer'
winston = require 'winston'

configFileNames = lodash.filter lodash.flatten [
  argv.config
  argv.c
  process.env.GLP_CONFIG_FILENAME
  'glp.yml'
]

for configFileName in configFileNames
  break if configFileName?

prefer.load configFileName, (err, configurator) ->
  throw err if err

  winston.debug 'Using configuration: ' + chalk.white configFileName
  return new GLP configurator