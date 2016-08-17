# coffeelint: disable=no_empty_functions
{CrudConfig, makeSimpleStore, extendConfig} = require './helpers'
{CourseListingActions} = require './course-listing'
_ = require 'underscore'

LOADED  = 'loaded'

DELETING = 'deleting'
DELETED = 'deleted'

UNDROPPING = 'undropping'
UNDROPPED = 'undropped'


RosterConfig = {

  _asyncStatus: {}

  create: (courseId, params) ->

  created: (student, courseId) ->
    @_local[courseId].push(student)
    @emitChange()

  saved: (newProps, studentId) ->
    @_asyncStatus[studentId] = LOADED
    # update the student from all the courses rosters
    for courseId, roster of @_local
      students = roster.students
      student = _.findWhere(students, id: studentId)
      _.extend(student, newProps) if student
    @emit("saved:#{studentId}")
    @emitChange()

  delete: (studentId) ->
    @_asyncStatus[studentId] = DELETING
    @emitChange()

  deleted: (unused, studentId) ->
    @_asyncStatus[studentId] = DELETED
    # set inactive
    for courseId, roster of @_local
      students = roster.students
      student = _.findWhere(students, id: studentId)
      student?.is_active = false
    @emitChange()

  teacherDelete: (teacherId, courseId, isCurrent) ->
    @_asyncStatus[teacherId] = DELETING
    for courseId, roster of @_local
      teachers = roster.teachers
      teacherIndex = _.findIndex(teachers, id: teacherId)
    roster.teachers?.splice(teacherIndex, 1)
    if isCurrent
      CourseListingActions.delete(courseId)
    @emitChange()

  teacherDeleted: (unused, teacherId) ->
    @_asyncStatus[teacherId] = DELETED
    @emitChange()

  undrop: (studentId) ->
    @_asyncStatus[studentId] = UNDROPPING
    @emitChange()

  undropped: (unused, studentId) ->
    @_asyncStatus[studentId] = UNDROPPED
    # set active
    for courseId, roster of @_local
      students = roster.students
      student = _.findWhere(students, id: studentId)
      student?.is_active = true
    @emitChange()





  exports:

    getActiveStudentsForPeriod: (courseId, periodId) ->
      _.where(@_get(courseId)?.students, period_id: periodId, is_active: true)

    getDroppedStudents: (courseId, periodId) ->
      _.where(@_get(courseId)?.students, period_id: periodId, is_active: false)

    isDeleting: (studentId) -> @_asyncStatus[studentId] is DELETING

    isTeacherDeleting: (teacherId) -> @_asyncStatus[teacherId] is DELETING

    isUnDropping: (studentId) -> @_asyncStatus[studentId] is UNDROPPING

}

extendConfig(RosterConfig, new CrudConfig())
{actions, store} = makeSimpleStore(RosterConfig)
module.exports = {RosterActions:actions, RosterStore:store}
