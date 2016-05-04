$ = require 'jquery'
_ = require 'underscore'
{ExerciseActions, ExerciseStore} = require './stores/exercise'
{VocabularyActions, VocabularyStore} = require './stores/vocabulary'
{ErrorsActions} = require './stores/errors'

# Do some special things when running without a tutor-server backend.
#
# - suffix calls with `.json` so we can have `/plans` and `/plans/1`
#   - otherwise there would be a file named `plans` and a directory named `plans`
# - do not error when a PUT occurs
IS_LOCAL = window.location.port is '8001' or window.__karma__

CSRF_Token = document.head.querySelector('meta[name=csrf-token]')?.getAttribute("content")

# Make sure API calls occur **after** all local Action listeners complete
delay = (ms, fn) -> setTimeout(fn, ms)

apiHelper = (Actions, listenAction, successAction, httpMethod, pathMaker) ->
  listenAction.addListener 'trigger', (args...) ->
    # Make sure API calls occur **after** all local Action listeners complete
    delay 20, ->
      {url, payload, httpMethod:httpMethodOverride} = pathMaker(args...)

      opts =
        method: httpMethod or httpMethodOverride
        dataType: 'json'
        headers:
          'X-CSRF-Token': CSRF_Token,

      if payload?
        opts.data = JSON.stringify(payload)
        opts.processData = false
        # For now, the backend is expecting JSON and cannot accept url-encoded forms
        opts.contentType = 'application/json'

      if IS_LOCAL
        [uri, params] = url.split("?")
        if opts.method is 'GET'
          url = "#{uri}.json?#{params}"
        else
          url = "#{uri}/#{opts.method}.json?#{params}"
          opts.method = 'GET'

      resolved = (results, statusStr, jqXhr) ->
        successAction(results, args...) # Include listenAction for faking
      rejected = (jqXhr, statusMessage, err) ->
        statusCode = jqXhr.status
        ErrorsActions.setServerError(statusCode, jqXhr.responseText, {url, opts})
        if statusMessage is 'parsererror' and statusCode is 200 and IS_LOCAL
          if httpMethod is 'PUT' or httpMethod is 'PATCH'
            # HACK for PUT
            successAction(null, args...)
          else
            # Hack for local testing. Webserver returns 200 + HTML for 404's
            Actions.FAILED(404, 'Error Parsing the JSON or a 404', args...)
        else if statusCode is 404
          Actions.FAILED(statusCode, 'ERROR_NOTFOUND', args...)
        else
          # Parse the error message and fail
          try
            msg = JSON.parse(jqXhr.responseText)
          catch e
            msg = jqXhr.responseText
          Actions.FAILED(statusCode, msg, args...)

      $.ajax(url, opts)
      .then(resolved, rejected)

start = ->
  apiHelper ExerciseActions, ExerciseActions.load, ExerciseActions.loaded, 'GET', (id) ->
    url: "/api/exercises/#{id}@draft"

  apiHelper ExerciseActions, ExerciseActions.save, ExerciseActions.saved, 'PUT', (id) ->

    # backend expects the changed props and the entire exercise for some reason
    obj = ExerciseStore.getChanged(id)
    obj.exercise = ExerciseStore.get(id)

    exerciseId = if id.indexOf("@") is -1 then id else id.split("@")[0]

    url:"/api/exercises/#{exerciseId}@draft"
    httpMethod: 'PUT'
    payload: obj

  apiHelper ExerciseActions, ExerciseActions.create, ExerciseActions.created, 'POST', (id, obj) ->
    # backend expects the changed props and the entire exercise for some reason
    obj = ExerciseStore.get(id)

    url:"/api/exercises"
    httpMethod: 'POST'
    payload: obj

  apiHelper ExerciseActions, ExerciseActions.publish, ExerciseActions.published, 'PUT', (id) ->

    obj = ExerciseStore.get(id)
    uid = ExerciseStore.getId(id)

    url: "/api/exercises/#{uid}/publish"
    httpMethod: 'PUT'
    payload: obj

  apiHelper ExerciseActions, ExerciseActions.deleteAttachment, ExerciseActions.attachmentDeleted, 'DELETE',
  (exerciseUid, attachmentId) ->
    url: "/api/exercises/#{exerciseUid}/attachments/#{attachmentId}"
    httpMethod: 'DELETE'

  apiHelper VocabularyActions, VocabularyActions.load, VocabularyActions.loaded, 'GET', (id) ->
    url: "/api/vocab_terms/#{id}@draft"

  apiHelper VocabularyActions, VocabularyActions.create, VocabularyActions.created, 'POST', (id, obj) ->
    # backend expects the changed props and the entire exercise for some reason
    obj = VocabularyStore.get(id)

    url:"/api/vocab_terms"
    httpMethod: 'POST'
    payload: obj

  apiHelper VocabularyActions, VocabularyActions.save, VocabularyActions.saved , 'PUT', (id, obj) ->
    # backend expects the changed props and the entire exercise for some reason
    obj = VocabularyStore.get(id)

    url:"/api/vocab_terms"
    httpMethod: 'PUT'
    payload: obj

uploadExerciseImage = (exerciseUid, image, cb) ->
  url = "/api/exercises/#{exerciseUid}/attachments"
  xhr = new XMLHttpRequest()
  xhr.addEventListener 'load', (req) ->
    cb(if req.currentTarget.status is 201
      attachment = JSON.parse(req.target.response)
      ExerciseActions.attachmentUploaded(exerciseUid, attachment)
      {response: attachment, progress: 100}
    else
      {error: req.currentTarget.statusText})
  xhr.addEventListener 'progress', (ev) ->
    cb({progress: (ev.total / (ev.total or image.size) * 100) })
  xhr.open('POST', url, true)
  xhr.setRequestHeader('X-CSRF-Token', CSRF_Token)
  form = new FormData()
  form.append("image", image, image.name)
  xhr.send(form)

module.exports = {start, uploadExerciseImage}
