React = require 'react'
BS = require 'react-bootstrap'

{TaskPlanStore, TaskPlanActions} = require '../../../flux/task-plan'
{PlanPublishStore} = require '../../../flux/plan-publish'
PlanHelper = require '../../../helpers/plan'

HelpTooltip  = require './help-tooltip'
SaveButton   = require './save-button'
CancelButton = require './cancel-button'
BackButton   = require './back-button'
DraftButton  = require './save-as-draft'
DeleteLink   = require './delete-link'

PlanFooter = React.createClass
  displayName: 'PlanFooter'
  contextTypes:
    router: React.PropTypes.object
  propTypes:
    id:               React.PropTypes.string.isRequired
    courseId:         React.PropTypes.string.isRequired
    hasError:         React.PropTypes.bool.isRequired
    goBackToCalendar: React.PropTypes.func

  getDefaultProps: ->
    goBackToCalendar: =>
      @context.router.transitionTo(Router.makePathname('taskplans', {courseId}))
    isVisibleToStudents: false

  getInitialState: ->
    isEditable: TaskPlanStore.isEditable(@props.id)
    publishing: TaskPlanStore.isPublishing(@props.id)
    saving: TaskPlanStore.isSaving(@props.id)

  checkPublishingStatus: (published) ->
    planId = @props.id
    if published.for is planId
      planStatus =
        publishing: PlanPublishStore.isPublishing(planId)

      @setState(planStatus)
      if PlanPublishStore.isDone(planId)
        PlanPublishStore.removeAllListeners("progress.#{planId}.*", @checkPublishingStatus)
        TaskPlanActions.load(planId)

  componentWillMount: ->
    plan = TaskPlanStore.get(@props.id)
    publishState = PlanHelper.subscribeToPublishing(plan, @checkPublishingStatus)
    @setState(publishing: publishState.isPublishing)

  saved: ->
    courseId = @props.courseId
    TaskPlanStore.removeChangeListener(@saved)
    @props.goBackToCalendar()

  onDelete: ->
    {id, courseId} = @props
    TaskPlanActions.delete(id)
    @props.goBackToCalendar()

  onSave: ->
    saving = @props.onSave()
    @setState({saving: saving, publishing: false})

  onPublish: ->
    publishing = @props.onPublish()
    @setState({publishing: publishing, saving: false, isEditable: TaskPlanStore.isEditable(@props.id)})

  onViewStats: ->
    {id, courseId} = @props
    @context.router.transitionTo(Router.makePathname('viewStats', {courseId, id}))

  render: ->
    {id, hasError} = @props
    plan = TaskPlanStore.get(id)
    isWaiting   = TaskPlanStore.isSaving(id) or TaskPlanStore.isPublishing(id) or TaskPlanStore.isDeleteRequested(id)
    isFailed    = TaskPlanStore.isFailed(id)
    isPublished = TaskPlanStore.isPublished(id)

    <div className='builder-footer-controls'>
      <SaveButton
        onSave={@onSave}
        onPublish={@onPublish}
        isWaiting={isWaiting}
        isSaving={@state.saving}
        isEditable={@state.isEditable}
        isPublishing={@state.publishing}
        isPublished={isPublished}
        hasError={hasError}
      />
      <DraftButton
        onClick={@onSave}
        isWaiting={isWaiting and @state.saving}
        isPublishing={@state.publishing}
        isFailed={isFailed}
        hasError={hasError}
        isPublished={isPublished}
      />
      <CancelButton
        isWaiting={isWaiting}
        onClick={@props.onCancel}
        isEditable={@state.isEditable}
      />
      <BackButton
        isEditable={@state.isEditable}
        getBackToCalendarParams={@props.getBackToCalendarParams}
      />
      <HelpTooltip
        isPublished={isPublished}
      />
      <DeleteLink
        isNew={TaskPlanStore.isNew(id)}
        onClick={@onDelete}
        isFailed={isFailed}
        isVisibleToStudents={@props.isVisibleToStudents}
        isWaiting={TaskPlanStore.isDeleting(id)}
        isPublished={isPublished}
      />
    </div>

module.exports = PlanFooter
