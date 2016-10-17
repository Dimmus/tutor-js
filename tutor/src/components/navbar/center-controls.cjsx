React = require 'react'
PureRenderMixin = require 'react-addons-pure-render-mixin'

moment = require 'moment'
classnames = require 'classnames'
_ = require 'underscore'

Icon = require '../icon'
{TaskStore} = require '../../flux/task'
{TaskPanelStore} = require '../../flux/task-panel'

TutorRouter = require '../../helpers/router'
TutorLink = require '../link'

module.exports = React.createClass
  displayName: 'CenterControls'

  mixins: [PureRenderMixin]

  getDefaultProps: ->
    shouldShow: false

  getInitialState: ->
    params = @props.params or {}
    params.stepIndex ?= TaskPanelStore.getStepKey(params.id, {is_completed: false})
    taskInfo = @getTaskInfo(params)
    controlInfo = @getControlInfo(params)

    _.extend {}, taskInfo, controlInfo

  componentWillMount: ->
    TaskStore.on('loaded', @updateTask)

  componentWillUnmount: ->
    TaskStore.off('loaded', @updateTask)

  componentWillReceiveProps: (nextProps) ->
    @updateControls(nextProps.params, window.location.pathname)

  shouldShow: (path) ->
    {shouldShow} = @props
    return true if shouldShow

    path ?= @props.pathname
    matchedPath = TutorRouter.pathToEntry(path)
    return false unless matchedPath?.entry?.paths

    'viewTask' in matchedPath.entry.paths

  update: (getState, params, path) ->
    show = @shouldShow(path)
    unless show
      @setState({show})
      return false

    params ?= @props.params
    params.stepIndex ?= TaskPanelStore.getStepKey(params.id, {is_completed: false})
    state = getState(params)
    @setState(state) if state?

  updateControls: (params, {path}) ->
    @update(@getControlInfo, params, path)

  updateTask: (taskId) ->
    {params} = @props
    @update(@getTaskInfo) if taskId is params.id

  getTaskInfo: (params) ->
    {id} = params
    task = TaskStore.get(id)

    return {show: false} unless task and task?.type is 'reading'

    show: true
    assignment: task.title
    due: @reformatTaskDue(task.due_at)
    date: @getDate(task.due_at)

  reformatTaskDue: (due_at) ->
    "Due #{moment(due_at).calendar()}"

  getDate: (due_at) ->
    "#{moment(due_at).date()}"

  getControlInfo: (params) ->
    hasMilestones = @hasMilestones(params)
    linkParams = @getLinkProps(params, hasMilestones)

    _.extend {}, linkParams, {hasMilestones}

  hasMilestones: (params) ->
    params.milestones?

  getLinkProps: (params, hasMilestones) ->
    return {show: false} unless params.id and params.courseId

    if hasMilestones
      params: _.omit(params, 'milestones')
      to: 'viewTaskStep'
    else
      params: _.extend({milestones: 'milestones'}, params)
      to: 'viewTaskStepMilestones'

  render: ->
    {show, assignment, due, date, hasMilestones} = @state
    return null unless show

    linkProps = _.pick @state, 'to', 'params'

    milestonesToggleClasses = classnames 'milestones-toggle',
      'active': hasMilestones

    <div className='navbar-overlay'>
      <div className='center-control'>
        <span className='center-control-assignment'>
          {assignment}
        </span>

        <span className='fa-stack'>
          <Icon type='calendar-o' onNavbar
            className='fa-stack-2x'
            tooltipProps={placement: 'bottom'}
            tooltip={due} />
          <strong className='fa-stack-1x calendar-text'>{date}</strong>
        </span>

        <TutorLink
          {...linkProps}
          ref='milestonesToggle'
          activeClassName=''
          className={milestonesToggleClasses}>
          <Icon type='th' />
        </TutorLink>
      </div>
    </div>