# For handling steps logic outside of breadcrumb and task step rendering.
# Specifically, it returns psuedo steps `intro` and `end` in sequence with real task steps.
_ = require 'underscore'

{TaskStore} = require '../../flux/task'
{TaskStepStore} = require '../../flux/task-step'

module.exports =
  # Nice little alias that will return unique values for intro and end as step indexes.
  # This logic need not be buried with render logic anymore, yay!
  getDefaultCurrentStep: ->
    {id} = @props
    defaultIndex = TaskStore.getDefaultStepIndex(id)
    steps = TaskStore.getSteps id

    if defaultIndex is -1
      if TaskStore.isTaskCompleted(id)
        defaultIndex = steps.length
      else
        defaultIndex = 0

    defaultIndex

  latestPartIndex: ->
    {id} = @props
    latestIndex = @getDefaultCurrentStep()
    currentStep = TaskStore.getSteps(id)[latestIndex]
    return 0 unless currentStep?
    latestStepId = currentStep.id

    parts = TaskStore.getStepParts(id, latestStepId)
    latestPartIndex = TaskStore.getStepIndex(id, _.last(parts).id)

  _shouldStepCrumb: (index) ->
    {id} = @props
    latestIndex = @getDefaultCurrentStep()
    latestPartIndex = @latestPartIndex()

    # doesAllowSeeAhead is currently true for if task type is homework and for practices.
    doesAllowSeeAhead = TaskStore.doesAllowSeeAhead(id)
    doesAllowSeeAhead or index <= latestIndex or index <= latestPartIndex

  _getStepListeners: (stepType) ->
    #   One per step for the crumb status updates
    #   Two additional listeners for step loading and completion
    #     if there are placeholder steps.
    listeners =
      placeholder: 3

    listeners[stepType] or 1

  _buildSectionLabel: (chapter_section, crumbs) ->
    sectionLabel = @sectionFormat?(chapter_section, @props.sectionSeparator) if chapter_section?

    # don't label crumbs that don't start a section
    sectionLabel = null if _.findWhere(crumbs, {sectionLabel: sectionLabel})?
    sectionLabel

  _generateCrumbsFromSteps: (task, steps) ->
    crumbs = []
    task.is_completed = TaskStore.isTaskCompleted(task.id)

    # The following pushing of objects onto crumbs could be abstracted some more.
    # That would come in handy for any further case/task specific configuration needed for crumbs

    # Step crumbs
    _.each steps, (step, index) =>
      crumbs.push
        key: index
        data: step
        crumb: @_shouldStepCrumb(index)
        sectionLabel: @_buildSectionLabel(step.chapter_section, crumbs)
        type: 'step'
        listeners: @_getStepListeners(step.type)

    # Completion
    crumbType = 'end'
    crumbs.push
      key: steps.length
      data: _.pick(task, 'title', 'type')
      crumb: @_shouldStepCrumb(steps.length)
      type: crumbType
      listeners: @_getStepListeners(crumbType)
      label: 'Summary'

    crumbs

  _generateCrumbs: (id) ->
    task = TaskStore.get(id)
    steps = TaskStore.getSteps(id)
    crumbs = @_generateCrumbsFromSteps(task, steps)
    @_modifyCrumbs(task, crumbs)
    crumbs


  # can possibly abstract this more and pull this out somewhere else if needed in the future
  _modifyCrumbs: (task, crumbs) ->
    {currentStep} = @props

    # insert spacer panel/crumb for reading task that have spaced practices or personalized problems
    if task.type is 'reading'

      lastCoreIndex = _.findLastIndex crumbs, (crumb) ->
        (crumb.type is 'step') and TaskStepStore.isCore(crumb.data.id)

      notCore = if lastCoreIndex is -1
        _.find crumbs, (crumb) ->
          (crumb.type is 'step') and not TaskStepStore.isCore(crumb.data.id)
      else
        crumbs[lastCoreIndex + 1]
      if notCore?
        crumbType = 'spacer'
        spacerCrumb =
          data:
            task_id: task.id
            type: 'coach'
          crumb: @_shouldStepCrumb(notCore.key)
          type: crumbType
          listeners: @_getStepListeners(crumbType)

        crumbs.splice(notCore.key, 0, spacerCrumb)

        # # Comment in to hide next breadcrumb if needed.
        # shouldCrumbnotCore = @_shouldStepCrumb(notCore.key + 1) or (notCore.key + 1) is currentStep
        # crumbs[notCore.key + 1].crumb = shouldCrumbnotCore

        # re-key crumbs
        _.each crumbs, (crumb, index) ->
          crumb.key = index


  generateCrumbs: ->
    {id} = @props
    @_generateCrumbs id

  getCrumableCrumbs: ->
    # only return crumbables for breadcrumbs to render through
    allCrumbs = @generateCrumbs()
    crumbableCrumbs = _.where allCrumbs,
      crumb: true

  getMaxListeners: ->
    crumbs = @generateCrumbs()
    listeners = _.reduce crumbs, (memo, crumb) ->
      memo + crumb.listeners
    , 0
