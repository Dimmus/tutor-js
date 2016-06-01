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

  renderRow: (item) ->
    url = "https://cnx.org/contents/#{item.cnx_id}"
    link = if (item.type is "page") and (item.chapter_section[1] != 0) then <a href="#{url}">{url}</a>else null

    chapter_section = item.chapter_section.join('.')
    chapter_section = <span className="section">{chapter_section}</span> if item.chapter_section.length > 1

    row = <tr><td>{chapter_section} </td><td>{item.title}{link}</td></tr>

    if item.chapter_section.length == 1
      <tbody>
        { row }
        { (_.map item.children, (child) => @renderRow(child)) if item.chapter_section.length == 1}
      </tbody>
    else
      {row}

  render: ->
    toc = ReferenceBookStore.getToc(@ecosystem_id)
    return null if !toc?.children?

    <BS.Panel className="assignment-links">
      <span className='assignment-links-title'>Assignment Links</span>

      <p>Here are 3 easy steps to assigning Concept Coach.</p>

      <ol>
        <li>Find the textbook sections you want to assign in the list below.</li>
        <li>Copy and paste the corresponding links into your syllabus or LMS.<small>We recommend setting your LMS to open the link in a new tab.</small></li>
        <li>Your students will be able to launch Concept Coach from the bottom of each section.</li>
      </ol>

      <table>
        { _.map toc.children, (child) => @renderRow(child)  }
      </table>

    </BS.Panel>

module.exports = {AssignmentLinks}

