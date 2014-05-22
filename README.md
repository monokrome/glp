glp
===

A simple configuration system for building projects using gulp.


Usage
-----

Firstly, install `glp`. It is recommended to be installed globally, but it is
not a requirement. Installing it globally may be unnecessary if you have
`./node_modules/.bin` in your path or if you run it manually via other
means - such as `npm start`. You can install it globally with this terminal
command:

```sh
npm install -g glp
```

If you get an error that you don't have permission to the files or you don't
want to install it globally, you can install it into your current directory's
*node_modules* with this terminal command:

```sh
npm install glp
```

In most cases, you can put your scripts into a `src/scripts` directory, and glp
will build them into the `public` directory. Templates go in `src/templates`,
and stylesheets go into `src/stylsheets` with the [default
configuration][defconf], but you can always define your own configuration
options if you would like to specify a more complicated build process. To
create a default configuration, create a new file called `glp.yml` and give it
the following content:

```yaml
glp: {}
```

Thanks to [PreferJS][prefer], the configuration file can also be placed in
`etc/glp.yml`, `~/.config/glp.yml`, `~/glp.yml`, `/usr/local/etc/glp.yml`
or any other standard locations on both Windows and UNIX platforms.

The configuration file format for GLP provides users the ability to instruct
GLP exactly how you want your files built. Some potential ways to configure GLP
include:

- **files** with *named groups* and where to find them
- **filters** for introducing new ways to transform files in *file group*
- **plugins** options for changing the way that glp uses them for each *file group*
- **concatenators** for defining which plugins are used for joining files in a *file group*
- **minifiers** for changing how a *file group* is minified
- **extensions** for defining the suffix of output files for each *file group*.
- **liveReload** options for defining changes affect your browser after compiling.
- **static** options for defining routing of built files to a local web server
- **tasks** to overlay different groupings of options based on command-line arguments

More details for configuration can be [found here][defaults].


[prefer]: https://github.com/LimpidTech/prefer
[defconf]: https://github.com/monokrome/glp/tree/master/src/defaults.coffee
[defaults]: https://github.com/monokrome/glp/blob/master/src/defaults.litcoffee

