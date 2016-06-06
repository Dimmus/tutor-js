# coffeelint: disable=max_line_length

React = require 'react'
BS = require 'react-bootstrap'
_ = require 'underscore'

{TutorInput} = require '../tutor-input'

# Approx how wide each char is in the text input
# it's width will be set to this * link's character count
CHAR_WIDTH = 7

StudentEnrollmentLink = React.createClass

  propTypes:
    period: React.PropTypes.object.isRequired

  selectText: (ev) ->
    @refs.input.getDOMNode().select()

  render: ->
    <span className='enrollment-code-link' onClick={@selectText}>
      <span className="title">Student Enrollment URL:</span>
      <input type="text"
        ref='input'
        style={width: @props.period.enrollment_url.length * CHAR_WIDTH}
        value={@props.period.enrollment_url}
        readOnly />
    </span>

module.exports = StudentEnrollmentLink
