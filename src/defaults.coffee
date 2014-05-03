lodash = require 'lodash'


defaults =
  root: 'public'
  watch: no
  debug: no

  minify:
    enabled: no
    extension: '.min'

  files:
    scripts:
      '/': [
        'src/**/*.js'
        'src/**/*.coffee'
      ]

    templates:
      '/': [
        'src/**/*.html'
        'src/**/*.jade'
      ]

    stylesheets:
      '/': [
        'src/**/*.css'
        'src/**/*.less'
        'src/**/*.sass'
        'src/**/*.stylus'
      ]

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
      minify:
        enabled: yes

      plugins:
        uglify:
          outSourceMap: no

        jade:
          pretty: no


module.exports = defaults
