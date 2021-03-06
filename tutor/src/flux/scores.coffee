# coffeelint: disable=no_empty_functions
{CrudConfig, makeSimpleStore, extendConfig} = require './helpers'
_ = require 'underscore'

{TimeStore} = require './time'

TH = require '../helpers/task'

ACCEPTING = 'accepting'
ACCEPTED = 'accepted'

REJECTING = 'rejecting'
REJECTED = 'rejected'

TASK_ID_CACHE = {}

allStudents = (scores) ->
  _.chain(scores)
    .pluck('students')
    .flatten(true)
    .each((student) ->
      # TODO remove when BE fixes role to be string
      student.role = "#{student.role}"
    )
    .value()

computeTaskCache = (data) ->
  for courseId, period of data
    for period, periodIndex in data[courseId]
      for student, studentIndex in period.students when student.is_dropped isnt true
        for task in student.data when task?
          TASK_ID_CACHE[task.id] = {task, courseId, period, periodIndex, studentIndex}

getTaskInfoById = (taskId, data) ->
  taskId = parseInt(taskId, 10)
  computeTaskCache(data) if _.isEmpty(TASK_ID_CACHE)
  return TASK_ID_CACHE[taskId]


adjustTaskAverages = (data, taskInfo, columnIndex) ->
  {task} = taskInfo
  oldScore = task.score
  course = data[taskInfo.courseId][0]
  student = course.students[taskInfo.studentIndex]

  # Update score for the task without rounding so the calculations below will use it's full precision
  task.score =
    (task.correct_on_time_exercise_count + task.correct_accepted_late_exercise_count ) /
      task.exercise_count

  # Student's course average
  numTasksStudent = 0
  numTasksStudent += 1 for studentTask in student.data when studentTask?.is_included_in_averages

  student.average_score =
    ( student.average_score - ( oldScore / numTasksStudent ) ) +
      ( task.score / numTasksStudent )

  # Assignment averages
  numStudentsTask = 0
  for student in course.students
    for studentTask, i in student.data when studentTask
      if i is columnIndex
        numStudentsTask += 1 if studentTask.is_included_in_averages

  heading = course.data_headings[columnIndex]
  if heading.average_score?
    heading.average_score =
      ( heading.average_score - ( oldScore / numStudentsTask ) ) +
        ( task.score / numStudentsTask )

  # Overall course averages
  taskCount = 0
  for student in course.students
    taskCount += 1 for studentTask in student.data when studentTask?.is_included_in_averages

  course.overall_average_score =
    (course.overall_average_score - ( oldScore / taskCount ) ) +
      ( task.score / taskCount )

  # Now round the score
  task.score = Math.round(task.score * 100 ) / 100



ScoresConfig = {

  _asyncStatus: {}

  # clear the task id cache on load & reset
  _loaded: (obj) ->
    TASK_ID_CACHE = {}
    obj
  _reset: ->
    TASK_ID_CACHE = {}

  ######################################################################
  ## The accept / reject methods mirror Tutor-Server logic.           ##
  ## See: app/subsystems/tasks/models/task.rb                         ##
  ######################################################################

  acceptLate: (taskId, columnIndex) ->
    @_asyncStatus[taskId] = ACCEPTING
    taskInfo = getTaskInfoById(taskId, @_local)
    {task} = taskInfo

    # nothing to do if it's not actually late
    return unless TH.hasLateWork(task)

    task.is_late_work_accepted = true

    task.completed_accepted_late_exercise_count =
      task.completed_exercise_count - task.completed_on_time_exercise_count
    task.correct_accepted_late_exercise_count =
      task.correct_exercise_count - task.correct_on_time_exercise_count
    task.completed_accepted_late_step_count =
      task.completed_step_count - task.completed_on_time_step_count

    task.accepted_late_at = TimeStore.getNow().toISOString()

    if task.is_included_in_averages
      adjustTaskAverages(@_local, taskInfo, columnIndex)

    @emitChange()

  acceptedLate: (unused, taskId, courseId) ->
    @_asyncStatus[taskId] = ACCEPTED
    @emitChange()

  rejectLate: (taskId, columnIndex) ->
    @_asyncStatus[taskId] = REJECTING
    taskInfo = getTaskInfoById(taskId, @_local)
    {task} = taskInfo
    task.is_late_work_accepted = false
    task.correct_accepted_late_exercise_count = 0
    task.completed_accepted_late_exercise_count = 0
    task.completed_accepted_late_step_count = 0
    delete task.accepted_late_at

    if task.is_included_in_averages
      adjustTaskAverages(@_local, taskInfo, columnIndex)

    @emitChange()

  rejectedLate: (unused, taskId, courseId) ->
    @_asyncStatus[taskId] = REJECTED
    @emitChange()


  exports:
    getEnrolledScoresForPeriod: (courseId, periodId) ->
      data = @_get(courseId)
      scores = if periodId? then _.findWhere(data, period_id: periodId) else _.first(data)
      if scores?
        scores.students = _.reject(scores.students, 'is_dropped')
      scores

    getTaskInfoById: (taskId) ->
      getTaskInfoById(taskId, @_local)

    getStudent: (courseId, roleId) ->
      students = allStudents @_get(courseId)
      _.findWhere(allStudents(@_get(courseId)), role: roleId)

    getAllStudents: (courseId) ->
      allStudents @_get(courseId)

    getStudentOfTask: (courseId, taskId) ->
      students = allStudents @_get(courseId)

      # TODO remove when BE fixed for ids to be strings instead of numbers
      taskId = parseInt(taskId)

      _.find students, (student) ->
        taskIds = _.pluck student.data, 'id'
        _.indexOf(taskIds, taskId) > -1

    isUpdatingLateStatus: (taskId) ->
      @_asyncStatus[taskId] is ACCEPTING or
      @_asyncStatus[taskId] is REJECTING


}

extendConfig(ScoresConfig, new CrudConfig())
{actions, store} = makeSimpleStore(ScoresConfig)
module.exports = {ScoresActions:actions, ScoresStore:store}
