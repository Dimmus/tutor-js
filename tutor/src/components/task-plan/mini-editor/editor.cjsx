React = require 'react'

BS = require 'react-bootstrap'
isEmpty = require 'lodash/isEmpty'

{TaskPlanStore, TaskPlanActions} = require '../../../flux/task-plan'

classnames = require 'classnames'
camelCase = require 'lodash/camelCase'
Icon = require '../../icon'
Loading = require './loading'
TutorLink = require '../../link'
TaskingDateTimes = require '../builder/tasking-date-times'
BindStoresMixin = require '../../bind-stores-mixin'
{TutorInput, TutorTextArea} = require '../../tutor-input'
{TaskingStore, TaskingActions} = require '../../../flux/tasking'
{TeacherTaskPlanActions} = require '../../../flux/teacher-task-plan'
TimeHelper = require '../../../helpers/time'

taskPlanEditingInitialize = require '../initialize-editing'

PublishButton = require '../footer/save-button'
DraftButton   = require '../footer/save-as-draft'

PlanMixin       = require '../plan-mixin'
ServerErrorMessage = require '../../server-error-message'

TaskPlanMiniEditor = React.createClass

  propTypes:
    courseId:     React.PropTypes.string.isRequired
    termStart:    TimeHelper.PropTypes.moment
    termEnd:      TimeHelper.PropTypes.moment
    id:           React.PropTypes.string.isRequired
    onHide:       React.PropTypes.func.isRequired
    handleError:  React.PropTypes.func.isRequired

  mixins: [PlanMixin, BindStoresMixin]
  getBindEvents: ->
    {id} = @props
    taskingChanged:
      store: TaskingStore
      listenTo: "taskings.#{id}.*.changed"
      callback: @changeTaskPlan
    taskErrored:
      store: TaskPlanStore
      listenTo: 'errored'
      callback: @setError

  changeTaskPlan: ->
    {id} = @props

    taskings = TaskingStore.getChanged(id)
    TaskPlanActions.replaceTaskings(id, taskings)

  setTitle: (title) ->
    {id} = @props
    TaskPlanActions.updateTitle(id, title)

  setError: (error) ->
    @props.handleError(error)
    @setState({error})

  initializePlan: (props) ->
    props ?= @props
    {id, courseId, termStart, termEnd} = props
    taskPlanEditingInitialize(id, courseId, {start: termStart, end: termEnd})

  componentWillMount: ->
    @initializePlan()
    TaskingActions.updateTaskingsIsAll(@props.id, true)

  componentWillReceiveProps: (nextProps) ->
    if @props.id isnt nextProps.id or
      @props.courseId isnt nextProps.courseId
        @initializePlan(nextProps)
        TaskingActions.updateTaskingsIsAll(@props.id, true)

  onSave: ->
    saving = @save()
    @setState({saving: saving, publishing: false})

  onPublish: ->
    publishing = @publish()
    @setState({saving: false, publishing: publishing})

  afterSave: ->
    @setState({saving: false, publishing: false})
    @onCancel()

  onCancel: ->
    @props.onHide()
    if TaskPlanStore.isNew(@props.id)
      TaskPlanActions.removeUnsavedDraftPlan(@props.id)
      TeacherTaskPlanActions.removeClonedPlan(@props.courseId, @props.id)

  render: ->
    {id, courseId, termStart, termEnd} = @props
    hasError = @hasError()
    classes = classnames('task-plan-mini-editor',
      'is-invalid-form': hasError
    )

    plan = TaskPlanStore.get(id)
    isPublished = TaskPlanStore.isPublished(id)

    <div className={classes}>
      <div className="row">
        <BS.Col xs=12>
          <h4>Add Copied Assignment</h4>
        </BS.Col>
      </div>
      <div className="row">
        <BS.Col xs=12>
          <TutorInput
            label="Title"
            className='assignment-name'
            id='reading-title'
            value={plan.title or ''}
            required={true}
            onChange={@setTitle}
            disabled={@state.error?} />
        </BS.Col>
      </div>
      <div className="row times">
        <TaskingDateTimes
          bsSizes={{}}
          id={plan.id}
          isEditable={not @state.error?}
          courseId={courseId}
          termStart={termStart}
          termEnd={termEnd}
          taskingIdentifier='all'
        />
      </div>
      <div className="row">
        <BS.Col xs=6>
          Assigned to all sections
        </BS.Col>
        <BS.Col xs=6 className='text-right'>
          <TutorLink
            to={camelCase("edit-#{plan.type}")}
            params={id: plan.id, courseId: courseId}
          >
              Edit other assignment details
          </TutorLink>
        </BS.Col>
      </div>

      {<BS.Alert bsStyle='danger'>
        <ServerErrorMessage {...@state.error} debug={false} />
      </BS.Alert> if @state.error}

      <div className="builder-footer-controls">
        <PublishButton
          bsSize='small'
          onSave={@onSave}
          onPublish={@onPublish}
          isWaiting={!!(@isWaiting() and @state.publishing and isEmpty(@state.error))}
          isSaving={!!@state.saving}
          isEditable={!!@state.isEditable}
          isPublishing={!!@state.publishing}
          isPublished={isPublished}
          hasError={hasError}
        />
        <DraftButton
          bsSize='small'
          onClick={@onSave}
          isWaiting={!!(@isWaiting() and @state.saving and isEmpty(@state.error))}
          isFailed={TaskPlanStore.isFailed(id)}
          hasError={hasError}
          isPublished={isPublished}
          isPublishing={!!@state.publishing}
        />
        <BS.Button
          bsSize='small'
          className='cancel'
          bsStyle={if @state.error? then 'primary'}
          onClick={@onCancel}
          disabled={@isWaiting() and not @state.error?}
        >
          Cancel
        </BS.Button>
      </div>
    </div>

module.exports = TaskPlanMiniEditor
