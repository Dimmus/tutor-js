{React, Testing, _} = require '../helpers/component-testing'

{TimeActions, TimeStore} = require '../../../src/flux/time'

Cell = require '../../../src/components/scores/reading-cell'
PieProgress = require '../../../src/components/scores/pie-progress'

TH = require '../../../src/helpers/task'

describe 'Student Scores Report Reading Cell', ->

  beforeEach ->
    @props =
      courseId: '1'
      student:
        name: 'Molly Bloom'
        role: 1
      task:
        status:          'in_progress'
        type:            'reading'
        step_count: 17
        completed_step_count: 11
        completed_on_time_step_count: 11
        completed_accepted_late_step_count: 0

  it 'renders progress cell', ->
    @props.size = 24
    @props.value = 33
    wrapper = shallow(<PieProgress {...@props} />)
    expect(wrapper.find('svg[width="24"][height="24"]')).to.have.length(1)
    undefined

  it 'renders as not started', ->
    @props.task.completed_step_count = 0
    @props.task.completed_on_time_step_count = 0
    expect(TH.getCompletedPercent(@props.task)).to.equal(0)
    wrapper = shallow(<Cell {...@props} />)
    expect(wrapper.find('.worked .not-started')).to.have.length(0)
    undefined

  it 'displays late caret when worked late', ->
    @props.task.completed_on_time_step_count = 3
    wrapper = shallow(<Cell {...@props} />)
    expect(wrapper.find('LateWork')).to.have.length(1)
    undefined

  it 'displays accepted caret when accepted', ->
    @props.task.completed_on_time_step_count = 1
    @props.task.is_late_work_accepted = true
    wrapper = mount(<Cell {...@props} />)
    expect(wrapper.find('LateWork')).to.have.length(1)
    expect(wrapper.find('.late-caret.accepted')).to.have.length(1)
    undefined
