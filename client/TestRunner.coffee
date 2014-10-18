class TestRunner
  running: false

  results: {}

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
    @results = {}
    @running = true;
    console.info 'Calling Tinytest._runTestsEverywhere()'
    Tinytest._runTestsEverywhere @onNewTestReport, @onTestsCompleted, ["tinytest"]


  onNewTestReport: (report)=>
    log.debug 'onNewTestReport:', report

    testName = TinytestResult.getUniqueTestName(report)
    result = @results[testName] ?= new TinytestResult(testName, report)
    result.processEvents(report)

    return if not result.done

    velocityResult = result.toVelocityResult()
    log.debug "Reporting the following test result to velocity:", velocityResult
    velocity.postResult velocityResult


  onTestsCompleted: ->
    log.info "test-in-velocity: all tests completed."
    @running = false
    @results = {}
#    Meteor.connection._unsubscribeAll()


@testRunner = TestRunner.get()
