React = require 'react'
classnames = require 'classnames'
Router = require '../helpers/router'
renderers = require '../router'
RoutingHelper = require '../helpers/routing'
Analytics = require '../helpers/analytics'
Navbar = require './navbar'
merge = require 'lodash/merge'
{SpyMode} = require 'shared'
{CourseStore} = require '../flux/course'
{TransitionActions, TransitionStore} = require '../flux/transition'

module.exports = React.createClass
  displayName: 'App'
  contextTypes:
    router: React.PropTypes.object

#   getChildContext: ->
#     debugger
#     router: merge(@context.router, getCurrentParams: Router.getCurrentParams)
# #    courseId: @props.params?.courseId

  childContextTypes:
    courseId: React.PropTypes.string

  componentDidMount: ->
    @storeHistory()
    Analytics.setTracker(window.ga)

  componentDidUpdate: ->
    @storeHistory()

  storeHistory:  ->
    Analytics.onNavigation(@props.location.pathname)
    TransitionActions.load(@props.location.pathname)

  render: ->
    params = Router.currentParams()
    {courseId} = params

    classNames = classnames('tutor-app', 'openstax-wrapper', {
      'is-college':     courseId? and CourseStore.isCollege(courseId)
      'is-high-school': courseId? and CourseStore.isHighSchool(courseId)
    })

    <div className={classNames}>
      <SpyMode.Wrapper>
        <Navbar {...@props}/>
        <RoutingHelper.component routes={Router.getRenderableRoutes(renderers)} />
      </SpyMode.Wrapper>
    </div>