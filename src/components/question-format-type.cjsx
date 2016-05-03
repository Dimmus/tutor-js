React = require 'react'
BS = require 'react-bootstrap'
_ = require 'underscore'

{QuestionActions, QuestionStore} = require '../stores/question'


PREFIX = 'format'
TYPES =
  'multiple-choice' : 'Multiple Choice'
  'true-false'      : 'True/False'

# Temporarily removed as options (not needed & causes 500 on BE)
#  'vocabulary'      : 'Vocabulary'
#  'open-ended'      : 'Open Ended'

QuestionFormatType = React.createClass


  update: -> @forceUpdate()

  componentWillMount: ->
    QuestionStore.addChangeListener(@update)

  componentWillUnmount: ->
    QuestionStore.removeChangeListener(@update)

  propTypes:
    questionId: React.PropTypes.number.isRequired
    sync: React.PropTypes.func.isRequired

  updateFormat: (ev) ->
    selected = ev.target.value
    for id, name of TYPES
      QuestionActions.toggleFormat(@props.questionId, id, selected is id)
    @props.sync()

  isFormatChecked: (name) ->
    QuestionStore.hasFormat(@props.questionId, name)

  setChoiceRequired: (ev) ->
    QuestionActions.toggleFormat(@props.questionId, 'free-response', not ev.target.checked)
    @props.sync()

  doesRequireChoices: ->
    not @isFormatChecked('free-response')

  render: ->
    <div className="format-type">
      {for id, name of TYPES
        <BS.Input
          key={id}
          type="radio"
          name='formats'
          label={name}
          value={id}
          onClick={@updateFormat}
          checked={@isFormatChecked(id)}
        />}

      {<BS.Input type="checkbox" label="Requires Choices"
        onChange={@setChoiceRequired}
        checked={@doesRequireChoices()}
      /> if QuestionStore.hasFormat(@props.questionId, 'multiple-choice')}
    </div>


module.exports = QuestionFormatType
