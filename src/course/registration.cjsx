React = require 'react'

NewCourseRegistration = require './new-registration'
ModifyCourseRegistration = require './modify-registration'

UserStatus = require '../user/status-mixin'
Course = require './model'

CourseRegistration = React.createClass

  propTypes:
    collectionUUID: React.PropTypes.string.isRequired

  mixins: [UserStatus]

  render: ->
    course = @getUser().getCourse(@props.collectionUUID)
    body = if course?.isRegistered()
      <ModiyCourseRegistration {...@props} />
    else
      <NewCourseRegistration {...@props} />

    <div className="row">
      {body}
    </div>

module.exports = CourseRegistration
