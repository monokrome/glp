glp
===

A simple configuration system for building projects using gulp.


Usage
-----

Firstly, install `glp`. It is recommended to be installed globally, but it is
not a requirement. Installing it globally may be unnecessary if you have
`./node_modules/.bin` in your path or if you run it manually via other
means - such as `npm start`.

In most cases, you can put your app's files into a `src` directory, and glp
will build them into the `public` directory. This will be compiled with the
provided [default configuration][defconf], but you can always create your own
configuration file if you would like to specify a more complicated build
process.

The configuration file format for GLP provides users the ability to instruct
GLP exactly how you want your files built. Some potential ways to configure GLP
include:

- **paths** to find and place files in
- **filters** for introducing new file formats
- **plugins** options for changing the way that glp uses gulp plugins
- **concatenators** for defining which plugins are used for joining built files together
- **minifiers** for changing how file types are minified
- **extensions** for defining the suffix of outut files.
- **liveReload** options for defining how changing files affects your browser
- **static** options for defining routing to GLP's web server
- **tasks** to run with the GLP command-line tool


[defconf]: https://github.com/monokrome/glp/tree/master/src/defaults.coffee

