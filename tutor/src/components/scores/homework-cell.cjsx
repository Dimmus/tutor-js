React      = require 'react'
ReactDOM   = require 'react-dom'
TutorLink  = require '../link'
classNames = require 'classnames'
BS = require 'react-bootstrap'

Time = require '../time'
CellStatusMixin = require './cell-status-mixin'
PieProgress = require './pie-progress'
{LateWork} = require './late-work'

TH = require '../../helpers/task'

HomeworkScore = React.createClass
  displayName: 'HomeworkScore'
  render: ->
    {task, displayAs, courseId} = @props

    scorePercent = TH.getHumanScorePercent(task)
    scoreNumber = TH.getHumanScoreNumber(task)
    completed = task.completed_exercise_count is task.exercise_count
    scoreText = if completed or TH.isDue(task)
      if displayAs is 'number' then scoreNumber else scorePercent
    else
      '---'

    if TH.isHomeworkTaskStarted(@props.task)
      <div className="score">
        <TutorLink to='viewTaskStep'
          data-assignment-type="#{task.type}"
          params={courseId: courseId, id: task.id, stepIndex: 1}>
            {scoreText}
        </TutorLink>
      </div>
    else
      <div className="score not-started">---</div>



HomeworkCell = React.createClass

  mixins: [CellStatusMixin] # prop validation

  getInitialState: ->
    isShowingPopover: false

  show: ->
    @setState(isShowingPopover: true)

  hide: -> @setState(isShowingPopover: false)

  getPieChartTarget: ->
    ReactDOM.findDOMNode(@refs.pieChart)

  render: ->
    {task, courseId, displayAs, isConceptCoach, rowIndex, columnIndex, period_id} = @props

    <div className='scores-cell'>

      <HomeworkScore {...@props} />

      <div className="worked" onMouseOver={@show} onMouseLeave={@hide}>
        <BS.Overlay
          target={@getPieChartTarget}
          show={@state.isShowingPopover}
          onHide={@hide}
          placement="left"
        >
          <BS.Popover
            onMouseOver={@show}
            onMouseLeave={@hide}
            id="scores-cell-info-popover-#{task.id}"
            className='scores-scores-tooltip-completed-info'>
            <div className='info'>
              <div className='row'>
                <div>Completed {TH.getHumanCompletedPercent(task)}</div>
              </div>
              <div className='row'>
                <div>
                  {TH.getHumanProgress(task)} questions
                </div>
              </div>
            </div>
          </BS.Popover>
        </BS.Overlay>

        <PieProgress
          ref="pieChart"
          isConceptCoach={isConceptCoach}
          size={20}
          value={TH.getCompletedPercent(task)}
          isLate={TH.isDue(task)}
        />

      </div>

      <LateWork
        onMouseOver={@show}
        onMouseLeave={@hide}
        task={task}
        columnIndex={columnIndex} />

    </div>



module.exports = HomeworkCell
