lodash = require 'lodash'


defaults =
  root: 'public'
  watch: no

  minify: no
  debug: no

  files:  {}

  plugins:
    cached:
      optimizeMemory: yes

    uglify:
      outSourceMap: yes

    jade:
      pretty: yes

  filters:
    scripts:
      coffee: {}

      jade:
        options:
          client: true

    stylesheets:
      sass: {}
      less: {}

      stylus:
        transforms: 'stylus'

        hints:
          use: ['nib']

        matches: [
          '**/*.styl'
          '**/*.stylus'
        ]

    templates:
      jade:
        options:
          client: false

    images:
      imagemin:
        matches: [
          '**/*.png'
          '**/*.gif'
          '**/*.jpg'
          '**/*.jpeg'
        ]

  concatenators: {}

  minifiers:
    js: 'uglify'
    css: 'minify-css'

  extensions:
    scripts: 'js'
    stylesheets: 'css'
    templates: 'html'

  liveReload:
    enabled: no
    port: 35729
    inject: yes

  static:
    directories: no
    catchAll: null
    enabled: no
    port: 3333

  tasks:
    default: {}

    watch:
      watch: yes

    server:
      watch: yes

      static:
        enabled: yes

      liveReload:
        enabled: yes

    release:
      minify: yes

      plugins:
        uglify:
          outSourceMap: no

        jade:
          pretty: no


# Alias some things for use preference reasons.
defaults.filters.styles = defaults.filters.stylesheets
defaults.filters.javascripts = defaults.filters.scripts

defaults.extensions.styles = defaults.extensions.stylesheets
defaults.extensions.javascripts = defaults.extensions.scripts

defaults.tasks.serve = defaults.tasks.server
defaults.tasks.production = defaults.tasks.release

defaults.concat = defaults.concatenators


module.exports = defaults
