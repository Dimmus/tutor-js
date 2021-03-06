{React} = require '../helpers/component-testing'

Header = require '../../../src/components/course-calendar/header'
moment = require 'moment'

describe 'CourseCalendar Header', ->

  beforeEach ->
    @props =
      courseId: '1'
      duration: 'month'
      setDate: sinon.spy()
      date: moment()
      format: 'MMMM YYYY'
      hasPeriods: true
      onSidebarToggle: sinon.spy()

  it 'renders with links', ->
    wrapper = shallow(<Header {...@props} />)
    expect(wrapper.find('TutorLink[to="viewPerformanceGuide"]')).to.not.be.empty
    expect(wrapper.find('TutorLink[to="viewScores"]')).to.not.be.empty
    undefined
