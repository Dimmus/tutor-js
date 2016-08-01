{NotificationActions} = require 'openstax-react-components'


module.exports =

  start: (bootstrapData) ->
    NotificationActions.startPolling()
    for level, message of (bootstrapData.flash or {})
      NotificationActions.display({message, level})
