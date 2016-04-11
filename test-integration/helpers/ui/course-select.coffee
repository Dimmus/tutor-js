selenium = require 'selenium-webdriver'
{TestHelper} = require './test-element'
_ = require 'underscore'


COMMON_ELEMENTS =
  courseByAppearance: ({appearance, isCoach}, roles = ['student', 'teacher']) ->

    roles = [roles.toLowerCase()] if _.isString(roles)

    dataAttr = 'data-appearance'

    if appearance?
      dataAttr += "='#{appearance}'"

    selectors = {}

    if isCoach
      selectors.teacher = "[#{dataAttr}] > [href*='cc-dashboard']"
      selectors.student = "[#{dataAttr}] > [href*='content']"
    else
      selectors.teacher = "[#{dataAttr}] > [href*='calendar']"
      selectors.student = "[#{dataAttr}] > [href*='list']"

    validLinks = _.chain(selectors).pick(roles).values().value()

    css: validLinks.join(', ')

  courseByTitle: (title) ->
    css: "[data-title='#{name}'] > a"


###
Exposes helper functions for testing `.course-listing`
###
class CourseSelect extends TestHelper

  constructor: (test, testElementLocator) ->

    testElementLocator ?=
      css: '.course-listing'
    super(test, testElementLocator, COMMON_ELEMENTS)

  goToByType: (category, roles) ->
    @waitUntilLoaded()
    # Go to the bio dashboard
    switch category
      when 'BIOLOGY'
        course = @el.courseByAppearance({appearance: 'biology'}, roles).findElement()
      when 'PHYSICS'
        course = @el.courseByAppearance({appearance: 'physics'}, roles).findElement()
      when 'CONCEPT_COACH'
        course = @el.courseByAppearance({isCoach: true}, roles).findElement()
      else
        course = @el.courseByAppearance().findElement()

    console.info('course gotten or something')

    course
      .then ->
        console.info('then')
        course.click()
        true
      .thenCatch (error) ->
        console.info('thenCatch')
        console.info("Course matching #{category}, #{roles} not found.")
        # @test.utils.verbose("Course matching #{category}, #{roles} not found.  #{error.message}")
        console.info(_.keys(@), _.keys(course))
        course.cancel()
        false



  goToByTitle: (name) ->
    @el.courseByTitle(name).waitClick()

module.exports = CourseSelect
