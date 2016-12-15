moment = require 'moment-timezone'
{TaskPlanStore, TaskPlanActions} = require '../../flux/task-plan'
{CourseStore, CourseActions}   = require '../../flux/course'
TimeHelper = require '../../helpers/time'
{TimeStore} = require '../../flux/time'
{TaskingStore, TaskingActions} = require '../../flux/tasking'
_ = require 'underscore'
Router = require '../../helpers/router'

getOpensAtDefault = (termStart) ->
  now = TimeStore.getNow()
  if termStart.isAfter(now)
    termStart.format(TimeHelper.ISO_DATE_FORMAT)
  else
    moment(now).add(1, 'day').format(TimeHelper.ISO_DATE_FORMAT)

getQueriedOpensAt = (planId, dueAt, termStart) ->
  {opens_at} = Router.currentQuery() # attempt to read the open date from query params
  isNewPlan = TaskPlanStore.isNew(planId)
  opensAt = if opens_at and isNewPlan then TimeHelper.getMomentPreserveDate(opens_at)
  if not opensAt
    # default open date is tomorrow
    opensAt = getOpensAtDefault(termStart)

  # if there is a current due date, make sure it's not the same as the open date
  if dueAt?
    dueAtMoment = TimeHelper.getMomentPreserveDate(dueAt)
    # there's a corner case is certain timezones where isAfter doesn't quite cut it
    # and we need to check that the ISO strings don't match
    unless (dueAtMoment.isSameOrAfter(opensAt, 'day') and dueAtMoment.format(TimeHelper.ISO_DATE_FORMAT) isnt opensAt)
      # make open date today if default due date is tomorrow or today
      opensAt = moment(TimeStore.getNow()).format(TimeHelper.ISO_DATE_FORMAT)

  opensAt

getCurrentDueAt = (planId) ->
  {due_at} = Router.currentQuery() # attempt to read the due date from query params
  if due_at?
    TimeHelper.getMomentPreserveDate(due_at).format(TimeHelper.ISO_DATE_FORMAT)
  else if TaskingStore.hasTasking(planId)
    TaskingStore.getFirstDueDate(planId)

getTaskPlanOpensAt = (planId) ->
  firstDueAt = _.first(TaskPlanStore.get(planId)?.tasking_plans)?.due_at
  TimeHelper.getMomentPreserveDate(firstDueAt).format(TimeHelper.ISO_DATE_FORMAT) if firstDueAt


setPeriodDefaults = (courseId, planId, term) ->
  unless TaskingStore.hasTasking(planId)
    if TaskPlanStore.isNew(planId)
      due_date = getCurrentDueAt(planId) or getTaskPlanOpensAt(planId)
      TaskingActions.create(planId, {open_date: getQueriedOpensAt(planId, due_date, term.start), due_date})
    else
      {tasking_plans} = TaskPlanStore.get(planId)
      TaskingActions.loadTaskings(planId, tasking_plans)

  nextState = {}
  nextState.showingPeriods = not TaskingStore.getTaskingsIsAll(planId)
  nextState


loadCourseDefaults = (courseId) ->

  courseDefaults = CourseStore.getTimeDefaults(courseId)

  return unless courseDefaults?

  periods = CourseStore.getPeriods(courseId)
  TaskingActions.loadDefaults(courseId, courseDefaults, periods)


module.exports = (planId, courseId, term) ->
  courseTimezone = CourseStore.getTimezone(courseId)
  TaskingActions.loadTaskToCourse(planId, courseId)
  loadCourseDefaults(courseId)

  #set the periods defaults only after the timezone has been synced
  return setPeriodDefaults(courseId, planId, term)
