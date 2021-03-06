glp
===

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/monokrome/glp?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

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
and stylesheets go into `src/stylesheets` with the [default
configuration][defconf], but you can always define your own configuration
options if you would like to specify a more complicated build process. To
create a default configuration, create a new file called `glp.yml` and give it
the following content:

```yaml
glp: {}
```

Thanks to [PreferJS][prefer], the configuration file can also be placed in
`etc/glp.yml`, `~/.config/glp.yml`, `~/glp.yml`, `/usr/local/etc/glp.yml`
or any other standard locations on both Windows and UNIX platforms. It can also
be created in a varienty of formats, so you could call it `glp.json`,
`glp.coffee`, `glp.cson`, `glp.ini`, `glp.xml`, or use any other format
supported by [PreferJS][prefer].

The configuration file format for GLP provides users the ability to instruct
GLP exactly how you want your files built. Some potential ways to configure GLP
include:

- **files** defining *named groups* and where to build their sources
- **filters** for introducing new ways to transform files in *named groups*
- **plugins** options for changing the way that glp processes files for each *named group*
- **concatenators** for defining which plugins are used for joining files together in a *named group*
- **minifiers** for changing how a *named groups* are minified
- **extensions** for defining the suffix of output files for each *named group*.
- **liveReload** options for defining how changing files affects your browser after compiling.
- **static** options for defining routing of built files to a local web server.
- **tasks** to overlay different groupings of options based on command-line arguments.

More details for configuration can be [found here][defaults].


[prefer]: https://github.com/LimpidTech/prefer
[defconf]: https://github.com/monokrome/glp/tree/master/src/defaults.coffee
[defaults]: https://github.com/monokrome/glp/blob/master/src/defaults.litcoffee

