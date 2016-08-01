React = require 'react'
{ChapterSectionMixin} = require 'openstax-react-components'
_ = require 'underscore'

module.exports = React.createClass
  displayName: 'ChapterSection'
  propTypes:
    section: React.PropTypes.oneOfType([
      React.PropTypes.array
      React.PropTypes.string
    ]).isRequired

  componentWillMount: ->
    @setState(skipZeros: false)
  mixins: [ChapterSectionMixin]
  render: ->
    {section} = @props
    <span className="chapter-section" data-chapter-section={@sectionFormat(section)}>
      {@sectionFormat(section)}
    </span>
