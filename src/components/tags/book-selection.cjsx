React = require 'react'
_ = require 'underscore'

BOOKS =
  'stax-soc'     : 'Sociology'
  'stax-phys'    : 'College Physics'
  'stax-k12phys' : 'Physics',
  'stax-bio'     : 'Biology'
  'stax-apbio'   : 'Biology for AP® Courses'
  'stax-econ'    : 'Economics'
  'stax-macro'   : 'Macro Economics'
  'stax-micro'   : 'Micro Economics'
  'stax-cbio'    : 'Concepts of Biology'
  'stax-anp'     : 'Anatomy and Physiology'

BookSelection = React.createClass

  propTypes:
    onChange: React.PropTypes.func
    selected: React.PropTypes.string

  render: ->
    <select
      className='form-control'
      onChange={@props.onChange} value={@props.selected}
    >
      {if _.isEmpty(@props.selected)
        <option key='blank' value={''}></option>}
      {for tag, name of BOOKS
        <option key={tag} value={tag}>{name}</option>}
    </select>


module.exports = BookSelection
