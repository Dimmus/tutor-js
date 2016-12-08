React = require 'react'
omit = require 'lodash/omit'
{AsyncButton, OXLink} = require 'shared'

SaveAsDraft = React.createClass

  propTypes:
    onClick:      React.PropTypes.func.isRequired
    isWaiting:    React.PropTypes.bool.isRequired
    isFailed:     React.PropTypes.bool.isRequired
    isValid:      React.PropTypes.bool.isRequired
    isPublished:  React.PropTypes.bool.isRequired

  render: ->
    return null if @props.isPublished

    additionalProps = OXLink.filterProps(
      omit(@props, 'onSave', 'onPublish', 'isEditable', 'isSaving', 'isWaiting', 'isPublished', 'isPublishing')
    , prefixes: 'bs')

    <AsyncButton
      className='-save save'
      onClick={@props.onClick}
      isWaiting={@props.isWaiting}
      isFailed={@props.isFailed}
      waitingText='Saving…'
      disabled={not @props.isValid or @props.isWaiting}
      {...additionalProps}
    >
      Save as Draft
    </AsyncButton>


module.exports = SaveAsDraft
