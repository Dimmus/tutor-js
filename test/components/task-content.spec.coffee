# Tests for homework specific tasks

# -----------------------------------------------------------------------------------------------------
# TODO: For some reason the StepContent is undefined in the test, and therefore this code doesn't work.
# -----------------------------------------------------------------------------------------------------

{Testing, expect, sinon, _} = require './helpers/component-testing'

{StepContent} = require '../../src/components/task-step/step-with-reading-content'

{TaskActions, TaskStore} = require '../../src/flux/task'
{TaskStepActions, TaskStepStore} = require '../../src/flux/task-step'
{CourseActions} = require '../../src/flux/course'

courseId = '1'
course = require '../../api/user/courses/1.json'
step = require '../../api/steps/step-id-4-4.json'
stepId = '4'

describe 'Task Widget, rendering content', ->
  beforeEach ->
    CourseActions.loaded(course, courseId)

  it 'should render no frame for interactives', ->
    TaskStepActions.loaded(step, stepId)

    # render the step and then make sure it doesn't have a frame around it
    props = {
      id: stepId
      stepType: 'interactive'
    }

    Testing.renderComponent(StepContent, props: props).then ({dom}) ->
      expect(dom.querySelector('.frame-wrapper')).to.be.null

  it 'should render a frame for non-interactives', ->
    TaskStepActions.loaded(step, stepId)

    # render the step and then make sure it doesn't have a frame around it
    props = {
      id: stepId
      stepType: 'reading'
    }

    Testing.renderComponent(StepContent, props: props).then ({dom}) ->
      expect(dom.querySelector('.frame-wrapper')).to.not.be.null
