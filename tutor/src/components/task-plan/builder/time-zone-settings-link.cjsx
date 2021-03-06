React  = require 'react'
BS     = require 'react-bootstrap'

TutorLink = require '../../link'

{CourseStore} = require '../../../flux/course'

TimeZoneSettingsLink = React.createClass

  propTypes:
    courseId: React.PropTypes.string.isRequired

  contextTypes:
    router: React.PropTypes.object

  render: ->
    tooltip =
      <BS.Tooltip id='change-course-time'>
        Click to change course time zone
      </BS.Tooltip>
    <TutorLink
      className='course-time-zone'
      to='courseSettings'
      params={courseId: @props.courseId}
    >
      <BS.OverlayTrigger placement='top' overlay={tooltip}>
        <span>{CourseStore.getTimezone(@props.courseId)}</span>
      </BS.OverlayTrigger>
    </TutorLink>



module.exports = TimeZoneSettingsLink
