React = require 'react'
BS = require 'react-bootstrap'

CrumbMixin = require './crumb-mixin'
Breadcrumbs = require './breadcrumbs'
{ReviewShell} = require './review'
{StatsModalShell} = require '../plan-stats'
{PinnedHeaderFooterCard, ChapterSectionMixin, ScrollToMixin} = require 'shared'

_ = require 'underscore'

{TaskTeacherReviewStore} = require '../../flux/task-teacher-review'
ScrollSpy = require '../scroll-spy'


TaskTeacherReview = React.createClass
  propTypes:
    id: React.PropTypes.string

  displayName: 'TaskTeacherReview'

  mixins: [ChapterSectionMixin, CrumbMixin, ScrollToMixin]

  scrollingTargetDOM: -> window.document

  contextTypes:
    router: React.PropTypes.func

  setStepKey: ->
    {sectionIndex} = @context.router.getCurrentParams()
    defaultKey = null
    # url is 1 based so it matches the breadcrumb button numbers
    crumbKey = if sectionIndex then parseInt(sectionIndex) - 1 else defaultKey
    @setState(currentStep: crumbKey)

  getPeriodIndex: ->
    {periodIndex} = @context.router.getCurrentParams()
    periodIndex ?= 1

    parseInt(periodIndex) - 1

  setScrollState: (scrollState) ->
    @setState({scrollState})

  getInitialState: ->
    {id} = @props

    currentStep: null
    scrollState: {}
    period: {}
    isReviewLoaded: TaskTeacherReviewStore.get(id)?

  componentWillMount: ->
    @setStepKey()
    TaskTeacherReviewStore.on('review.loaded', @setIsReviewLoaded)

    location = @context.router.getLocation()
    location.addChangeListener(@syncRoute)

  componentWillUnmount: ->
    TaskTeacherReviewStore.off('review.loaded', @setIsReviewLoaded)

    location = @context.router.getLocation()
    location.removeChangeListener(@syncRoute)

  componentWillReceiveProps: (nextProps) ->
    if nextProps.shouldUpdate
      key = _.first(nextProps.onScreenElements)
      if key? and parseInt(key) isnt @state.currentStep
        @goToStep(parseInt(key))

  syncRoute: ({path}) ->
    {params} = @context.router.match(path)
    @syncStep(params)

  syncStep: (params) ->
    {sectionIndex} = params
    currentStep = sectionIndex - 1
    @setState({currentStep})

  scrollToStep: (currentStep) ->
    stepSelector = "[data-section='#{currentStep}']"
    @scrollToSelector(stepSelector, {updateHistory: false, unlessInView: true})

  shouldComponentUpdate: (nextProps) ->
    {shouldUpdate} = nextProps
    shouldUpdate ?= true

    shouldUpdate

  goToStep: (stepKey) ->
    params = _.clone(@context.router.getCurrentParams())
    # url is 1 based so it matches the breadcrumb button numbers
    params.sectionIndex = stepKey + 1
    params.id = @props.id # if we were rendered directly, the router might not have the id

    params.periodIndex ?= 1

    @context.router.replaceWith('reviewTaskStep', params)

  setPeriod: (period) ->
    return unless @state.isReviewLoaded

    contentState = @getReviewContents(period)
    contentState.period = period

    @setState(contentState)

  setPeriodIndex: (key) ->
    periodKey = key + 1
    params = _.clone(@context.router.getCurrentParams())
    params.periodIndex = periodKey

    if params.sectionIndex
      @context.router.replaceWith('reviewTaskStep', params)
    else
      @context.router.replaceWith('reviewTaskPeriod', params)

  setIsReviewLoaded: (id) ->
    return null unless id is @props.id

    TaskTeacherReviewStore.off('review.loaded', @setIsReviewLoaded)

    params = _.clone(@context.router.getCurrentParams())
    @syncStep(params)

    contentState = @getReviewContents()
    contentState.isReviewLoaded = true

    @setState(contentState)

  getReviewContents: (period) ->
    steps = @getContents(period)
    crumbs = @getCrumableCrumbs(period)

    {steps, crumbs}

  getActiveStep: ->
    {steps, currentStep} = @state
    activeStep = _.find(steps, {key: currentStep})

  render: ->
    {id, courseId} = @props
    {steps, crumbs} = @state
    periodIndex = @getPeriodIndex()

    panel = <ReviewShell
          id={id}
          review='teacher'
          panel='teacher-review'
          goToStep={@goToStep}
          steps={steps}
          currentStep={@state.currentStep}
          period={@state.period} />

    taskClasses = 'task-teacher-review'

    if @state.isReviewLoaded
      task = TaskTeacherReviewStore.get(id)
      taskClasses = "task-teacher-review task-#{task.type}"

      breadcrumbs = <Breadcrumbs
        id={id}
        crumbs={crumbs}
        goToStep={@goToStep}
        scrollToStep={@scrollToStep}
        currentStep={@state.currentStep}
        title={task.title}
        courseId={courseId}
        key="task-#{id}-breadcrumbs" />

    <PinnedHeaderFooterCard
      className={taskClasses}
      fixedOffset={0}
      header={breadcrumbs}
      cardType='task'>
        <BS.Grid fluid>
          <BS.Row>
            <BS.Col sm={8}>
              {panel}
            </BS.Col>
            <BS.Col sm={4}>
              <StatsModalShell
                id={id}
                courseId={courseId}
                initialActivePeriod={periodIndex}
                shouldOverflowData={true}
                activeSection={@getActiveStep()?.sectionLabel}
                handlePeriodSelect={@setPeriod}
                handlePeriodKeyUpdate={@setPeriodIndex}/>
            </BS.Col>
          </BS.Row>
        </BS.Grid>
    </PinnedHeaderFooterCard>


TaskTeacherReviewShell = React.createClass
  contextTypes:
    router: React.PropTypes.func
  render: ->
    {id, courseId} = @context.router.getCurrentParams()
    <ScrollSpy dataSelector='data-section'>
      <TaskTeacherReview key={id} id={id} courseId={courseId}/>
    </ScrollSpy>

module.exports = {TaskTeacherReview, TaskTeacherReviewShell}
