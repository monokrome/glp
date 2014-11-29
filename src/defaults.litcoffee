# Configuration

GLP is configured using a specific grammar for explaining how to build a gulp
project. This grammar allows you to easily explain both simple and complicated
build processes in a single configuration file.

The file should be named **glp.yml** and can be placed in your project's root
directory, or it can be placed in an `etc` directory if preferred. You can
also include the configuration in your standard user-level or system-wide
configuration directories.

This document aims to provide a descriptive explanation of all configuration
and best practices for configuration options available to users of GLP.

GLP configuration options can be split up into the following high level
categories:

- **root** tells GLP where to place it's output files.
- **files** with *named groups* and where to find them
- **filters** for introducing new ways to transform files in *file group*
- **plugins** options for changing the way that glp uses them for each *file group*
- **concatenators** for defining which plugins are used for joining files in a *file group*
- **minifiers** for changing how a *file group* is minified
- **extensions** for defining the suffix of output files for each *file group*.
- **liveReload** options for defining changes affect your browser after compiling.
- **static** options for defining routing of built files to a local web server
- **tasks** to overlay different groupings of options based on command-line arguments

The following document will walk you step-by-step through GLP's default
configuration. It should help increase familiarity with all features, and how
to get started with building your own software using GLP and your favorite
programming languages.

## How GLP configuration works

This is a `.litcoffee` file, so we will be using the default configuration as a
practical example of what you can do when writing a configuration file. The
documented values are exactly what is exported to the compiler in GLP.

    module.exports =

These defaults are always overridden with any user-specific settings. When a
configuration file is loaded, GLP will run [lodash.merge][lodashmerge] in order
to merge the user's configuration data over the defaults. Once this is done,
the current *task* is merged in order to define commands which change behavior.

The one exception to this rule is the *files* option, which will be completely
overriden if provided by a user instead of being merged into the default
configuration. The *files* option will still be merged (instead of replaced) if
modified by *tasks*.

Don't  feel discouraged if this seems confusing. It will make more sense as you
read through this document and develop a better understanding of GLP's options.

# Options

## root

This should be a string that contains the name of the directory where you would
like GLP to put build output files.

      root: 'public'

## watch

This should be a boolean. When true, GLP will continue watching for changes to
files after tasks finish. Otherwise, it will not watch for any changes to files.

      watch: no

## debug

If this is set to true, then GLP will provide you with an exhaustive amount of
information describing the build process.

      debug: no

## globOptions

This can be an object which describes the options that should be passed to the
`gulp.watch` and `gulp.src` functions. The keys of the object should be the
name of the task that the options are used with. The value for each task should
be the options as [documented here][gulpsrcopts]. If no options are defined for
the currently active task, then the 'default' options will be used.

      globOptions:
        default:
          options: {}

## cache

Options for controlling how GLP caches files for faster compiling while watching
files for changes.

      cache:

The `cache.enabled` option is false by default, but can be made true if caching
happens to be working as expected with your project. This feature is disabled
by default because it is still experimental for now.

        enabled: no

## minify

Options for controlling how GLP minifies files.

      minify:

The `minify.enabled` option is false by default. You can set it to true
if you would like to minify built files.

        enabled: no

The `minify.extension` option  can be changed if you'd like to use a custom
prefix extension. For instance, files with the extension **.js** will be
converted to **.min.js** when minification is turned on. If you set
`minify.extension` to an empty string, it will then be converted into.

        extension: '.min'

## ordering

Ordering is disabled by default, but if ordering looks wrong (this shouldn't
ever happen) then you can use this in order to map specific file types to the
ordering you'd want the files to be in. This supports the globbing same format
which is supported by `gulp.src` and `gulp.watch` which is more thoroughly
[documented here][gulpsrcopts].

      ordering: {}


## plugins

The plugins option allows users to define options for gulp all plugins which
are used in the build process. In order to do this, you provide an object
where plugin names are *keys* and the options object is what will be passed
to the related gulp plugin.

Whenever referring to gulp plugins in GLP, you can optionally omit the `gulp-`
prefix. For instance, telling GLP to use a plugin called *cached* is the same
as telling it to use *gulp-cached*. The plugins are standard gulp plugins, so
any standard gulp plugin should work with GLP.


GLP has verify flexible support for easily configuring plugins to be used
through gulp, and tries to be as transparent as possible without sacrificing
usability in the process.

      plugins:

By default, we ask the [gulp-cached][gulpcached] plugin to optimize memory by
storing the files as MD5 instead of the entire file contents.

        cached:
          optimizeMemory: yes

We also want [gulp-uglify][gulpuglify] to output source maps.

        uglify:
          outSourceMap: yes

And while we're developing, we want our templates to be readable. So, we tell
jade to render pretty files instead of spitting them out in a single line.

        jade:
          pretty: yes

We'll also want source maps, so let's enabled those.

        coffee:
          sourceMap: yes

The options provided here can also be overridden per-file-type with the
*filters* option as described in the next section. Every setting can be
overriden on a per-task basis as well. This means that we can tell GLP to not
output source maps, pretty templates, or any other option via the *tasks*
option as will also be defined later.

## filters

It's important to remember that you can use any gulp plugin with GLP by
installing it into your project with [npm][npm]. In order to let users define
arbitrary ways of transforming files, we have filters.

The *filters* option provide a way to transform file contents for different
types of files. Each type of file can be given a number of filters which can
be passed through by defining them with this option.

      filters:

For instance, scripts can be compiled as *coffee*. This example is the least
verbose way to define a new filter. Since an empty settings object is being
mapped to the *coffee* type, GLP will automatically transform using a plugin
called [gulp-coffee][gulpcoffee] and match this plugin against a glob which
will automatically be generated with the filter name. In this case, the glob
pattern would be `\*\*/\*.coffee`.

It's worth noting here that you can install **any** gulp plugin into your
project, and GLP will support it when you just add a new filter option for it.

It is possible that the most powerful feature of GLP is it's ability to let you
configure it for any type of file without needing to touch any source code in
the process. This configuration file is all that you will need.

        scripts:
          coffee: {}

Scripts can also be compiled from jade templates. Since we have grouped
filters with the *scripts* file group, we also know that we want the compiled
files to become scripts in the end. So, we can use the `options` key to
forward options to [gulp-jade][gulpjade] in this case.

          jade:
            options:
              client: true

Some more default formats are provided here:

          typescript:
            matches: '**/*.ts'

          livescript:
            matches: '**/*.ls'

          handlebars:
            matches: '**/*.hbs'

          coco:
            matches: '**/*.co'

          eco:
            matches: '**/*.eco'

          dust:
            matches: ['**/*.djs', '**/*.dust']

          nunjucks:
            matches: ['**/*.njs', '**/*.nunjucks']

For the stylesheets group, we set up *sass* and *less* so that they will be
bound to files with matching extensions. We have no special options in these
cases, so we can just assign an empty object to them and let GLP assign
defaults as described before.

        stylesheets:
          sass: {}
          less: {}

There are more specific cases for stylus, though. We want to use the
[gulp-stylus][gulpstylus] module and match it against both *.styl* and
*.stylus* file extensions. A more specific case is that we also want to use the
'nib' module by default, but still allow users to override that choice with the
global *plugins* option. That's what the *hints* option is for.

By default, the *options* in a filter override global *plugins* options. The
*hints* option provides the opposite, where the *plugins* options act as an
override. This isn't an extremely useful feature, but it's helpful here for
users that might not want to use *nib* with their stylus files. They could just
set `use` to an empty array in the *plugins* option to prevent it.

          stylus:
            transforms: 'stylus'

            hints:
              use: ['nib']

            matches: [
              '**/*.styl'
              '**/*.stylus'
            ]

Here we redefine jade, but this time we are defining it as a template. The
reason that we have to define this twice is because we want to give different
options to [gulp-jade][gulpjade] for templates instead of scripts. This allows
us to render *templates* as *HTML* files, but jade files in *scripts* will be
rendered as *js* files as  described previously.

        templates:
          jade:
            options:
              client: false

Some more default formats are provided here:

          haml: {}
          ejs: {}
          mustache: {}

          markdown:
            matches: ['**/*.md', '**/*.markdown']

          template:
            matches: '**/*.tpl'

## concatenators

If you need to use custom concatenation rules, you can define them here. This
can be set to an object which maps types of files to a plugin name. It can also
be set to an array if you need to use multiple concatenators. They will be
streamed through plugins in the order that they are provided.

When a plugin isn't defined in the *concatenators* option for a specific type,
GLP will set it to 'concat' as the default value. GLP will automatically prefix
plugin names with *gulp-*, so you don't need to do that. So, the default
concatenator could be found in [NPM][npm] as [gulp-concat][gulpconcat]

As an example use case, some users might want to compile all of their scripts
to [gulp-commonjs][gulpcommonjs] files and then pass the commonjs output to
[gulp-concat][gulpconcat] afterward. That could be done simply by adding a new
key to *concatenators*, such as: `scripts: ['commonjs', 'concat']` followed by
installing the necessary NPM plugins in your project directory.

      concatenators: {}

## extensions


      extensions:
        scripts: 'js'
        stylesheets: 'css'
        templates: 'html'

## minifiers

The minifiers option tells GLP how to minify files with different file
extensions. As an example, the default would use the [gulp-uglify][gulpuglify]
plugin for *js* files, and the [gulp-minify-css][gulpminifycss] plugin for css
files.

      minifiers:
        js: 'uglify'
        css: 'minify-css'

## files

Options for defining what types of files exist, where they are located, and
where they are placed after they have finished being built. The default
configuration will build many types of files from a directory called `src`,
and place them into the **root** directory (the default root is *public* as
described above) after they have been built.

      files:

Each type of file that needs built is given a name. The names can be whatever
you like, and any number of named types can be created. For instance, the
following files are called *scripts*:

        scripts:

Each type is an object which maps a path to a list of files. If a path ends
with a slash, then the files will be copied into a **directory** containing
an output file for every source file that was built. If the path does not
end with a slash, then the  *concatenators* for this type will be used.

In this case, we are building all files ending with `.js`, `.coffee` and a few
other extensions. After they are built, the resulting files will be placed in
the directory specified by the **root** function as separate files. If the
output file was not a **directory** (as denoted by the ending slash) then the
files would also be concatenated and the resulting file would be given the
*extension* which corresponds to this type of file.

          '/scripts/': [
            'src/scripts/**/*.js'
            'src/scripts/**/*.coffee'
            'src/scripts/**/*.co'
            'src/scripts/**/*.ls'
            'src/scripts/**/*.ts'
            'src/scripts/**/*.hbs'
            'src/scripts/**/*.eco'
            'src/scripts/**/*.djs'
            'src/scripts/**/*.dust'
            'src/scripts/**/*.njs'
            'src/scripts/**/*.nunjucks'
          ]

Here, we are doing the same thing for *html*, *jade*, and some other file
extensions. This time we are outputting them with the `templates` file type.

        templates:
          '/': [
            'src/templates/**/*.html'
            'src/templates/**/*.jade'
            'src/templates/**/*.md'
            'src/templates/**/*.markdown'
            'src/templates/**/*.haml'
            'src/templates/**/*.ejs'
            'src/templates/**/*.mustache'
            'src/templates/**/*.tpl'
          ]

We are doing the same thing here but using different files and associating
them to the *stylesheets* file type.

        stylesheets:
          '/stylesheets/': [
            'src/stylesheets/**/*.css'
            'src/stylesheets/**/*.less'
            'src/stylesheets/**/*.sass'
            'src/stylesheets/**/*.stylus'
          ]

## static

GLP can optionally run a static server. If this is enabled, then the path
specified by the *root* option will be server on the provided static server
port.

      static:

The `static.enabled` function can be true or false. If it is true, then glp
will run it's static server. If false, then the server will not be run.

        enabled: no

The `static.directories` option can be set to true if you want to server
directory indexes, but defaults to false in order to prevent accidental
exposure of file listenings.

        directories: no

The `static.catchAll` option can be set to a string containing a filename. If
set, then all URLs that don't have a static file ready on the server will be
redirected to the given filename. This allows HTML5-style routing without
needing to define every possible route through GLP.

        catchAll: null

The `static.port` option tells GLP what port to serve it's static server on. By
default, the [local server][localserver] will be on port `3333`.

        port: 3333

**NOTE:** Remember that the *watch* option is separated from the *static*
option, so that glp's static server isn't limited to only development
environments.  If *watch* is set to false, then the server will not reflect
your changes until the next time you rebuild the files being served.

## liveReload

The `liveReload` options allow you to change the way that your browser responds
when files are changed.

      liveReload:

You can enable or disable liveReload by setting the `liveReload.enabled` option
to true, or disable it with a value of false.

        enabled: no

You can set the `liveReload.port` to whichever port you want the `liveReload`
server to be listening on if the default value of 35729 is not sufficient.

        port: 35729

If you have `liveReload.enabled` set to a truthy value, you're using the GLP
static server, and you set `liveReload.inject` to a truthy value, then GLP will
automatically inject *livereload.js* into the app from within the static
server. This means that you don't need to change your templates or install any
browser addons in order to get instant feedback of changes in your browser.

        inject: yes

## tasks

Every action in GLP is ran via a *task*. For instance, when you run `glp` you
are actually running the *default* task. This can also be ran with the `glp
default` command if you feel like typing extra. GLP allows you to define any
arbitrary task that you would like.

All tasks can optionally be set to a configuration object. When a configuration
option is provided for a task *it will override* the previously defined
options. Some examples:

      tasks:

You could define a task that is exactly the same as the default task by
providing no option overrides, for instance. This is how the default task
is defined:

        default: {}

You could also request GLP to watch all of your files by overriding the *watch*
option and setting it to yes. This is how the `glp watch` command works:

        watch:
          watch: yes

You could extend this even further by watching files *and* running a static
server with liveReload enabled. Under the hood, this is how the `glp server`
command works:

        server:
          watch: yes

          static:
            enabled: yes

          liveReload:
            enabled: yes

Maybe you don't want to run any servers or watch any files, but you may still
like to make sure that a specific build process outputs it's files in a
different way. This is exactly how `glp release` works:

        release:
          minify:
            enabled: yes

          plugins:
            coffee:
              sourceMap: no

            uglify:
              outSourceMap: no

            jade:
              pretty: no


[npm]: https://www.npmjs.org/
[gulpsrcopts]: https://github.com/gulpjs/gulp/blob/master/docs/API.md#gulpsrcglobs-options
[gulpcoffee]: https://www.npmjs.org/package/gulp-coffee
[gulpjade]: https://www.npmjs.org/package/gulp-jade
[gulpstylus]: https://www.npmjs.org/package/gulp-stylus
[gulpconcat]: https://github.com/wearefractal/gulp-concat
[gulpuglify]: https://www.npmjs.org/package/gulp-uglify
[gulpminifycss]: https://www.npmjs.org/package/gulp-minify-css
[gulpcached]: https://www.npmjs.org/package/gulp-cached
[localserver]: http://localhost:3333/
[lodashmerge]: http://lodash.com/docs#merge
