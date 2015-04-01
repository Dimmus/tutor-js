React = require 'react'
BS = require 'react-bootstrap'
Router = require 'react-router'

TaskEnd = React.createClass
  render: ->
    footer = <Router.Link to="dashboard" className="btn btn-primary">Back to Dashboard</Router.Link>

    <BS.Panel bsStyle="default" footer={footer}>
      <h1>You Are Done.</h1>
      <h3>Great Job!</h3>
    </BS.Panel>

module.exports = TaskEnd