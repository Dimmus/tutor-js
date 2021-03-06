React = require 'react'
{CurrentUserStore} = require '../../flux/current-user'

SUPPORT_LINK_PARAMS = '&cu=1&fs=ContactUs&q='

makeContactMessage = (status, message, request) ->
  userAgent = window.navigator.userAgent
  location = window.location.href

  errorInfo = "#{status} with #{message} for #{request.method} on #{request.url}"

  if request.data?
    errorInfo += " with\n#{request.data}"

  template = """Hello!
    I ran into a problem on
    #{userAgent} at #{location}.

    Here is some additional info:
    #{errorInfo}."""

makeContactURL = (supportLinkBase, status, message, request) ->
  q = encodeURIComponent(makeContactMessage(status, message, request))
  "#{supportLinkBase}#{SUPPORT_LINK_PARAMS}#{q}"

ServerErrorMessage = React.createClass
  displayName: 'ServerErrorMessage'

  propTypes:
    status: React.PropTypes.number.isRequired
    statusMessage: React.PropTypes.string.isRequired
    config: React.PropTypes.object.isRequired
    supportLinkBase: React.PropTypes.string
    debug: React.PropTypes.bool

  getDefaultProps: ->
    supportLinkBase: CurrentUserStore.getHelpLink()
    debug: true

  render: ->
    {status, statusMessage, config, supportLinkBase, debug} = @props
    statusMessage ?= 'No response was received'
    q = makeContactMessage(status, statusMessage, config)

    dataMessage =  <span>
      with <pre>{config.data}</pre>
    </span> if config.data?

    debugInfo = [
      <p key='error-note'>Additional error messages returned from the server is:</p>
      <pre key='error-response' className='response'>{statusMessage}</pre>
      <div key='error-request' className='request'>
        <kbd>{config.method}</kbd> on {config.url} {dataMessage}
      </div>
    ] if debug

    errorMessage =
      <div className='server-error'>
        <h3>An error with code {status} has occured</h3>
        <p>Please visit <a target='_blank'
          href={makeContactURL(supportLinkBase, status, statusMessage, config)}
        >our support page</a> to file a bug report.
        </p>
        {debugInfo}
      </div>

module.exports = ServerErrorMessage
