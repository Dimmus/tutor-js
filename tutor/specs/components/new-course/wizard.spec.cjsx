jest.mock('../../../src/helpers/router')
Router = require '../../../src/helpers/router'

{React, spyOnComponentMethod, pause} = require '../helpers/component-testing'
extend = require 'lodash/extend'
uniqueId = require 'lodash/uniqueId'
Wizard = require '../../../src/components/new-course/wizard'
OFFERINGS = require '../../../api/offerings'

{CourseActions, CourseStore} = require '../../../src/flux/course'
COURSE  = require '../../../api/courses/1.json'
COURSE_ID = '1'
{OfferingsActions} = require '../../../src/flux/offerings'

{CourseListingActions} = require '../../../src/flux/course-listing'

SnapShot = require 'react-test-renderer'

stubCourse = (courseData) ->
  extend({id: uniqueId()}, {roles: [{type: 'teacher'}]}, courseData)


describe 'Creating a course', ->

  beforeEach ->
    CourseListingActions.loaded([ stubCourse(is_concept_coach: true)])
    OfferingsActions.loaded(OFFERINGS)
    Router.currentParams.mockReturnValue({})
    @props =
      isLoading: false

  it 'displays as loading and then sets stage when done', ->
    CourseActions.loaded(COURSE, COURSE_ID)
    Router.currentParams.mockReturnValue({sourceId: '1'})
    @props.isLoading = true
    wrapper = shallow(<Wizard {...@props} />)
    expect(wrapper).toHaveRendered('OXFancyLoader[isLoading=true]')
    wrapper.setProps(isLoading: false)
    expect(wrapper).toHaveRendered('OXFancyLoader[isLoading=false]')
    expect(wrapper).toHaveRendered('SelectDates')
    expect(wrapper.state('firstStage')).to.eq(2)
    expect(wrapper.state('currentStage')).to.eq(2)
    undefined

  it 'it skips course type if a single kind was previously taught', ->
    CourseListingActions.loaded([ stubCourse(is_concept_coach: false)])
    wrapper = shallow(<Wizard {...@props} />)
    expect(wrapper).not.toHaveRendered('SelectType')
    expect(wrapper).toHaveRendered('SelectCourse')
    undefined

  it 'displays select type if multiple kinds were previously taught', ->
    CourseListingActions.loaded([
      stubCourse(is_concept_coach: true),
      stubCourse(is_concept_coach: false)
    ])
    wrapper = shallow(<Wizard {...@props} />)
    expect(wrapper).toHaveRendered('SelectType')
    undefined

  it 'advances and can go back', ->
    spy = spyOnComponentMethod(Wizard, 'onContinue')
    wrapper = mount(<Wizard {...@props} />)
    wrapper.find('CourseChoiceItem').simulate('click')
    wrapper.find('.btn.next').simulate('click')
    expect(spy.calledOnce).to.be.true
    expect(wrapper).toHaveRendered('SelectDates')
    wrapper.find('.btn.back').simulate('click')
    expect(wrapper).toHaveRendered('SelectCourse')
    undefined

  it 'matches snapshot', ->
    component = SnapShot.create(
      <Wizard {...@props} />
    )
    tree = component.toJSON()
    expect(tree).toMatchSnapshot()
    undefined
