{makeConfig} = require './webpack-helper'

getWebpackConfig = (name, isProduction) ->
  configs =
    main: [{
        entry: './index'
        output:
          filename: 'main.js'
      }, {isProduction, isDebug: true, excludeExternals: true}]
    'main.min': [{
        entry:
          main: './index'
        output:
          filename: 'main.min.js'
      }, {isProduction, excludeExternals: true, minify: true}]
    fullBuild: [{
        entry: './full-build'
        output:
          filename: 'full-build.js'
      }, {isProduction, isDebug: true, excludePeers: true}]
    'fullBuild.min': [{
        entry: './full-build'
        output:
          filename: 'full-build.min.js'
      }, {isProduction, excludePeers: true, minify: true}]
    'devServer': [{
        entry:
          demo: [
            './demo'
            './resources/styles/main.less'
            './resources/styles/demo.less'
          ]
      }, {isProduction, isDebug: true}]
    'demo': [{
        entry:
          'demo.js': [
            './demo'
          ]
          'demo': [
            './resources/styles/demo.less'
          ]
          'main': [
            './resources/styles/main.less'
          ]
        output:
          path: './assets/'
          publicPath: './'
          filename: '[name]'
      }, {isProduction, isDebug: true, minify: true}]

  if configs[name]?
    makeConfig.apply(null, configs[name])
  else
    {}

module.exports = getWebpackConfig
