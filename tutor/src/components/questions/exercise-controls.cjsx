React = require 'react'
BS = require 'react-bootstrap'
classNames = require 'classnames'

{ExerciseStore, ExerciseActions} = require '../../flux/exercise'
{CourseStore} = require '../../flux/course'
{AsyncButton, ScrollToMixin} = require 'shared'
showDialog = require './unsaved-dialog'

Icon = require '../icon'

QuestionsControls = React.createClass

  mixins: [ScrollToMixin]
  scrollingTargetDOM: -> @props.windowImpl.document
  propTypes:
    exercises: React.PropTypes.shape(
      all: React.PropTypes.object
      homework: React.PropTypes.object
      reading: React.PropTypes.object
    ).isRequired
    courseId: React.PropTypes.string.isRequired
    selectedExercises: React.PropTypes.array
    filter: React.PropTypes.string
    onFilterChange: React.PropTypes.func.isRequired
    sectionizerProps:  React.PropTypes.object
    onShowDetailsViewClick: React.PropTypes.func.isRequired
    onShowCardViewClick: React.PropTypes.func.isRequired

  getDefaultProps: ->
    sectionizerProps: {}

  getInitialState: -> {
    hasSaved: false
  }

  getSections: ->
    _.keys @props.exercises.all.grouped

  onFilterClick: (ev) ->
    filter = ev.currentTarget.getAttribute('data-filter')
    if filter is @props.filter then filter = ''
    @props.onFilterChange( filter )

  render: ->
    sections = @getSections()

    selected = @props.selectedSection or _.first(sections)

    isConceptCoach = CourseStore.isConceptCoach(@props.courseId)
    filters =
      <BS.ButtonGroup className="filters">
        <BS.Button data-filter='all' onClick={@onFilterClick}
          className={classNames 'all', 'active': _.isEmpty(@props.filter) or @props.filter is 'all'}
        >
          All
        </BS.Button>

        <BS.Button data-filter='reading' onClick={@onFilterClick}
          className={classNames 'reading', 'active': @props.filter is 'reading'}
        >
          Reading
        </BS.Button>

        <BS.Button data-filter='homework' onClick={@onFilterClick}
          className={classNames 'homework', 'active': @props.filter is 'homework'}
        >
          Practice
        </BS.Button>
      </BS.ButtonGroup>

    <div className="exercise-controls-bar">
      <div className="filters-wrapper">
        {if not isConceptCoach then filters}
      </div>

      {@props.children}

      <BS.Button onClick={@scrollToTop}>
        + Select more sections
      </BS.Button>

    </div>



module.exports = QuestionsControls
