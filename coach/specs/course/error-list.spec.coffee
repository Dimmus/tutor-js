{Testing, expect, sinon, _, ReactTestUtils} = require 'shared/specs/helpers'

ErrorList = require 'course/error-list'
Course = require 'course/model'
STATUS = require '../../auth/status/GET'
COURSE = STATUS.courses[0]

describe 'ErrorList Component', ->

  it 'displays errors from course', ->
    course = new Course(COURSE)
    course.errors = [
      {code: 'already_enrolled'}, {code: 'already_processed'}
    ]
    Testing.renderComponent( ErrorList, props: {course} ).then ({dom}) ->
      expect(_.pluck(dom.querySelectorAll('li'), 'textContent')).to.deep.equal(
        ['You are already enrolled in this course.  Please verify the enrollment code and try again.',
         'Your enrollment in this course has been processed. Please reload the page.']
      )
