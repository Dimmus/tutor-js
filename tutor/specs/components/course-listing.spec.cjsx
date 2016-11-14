_              = require 'underscore'
React          = require 'react'
CourseListing = require '../../src/components/course-listing'
{CourseListingActions, CourseListingStore} = require '../../src/flux/course-listing'
{CurrentUserActions} = require '../../src/flux/current-user'
{CourseStore} = require '../../src/flux/course'
{shallow, mount} = require 'enzyme'

{
  STUDENT_COURSE_ONE_MODEL
  TEACHER_COURSE_TWO_MODEL
  TEACHER_AND_STUDENT_COURSE_THREE_MODEL
  MASTER_COURSES_LIST,
  TUTOR_HELP,
  CONCEPT_COACH_HELP,
  STUDENT_ARCHIVED_COURSE,
  TEACHER_PAST_COURSE,
  STUDENT_PAST_COURSE
} = require '../courses-test-data'

loadTeacherUser = ->
  CurrentUserActions.loaded(faculty_status: 'confirmed_faculty')

describe 'Course Listing Component', ->

  afterEach ->
    CurrentUserActions.reset()

  it 'renders the listing', ->
    CourseListingActions.loaded(MASTER_COURSES_LIST)
    wrapper = mount(<CourseListing />)
    for course, i in MASTER_COURSES_LIST
      expect(wrapper.find(".course-listing-current [data-course-id=#{course.id}]")).to.have.length(1)
    undefined

  it 'renders the listing without archived courses', ->
    courseList = _.flatten([MASTER_COURSES_LIST, STUDENT_ARCHIVED_COURSE])
    CourseListingActions.loaded(courseList)
    wrapper = shallow(<CourseListing />)
    expect(wrapper.find("CourseLink[courseId=#{STUDENT_ARCHIVED_COURSE.id}]")).to.have.length(0)
    undefined

  it 'renders add course action if user is teacher', ->
    loadTeacherUser()
    wrapper = mount(<CourseListing />)
    expect(wrapper.find(".course-listing-add-zone")).to.have.length(1)
    undefined

  it 'renders controls for course if user is teacher of course', ->
    loadTeacherUser()
    CourseListingActions.loaded(MASTER_COURSES_LIST)

    wrapper = mount(<CourseListing />)

    for course, i in MASTER_COURSES_LIST
      expect(wrapper.find("[data-course-id=#{course.id}] .course-listing-item-controls"))
        .to.have.length(1) if CourseStore.isTeacher(course.id)

    undefined

  it 'does not render controls for course if user is student of course', ->
    loadTeacherUser()
    CourseListingActions.loaded(MASTER_COURSES_LIST)

    wrapper = mount(<CourseListing />)

    for course, i in MASTER_COURSES_LIST
      expect(wrapper.find("[data-course-id=#{course.id}] .course-listing-item-controls"))
        .to.have.length(0) unless CourseStore.isTeacher(course.id)

    undefined

  it 'renders past courses in past courses listing', ->
    CourseListingActions.loaded([TEACHER_PAST_COURSE, STUDENT_PAST_COURSE])

    wrapper = mount(<CourseListing />)

    expect(wrapper.find(".course-listing-past [data-course-id=#{TEACHER_PAST_COURSE.id}]"))
      .to.have.length(1)
    expect(wrapper.find(".course-listing-past [data-course-id=#{STUDENT_PAST_COURSE.id}]"))
      .to.have.length(1)

    undefined

  it 'renders empty courses if course list only contains archived course', ->
    CourseListingActions.loaded([STUDENT_ARCHIVED_COURSE])
    wrapper = shallow(<CourseListing />)
    expect(wrapper.find("EmptyCourses")).to.have.length(1)
    undefined

  it 'renders course appropriate flag', ->
    CourseListingActions.loaded(MASTER_COURSES_LIST)
    wrapper = mount(<CourseListing />)
    for course, i in MASTER_COURSES_LIST
      expect(
        wrapper.find("[data-course-id=#{course.id}] .course-listing-item-brand").render().text()
      ).equal('Openstax Tutor')
    undefined


  it 'redirects to dashboard for a single course', ->
    CourseListingActions.loaded([STUDENT_COURSE_ONE_MODEL])
    wrapper = shallow(<CourseListing />)
    expect(wrapper.find('Redirect[to="/course/1"]')).to.have.length(1)
    undefined
