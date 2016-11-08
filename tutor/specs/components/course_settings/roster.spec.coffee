{Testing, sinon, _, ReactTestUtils} = require '../helpers/component-testing'
ld = require 'lodash'
Roster = require '../../../src/components/course-settings/roster'

COURSE = require '../../../api/user/courses/1.json'
ROSTER = require '../../../api/courses/1/roster.json'

COURSE_ID = '1'

{CourseActions} = require '../../../src/flux/course'
{PeriodActions} = require '../../../src/flux/period'
{RosterActions} = require '../../../src/flux/roster'

describe 'Course Settings', ->

  beforeEach ->
    CourseActions.loaded(COURSE, COURSE_ID)
    RosterActions.loaded(ROSTER, COURSE_ID)
    sinon.stub(PeriodActions, 'delete', (periodId) ->
      PeriodActions._deleted(arguments...)
      course = ld.cloneDeep(COURSE)
      period = _.findWhere(course.periods, id: periodId)
      period.is_archived = true
      CourseActions.loaded(course, COURSE_ID)
    )
    sinon.stub(PeriodActions, 'restore').returns(null)
    @props =
      courseId: COURSE_ID

  afterEach ->
    PeriodActions.delete.restore()
    PeriodActions.restore.restore()

  it 'renders period panels', ->
    Testing.renderComponent( Roster, props: @props ).then ({dom}) ->
      titles = _.pluck(dom.querySelectorAll('.nav-tabs li a'), 'textContent')
      expect(titles)
        .to.deep.equal(['1st', '2nd', '3rd', '5th', '6th', '10th'])


  it 'renders students in the panels', ->
    Testing.renderComponent( Roster, props: @props ).then ({dom}) ->
      names = _.pluck(dom.querySelectorAll("table.roster tr td:nth-child(2)"), 'textContent')
      expect(names).to.deep.equal(
        ['Angstrom', 'Glass', 'Hackett', 'Jaskolski', 'Lowe', 'Tromp', 'Reilly']
      )

  it 'switches roster when tab is clicked', (done) ->
    Testing.renderComponent( Roster, props: @props ).then (result) ->
      Testing.actions.click(result.dom.querySelector('.periods .nav-tabs li:nth-child(2) a'))
      _.defer ->
        names = _.pluck(result.dom.querySelectorAll("table.roster tr td:nth-child(2)"), 'textContent')
        expect(names).to.deep.equal(
          ['Bloom', 'Kirlin']
        )
        done()
    true

  ## this is flaky, doesn't always complete in time
  xit 'can archive periods', (done) ->
    Testing.renderComponent( Roster, props: @props, unmountAfter: 30 ).then ({dom}) ->
      Testing.actions.click(dom.querySelector('.control.archive-period'))
      expect(dom.querySelector('.nav-tabs .active').textContent).to.equal('1st')
      expect(dom.querySelector('.roster tbody td').textContent).to.equal('Rabbit')
      _.defer ->
        Testing.actions.click(document.querySelector('button.archive-section'))
        expect(PeriodActions.delete).to.have.been.called
        _.defer ->
          expect(dom.querySelector('.nav-tabs .active').textContent).to.equal('2nd')
          expect(dom.querySelector('.roster tbody td').textContent).to.equal('Molly')
          done()
    true

  it 'can view and unarchive periods', (done) ->
    Testing.renderComponent( Roster, props: @props ).then ({dom}) ->
      Testing.actions.click(dom.querySelector('.view-archived-periods > button'))
      _.defer ->
        periods = _.pluck(document.querySelectorAll(
          '.view-archived-periods-modal tbody td:first-child'), 'textContent'
        )
        expect(periods).to.deep.equal(
          ['4th', '7th']
        )
        Testing.actions.click(
          document.querySelector('.view-archived-periods-modal .restore-period button')
        )
        expect(PeriodActions.restore).to.have.been.called
        done()
    true
