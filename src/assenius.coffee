#### Helpers & Setup

# Require our external dependencies
commander = require 'commander'
fs       = require 'fs'
im       = require 'imagemagick'
async    = require 'async'

# Extract the assenius version from `package.json`
version = JSON.parse(fs.readFileSync("#{__dirname}/../package.json")).version

# Default configuration options.
defaults =
  sprites : 'sprites.png'
  output  : 'osprites.css'
  crush  : false
  base_dir  : process.cwd()

config = {}

# ### Run from Commandline

# Run Assenius from a set of command line arguments.
#
# 1. Parse command line using [Commander JS](https://github.com/visionmedia/commander.js).
# 2. Document sources, or print the usage help if none are specified.
run = (args=process.argv) ->
  commander.version(version)
    .usage("[options] <css file>")
    .option("-s, --sprites [file]", "convert PNGs into sprites", defaults.sprites)
    .option("-b, --base_dir [path]", "base path to which css images are relative to", defaults.base)
    .option("-os, --output_sprites [file]", "output css file with sprites", defaults.output)
    .option("-p, --optimize", "optimize PNGs", defaults.crush)
    .parse(args)
    .name = "assenius"
  if commander.args.length
    assetize(commander.args.slice(), commander)
  else
    console.log commander.helpInformation()

assetize = (source, options = {}, callback = null) ->
    config[key] = defaults[key] for key, value of defaults
    config[key] = value for key, value of options if key of defaults
    config.source = source.shift()

    optimize(config.source)

offset = 0
images = []

optimize = (source) ->
    fs.readFile source, (error, buffer) ->
        code = buffer.toString()
        lines = code.split '\n'
        async.mapSeries lines, parseLine, (err, results) ->
            console.log results
            lines = (result.line for result in results).join "\n"
            paths = (result.path for result in results).filter (path) ->
                path != null
            console.log(lines)
            console.log(paths)

parseLine = (line, callback) ->
    bgMatcher = /background-image:\s+url\(['"]?(.*png)['"]?\)/g
    match = bgMatcher.exec(line)
    if match
        path = match[1]
        optimizeBg path, (line, path) ->
            callback null, (line: line, path: path)
    else
        callback null, (line: line, path: null)

optimizeBg = (path, callback) ->
    if path.indexOf('/') == 0
       imagePath = config.base_dir + path
       images.push imagePath
       getHeight imagePath, (height) ->
            offset = offset + height
            callback "\tbackground-image: url('#{config.sprites}')\n\t background-position: 0 -#{ offset }px", imagePath

getHeight = (imgPath, callback) ->
    im.identify imgPath, (err, features) ->
        callback(features.height)

# ### Exports

# Information about assenius, and functions for programatic usage.
exports[key] = value for key, value of {
  run           : run
}
