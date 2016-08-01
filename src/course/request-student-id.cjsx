React = require 'react'
BS = require 'react-bootstrap'
ENTER = 'Enter'

User = require '../user/model'
Course = require './model'
ErrorList = require './error-list'
{AsyncButton} = require 'openstax-react-components'

RequestStudentId = React.createClass

  propTypes:
    onCancel: React.PropTypes.func.isRequired
    onSubmit: React.PropTypes.func.isRequired
    label: React.PropTypes.oneOfType([
      React.PropTypes.string
      React.PropTypes.element
    ]).isRequired
    saveButtonLabel: React.PropTypes.string.isRequired
    title: React.PropTypes.string.isRequired
    course: React.PropTypes.instanceOf(Course).isRequired

  startConfirmation: ->
    @props.course.confirm(@refs.input.getValue())

  onKeyPress: (ev) ->
    @onSubmit() if ev.key is ENTER

  onCancel: (ev) ->
    ev.preventDefault()
    @props.onCancel()

  onSubmit: ->
    @props.onSubmit(@refs.input.getValue())

  render: ->
    button =
      <AsyncButton
        className="btn btn-success"
        isWaiting={!!@props.course.isBusy}
        waitingText={'Confirming…'}
        onClick={@onSubmit}
      >{@props.saveButtonLabel}</AsyncButton>

    <div className="request-student-id form-group">
      <h3 className="text-center">
        {@props.title}
      </h3>
      <ErrorList course={@props.course} />
      <div className='panels'>
        <div className='field'>
          <BS.Input type="text" ref="input" label={@props.label}
            placeholder="School issued ID" autoFocus
            defaultValue={@props.course.getStudentIdentifier()}
            onKeyPress={@onKeyPress}
            buttonAfter={button} />
        </div>
        <div className="cancel">
          <a href='#' onClick={@onCancel}>Cancel</a>
        </div>
      </div>
    </div>

module.exports = RequestStudentId
