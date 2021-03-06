React  = require 'react'
moment = require 'moment'
EmptyPanel  = require './empty-panel'
EventsPanel = require './events-panel'
{StudentDashboardStore} = require '../../flux/student-dashboard'
_ = require 'underscore'

module.exports = React.createClass
  displayName: 'AllEventsByWeek'
  propTypes:
    courseId: React.PropTypes.string.isRequired
    isCollege: React.PropTypes.bool.isRequired

  renderWeek:(events, week) ->
    startAt = moment(week, 'YYYYww')
    <EventsPanel
      key={week}
      className='-weeks-events'
      courseId={@props.courseId}
      isCollege={@props.isCollege}
      events={events}
      startAt={startAt}
      endAt={startAt.clone().add(1, 'week')}
    />

  render: ->
    weeks = StudentDashboardStore.pastEventsByWeek(@props.courseId)
    if _.any(weeks)
      <div>{_.map(weeks, @renderWeek)}</div>
    else
      <EmptyPanel>No past tasks</EmptyPanel>
