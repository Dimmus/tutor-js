React = require 'react'
BS = require 'react-bootstrap'
Router = require 'react-router'
_ = require 'underscore'
classnames = require 'classnames'

CourseName = require './course-name'
ServerErrorMonitoring = require './server-error-monitoring'
UserActionsMenu = require './user-actions-menu'
BookLinks = require './book-links'
CenterControls = require './center-controls'
{NotificationsBar} = require 'openstax-react-components'

{CurrentUserActions} = require '../../flux/current-user'
{CourseStore} = require '../../flux/course'
{CourseListingStore} = require '../../flux/course-listing'

module.exports = React.createClass
  displayName: 'Navigation'

  contextTypes:
    router: React.PropTypes.func

  componentWillMount: ->
    CourseListingStore.ensureLoaded()

  getInitialState: ->
    course = @getCourseFromParams()
    {course}

  getCourseFromParams: ->
    {courseId} = @context.router.getCurrentParams()
    CourseStore.get(courseId) if courseId?

  handleCourseChanges: ->
    if @isMounted()
      course = @getCourseFromParams()
      unless _.isEqual(course, @state.course)
        @setState({course})

  componentDidUpdate: ->
    @handleCourseChanges()

  componentDidMount: ->
    CourseStore.on('course.loaded', @handleCourseChanges)

  componentWillUnmount: ->
    CourseStore.off('course.loaded', @handleCourseChanges)

  render: ->
    {course} = @state
    {courseId} = @context.router.getCurrentParams()

    brand = <Router.Link to='dashboard' className='navbar-brand'>
              <i className='ui-brand-logo'></i>
            </Router.Link>

    <BS.Navbar toggleNavKey={0} fixedTop fluid>
      <CenterControls/>
      <BS.NavBrand>
        {brand}
      </BS.NavBrand>
      <BS.CollapsibleNav eventKey={0}>
        <BS.Nav navbar>
          <CourseName course={course}/>
          <BookLinks courseId={courseId} />
        </BS.Nav>
        <BS.Nav right navbar>
          <UserActionsMenu courseId={courseId} course={@getCourseFromParams()} />
        </BS.Nav>
      </BS.CollapsibleNav>
      <ServerErrorMonitoring />
      <NotificationsBar />
    </BS.Navbar>
