_ = require 'lodash'
hash = require 'object-hash'
moment = require 'moment-timezone'

validateOptions = (requiredProperties) ->
  (options) ->
    _.every(requiredProperties, _.partial(_.has, options))

hashWithArrays = _.partial(hash, _, {unorderedArrays: true})

makeHashWith = (uniqueProperties...) ->
  (objectToHash) ->
    hashWithArrays(_.pick(objectToHash, uniqueProperties...))

constructCollection = (context, makeItem, lookup) ->
  context._cache = {}
  context.make = makeItem
  context.lookup = _.memoize(lookup) or _.memoize(_.flow(makeItem, hashWithArrays))

  context

class Collection
  constructor: (makeItem, lookup) ->
    constructCollection(@, makeItem, lookup)

  set: (args...) =>
    @_cache[@lookup(args...)] = @make(args...)

  load: (items) =>
    _.forEach items, @set

  get: (args...) =>
    _.cloneDeep(@_cache[@lookup(args...)])

  delete: (args...) =>
    delete @_cache[@lookup(args...)]
    true


class CollectionCached
  constructor: (makeItem, lookup) ->
    constructCollection(@, makeItem, lookup)

  update: (args...) =>
    @_cache[@lookup(args...)] ?= []
    @_cache[@lookup(args...)].push(@make(args...))

  get: (args...) =>
    _.flow(_.last, _.cloneDeep)(@_cache[@lookup(args...)])

  getAll: (args...) =>
    _.cloneDeep(@_cache[@lookup(args...)])

  getSize: (args...) =>
    _.size(@_cache[@lookup(args...)]) or 0

  reset: (args...) =>
    delete @_cache[@lookup(args...)]
    true


# the combination of these should be unique
ROUTE_UNIQUES = ['subject', 'action']

# options will be stored by hash of ROUTE_UNIQUES
#
# routesSchema = [{
#   subject: 'exercises'
#   topic: '*' // optional, default
#   pattern: ''
#   method: 'GET'
#   action: 'fetch' // optional, defaults to method
#   baseUrl: // optional, will override API class default
#   onSuccess: -> // optional
#   onFail: -> // optional
#   headers: // optional
#   withCredentials: // option
# }]
METHODS_TO_ACTIONS =
  POST: 'create'
  GET: 'read'
  PATCH: 'update'
  DELETE: 'delete'

makeRoute = (options = {}) ->
  # TODO throw errors
  # TODO look for validator lib, maybe even use React.PropTypes base/would be nice to
  #   validate that method is valid for example and not just exists.
  return options unless validateOptions('subject', 'pattern', 'method')(options)

  DEFAULT_ROUTE_OPTIONS =
    topic: '*'

  route = _.merge({}, DEFAULT_ROUTE_OPTIONS, options)
  route?.action = METHODS_TO_ACTIONS[route.method]
  route

class Routes extends Collection
  constructor: (routes = [], uniqueProperties = ROUTE_UNIQUES) ->
    hashRoute = makeHashWith(uniqueProperties...)
    lookup = _.flow(makeRoute, hashRoute)

    super(makeRoute, lookup)
    @load(routes)
    @

simplifyRequestConfig = (requestConfig) ->
  requestConfig = _.pick(requestConfig, 'method', 'data', 'url')
  requestConfig = _.omit(requestConfig, 'data') if _.isEmpty(requestConfig.data)
  requestConfig

class XHRRecords
  constructor: ->
    hashRequestConfig = _.flow(simplifyRequestConfig, hashWithArrays)
    makeTime = ->
      moment()

    @_requests = new CollectionCached(makeTime, hashRequestConfig)
    @_responses = new CollectionCached(makeTime, hashRequestConfig)
    @

  queRequest: (requestConfig) =>
    @_requests.update(requestConfig)

  recordResponse: ({config}) =>
    @_responses.update(config)

  isPending: (requestConfig) =>
    if requestConfig
      @_requests.getSize(requestConfig) > @_responses.getSize(requestConfig)
    else
      _.some @_requests._cache, (cachedRequests, requestKey) =>
        _.size(cachedRequests) > _.size(@_responses._cache[requestKey])

  getResponseTime: (requestConfig) =>
    @_requests.get(requestConfig).diff(@_responses.get(requestConfig))


utils = {validateOptions, hashWithArrays, makeHashWith, constructCollection, makeRoute, simplifyRequestConfig}

module.exports = {Collection, CollectionCached, Routes, XHRRecords, utils}
