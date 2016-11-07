{connectModify, connectCreate, connectRead, connectUpdate, connectDelete} = require './adapter'

{ExerciseActions, ExerciseStore} = require '../stores/exercise'
{VocabularyActions, VocabularyStore} = require '../stores/vocabulary'

getIdOnly = (id) ->
  if id.indexOf("@") is -1 then id else id.split("@")[0]

getIdWithVersion = (id, version = 'latest') ->
  if id.indexOf("@") is -1 then "#{id}@#{version}" else id

start = ->
  connectRead(ExerciseActions, handleError: ExerciseStore.isMissingExercise, url: (id) -> "exercises/#{getIdWithVersion(id)}" )

  connectUpdate(ExerciseActions, (id) ->
    # backend expects the changed props and the entire exercise for some reason
    obj = ExerciseStore.getChanged(id)
    obj.exercise = ExerciseStore.get(id)

    exerciseId = getIdOnly(id)

    url: "exercises/#{exerciseId}@draft"
    method: 'PUT'
    data: obj
  )

  connectCreate(ExerciseActions, url: 'exercises', data: ExerciseStore.get)

  connectModify(ExerciseActions, {trigger: 'publish', onSuccess: 'published'},
    (id) ->
      obj = ExerciseStore.get(id)
      uid = ExerciseStore.getId(id)

      url: "exercises/#{uid}/publish"
      data: obj
  )

  connectDelete(ExerciseActions, {trigger: 'deleteAttachment', onSuccess: 'attachmentDeleted'},
    (exerciseUid, attachmentId) -> url: "/api/exercises/#{exerciseUid}/attachments/#{attachmentId}"
  )

  connectRead(VocabularyActions, (id) -> url: "vocab_terms/#{getIdWithVersion(id, 'draft')}")

  connectCreate(VocabularyActions, url: 'vocab_terms', data: VocabularyStore.get)

  connectUpdate(VocabularyActions, (id) ->
    url: "vocab_terms/#{getIdOnly(id)}@draft"
    data: VocabularyStore.get(id)
  )

  connectModify(VocabularyActions,
    trigger: 'publish', onSuccess: 'published'
    route: VocabularyStore.get, data: VocabularyStore.get
  )

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
