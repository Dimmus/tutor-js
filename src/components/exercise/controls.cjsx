React = require 'react'
BS = require 'react-bootstrap'
{ExerciseActions, ExerciseStore} = require '../../stores/exercise'
AsyncButton = require 'openstax-react-components/src/components/buttons/async-button.cjsx'
MPQToggle = require '../mpq-toggle'
SuretyGuard = require '../surety-guard'

ExerciseControls = React.createClass

  propTypes:
    id:   React.PropTypes.string.isRequired
    history: React.PropTypes.object

  componentWillMount: ->
    ExerciseStore.addChangeListener(@update)

  componentWillUnmount: ->
    ExerciseStore.removeChangeListener(@update)

  update: -> @forceUpdate()

  isExerciseDirty: ->
    @props.id and ExerciseStore.isChanged(@props.id)

  saveExercise: ->
    if ExerciseStore.isNew(@props.id)
      ExerciseActions.create(@props.id, ExerciseStore.get(@props.id))
    else
      ExerciseActions.save(@props.id)

   publishExercise: ->
    ExerciseActions.save(@state.exerciseId)
    ExerciseActions.publish(@state.exerciseId)

  render: ->
    {id} = @props
    return null unless id

    guardProps =
      onlyPromptIf: @isExerciseDirty
      placement: 'right'
      message: "You will lose all unsaved changes"

    <div className="exercise-navbar-controls">
      <BS.ButtonToolbar className="navbar-btn">
        { if id?
          <AsyncButton
            bsStyle='info'
            className='draft'
            onClick={@saveExercise}
            disabled={not ExerciseStore.isSavable(id)}
            isWaiting={ExerciseStore.isSaving(id)}
            waitingText='Saving...'
            isFailed={ExerciseStore.isFailed(id)}
            >
            Save Draft
          </AsyncButton>
        }
        { if id and not ExerciseStore.isNew(id)
          <SuretyGuard
            onConfirm={@publishExercise}
            okButtonLabel='Publish'
            placement='right'
            message="Once an exericse is published, it is available for use."
          >
            <AsyncButton
              bsStyle='primary'
              className='publish'
              disabled={not ExerciseStore.isPublishable(id)}
              isWaiting={ExerciseStore.isPublishing(id)}
              waitingText='Publishing...'
              isFailed={ExerciseStore.isFailed(id)}
              >
              Publish
            </AsyncButton>
          </SuretyGuard>
        }
      </BS.ButtonToolbar>
      <div className="right-side">
        <MPQToggle exerciseId={@props.id} />
      </div>

    </div>

module.exports = ExerciseControls
