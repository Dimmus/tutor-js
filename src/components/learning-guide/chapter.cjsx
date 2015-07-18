React = require 'react'
BS = require 'react-bootstrap'
Router = require 'react-router'

ChapterSectionMixin = require '../chapter-section-mixin'

ChapterSectionType = require './chapter-section-type'
ProgressBar = require './progress-bar'
Section = require './section'

# This many pixels are allocated per section when the chapter is expanded
PER_SECTION_HEIGHT = 100

module.exports = React.createClass

  displayName: 'LearningGuideChapter'

  propTypes:
    courseId: React.PropTypes.string.isRequired
    chapter:  ChapterSectionType.isRequired
    onPractice: React.PropTypes.func

  getInitialState: ->
    expanded: false

  onToggle: (event) ->
    @setState(expanded: not @state.expanded)

  render: ->
    {chapter, courseId} = @props
    classes = ['chapter-panel']
    classes.push 'expanded' if @state.expanded
    sectionHeight = chapter.children.length * PER_SECTION_HEIGHT * ( if @state.expanded then 1 else 0 )
    <div className={classes.join(' ')}>
      <div className='view-toggle' onClick={@onToggle}>
        {if @state.expanded then 'View Less' else 'View More'}
      </div>
      <div className='chapter-heading'>
        <span className='chapter-number'>{chapter.chapter_section[0]}</span>
        <div className='chapter-title' title={chapter.title}>{chapter.title}</div>

        <ProgressBar {...@props} section={chapter} />

        <div className='amount-worked'>
          <span className='count'>{chapter.questions_answered_count} worked</span>
        </div>
      </div>
      <div className="sections" style={maxHeight: sectionHeight}>
        { for section, i in chapter.children
          <Section  key={i} section={section} {...@props} /> }
      </div>
    </div>
