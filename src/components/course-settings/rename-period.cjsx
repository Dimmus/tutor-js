React = require 'react'
BS = require 'react-bootstrap'
_ = require 'underscore'
{PeriodActions, PeriodStore} = require '../../flux/period'
{TutorInput} = require '../tutor-input'
CourseGroupingLabel = require '../course-grouping-label'

RenamePeriodField = React.createClass

  displayName: 'RenamePeriodField'
  propTypes:
    courseId: React.PropTypes.string
    label: React.PropTypes.string.isRequired
    name:  React.PropTypes.string.isRequired
    default: React.PropTypes.string.isRequired
    onChange:  React.PropTypes.func.isRequired
    autofocus: React.PropTypes.bool
    validate: React.PropTypes.func.isRequired

  componentDidMount: ->
    @refs.input.focus() if @props.autofocus
    @refs.input.cursorToEnd() if @props.autofocus

  onChange: (value) ->
    @props.onChange(value)

  render: ->
    <TutorInput
      ref="input"
      label={@props.label}
      default={@props.default}
      required={true}
      onChange={@onChange}
      validate={@props.validate} />

module.exports = React.createClass
  displayName: 'RenamePeriodLink'
  propTypes:
    courseId: React.PropTypes.string.isRequired
    periods: React.PropTypes.array.isRequired
    activeTab: React.PropTypes.object.isRequired

  getInitialState: ->
    period_name: @props.activeTab.name
    showModal: false

  close: ->
    @setState({showModal: false})

  open: ->
    @setState({showModal: true})

  validate: (name) ->
    error = PeriodStore.validatePeriodName(name, @props.periods, @props.activeTab.name)
    @setState({invalid: error?})
    error

  performUpdate: ->
    if not @state.invalid
      id = @props.activeTab.id
      PeriodActions.save(@props.courseId, id, period: {name: @state.period_name})
      @close()

  renderForm: ->
    formClasses = ['modal-body', 'teacher-edit-period-form']
    if @state?.invalid
      formClasses.push('is-invalid-form')
      disabled = true
    title =
      <h4>Rename <CourseGroupingLabel courseId={@props.courseId}/></h4>
    label =
      <span><CourseGroupingLabel courseId={@props.courseId}/> Name</span>

    <BS.Modal
      {...@props}
      show={@state.showModal}
      onHide={@close}
      className='teacher-edit-period-modal'>

      <BS.Modal.Header closeButton>
        <BS.Modal.Title>{title}</BS.Modal.Title>
      </BS.Modal.Header>

      <div className={formClasses.join(' ')}>
        <RenamePeriodField
        label={label}
        name='period-name'
        default={@props.activeTab.name}
        onChange={(val) => @setState(period_name: val)}
        validate={@validate}
        autofocus />
      </div>

      <div className='modal-footer'>
        <BS.Button
        className='-edit-period-confirm'
          onClick={@performUpdate}
          disabled={disabled}>
          Rename
        </BS.Button>
      </div>

    </BS.Modal>

  render: ->
    <span>
      <BS.Button onClick={@open} bsStyle='link' className='edit-period'>
        <i className='fa fa-pencil' />
        Rename <CourseGroupingLabel courseId={@props.courseId}/>
      </BS.Button>
      {@renderForm()}
    </span>
