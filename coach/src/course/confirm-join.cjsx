React = require 'react'

Course = require './model'
ErrorList = require './error-list'
{Join} = require 'shared'

ConfirmJoin = React.createClass

  propTypes:
    course: React.PropTypes.instanceOf(Course).isRequired
    optionalStudentId: React.PropTypes.bool

  render: ->
    <Join
      course={@props.course}
      errorList={React.createElement(ErrorList, course: @props.course)}
      optionalStudentId={@props.optionalStudentId}
    />


module.exports = ConfirmJoin
