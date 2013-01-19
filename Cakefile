Assenius      = require './src/assenius'
CoffeeScript  = require 'coffee-script'
{spawn, exec} = require 'child_process'


task 'build', 'build the assenius library', (options) ->
    coffee = spawn 'node', ['./node_modules/coffee-script/bin/coffee','-c' + (if options.watch then 'w' else ''), '-o', 'lib', 'src']
    coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
    coffee.stderr.on 'data', (data) -> console.log data.toString().trim()



REPORTER = "min"

task "test", "run tests", ->
  exec "NODE_ENV=test
    mocha
    --compilers coffee:coffee-script
    --reporter #{REPORTER}
    --require coffee-script
    --colors
  ", (err, output) ->
    throw err if err
    console.log output
