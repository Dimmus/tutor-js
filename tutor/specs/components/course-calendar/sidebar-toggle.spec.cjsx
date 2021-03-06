{React, SnapShot} = require '../helpers/component-testing'
{UiSettings} = require 'shared'

jest.mock('../../../src/components/course-calendar/helper')
Helper = require '../../../src/components/course-calendar/helper'

Toggle = require '../../../src/components/course-calendar/sidebar-toggle'

describe 'CourseCalendar Sidebar Toggle', ->

  beforeEach ->

    @props =
      courseId: '42'
      onToggle: sinon.spy()

  it 'renders and toggles', ->
    wrapper = shallow(<Toggle {...@props} />)
    expect(wrapper.hasClass('open')).to.equal false
    wrapper.simulate('click')
    expect(wrapper.hasClass('open')).to.equal true
    expect(@props.onToggle).to.have.been.calledWith(true)
    undefined

  it 'schedules and then clears timeout on unmount', ->
    Helper.scheduleIntroEvent.mockReturnValueOnce(42)
    wrapper = shallow(<Toggle {...@props} />)
    expect(Helper.scheduleIntroEvent).toHaveBeenCalled()
    wrapper.unmount()
    expect(Helper.clearScheduledEvent).toHaveBeenCalledWith(42)
    undefined

  it 'stores per-course state using helper', ->
    wrapper = shallow(<Toggle {...@props} />)
    wrapper.simulate('click')
    expect(Helper.setSidebarOpen).toHaveBeenCalledWith(@props.courseId, true)
    undefined


  it 'displays the correct icon after animation finishes', ->
    wrapper = shallow(<Toggle {...@props} />)
    expect(wrapper.hasClass('open')).to.equal false
    wrapper.simulate('click')
    expect(wrapper.find('Icon[type="bars"]').length).to.equal(1)
    wrapper.simulate('transitionEnd')
    expect(wrapper.find('Icon[type="times"]').length).to.equal(1)
    undefined

  it 'defaults to last opened value', ->
    Helper.isSidebarOpen.mockReturnValueOnce(true)
    wrapper = shallow(<Toggle {...@props} />)
    expect(wrapper.hasClass('open')).to.equal true
    expect(wrapper.find('Icon[type="times"]').length).to.equal(1)
    undefined

  it 'matches snapshot', ->
    component = SnapShot.create(
      <Toggle {...@props} />
    )
    tree = component.toJSON()
    expect(tree).toMatchSnapshot()
