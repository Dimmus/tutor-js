React = require 'react/addons'
BS = require 'react-bootstrap'
Router = require 'react-router'

api = require '../../api'
{TaskStore} = require '../../flux/task'
{TaskStepActions, TaskStepStore} = require '../../flux/task-step'
{CourseActions, CourseStore} = require '../../flux/course'

TaskStep = require '../task-step'
TaskEnd = require '../task-step/task-end'
PracticeEnd = require '../task-step/practice-end'
Breadcrumbs = require './breadcrumbs'
Time = require '../time'


module.exports = React.createClass
  displayName: 'ReadingTask'

  contextTypes:
    router: React.PropTypes.func

  getInitialState: ->
    {id} = @props
    currentStep = TaskStore.getDefaultStepIndex(id)

    {currentStep}

  getDefaultCurrentStep: ->
    {id} = @props
    TaskStore.getCurrentStepIndex(id)

  goToStep: (num) -> () =>
    # Curried for React
    @setState({currentStep: num})

  render: ->
    {id} = @props
    model = TaskStore.get(id)
    steps = TaskStore.getSteps(id)
    stepConfig = steps[@state.currentStep]
    {courseId} = @context.router.getCurrentParams()

    allStepsCompleted = true
    for step in steps
      unless step?.is_completed
        allStepsCompleted = false

    cx = React.addons.classSet
    classes = cx({
      'task': true
      'task-completed': allStepsCompleted 
    })

    unless TaskStore.isSingleStepped(id)
      breadcrumbs =
        <div className="panel-header">
          <Breadcrumbs id={id} goToStep={@goToStep} currentStep={@state.currentStep} />
        </div>

    if @state.currentStep > steps.length
      throw new Error('BUG! currentStep is too large')
    else if @state.currentStep < -1
      throw new Error('BUG! currentStep is too small')

    else if @state.currentStep is -1
      if allStepsCompleted
        End = if model.type is 'practice' then PracticeEnd else TaskEnd

        panel = <End courseId={courseId} taskId={id} reloadPractice={@reloadTask}/>

      else
        footer = <BS.Button bsStyle="primary" className='-continue' onClick={@goToStep(0)}>Continue</BS.Button>
        
        panel = <BS.Panel bsStyle="default" footer={footer}>
                  <h1>{model.title}</h1>
                  <p>Due At: <Time date={model.due_at}></Time></p>
                </BS.Panel>

    else
      throw new Error('BUG: no valid step config') unless stepConfig

      panel = <TaskStep
                id={stepConfig.id}
                onStepCompleted={@onStepCompleted}
                onNextStep={@onNextStep}
              />

    <div className={classes}>
      {breadcrumbs}
      {panel}
    </div>

  reloadTask: ->
    @setState({currentStep: 0})

  onStepCompleted: ->
    {id} = @props
    # TODO: Operate on just the corrent step
    # step = TaskStore.getCurrentStep(id)
    steps = TaskStore.getSteps(id)
    step = steps[@state.currentStep]
    TaskStepActions.complete(step.id)

  onNextStep: ->
    @setState({currentStep: @getDefaultCurrentStep()})
