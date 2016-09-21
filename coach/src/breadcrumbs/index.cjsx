React = require 'react'
classnames = require 'classnames'
{Breadcrumb} = require 'shared'
_ = require 'underscore'

tasks = require '../task/collection'
exercises = require '../exercise/collection'


BreadcrumbDynamic = React.createClass
  displayName: 'BreadcrumbDynamic'

  propTypes:
    goToStep: React.PropTypes.func.isRequired
    step: React.PropTypes.object.isRequired

  getInitialState: ->
    step: @props.step

  componentWillMount: ->
    {id} = @props.step
    exercises.channel.on("load.#{id}", @update)

  componentWillUnmount: ->
    {id} = @props.step
    exercises.channel.off("load.#{id}", @update)

  update: (eventData) ->
    @setState(step: eventData.data)

  goToStep: (stepIndex) ->
    @props.goToStep(stepIndex)

  render: ->
    {step} = @state
    crumbProps = _.omit(@props, 'step')

    <Breadcrumb
      {...crumbProps}
      step={step}
      canReview={true}
      goToStep={@goToStep}/>



Breadcrumbs = React.createClass
  displayName: 'Breadcrumbs'

  propTypes:
    goToStep: React.PropTypes.func.isRequired
    moduleUUID: React.PropTypes.string.isRequired
    collectionUUID: React.PropTypes.string.isRequired
    currentStep: React.PropTypes.number
    canReview: React.PropTypes.bool

  getInitialState: ->
    {collectionUUID, moduleUUID} = @props
    taskId = "#{collectionUUID}/#{moduleUUID}"

    task: tasks.get(taskId)
    moduleInfo: tasks.getModuleInfo(taskId)

  makeCrumbEnd: (label, enabled) ->
    {moduleInfo, task} = @state

    reviewEnd =
      type: 'end'
      # data:
      #   id: "#{label}"
      #   title: moduleInfo.title
      task:
        title: moduleInfo.title
        id: task.id
      label: label
      disabled: not enabled

  render: ->
    {task, moduleInfo} = @state
    {currentStep, canReview} = @props
    return null if _.isEmpty(task.steps)

    crumbs = _.map task.steps, (step, index) ->
      _.pick(step, 
        'id', 'type', 'is_completed', 'related_content', 'group',
        'is_correct', 'answer_id', 'correct_answer_id'
      )

    reviewEnd = @makeCrumbEnd('summary', canReview)

    crumbs.push(reviewEnd)

    breadcrumbs = _.map crumbs, (crumb, index) =>
      {disabled} = crumb
      classes = classnames({disabled})

      <BreadcrumbDynamic
        className={classes}
        data-label={crumb.label}
        key={crumb.id}
        crumb={crumb}
        stepIndex={index}
        step={crumb or {}}
        currentStep={currentStep}
        goToStep={@props.goToStep}/>


    <div className='task-homework'>
      <div className='task-breadcrumbs'>
        {breadcrumbs}
      </div>
    </div>

module.exports = {Breadcrumbs}
