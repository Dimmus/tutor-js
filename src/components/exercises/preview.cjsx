React = require 'react'

{ExercisePreview} = require 'openstax-react-components'
BindStoreMixin = require '../bind-store-mixin'

# Wraps the ExercisePreview component so it will re-render in
# response to a store event
ExercisePreviewWrapper = React.createClass

  propTypes:
    exercise:               React.PropTypes.object.isRequired
    onShowDetailsViewClick: React.PropTypes.func.isRequired
    onExerciseToggle:       React.PropTypes.func.isRequired
    getExerciseIsSelected:  React.PropTypes.func.isRequired
    getExerciseActions:     React.PropTypes.func.isRequired
    watchStore:             React.PropTypes.func
    watchEvent:             React.PropTypes.string

  mixins: [BindStoreMixin]
  bindStore: -> @props.watchStore
  bindEvent: ->
    { watchEvent, exercise } = @props
    "#{watchEvent}#{exercise.id}"

  render: ->
    { exercise } = @props
    <ExercisePreview
      key={exercise.id}
      className='exercise-card'
      isInteractive={false}
      isVerticallyTruncated={true}
      isSelected={@props.getExerciseIsSelected(exercise)}
      exercise={exercise}
      onOverlayClick={@onExerciseToggle}
      overlayActions={@props.getExerciseActions(exercise)}
    />

module.exports = ExercisePreviewWrapper
