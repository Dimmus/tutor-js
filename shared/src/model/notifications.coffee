EventEmitter2 = require 'eventemitter2'
moment = require 'moment'

clone     = require 'lodash/clone'
defaults  = require 'lodash/defaults'
uniqueId  = require 'lodash/uniqueId'
without   = require 'lodash/without'
extend    = require 'lodash/extend'
find      = require 'lodash/find'
isEmpty   = require 'lodash/isEmpty'

URLs = require './urls'
EVENT_BUS = new EventEmitter2
POLLERS = {}

NOTICES = []

CLIENT_ID = 'client-specified'
Poller = require './notifications/pollers'

Notifications = {
  POLLING_TYPES:
    MISSING_STUDENT_ID: 'missing_student_id'
    COURSE_HAS_ENDED: 'course_has_ended'

  # for use by specs, not to be considered "public"
  _reset: ->
    @stopPolling()
    NOTICES = []

  display: (notice) ->
    # fill in an id and type if not provided
    NOTICES.push( defaults(clone(notice), id: uniqueId(CLIENT_ID), type: CLIENT_ID ))
    @emit('change')

  _startPolling: (type, url) ->
    POLLERS[type] ||= Poller.forType(@, type)
    POLLERS[type].setUrl(url)

  startPolling: (@windowImpl = window) ->
    @_startPolling(
      'accounts', URLs.construct('accounts_api', 'user')
    ) if URLs.get('accounts_api')

    @_startPolling(
      'tutor', URLs.construct('tutor_api', 'notifications')
    ) if URLs.get('tutor_api')


  acknowledge: (notice) ->
    poller = POLLERS[notice.type]
    if poller # let the poller decide what to do
      poller.acknowledge(notice)
    else
      NOTICES = without(NOTICES, find(NOTICES, id: notice.id))
      @emit('change')

  getActive: ->
    return NOTICES[0] if NOTICES.length
    for type, poller of POLLERS
      notice = poller.getActiveNotification()
      return notice if notice
    null

  stopPolling: ->
    poller.destroy() for type, poller of POLLERS
    POLLERS = {}

  setCourseRole: (course, role) ->
    return if role.type is 'teacher'
    unless isEmpty(role)
      studentId = find(course.students, role_id: role.id)?.student_identifier
      if isEmpty(studentId) and moment().diff(role.joined_at, 'days') > 7
        @display({type: @POLLING_TYPES.MISSING_STUDENT_ID, course, role})
    if moment(course.ends_at).isBefore(moment(), 'day')
      @display({type: @POLLING_TYPES.COURSE_HAS_ENDED, course, role})

}

# mixin event emitter methods, particulary it's 'on' and 'off'
# since they're compatible with Tutor's bindstore mixin
extend Notifications, EVENT_BUS

module.exports = Notifications
