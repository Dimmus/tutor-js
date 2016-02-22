React = require 'react'
BS = require 'react-bootstrap'
_ = require 'underscore'
classnames = require 'classnames'
api = require '../api'
{ExerciseActions, ExerciseStore} = require '../stores/exercise'

Attachment = React.createClass

  propTypes:
    exerciseUid: React.PropTypes.string.isRequired
    attachment: React.PropTypes.shape({
      asset: React.PropTypes.shape({
        url: React.PropTypes.string.isRequired
        large: React.PropTypes.shape( url: React.PropTypes.string.isRequired ).isRequired
        medium: React.PropTypes.shape( url: React.PropTypes.string.isRequired ).isRequired
        small: React.PropTypes.shape( url: React.PropTypes.string.isRequired ).isRequired
      }).isRequired
    }).isRequired

  deleteImage: ->
    ExerciseActions.deleteAttachment(@props.exerciseUid, @props.attachment.id)

  render: ->
    copypaste = """
      <img src="#{@props.attachment.asset.url}" alt="">
      <img src="#{@props.attachment.asset.large.url}" alt="">
      <img src="#{@props.attachment.asset.medium.url}" alt="">
      <img src="#{@props.attachment.asset.small.url}" alt="">
    """
    <div className='attachment with-image'>
      <img className="preview" src={@props.attachment.asset.url} />
      <div className="controls">
        <BS.Button onClick={@deleteImage}>Delete</BS.Button>
      </div>
      <textarea value={copypaste} readOnly className="copypaste" />
    </div>

module.exports = Attachment
