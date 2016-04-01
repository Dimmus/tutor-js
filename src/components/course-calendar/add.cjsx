moment = require 'moment'
twix = require 'twix'
_ = require 'underscore'

React = require 'react'
BS = require 'react-bootstrap'
classnames = require 'classnames'

{TimeStore} = require '../../flux/time'

CourseAddMenuMixin = require './add-menu-mixin'

CourseAdd = React.createClass
  displayName: 'CourseAdd'

  mixins: [CourseAddMenuMixin]

  getInitialState: ->
    positionLeft: 0
    positionTop: 0
    open: false
    referenceDate: moment(TimeStore.getNow())

  updateState: (date, x, y) ->
    @setState({
      addDate: date
      positionLeft: x
      positionTop: y
      open: true
    })

  close: ->
    @setState({
      addDate: null
      open: false
    })

  render: ->
    {referenceDate, addDate, open} = @state

    # DYNAMIC_ADD_ON_CALENDAR_POSITIONING
    # Positions Add menu on date
    style =
      left: @state.positionLeft
      top: @state.positionTop

    style['display'] = if open then 'block' else 'none'

    className = classnames 'course-add-dropdown',
      'no-add': not addDate?.isAfter(referenceDate, 'day')

    # only allow add if addDate is on or after reference date
    if addDate?.isAfter(referenceDate, 'day')
      dropdownContent = @renderAddActions()
    else
      dayType = if addDate?.isSame(referenceDate, 'day') then 'today' else 'past day'
      dropdownContent = <li>
        <span className='no-add-text'>Cannot assign to {dayType}</span>
      </li>

    <BS.Dropdown.Menu id='course-add-dropdown' ref='addOnDayMenu' style={style} className={className}>
      {dropdownContent}
    </BS.Dropdown.Menu>

module.exports = CourseAdd
