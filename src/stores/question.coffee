_ = require 'underscore'
flux = require 'flux-react'
{CrudConfig, makeSimpleStore, extendConfig} = require './helpers'
{AnswerActions, AnswerStore} = require './answer'

QuestionConfig = {
  _loaded: (obj, id) ->
    for answer in obj?.answers
      AnswerActions.loaded(answer, answer.id)

    obj

  sync: (id) ->
    answers = _.map @_local[id]?.answers, (answer) ->
      AnswerStore.get(answer.id)
    @_change(id, {answers})
    
  updateStem: (id, stem_html) -> @_change(id, {stem_html})

  updateStimulus: (id, stimulus_html) -> @_change(id, {stimulus_html})

  updateFeedback: (id, feedback) ->
    solution = _.first(@_local[id].solutions)
    solution.content_html = feedback

    @_change(id, {solutions: [solution]})

  setCorrectAnswer: (id, newAnswer, curAnswer) ->
    if not AnswerStore.isCorrect(newAnswer)
      AnswerActions.setCorrect(newAnswer)
      AnswerActions.setIncorrect(curAnswer) if curAnswer

  exports:

    getAnswers: (id) -> @_local[id]?.answers

    getStem: (id) -> @_local[id]?.stem_html

    getStimulus: (id) -> @_local[id]?.stimulus_html

    getFeedback: (id) ->
      _.first(@_local[id].solutions)?.content_html

    hasFeedback: (id) ->
      @_local[id].solutions?.length > 0

    getCorrectAnswer: (id) ->
      _.find @_local[id]?.answers, (answer) -> AnswerStore.isCorrect(answer.id)
}

extendConfig(QuestionConfig, new CrudConfig())
{actions, store} = makeSimpleStore(QuestionConfig)

module.exports = {QuestionActions:actions, QuestionStore:store}
