path = require 'path'
ExtractTextPlugin = require 'extract-text-webpack-plugin'

isProduction = process.env.NODE_ENV is 'production'
LOADERS = if isProduction then [] else ["react-hot", "webpack-module-hot-accept"]
lessLoader = if isProduction
  { test: /\.less$/,   loader: ExtractTextPlugin.extract('css!less') }
else
  { test: /\.less$/,   loaders: LOADERS.concat('style-loader', 'css-loader', 'less-loader') }

module.exports =
  cache: true

  devtool: if isProduction then undefined else 'source-map'

  entry:
    exercises: [
      './src/index.coffee',
      './resources/styles/app.less'
    ]

  output:
    path: if isProduction then 'dist' else '/'
    filename: '[name].js'
    publicPath: if isProduction then '' else 'http://localhost:8001/dist/'

  plugins: [ new ExtractTextPlugin('exercises.css') ]

  module:
    noParse: [
      /\/sinon\.js/
    ]
    loaders: [
      lessLoader
      { test: /\.json$/,   loader: "json-loader" }
      { test: /\.coffee$/, loaders: LOADERS.concat("coffee-loader") }
      { test: /\.cjsx$/,   loaders: LOADERS.concat("coffee-jsx-loader") }
      { test: /\.(png|jpg|svg|gif)/, loader: 'file-loader?name=[name].[ext]'}
      { test: /\.(woff|woff2|eot|ttf)/, loader: "url-loader?limit=30000&name=[name]-[hash].[ext]" }
   ]
  resolve:
    root: [ path.resolve(__dirname, './src') ]
    extensions: ['', '.js', '.json', '.coffee', '.cjsx']

  devServer:
    contentBase: './'
    publicPath: 'http://localhost:8001/dist/'
    historyApiFallback: true
    inline: true
    port: process.env['PORT'] or 8001
    # It suppress error shown in console, so it has to be set to false.
    quiet: false,
    # It suppress everything except error, so it has to be set to false as well
    # to see success build.
    noInfo: false
    host: 'localhost',
    outputPath: '/',
    filename: '[name].js',
    hot: true
    stats:
      # Config for minimal console.log mess.
      assets: false,
      colors: true,
      version: false,
      hash: false,
      timings: false,
      chunks: false,
      chunkModules: false
