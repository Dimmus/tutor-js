React = require 'react'
BS = require 'react-bootstrap'
{CloseButton} = require 'shared'
{CourseNameBase} = require './course-name'

Course = require '../course/model'
user = require '../user/model'
{channel} = require './model'
api = require '../api'
UserMenu = require '../user/menu'
{NotificationsBar} = require 'shared'

Navigation = React.createClass
  displayName: 'Navigation'

  contextTypes:
    close: React.PropTypes.func
    view: React.PropTypes.string

  propTypes:
    course: React.PropTypes.instanceOf(Course)

  componentWillMount: ->
    user.ensureStatusLoaded()
    user.channel.on('change', @update)

  componentWillUnmount: ->
    user.channel.off('change', @update)

  update: ->
    @forceUpdate() if @isMounted()

  close: ->
    @context.close?()

  handleSelect: (selectedKey) ->
    channel.emit("show.#{selectedKey}", view: selectedKey) if selectedKey?

  render: ->
    {course} = @props
    {view} = @context

    courseItems = [
      <BS.NavItem
        active={view is 'progress'}
        eventKey='progress'
        key='progress'
        className='concept-coach-dashboard-nav -progress'>
        My Progress
      </BS.NavItem>
    ] if course?.isRegistered()

    <BS.Navbar fixedTop fluid>
      <BS.Navbar.Brand>
        <span key='app' className='navbar-logo'>
          <strong>Concept</strong> Coach
        </span>
        <CourseNameBase key = 'course-name' className='hidden-sm hidden-xs' course={course}/>
      </BS.Navbar.Brand>
      <BS.Navbar.Collapse>
        <BS.Nav pullRight navbar activeKey={view} onSelect={@handleSelect}>
          {courseItems}
          <BS.NavItem
            onClick={@close}
            className='concept-coach-dashboard-nav'>
            <BS.Button className='btn-plain -coach-close'>Close</BS.Button>
          </BS.NavItem>
          <UserMenu course={@props.course} />
        </BS.Nav>
      </BS.Navbar.Collapse>
      <NotificationsBar />
    </BS.Navbar>

module.exports = {Navigation, channel}
