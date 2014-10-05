class TestRunner
  running: false

  instance = null
  @get: ->
    instance ?= new TestRunner();

  constructor: ()->
      Meteor.startup =>
        console.log 'TestRunner: Meteor.startup'
        Tracker.autorun @onVelocityIsReady

  onVelocityIsReady: =>
    console.log 'onVelocityIsReady:'
    return if not velocity.isReady() or @running
    @runTests()

  runTests: ->
    #Tracker.flush();
    Tinytest._runTestsEverywhere @onNewTestReport, @onTestsCompleted, ["tinytest"]
    @running = true;

  onNewTestReport: (report)=>
    console.debug report
    status = @_testStatus report
    if status is "running"
      console.log "Got a running report for: #{report.name}"
      return

    velocityResult = {
      id: '' + new Mongo.ObjectID()
      name: report.test
      # Todo: change this to tinytest
      framework: 'mocha'
      result: status
      ancestors: report.groupPath
    }

    if report.server
      velocityResult.isServer = true
      velocityResult.isClient = false
    else
      velocityResult.isServer = false
      velocityResult.isClient = true

    velocity.postResult velocityResult

  # Copied from meteor test-in-browser driver.js
  _testStatus: (t)->
    events = t.events || []
    exception = _.find events, (x)->
      return x.type is "exception"
    if exception
    # "exception" should be last event, except race conditions on the
    # server can make this not the case.  Technically we can't tell
    # if the test is still running at this point, but it can only
    # result in FAIL.
      return "failed"
    else if events.length is 0 or _.last(events).type is not "finish"
      return "running"
    else
      failed = _.any events, (e)->
        return e.type is "fail" or e.type is "exception"
      return "failed" if failed
      return "passed"


  onTestsCompleted: ()->
    console.log "TestRunner: tests completed."
    @running = false;
    #Tracker.flush();
    Meteor.connection._unsubscribeAll()


@testRunner = TestRunner.get()
