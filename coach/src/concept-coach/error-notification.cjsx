React = require 'react'
BS = require 'react-bootstrap'
_  = require 'underscore'
api = require '../api'


BASE_CONTACT_LINK = 'http://openstax.force.com/support?l=en_US&c=Products%3AConcept_Coach&cu=1&fs=ContactUs&q='

makeContactMessage = (errors, userAgent, location) ->
  template = """Hello!
    I ran into a problem while using Concept Coach on
    #{userAgent} at #{location}.

    Here is some additional info:
    #{errors.join()}."""

makeContactURL = (errors, windowContext) ->
  userAgent = windowContext.navigator.userAgent
  location = windowContext.location.href

  q = encodeURIComponent(makeContactMessage(errors, userAgent, location))

  "#{BASE_CONTACT_LINK}#{q}"


ErrorNotification = React.createClass

  getInitialState: ->
    error: false, isShowingDetails: false

  componentWillMount: ->
    api.channel.on 'error', @onError

  componentWillUnmount: ->
    api.channel.off 'error', @onError

  onError: ({response, failedData, exception}) ->
    return if failedData?.stopErrorDisplay # someone else is handling displaying the error
    if exception?
      errors = [exception.toString()]
    else if response.status is 0 # either no response, or the response lacked CORS headers and the browser rejected it
      errors = ["Unknown response received from server"]
    else
      errors = ["#{response.status}: #{response.statusText}"]
      if _.isArray(failedData.data?.errors) # we have something from server to display
        errors = errors.concat(
          _.flatten _.map failedData.data.errors, (error) ->
            # All 422 errors from BE *should* have a "code" property.  If not, show whatever it is
            if error.code then error.code else JSON.stringify(error)
          )
    @setState(errors: errors)

  toggleDetails: ->
    @setState(isShowingDetails: not @state.isShowingDetails)

  onHide: ->
    @setState(errors: false)

  renderDetails: ->
    <BS.Panel header="Error Details">
      <ul className="errors-listing">
        {for error, i in @state.errors
          <li key={i}>{error}</li>}
      </ul>
      <p>
        {window.navigator.userAgent}
      </p>
    </BS.Panel>

  render: ->
    return null unless @state.errors
    <BS.Modal className='errors' onRequestHide={@onHide} title="Error encountered">
      <div className='modal-body'>
        <p>
          An unexpected error has occured.  Please
          visit <a target="_blank"
            href={makeContactURL(@state.errors, window)}
          > our support site </a> so we can help to diagnose and correct the issue.
        </p>
        <p>
          When reporting the issue, it would be helpful if you could include the error details.
        </p>
        <BS.Button className='-display-errors' style={marginBottom: '1rem'} onClick={@toggleDetails}>
          {if @state.isShowingDetails then "Hide" else "Show"} Details
        </BS.Button>
        {@renderDetails() if @state.isShowingDetails}
      </div>
      <div className='modal-footer'>
        <BS.Button className='ok' bsStyle='primary' onClick={@onHide}>OK</BS.Button>
      </div>
    </BS.Modal>


module.exports = ErrorNotification
