axios = require 'axios'
extend = require 'lodash/extend'

OPTIONS = {}

emitError = (response) ->
  OPTIONS.handlers?.onFail?({response})

Networking = {

  setOptions: (options) ->
    OPTIONS = options

  perform: (opts) ->
    axios(extend({}, OPTIONS?.xhr, opts)).catch(emitError)
}

module.exports = Networking
