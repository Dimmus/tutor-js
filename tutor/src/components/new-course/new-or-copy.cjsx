React = require 'react'
BS = require 'react-bootstrap'

partial = require 'lodash/partial'
isEqual = require 'lodash/isEqual'
isEmpty = require 'lodash/isEmpty'

{NewCourseActions, NewCourseStore} = require '../../flux/new-course'
{CourseListingStore} = require '../../flux/course-listing'
TutorRouter = require '../../helpers/router'

Choice = require './choice'

KEY = "new_or_copy"

SelectDates = React.createClass
  displayName: 'SelectDates'
  statics:
    title: 'Do you want to create a new course or copy a previous course?'
    shouldSkip: ->
      TutorRouter.currentParams()?.sourceId or
        isEmpty(CourseListingStore.teachingCoursesForOffering(NewCourseStore.get('offering_id')))

  onSelect: (value) ->
    NewCourseActions.set({"#{KEY}": value})

  render: ->

    <BS.ListGroup>
      <Choice
        key='course-new'
        active={isEqual(NewCourseStore.get(KEY), 'new')}
        onClick={partial(@onSelect, 'new')}
        data-new-or-copy='new'
      >
        Create a new course
      </Choice>
      <Choice
        key='course-copy'
        active={isEqual(NewCourseStore.get(KEY), 'copy')}
        onClick={partial(@onSelect, 'copy')}
        data-new-or-copy='copy'
      >
        Copy a past course
      </Choice>
    </BS.ListGroup>


module.exports = SelectDates
