_ = require 'underscore'
React = require 'react'
BS = require 'react-bootstrap'
Router = require 'react-router'

BindStoreMixin = require './bind-store-mixin'
{ReferenceBookActions, ReferenceBookStore} = require '../flux/reference-book'
{CourseStore} = require '../flux/course'

AssignmentLinks = React.createClass
  displayName: 'AssignmentLinks'
  mixins: [BindStoreMixin]
  bindStore: ReferenceBookStore

  contextTypes:
    router: React.PropTypes.func

  componentWillMount: ->
    {courseId} = @context.router.getCurrentParams()
    course = CourseStore.get(courseId)
    @ecosystem_id = course.ecosystem_id
    ReferenceBookActions.load(course.ecosystem_id)

  renderRow: (item, baseUrl, bookId) ->
    chapter_section = item.chapter_section.join('.')

    pageId = item.short_id || item.uuid
    url = "#{baseUrl}/contents/#{bookId}:#{pageId}/#{chapter_section}"

    link = if (item.type is "page") and (item.chapter_section[1] != 0)
             <a href="#{url}">{url}</a>
           else
             null

    row = <tr>
      <td>{chapter_section}</td>
      <td>{item.title}{link}</td>
    </tr>

    if item.chapter_section.length == 1
      <tbody>
        { row }
        { _.map item.children, (child) => @renderRow(child, baseUrl, bookId) }
      </tbody>
    else
      {row}

  render: ->
    toc = ReferenceBookStore.getToc(@ecosystem_id)
    return null if !toc?.children?

    bookId = toc.short_id || toc.uuid
    baseUrl = toc.webview_url || 'https://cnx.org'

    <BS.Panel className="assignment-links">
      <span className='assignment-links-title'>Assignment Links</span>

      <p>Here are 3 easy steps to assigning Concept Coach:</p>

      <ol>
        <li>Find the textbook sections you want to assign in the list below.</li>
        <li>Copy and paste the corresponding links into your syllabus or LMS.
            <small>We recommend setting your LMS to open the link in a new tab.</small></li>
        <li>Your students will be able to launch Concept Coach from the bottom of each section.</li>
      </ol>

      <table>
        { _.map toc.children, (child) => @renderRow(child, baseUrl, bookId)  }
      </table>

    </BS.Panel>

module.exports = {AssignmentLinks}

