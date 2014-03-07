lodash = require 'lodash'


defaults =
  root: 'public'

  watch: no
  production:  no

  files:  {}

  plugins:
    uglify:
      outSourceMap: yes

    jade:
      pretty: yes

  minify: no

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

  minifiers:
    js: 'uglify'
    css: 'minify-css'

  extensions:
    scripts: 'js'
    javascripts: 'js'

    styles: 'css'
    stylesheets: 'css'

  liveReload:
    enabled: no
    port: 35729
    inject: yes
    types: ['stylesheets', 'scripts']

  static:
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


module.exports = defaults
