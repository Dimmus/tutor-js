_ = require 'underscore'
chai = require('chai')
expect = chai.expect
React = require 'react'
ReactDOM = require 'react-dom'
ReactTestUtils  = require 'react-addons-test-utils'
# No longer exists, needs further investigation if we're using it
# ReactContext   = require('react/lib/ReactContext')

{LocationBroadcast} = require 'react-router/Broadcasts'
{createRouterLocation} = require 'react-router/LocationUtils'
{Promise}      = require 'es6-promise'
{commonActions} = require './utilities'
sandbox = null
Sinon = {}


ROUTER = null
CURRENT_ROUTER_PARAMS = null
CURRENT_ROUTER_PATH   = null
CURRENT_ROUTER_QUERY = null
# Mock a router for the context
beforeEach ->
  sandbox = sinon.sandbox.create()
  ROUTER  = {
    transitionTo:     sandbox.spy()
    replaceWith:      sandbox.spy()
    blockTransitions: sandbox.spy()
    createHref: sandbox.spy( -> '/' )
  }
afterEach ->
  sandbox.restore()

# A wrapper component to setup the router context
Wrapper = React.createClass
  childContextTypes:
    router: React.PropTypes.object
  getChildContext: ->
    router: ROUTER
  render: ->
    location = createRouterLocation('/')
    React.createElement(LocationBroadcast, value: location,
      React.createElement(@props._wrapped_component,
        _.extend(_.omit(@props, '_wrapped_component'), ref: 'element')
      )
    )

Testing = {

  renderComponent: (component, options = {}) ->
    options.props ||= {}
    unmountAfter = options.unmountAfter or 1
    CURRENT_ROUTER_PARAMS = options.routerParams or {}
    CURRENT_ROUTER_QUERY = options.routerQuery or {}
    CURRENT_ROUTER_PATH   = options.routerPath   or '/'
    root = document.createElement('div')
    promise = new Promise( (resolve, reject) ->
      props = _.clone(options.props)
      props._wrapped_component = component
      wrapper = ReactDOM.render( React.createElement(Wrapper, props), root )
      resolve({
        root,
        wrapper,
        element: wrapper.refs.element,
        dom: ReactDOM.findDOMNode(wrapper.refs.element)
      })
    )
    # defer adding the then callback so it'll be called after whatever is attached after the return
    _.defer -> promise.then ->
      _.delay( ->
        ReactDOM.unmountComponentAtNode(root)
        CURRENT_ROUTER_PATH   = '/'
        CURRENT_ROUTER_PARAMS = {}
      , unmountAfter )
      return arguments
    promise

  actions: commonActions

  shallowRender: (component) ->
    context = router: ROUTER
#    ReactContext.current = context
    renderer = ReactTestUtils.createRenderer()
    renderer.render(component, context)
    output = renderer.getRenderOutput()
    ReactContext.current = {}

    output
}

# Hide the router behind a defined property so it can access the ROUTER variable that's set in the beforeEach
Object.defineProperty(Testing, 'router', {
  get: -> ROUTER
})

# Object.defineProperties(Sinon, {
#   spy:
#     get
# })

module.exports = {Testing, expect, sinon, React, _, ReactTestUtils}
