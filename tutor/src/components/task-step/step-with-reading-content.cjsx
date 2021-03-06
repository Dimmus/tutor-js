React = require 'react'

{TaskStepStore} = require '../../flux/task-step'
{ArbitraryHtmlAndMath, ChapterSectionMixin} = require 'shared'
CourseData = require '../../helpers/course-data'
{BookContentMixin, LinkContentMixin} = require '../book-content-mixin'
RelatedContent = require '../related-content'
Router = require '../../helpers/router'

# TODO: will combine with below, after BookContentMixin clean up
ReadingStepContent = React.createClass
  displayName: 'ReadingStepContent'

  propTypes:
    id: React.PropTypes.string.isRequired
    courseId: React.PropTypes.string.isRequired
    stepType: React.PropTypes.string.isRequired

  mixins: [BookContentMixin, ChapterSectionMixin]
  # used by BookContentMixin
  getSplashTitle: ->
    TaskStepStore.get(@props.id)?.title or ''
  getCnxId: ->
    TaskStepStore.getCnxId(@props.id)

  shouldExcludeFrame: ->
    @props.stepType is 'interactive'

  shouldOpenNewTab: -> true
  render: ->
    {id, stepType} = @props

    {content_html, related_content} = TaskStepStore.get(id)
    {courseId} = Router.currentParams()

    <div className="#{stepType}-step">
      <div className="#{stepType}-content" {...CourseData.getCourseDataProps(courseId)}>

        <RelatedContent contentId={id} {...related_content?[0]} />
        <ArbitraryHtmlAndMath
          className='book-content'
          shouldExcludeFrame={@shouldExcludeFrame}
          html={content_html}
        />
      </div>
    </div>

StepContent = React.createClass
  displayName: 'StepContent'

  propTypes:
    id: React.PropTypes.string.isRequired
    stepType: React.PropTypes.string.isRequired

  mixins: [LinkContentMixin]
  # used by LinkContentMixin
  getCnxId: ->
    TaskStepStore.getCnxId(@props.id)

  render: ->
    {id, stepType} = @props
    {content_html} = TaskStepStore.get(id)
    <div className={"#{stepType}-step"}>
      <ArbitraryHtmlAndMath
        className={"#{stepType}-content"}
        html={content_html}
        shouldExcludeFrame={@shouldExcludeFrame}
      />
    </div>


module.exports = {StepContent, ReadingStepContent}
