React = require 'react'
BS = require 'react-bootstrap'
_  = require 'underscore'

LoadableItem = require '../loadable-item'
{CourseStore} = require '../../flux/course'
{RosterStore, RosterActions} = require '../../flux/roster'
{StudentDashboardStore, StudentDashboardActions} = require '../../flux/student-dashboard'
{CCDashboardStore, CCDashboardActions} = require '../../flux/cc-dashboard'

Roster = require './roster'
TeacherRoster = require './teacher-roster'

RenameCourse = require './rename-course'
SetTimezone = require './set-timezone'

module.exports = React.createClass
  displayName: 'CourseSettings'
  propTypes:
    courseId: React.PropTypes.string.isRequired

  render: ->
    course = CourseStore.get(@props.courseId)

    if course.is_concept_coach
      store = CCDashboardStore
      actions = CCDashboardActions
    else
      store = StudentDashboardStore
      actions = StudentDashboardActions


    <BS.Panel className='course-settings'>

      <div className='course-settings-title'>{course.name}
        <RenameCourse courseId={@props.courseId}  course={course}/>
      </div>
      <div className='course-settings-timezone'>{CourseStore.getTimezone(@props.courseId)}
        <SetTimezone courseId={@props.courseId}/>
      </div>

      <div className="settings-section teachers">
        <LoadableItem
          id={@props.courseId}
          store={store}
          actions={actions}
          renderItem={=> <TeacherRoster
            store={store}
            courseRoles={course.roles}
            courseId={@props.courseId}/>}
        />
      </div>

      <LoadableItem
        id={@props.courseId}
        store={RosterStore}
        actions={RosterActions}
        renderItem={=> <Roster courseId={@props.courseId}/>}
      />

    </BS.Panel>
