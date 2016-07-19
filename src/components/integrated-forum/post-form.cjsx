React  = require 'react'
BS     = require 'react-bootstrap'
Time   = require '../time'
moment = require 'moment'
{TimeStore} = require '../../flux/time'
moment = require 'moment-timezone'

{ForumActions, ForumStore} = require '../../flux/forum'
classnames = require 'classnames'
FormGroup = require 'react-bootstrap/lib/FormGroup'
FormControl= require 'react-bootstrap/lib/FormControls'

module.exports = React.createClass
  displayName: 'PostForm'

  propTypes:
    onPostSubmit: React.PropTypes.func.isRequired
    topicTags: React.PropTypes.array.isRequired
    chapterTags: React.PropTypes.array.isRequired


  getInitialState: ->
    title: ''
    text: ''
    chapterTag:'Chapter 1'
    sectionTag:'Section 1'
    topicTag: @props.topicTags[0]

  handleTitleChange: (e)->
    @setState({title: e.target.value})

  handleTextChange: (e)->
    @setState({text: e.target.value})
  handleChapterTagChange: (e)->
    @setState({chapterTag: e.target.value})
  handleSectionTagChange: (e)->
    @setState({sectionTag: e.target.value})
  handleTopicTagChange: (e)->
    @setState({topicTag: e.target.value})

  handleSubmit: (submitEvent) ->
    submitEvent.preventDefault()
    title = @state.title.trim().replace(/\n\s*\n/g, '\n')
    text = @state.text.trim().replace(/\n\s*\n/g, '\n')
    chapterTag = @state.chapterTag + "." + @state.sectionTag.substring(8)
    topicTag = @state.topicTag
    @props.onPostSubmit({
        type: 'post',
        author: 'Johny Tran',
        text: text,
        postDate: moment(TimeStore.getNow()).format('YYYY-MM-DDTh:mm:ss.SSS')+"Z",
        title: title,
        status: "active"
        tags:[chapterTag, topicTag]
      }
    )
    @setState({title: '', text: ''})

  renderTopicTag: (topicTag)->
    <option>{topicTag}</option>

  renderChapterTags: (chapterLength)->
    optionRow = []
    for i in [1...chapterLength+1]
      optionRow.push(<option>{"Chapter "+i.toString()}</option>)
    optionRow

  renderSectionTags: (chapterTags)->
    chapterIdx = Number(@state.chapterTag.substring(8))-1
    sectionLength = chapterTags[chapterIdx]
    optionRow = []
    for i in [1...sectionLength+1]
      optionRow.push(<option>{"Section "+i.toString()}</option>)
    optionRow


  render: ->
    topicTags = @props.topicTags
    chapterTags = @props.chapterTags

    <form className="post-form" onSubmit={@handleSubmit}>
      <BS.Row className="title-row">
        <label className="title-label">{"Title:"}</label>
        <textarea
          className="post-form-title"
          placeholder="Title"
          value={@state.title}
          onChange={@handleTitleChange}>
        </textarea>
      </BS.Row>

      <BS.Row className="text-row">
        <label className="text-label">{"Text:"}</label>
        <textarea
          className="post-form-text"
          placeholder="Text"
          onChange={@handleTextChange}>
        </textarea>
      </BS.Row>
      <BS.Row className="book-tag-row">
        <div className="form-group chapter-tag-select">
          <label className="chapter-tag-label">{"Chapter: "}</label>
          <select className="form-control" onChange={@handleChapterTagChange}>
            {@renderChapterTags(chapterTags.length)}
          </select>
        </div>
        <div className="form-group section-tag-select">
          <label className="section-tag-label">{"Section: "}</label>
          <select className="form-control" onChange={@handleSectionTagChange}>
            {@renderSectionTags(chapterTags)}
          </select>
        </div>
      </BS.Row>

      <BS.Row className="topic-tag-row">
          <div className="form-group">
            <label className="topic-tag-label">{"Topic: "}</label>
            <select className="form-control topic-tag-select" onChange={@handleTopicTagChange}>
              {_.map(topicTags, @renderTopicTag)}
            </select>
          </div>
      </BS.Row>

      <BS.Row className="post-submit-row">
          <BS.Button type="submit" bsStyle="primary" className="post-submit-button">{"Submit"}</BS.Button>
      </BS.Row>
    </form>