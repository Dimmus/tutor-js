React = require 'react'
HTML5Backend = require 'react-dnd-html5-backend'
DragDropContext = require('react-dnd').DragDropContext

CourseMonth = require './month'

displayAsHandler =
  month: CourseMonth

CourseCalendar = React.createClass
  displayName: 'CourseCalendar'

  propTypes:
    loadPlansList: React.PropTypes.func
    hasPeriods: React.PropTypes.bool.isRequired

  render: ->
    {hasPeriods, displayAs, loadPlansList} = @props
    Handler = displayAsHandler[displayAs]

    plansList = if hasPeriods then loadPlansList?() else []

    <Handler {...@props} plansList={plansList} ref='calendarHandler'/>

module.exports = DragDropContext(HTML5Backend)(CourseCalendar)
