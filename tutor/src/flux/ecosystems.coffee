_ = require 'underscore'
flux = require 'flux-react'

LOADING = 'loading'
FAILED  = 'failed'

EcosystemsActions = flux.createActions [
  'load'
  'loaded'
  'FAILED'
]

EcosystemsStore = flux.createStore
  actions: _.values(EcosystemsActions)

  _asyncStatus: null

  load: -> # Used by API
    @_asyncStatus = LOADING
    @emit('load')

  loaded: (ecosystems) ->
    @_asyncStatus = null
    @_ecosystems = ecosystems
    @emit('loaded')

  FAILED: ->
    @_asyncStatus = FAILED
    @emit('failed')

  exports:
    isLoaded: -> not _.isEmpty(@_ecosystems)
    isLoading: -> @_asyncStatus is LOADING
    isFailed:  -> @_asyncStatus is FAILED

    allBooks: ->
      _.map @_ecosystems, (ecosystem) ->
        _.extend( _.first(ecosystem.books), {ecosystemId: "#{ecosystem.id}", ecosystemComments: ecosystem.comments} )

    first: ->
      _.first @_ecosystems

    getBook: (ecosystemId) ->
      _.first( _.findWhere(@_ecosystems, id: parseInt(ecosystemId, 10)).books )


module.exports = {EcosystemsActions, EcosystemsStore}
