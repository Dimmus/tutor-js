React = require 'react'

{TocStore, TocActions} = require '../../flux/toc'
{CourseStore} = require '../../flux/course'
LoadableItem = require '../loadable-item'
{UnsavedStateMixin} = require '../unsaved-state'
{ExerciseStore} = require '../../flux/exercise'
Router = require '../../helpers/router'
showDialog = require './unsaved-dialog'
Dashboard = require './dashboard'



QuestionsDashboardShell = React.createClass

  mixins: [UnsavedStateMixin]
  hasUnsavedState: ->
    ExerciseStore.hasUnsavedExclusions()

  render: ->
    {courseId} = Router.currentParams()
    ecosystemId = CourseStore.get(courseId).ecosystem_id

    <LoadableItem
      id={ecosystemId}
      store={TocStore}
      actions={TocActions}
      renderItem={-> <Dashboard courseId={courseId} ecosystemId={ecosystemId} />}
    />

module.exports = QuestionsDashboardShell
