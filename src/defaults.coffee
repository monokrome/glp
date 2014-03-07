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

  scriptTypes: ['scripts']

  filters:
    coffee: {}
    sass: {}
    less: {}

    stylus:
      transform: 'stylus'
      matches: [
        '**/*.styl'
        '**/*.stylus'
      ]

    jade:
      wrapper: (options, type, config) ->
        client = type in config.scriptTypes

        return lodash.merge {}, options,
          hints:
            client: client

  minifiers:
    js: 'uglify'
    css: 'minify-css'

  extensions:
    scripts: 'js'
    javascripts: 'js'

    styles: 'css'
    stylesheets: 'css'

  liveReload:
    port: 35729
    enabled: yes
    inject: yes
    types: ['stylesheets', 'scripts']

  static:
    enabled: yes
    port: 3333

  environments:
    watch:
      watch: yes

    server:
      server: yes

      static:
        enabled: yes

    release:
      minify: yes

      plugins:
        uglify:
          outSourceMap: no

        jade:
          pretty: false
