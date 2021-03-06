React    = require 'react'
BS       = require 'react-bootstrap'
EventRow = require './event-row'

# Represents a generic event, such as a Holiday.
# It's the fallback renderer for events that do not
# have a designated renderer
module.exports = React.createClass
  displayName: 'GenericEventRow'

  propTypes:
    event: React.PropTypes.object.isRequired
    courseId: React.PropTypes.string.isRequired

  render: ->
    <EventRow feedback='' {...@props} eventType='generic'>
        {@props.event.title}
    </EventRow>
