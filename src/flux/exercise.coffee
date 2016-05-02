# coffeelint: disable=no_empty_functions
flux = require 'flux-react'
_ = require 'underscore'
{TocStore} = require './toc'
{makeSimpleStore} = require './helpers'
LOADING = 'loading'
SAVING  = 'saving'

EXERCISE_TAGS =
  TEKS: 'teks'
  LO: ['lo', 'aplo']
  GENERIC: ['blooms', 'dok', 'length']

getChapterSection = (exercise) ->
  tag = _.find(exercise.tags, (t) ->
    _.include(EXERCISE_TAGS.LO, t.type)
  )
  tag?.chapter_section.join('.')

getTagName = (tag) ->
  name = _.compact([tag.name, tag.description]).join(' ')
  name = tag.id unless name
  name

EXERCISE_TYPE_MAPPING =
  homework: 'homework_core'
  reading:  'reading_dynamic'

filterForPoolType = (exercises, pool_type) ->
  _.filter exercises, (exercise) -> -1 isnt exercise.pool_types.indexOf(pool_type)

getImportantTags = (tags) ->
  obj =
    lo: ""
    section: ""
    tagString: []

  _.reduce(_.sortBy(tags, 'name'), (memo, tag) ->
    if (_.include(EXERCISE_TAGS.GENERIC, tag.type))
      memo.tagString.push(tag.name)
    else if (_.include(EXERCISE_TAGS.LO, tag.type))
      memo.lo = getTagName(tag)
      memo.section = tag.chapter_section
    memo
  , obj)

ExerciseConfig =
  _exercises: []
  _asyncStatus: null
  _exerciseCache: []
  _unsavedExclusions: {}

  FAILED: -> console.error('BUG: could not load exercises')

  reset: ->
    @_exercises = []
    @_exerciseCache = []
    @_unsavedExclusions = {}

  loadForCourse: (courseId, pageIds) -> # Used by API
    @_asyncStatus = LOADING
  loadedForCourse: (obj, courseId, pageIds) ->
    @processLoad(obj, pageIds)

  loadForEcosystem: (ecosystemId, pageIds) -> # Used by API
    @_asyncStatus = LOADING

  loadedForEcosystem: (obj, ecosystemId, pageIds) ->
    @processLoad(obj, pageIds)

  processLoad: (obj, pageIds) ->
    key = pageIds.toString()
    delete @_asyncStatus
    return if @_exercises[key] and @_HACK_DO_NOT_RELOAD
    @_exercises[key] = obj.items
    @cacheExercises(obj.items)

  cacheExercises: (exercises) ->
    for exercise in exercises
      if @_exerciseCache[exercise.id]
        _.extend(@_exerciseCache[exercise.id], exercise)
      else
        @_exerciseCache[exercise.id] = exercise
    @emitChange()

  saveExclusions: (courseId) -> # Used to trigger save by API
    @_exclusionsAsyncStatus = SAVING
    @emitChange()

  updateExercises: (updatedExercises) ->
    for updatedExercise in updatedExercises
      for pageIds, storedExercises of @_exercises
        for storedExercise in storedExercises when storedExercise.id is updatedExercise.id
          _.extend(storedExercise, updatedExercise)
    @cacheExercises(updatedExercises) # will @emitChange() so we don't bother to ourselves

  exclusionsSaved: (exercises, courseId) ->
    @_unsavedExclusions = {}
    delete @_exclusionsAsyncStatus
    @updateExercises(exercises)

  setExerciseExclusion: (exerciseId, isExcluded) ->
    @_unsavedExclusions[exerciseId] = isExcluded
    @emitChange()

  resetUnsavedExclusions: ->
    @_unsavedExclusions = {}
    @emitChange()

  HACK_DO_NOT_RELOAD: (bool) -> @_HACK_DO_NOT_RELOAD = bool

  exports:
    isLoading: -> @_asyncStatus is LOADING
    isSavingExclusions: -> @_exclusionsAsyncStatus is SAVING
    isLoaded: (pageIds) ->
      !!@_exercises[pageIds.toString()]

    get: (pageIds) ->
      @_exercises[pageIds.toString()] or throw new Error('BUG: Invalid page ids')

    isExcludedAtMinimum: (exercises) ->
      excluded = _.filter _.pluck(exercises, 'id'),
        _.bind(@.exports.isExerciseExcluded, @)
      (exercises.length - excluded.length) is 5

    hasUnsavedExclusions: ->
      not _.isEmpty @_unsavedExclusions
    getUnsavedExclusions: ->
      @_unsavedExclusions

    isExerciseExcluded: (exerciseId) ->
      if @_unsavedExclusions[exerciseId]?
        @_unsavedExclusions[exerciseId]
      else
        @_exerciseCache[exerciseId]?.is_excluded

    getGroupedIncludedExercises: (pageIds) ->
      exercises = @_exercises[pageIds.toString()]
      includedExercises = _.reject exercises, 'is_excluded'
      _.groupBy(includedExercises, getChapterSection)

    groupBySectionsAndTypes: (pageIds) ->
      all = @_exercises[pageIds.toString()]
      results = {
        all:
          count: all.length
          grouped: _.groupBy(all, getChapterSection)
      }
      for name, pool_type of EXERCISE_TYPE_MAPPING
        exercises = filterForPoolType(all, pool_type)
        results[name] = {
          count: exercises.length
          grouped: _.groupBy( exercises, getChapterSection)
        }
      results

    getExerciseById: (exercise_id) ->
      @_exerciseCache[exercise_id]

    getTeksString: (exercise_id) ->
      tags = @_exerciseCache[exercise_id].tags
      teksTags = _.where(tags, {type: EXERCISE_TAGS.TEKS})
      _.map(teksTags, (tag) ->
        tag.name?.replace(/[()]/g, '')
      ).join(" / ")

    getContent: (exercise_id) ->
      @_exerciseCache[exercise_id].content.questions[0].stem_html

    getTagContent: (tag) ->
      content = getTagName(tag) or tag.id
      isLO = _.include(EXERCISE_TAGS.LO, tag.type)
      {content, isLO}

    getTagStrings: (exercise_id) ->
      tags = @_exerciseCache[exercise_id].tags
      getImportantTags(tags)

    removeTopicExercises: (exercise_ids, topic_id) ->
      cache = @_exerciseCache
      topic_chapter_section = TocStore.getChapterSection(topic_id)
      _.reject(exercise_ids, (exercise_id) ->
        exercise = cache[exercise_id]
        {section} = getImportantTags(exercise.tags)
        section.toString() is topic_chapter_section.toString()
      )

    # Searches for the given format in either an exercise or it's content
    hasQuestionWithFormat: (format, {exercise, content}) ->
      content = exercise.content unless content?
      !!_.detect content.questions, (q) -> _.include(q.formats, format)

    # Searches for the given format in either an exercise or it's content
    doQuestionsHaveFormat: (format, {exercise, content}) ->
      content = exercise.content unless content?
      _.map content.questions, (q) -> _.include(q.formats, format)

    getExerciseTypes: (exercise) ->
      tags = _.filter exercise.tags, (tag) ->
        tag.id.indexOf('filter-type:') is 0 or tag.id.indexOf('type:') is 0
      _.map tags, (tag) -> _.last tag.id.split(':')

    getPageExerciseTypes: (pageId) ->
      _.unique _.flatten _.map @_exercises[pageId], @exports.getExerciseTypes

    # poolTypes: (exercise) ->
    #   _.without( exercise.pool_types, 'all_exercises')

    allForPage: (pageId) ->
      @_exercises[pageId] or []

{actions, store} = makeSimpleStore(ExerciseConfig)
module.exports = {ExerciseActions:actions, ExerciseStore:store}
