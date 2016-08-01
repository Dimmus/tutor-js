{Testing, expect, sinon, _} = require 'test/helpers'

moment = require 'moment'

Poller = require 'model/notifications/pollers'
FakeWindow = require 'test/helpers/fake-window'
TEST_NOTICES = require 'api/notifications'

describe 'Notification Pollers', ->
  beforeEach ->
    @notices = {
      windowImpl: new FakeWindow
      emit: sinon.spy()
    }
    @poller = Poller.forType(@notices, 'tutor')
    sinon.stub(@poller, 'poll')
    @poller.setUrl('test-url')

  it 'repeatedly requests tutor notices', ->
    expect(@notices.windowImpl.setInterval).to.have.been.calledWith(
      sinon.match.any,
      moment.duration(5, 'minutes').asMilliseconds()
    )

  it 'remembers notices when they are dismissed', ->
    @poller.onReply(data: TEST_NOTICES)
    expect(@notices.emit).to.have.been.calledWith('change')
    active = @poller.getActiveNotifications()
    expect( _.pluck(active, 'id') ).to.deep.equal( _.pluck(TEST_NOTICES, 'id') )
    expect(@notices.windowImpl.localStorage.setItem).not.to.have.been.called

  it 'does not list items that are ignored', ->
    @notices.windowImpl.localStorage.getItem.returns('["2"]')
    @poller.onReply(data: TEST_NOTICES)
    active = @poller.getActiveNotifications()
    expect( _.pluck(active, 'id') ).to.deep.equal( [TEST_NOTICES[0].id] )

  it 'removes outdated ids from localstorage', ->
    # mock that we've observed the current notices
    @notices.windowImpl.localStorage.getItem.returns('["1", "2"]')
    @poller.onReply(data: TEST_NOTICES)
    expect(@notices.windowImpl.localStorage.setItem).not.to.have.been.called

    # load a new set of messages that do not include the previous ones
    @poller.onReply(
      data: [{id: '3', message: 'message three'}]
    )

    # 1 and 2 are removed
    expect(@notices.windowImpl.localStorage.setItem).to.have.been.calledWith(
      'ox-notifications-tutor', '[]'
    )
