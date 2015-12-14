React = require 'react'

User  = require './model'
api   = require '../api'

LoginGateway = React.createClass

  getInitialState: ->
    loginWindow: false

  openLogin: (ev) ->
    ev.preventDefault()
    nY = Math.min(1000, window.screen.width - 20)
    oY = Math.min(800, window.screen.height - 30)

    options = ["toolbar=no", "location=" + (window.opera ? "no" : "yes"),
      "directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,copyhistory=no",
      "width=" + nY,
      "height=" + oY,
      "top=" + (window.screen.height - oY) / 2,
      "left=" + (window.screen.width - nY) / 2].join()

    loginWindow = window.open(User.urlForLogin(), 'oxlogin', options)
    @setState({loginWindow})

  parseAndDispatchMessage: (msg) ->
    return unless @isMounted()
    try
      @state.loginWindow.close()
      api.channel.emit 'user.status.receive.fetch', data: JSON.parse(msg.data)
    catch error
      console.warn(error)
  componentWillUnmount: ->

    window.removeEventListener('message', @parseAndDispatchMessage)
  componentWillMount: ->
    window.addEventListener('message', @parseAndDispatchMessage)

  renderWaiting: ->
    <p>
      Please log in using your OpenStax account in the window. {@loginLink('Click to reopen window.')}
    </p>

  loginLink: (msg) ->
    <a target='_blank' onClick={@openLogin} href={User.urlForLogin()}>{msg}</a>

  renderLogin: ->
    <p>
      Please {@loginLink('click to begin login.')}
    </p>

  render: ->

    <div className='login'>
      <h3>You need to login or signup in order to use ConceptCoach™</h3>
      {if @state.loginWindow then @renderWaiting() else @renderLogin()}
    </div>

module.exports = LoginGateway
