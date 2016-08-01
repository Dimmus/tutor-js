React = require 'react'
BS = require 'react-bootstrap'
_ = require 'underscore'
classnames = require 'classnames'

BackgroundAndDesk = require './background-and-desk'
LaptopAndMug = require '../laptop-and-mug'

{channel} = require '../model'


Launcher = React.createClass
  displayName: 'Launcher'
  propTypes:
    isLaunching: React.PropTypes.bool
    defaultHeight: React.PropTypes.number
  getDefaultProps: ->
    isLaunching: false
    defaultHeight: 388
  getInitialState: ->
    height: @getHeight()
  componentWillReceiveProps: (nextProps) ->
    @setState(height: @getHeight(nextProps)) if @props.isLaunching isnt nextProps.isLaunching

  getHeight: (props) ->
    props ?= @props
    {isLaunching, defaultHeight} = props
    if isLaunching then window.innerHeight else defaultHeight

  launch: ->
    channel.emit('launcher.clicked')
    undefined # stop react from complaining about returning false from a handler

  render: ->
    {isLaunching, defaultHeight} = @props
    {height} = @state

    classes = classnames 'concept-coach-launcher',
      launching: isLaunching

    <div className='concept-coach-launcher-wrapper'>
      <div className={classes} onClick={@launch}>
        <LaptopAndMug height={defaultHeight}/>
        <BS.Button bsStyle='primary' bsSize='large'>
          <span className="launch">Launch Concept Coach</span>
          <span className="warn">enrollment code needed</span>
        </BS.Button>
        <BackgroundAndDesk height={height}/>
      </div>
    </div>

module.exports = {Launcher}
