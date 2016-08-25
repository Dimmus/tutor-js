React = require 'react'
BS = require 'react-bootstrap'
_  = require 'underscore'
Icon = require '../icon'

{RosterStore, RosterActions} = require '../../flux/roster'
ChangePeriodLink  = require './change-period'
DropStudentLink = require './drop-student'
CourseGroupingLabel = require '../course-grouping-label'
StudentIdField = require './student-id-field'

module.exports = React.createClass
  displayName: 'PeriodRoster'
  propTypes:
    courseId: React.PropTypes.string.isRequired
    period: React.PropTypes.object.isRequired
    isConceptCoach: React.PropTypes.bool.isRequired

  renderStudentRow: (student) ->
    <tr key={student.id}>
      <td>{student.first_name}</td>
      <td>{student.last_name}</td>
      <td><StudentIdField student={student} courseId={@props.courseId} /></td>
      <td className="actions">
        <ChangePeriodLink
        courseId={@props.courseId}
        student={student} />
        <DropStudentLink
        student={student} />
      </td>
    </tr>

  isPeriodEmpty: ->
    id = @props.period.id
    students = RosterStore.getActiveStudentsForPeriod(@props.courseId, id)
    students.length is 0

  render: ->
    students = RosterStore.getActiveStudentsForPeriod(@props.courseId, @props.period.id)
    cgl = {courseId: @props.courseId}

    studentsTable =
      <BS.Table striped bordered condensed hover className="roster">
        <thead>
          <tr>
            <th>First Name</th>
            <th>Last Name</th>
            <th className="student-id">Student ID</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {for student in _.sortBy(students, 'last_name')
            @renderStudentRow(student)}
        </tbody>
      </BS.Table>
    emptyInfo =
      <div className='roster-empty-info'>
        Use the "Get Student Enrollment Code" link above to get the code for
        this <CourseGroupingLabel lowercase {...cgl} /> of your course.
        As your students login to Concept Coach, they will start appearing here.
        You will be able to drop students or change
        their <CourseGroupingLabel lowercase plural {...cgl} /> from
        this page.
      </div>

    <div className="period">
      {if @isPeriodEmpty() and @props.isConceptCoach then emptyInfo else studentsTable}
    </div>
