_ = require 'underscore'
React = require 'react'
ArbitraryHtml = require './html'

idCounter = 0

module.exports = React.createClass
  displayName: 'Question'
  propTypes:
    model: React.PropTypes.object.isRequired
    type: React.PropTypes.string.isRequired
    answer_id: React.PropTypes.string
    correct_answer_id: React.PropTypes.string
    content_uid: React.PropTypes.string
    feedback_html: React.PropTypes.string
    answered_count: React.PropTypes.number
    onChange: React.PropTypes.func
    onChangeAttempt: React.PropTypes.func

  getInitialState: ->
    answer: null

  getDefaultProps: ->
    type: 'student'

  # Curried function to remember the answer
  onChangeAnswer: (answer) ->
    (changeEvent) =>
      if @props.onChange?
        @setState({answer_id:answer.id})
        @props.onChange(answer)
      else
        changeEvent.preventDefault()
        @props.onChangeAttempt?(answer)

  render: ->
    {type, answered_count} = @props

    html = @props.model.stem_html
    qid = @props.model.id or "auto-#{idCounter++}"
    hasCorrectAnswer = !! @props.correct_answer_id

    if @props.feedback_html
      feedback = <div className='question-feedback'>
          <ArbitraryHtml
            className='question-feedback-content has-html'
            html={@props.feedback_html}
            block={true}/>
        </div>

    answers = _.map @props.model.answers, (answer, i) =>
      isChecked = answer.id in [@props.answer_id, @state.answer_id]
      isCorrect = answer.id is @props.correct_answer_id

      isCorrect = (answer.correctness is '1.0') if answer.correctness?

      classes = ['answers-answer']
      classes.push('answer-checked') if isChecked
      classes.push('answer-correct') if isCorrect
      classes = classes.join(' ')

      unless (hasCorrectAnswer or type is 'teacher-review')
        radioBox = <input
          type='radio'
          className='answer-input-box'
          checked={isChecked}
          id="#{qid}-option-#{i}"
          name="#{qid}-options"
          onChange={@onChangeAnswer(answer)}
        />

      if type is 'teacher-review'
        percent = Math.round(answer.selected_count / answered_count * 100)
        selectedCount = <div
          className='selected-count'
          data-count="#{answer.selected_count}"
          data-percent="#{percent}">
        </div>


      <div className={classes} key="#{qid}-option-#{i}">
        {selectedCount}
        {radioBox}
        <label
          htmlFor="#{qid}-option-#{i}"
          className='answer-label'>
          <div className='answer-letter' />
          <ArbitraryHtml className='answer-content' html={answer.content_html} />
        </label>
      </div>

    classes = ['question']
    classes.push('has-correct-answer') if hasCorrectAnswer
    classes = classes.join(' ')

    <div className={classes}>
      <ArbitraryHtml className='question-stem' block={true} html={html} />
      {@props.children}
      <div className='answers-table'>
        {answers}
      </div>
      {feedback}
      <div className="exercise-uid">{@props.exercise_uid}</div>
    </div>
