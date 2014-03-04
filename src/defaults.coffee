lodash = require 'lodash'


module.exports =
  watch:  no
  production:  no
  files:  {}
  plugins:  {}

  static:
    path: './lib'
    port: 3333

  scriptedTemplateTypes: ['scripts']

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
      wrapper: (options, type, config) -> lodash.merge {}, options,
        hints:
          client: type in config.scriptedTemplateTypes

  liveReload:
    port: 35729
    enabled: yes
    inject: yes
    types: ['stylesheets', 'scripts']

  minifiers:
    js: 'uglify'
    css: 'minify-css'

  environment:  'development'

  environments:
    development:
      minify: no
      plugins:
        uglify:
          outSourceMap: yes
        jade:
          pretty: yes

    production:
      minify: yes
      plugins:
        uglify:
          outSourceMap: no
        jade:
          pretty: false

  extensions:
    scripts: 'js'
    javascripts: 'js'

    styles: 'css'
    stylesheets: 'css'
