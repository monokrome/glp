lodash = require 'lodash'


module.exports =
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
        matches: [
          '**/*.styl'
          '**/*.stylus'
        ]

    templates:
      jade:
        options:
          client: false

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
