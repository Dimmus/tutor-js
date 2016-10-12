React = require 'react'
_ = require 'underscore'
BS = require 'react-bootstrap'
classnames = require 'classnames'

{ChapterSectionMixin, ArbitraryHtmlAndMath, StepHelpsHelper} = require 'shared'
{BreadcrumbStatic} = require '../../breadcrumb'

{TaskStepActions, TaskStepStore} = require '../../../flux/task-step'
{TaskProgressActions, TaskProgressStore} = require '../../../flux/task-progress'
{TaskPanelActions, TaskPanelStore} = require '../../../flux/task-panel'
{TaskStore} = require '../../../flux/task'
{StepTitleStore} = require '../../../flux/step-title'


{
  PERSONALIZED_GROUP,
  SPACED_PRACTICE_GROUP,
  TWO_STEP_ALIAS,
  INTRO_ALIASES,
  TITLES
} = StepHelpsHelper

ReactCSSTransitionGroup = require 'react-addons-css-transition-group'

Milestone = React.createClass
  displayName: 'Milestone'
  propTypes:
    goToStep: React.PropTypes.func.isRequired
    crumb: React.PropTypes.object.isRequired
    currentStep: React.PropTypes.number.isRequired

  handleKeyUp: (crumbKey, keyEvent) ->
    if keyEvent.keyCode is 13 or keyEvent.keyCode is 32
      @props.goToStep(crumbKey)
      keyEvent.preventDefault()

  getStepTitle: (crumb) ->
    {goToStep, crumb, currentStep, stepIndex} = @props

    title = StepTitleStore.get(crumb.id)

    if crumb.type is 'reading' and crumb.related_content?[0]?.title?
      if title is 'Summary'
        title = "#{title} of #{crumb.related_content?[0]?.title}"
      else if not title
        title = crumb.related_content?[0]?.title

    title

  getPreviewText: (crumb) ->
    if crumb.id?
      @getStepTitle(crumb)
    else
      switch crumb.type
        when 'end'
          "#{crumb.task.title} Completed"

        when 'coach'
          TITLES[SPACED_PRACTICE_GROUP]

        when INTRO_ALIASES[SPACED_PRACTICE_GROUP]
          TITLES[SPACED_PRACTICE_GROUP]

        when INTRO_ALIASES[PERSONALIZED_GROUP]
          TITLES[PERSONALIZED_GROUP]

        when INTRO_ALIASES[TWO_STEP_ALIAS]
          TITLES[TWO_STEP_ALIAS]

  render: ->
    {goToStep, crumb, currentStep, stepIndex} = @props

    isCurrent = stepIndex is currentStep

    classes = classnames 'milestone', "milestone-#{crumb.type}",
      'active': isCurrent

    previewText = @getPreviewText(crumb)

    if crumb.type is 'exercise'
      preview = <ArbitraryHtmlAndMath
        block={true}
        className='milestone-preview'
        html={previewText}/>
    else
      preview = <div className='milestone-preview'>{previewText}</div>

    goToStepForCrumb = _.partial(goToStep, stepIndex)

    <BS.Col xs=3 lg=2 className='milestone-wrapper'>
      <div
        tabIndex='0'
        className={classes}
        role='button'
        aria-label={previewText}
        onClick={goToStepForCrumb}
        onKeyUp={_.partial(@handleKeyUp, stepIndex)}>
        <BreadcrumbStatic
          crumb={crumb}
          data-label={crumb.label}
          currentStep={currentStep}
          goToStep={goToStepForCrumb}
          stepIndex={stepIndex}
          key="breadcrumb-#{crumb.type}-#{stepIndex}"
          ref="breadcrumb-#{crumb.type}-#{stepIndex}"/>
        {preview}
      </div>
    </BS.Col>

MilestonesWrapper = React.createClass
  displayName: 'MilestonesWrapper'

  mixins: [ChapterSectionMixin]

  propTypes:
    id: React.PropTypes.string.isRequired
    goToStep: React.PropTypes.func.isRequired

  getInitialState: ->
    currentStep = TaskProgressStore.get(@props.id)
    crumbs = TaskPanelStore.get(@props.id)

    currentStep: currentStep
    crumbs: crumbs

  componentDidMount: ->
    @switchCheckingClick()
    @switchTransitionListen()

  componentWillUnmount: ->
    @switchCheckingClick(false)
    @switchTransitionListen(false)

  componentDidEnter: (transitionEvent) ->
    @props.handleTransitions?(transitionEvent) if transitionEvent.propertyName is 'transform'

  switchTransitionListen: (switchOn = true) ->
    eventAction = if switchOn then 'addEventListener' else 'removeEventListener'

    milestones = @getDOMNode()
    milestones[eventAction]('transitionend', @componentDidEnter)
    milestones[eventAction]('webkitTransitionEnd', @componentDidEnter)

  switchCheckingClick: (switchOn = true) ->
    eventAction = if switchOn then 'addEventListener' else 'removeEventListener'

    document[eventAction]('click', @checkAllowed, true)
    document[eventAction]('focus', @checkAllowed, true)

  checkAllowed: (focusEvent) ->
    modal = @getDOMNode()

    unless modal.contains(focusEvent.target) or @props.filterClick?(focusEvent)
      focusEvent.preventDefault()
      focusEvent.stopImmediatePropagation()
      modal.focus()

  goToStep: (args...) ->
    unless @props.goToStep(args...)
      @props.closeMilestones()

  render: ->
    {crumbs, currentStep} = @state

    stepButtons = _.map crumbs, (crumb, crumbIndex) =>
      <Milestone
        key={"crumb-wrapper-#{crumbIndex}"}
        crumb={crumb}
        goToStep={@goToStep}
        stepIndex={crumbIndex}
        currentStep={currentStep}/>

    classes = 'task-breadcrumbs'

    <div className='milestones-wrapper' role='dialog' tabIndex='-1'>
      <div className='milestones task-breadcrumbs' role='document'>
        {stepButtons}
      </div>
    </div>


Milestones = React.createClass
  displayName: 'Milestones'
  propTypes:
    showMilestones: React.PropTypes.bool.isRequired

  render: ->

    milestones = <MilestonesWrapper
      {...@props}
      ref='milestones'/> if @props.showMilestones

    <ReactCSSTransitionGroup
      transitionName='task-with-milestones'
      transitionEnterTimeout={300}
      transitionLeaveTimeout={300}
      transitionAppearTimeout={0}
      transitionAppear={true}>
      {milestones}
    </ReactCSSTransitionGroup>

module.exports = {MilestonesWrapper, Milestone, Milestones}
