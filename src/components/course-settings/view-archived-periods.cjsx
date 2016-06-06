React = require 'react'
BS = require 'react-bootstrap'
_ = require 'underscore'
{PeriodActions, PeriodStore} = require '../../flux/period'
{TutorInput}  = require '../tutor-input'
{AsyncButton} = require 'openstax-react-components'
{CourseStore} = require '../../flux/course'
Icon = require '../icon'
PH   = require '../../helpers/period'
Time = require '../time'
BindStoreMixin      = require '../bind-store-mixin'


ViewArchivedPeriods = React.createClass

  propTypes:
    courseId: React.PropTypes.string.isRequired

  mixins: [BindStoreMixin]

  bindStore: PeriodStore

  bindUpdate: ->
    archived = PH.archivedPeriods(CourseStore.get(@props.courseId))
    if _.isEmpty(archived)
      @close()
    else
      @forceUpdate()

  getInitialState: ->
    showModal: false

  close: ->
    @setState({showModal: false})

  open: ->
    @setState({showModal: true})

  restore: (period) ->
    PeriodActions.restore(period.id, @props.courseId)

  renderRestoreLink: (period) ->
    if PeriodStore.isRestoring(period.id)
      <span><Icon spin type='spinner' /> UnArchiving...</span>
    else
      <BS.Button onClick={_.partial(@restore, period)} bsStyle='link'>
        <Icon type="recycle" /> Unarchive
      </BS.Button>

  render: ->
    archived = PH.archivedPeriods(CourseStore.get(@props.courseId))
    return null if _.isEmpty(archived)

    <li className='control view-archived-periods'>
      <BS.Button onClick={@open} bsStyle='link'>
        View Archived Sections
      </BS.Button>

      <BS.Modal
        show={@state.showModal}
        onHide={@close}
        className='view-archived-periods-modal'>

        <BS.Modal.Header closeButton>
          <BS.Modal.Title>Archived Sections</BS.Modal.Title>
        </BS.Modal.Header>

        <BS.Modal.Body>
          <p>
            The table below shows previously archived sections of this course.
          </p>
          <p>
            You can "unarchive" a section to make it visible again.
          </p>
          <table>
            <thead>
              <tr>
                <th>Name</th><th colSpan=2>Archive date</th>
              </tr>
            </thead>
            <tbody>
              {for period in archived
                <tr key={period.id}>
                  <td>{period.name}</td>
                  <td><Time date={period.archived_at} /></td>
                  <td>
                    <span className='control restore-period'>
                      {@renderRestoreLink(period)}
                    </span>
                  </td>
                </tr>}
            </tbody>
          </table>
        </BS.Modal.Body>

      </BS.Modal>

    </li>

module.exports = ViewArchivedPeriods
