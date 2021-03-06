# policies.coffee describes the following situations.
# This should handle the 4 different states an Exercise can be in:
# 1. `not(free_response)`: Show the question stem and a text area
# 2. `free_response and not(is_completed)`: Show stem, your free_response, and the multiple choice options
# 3. `correct_answer`: review how you did and show feedback (if any)
# 4. `task.is_completed and answer` show your answer choice but no option to change it

# This should also handle when an Exercise format is a True-False:
# 5.  `question.formats` does not have 'free-response' and not(is_completed): Show stem and true-false options
# 6.  `question.formats` does not have 'free-response' and `correct_answer`: review how you did and show feedback (if any)

# Also, also, also, this should handle with an exercise is part of a homework
# 7. Before due -- does not show feedback and moves on to the next question on question finish
# 8. After due -- does show feedback before moving on

_ = require 'underscore'
flux = require 'flux-react'

{TaskStepStore} = require '../../flux/task-step'
{TaskStore} = require '../../flux/task'

utils = require './utils'

defaultTask =
  type: 'default'

defaultStep =
  type: 'placeholder'

getTaskStepPanels = (stepId) ->
  step = TaskStepStore.get stepId
  step ?= defaultStep

  task = TaskStore.get step.task_id
  task ?= defaultTask

  panels = utils._getPanels task, step
  {panels, step, task}

getPanelsWithStatus = (stepId) ->
  {task, step, panels} = getTaskStepPanels stepId
  panelsWithStatus = utils._arePanelsPassed task, step, panels


StepPanel =
  getPanelsWithStatus: getPanelsWithStatus

  getPanel: (stepId) ->
    panelsWithStatus = getPanelsWithStatus stepId
    panel = utils._getPanel panelsWithStatus

    panel.name

  getRemainingActions: (stepId) ->
    panelsWithStatus = getPanelsWithStatus stepId
    remainingPanels = _.where panelsWithStatus, {passed: false}

    _.chain(remainingPanels).pluck('actions').flatten().value()

  canReview: (stepId) ->
    {panels} = getTaskStepPanels stepId
    utils._canReview panels

  canWrite: (stepId) ->
    {panels} = getTaskStepPanels stepId
    utils._canWrite panels

  canForward: (stepId) ->
    StepPanel.canContinue(stepId) and _.isEqual(StepPanel.getRemainingActions(stepId), ['clickContinue'])

  canContinue: (stepId) ->
    step = TaskStepStore.get stepId
    # if step is falsy, this step is a placeholder step and
    # can be continued from
    return true unless step?

    mostCurrentStep = TaskStore.getCurrentStep step.task_id
    isMostCurrentStep = mostCurrentStep? and (step.id is mostCurrentStep.id)

    # Steps can be continued if it's writable.
    # If it's not writable and the most current step,
    # then you cannot continue.
    @canWrite(stepId) or not isMostCurrentStep

module.exports = {StepPanel, utils}
