React = require 'react'
BS = require 'react-bootstrap'
classnames = require 'classnames'

Icon = require '../icon'
{PeriodActions, PeriodStore} = require '../../flux/period'
{TutorInput} = require '../tutor-input'
{SpyMode, AsyncButton} = require 'shared'

CourseGroupingLabel = require '../course-grouping-label'

AddPeriodField = React.createClass

  displayName: 'AddPeriodField'
  propTypes:
    label: React.PropTypes.object.isRequired
    name:  React.PropTypes.string.isRequired
    default: React.PropTypes.string
    onChange:  React.PropTypes.func.isRequired
    autofocus: React.PropTypes.bool

  componentDidMount: ->
    @refs.input.focus() if @props.autofocus

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
  displayName: 'AddPeriodLink'
  propTypes:
    courseId: React.PropTypes.string.isRequired
    periods:  React.PropTypes.array.isRequired
    show:     React.PropTypes.bool


  getInitialState: ->
    period_name: ''
    showModal: @props.show
    isCreating: false
    submitted: false

  close: ->
    @setState({showModal: false, isCreating: false, period_name: '', submitted: false})

  open: ->
    @setState({showModal: true})

  validate: (name) ->
    error = PeriodStore.validatePeriodName(name, @props.periods)
    @setState({invalid: error?})
    error

  performUpdate: ->
    @setState({submitted: true})
    if not @state.invalid
      @setState(isCreating: true)
      PeriodActions.create(@props.courseId, name: @state.period_name)
      PeriodStore.once 'created', => @close()

  renderForm: ->
    invalid = @state?.invalid
    title = <span>Add <CourseGroupingLabel courseId={@props.courseId} /></span>
    label = <span><CourseGroupingLabel courseId={@props.courseId} /> Name</span>

    <BS.Modal
      show={@state.showModal}
      onHide={@close}
      className='settings-edit-period-modal'>

      <BS.Modal.Header closeButton>
        <BS.Modal.Title>{title}</BS.Modal.Title>
      </BS.Modal.Header>

      <BS.Modal.Body className={classnames('is-invalid-form': invalid)}>
        <AddPeriodField
        label={label}
        name='period-name'
        default={@state.period_name}
        onChange={(val) => @setState(period_name: val)}
        validate={@validate}
        autofocus />
      </BS.Modal.Body>

      <BS.Modal.Footer>
        <AsyncButton
          className='-edit-period-confirm'
          onClick={@performUpdate}
          isWaiting={@state.isCreating}
          waitingText="Adding..."
          disabled={invalid}>
          Add
        </AsyncButton>
      </BS.Modal.Footer>

    </BS.Modal>

  render: ->
    <BS.Button onClick={@open} bsStyle='link' className='control add-period'>
      <Icon type="plus" />
      Add <CourseGroupingLabel courseId={@props.courseId} />
      {@renderForm()}
    </BS.Button>
