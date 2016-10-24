React = require 'react'
TutorLink = require '../link'

BookLink = React.createClass

  propTypes:
    book: React.PropTypes.shape(
      ecosystemId: React.PropTypes.string
      ecosystemComments: React.PropTypes.string
      id:      React.PropTypes.number
      title:   React.PropTypes.string
      uuid:    React.PropTypes.string
      version: React.PropTypes.string
    ).isRequired

  render: ->
    <TutorLink to='QAViewBook' className="book"
      params={ecosystemId: @props.book.ecosystemId}>
        <div className="title-version">
          <span>{@props.book.title}</span>
          <span>{@props.book.version}</span>
        </div>
        <span className="comments">{@props.book.ecosystemComments}</span>
    </TutorLink>


module.exports = BookLink
