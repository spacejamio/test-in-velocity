log.setLevel 'debug'

class TinytestResult

  events: []
  stack: null
  done: false
  failed: false
  failureMsg: null
  failureType: null

  constructor: (@name, @initialReport)->
    expect(@name).to.be.a 'string'
    expect(@initialReport).to.be.an 'object'


  @getUniqueTestName: (report)->
    name = if report.server then 'S: ' else 'C: '
    name += report.groupPath.join(' - ') + ' - ' + report.test


  processEvents: (report)->
    expect(report).to.be.an 'object'
    expect(report.events).to.be.an.instanceof(Array) if report.events
    logMsg = @name
    for event in report.events
      expect(event.sequence).to.be.a 'number'
      expect(event.type).to.be.a 'string'
      logMsg += ' - event ' + event.sequence + ', type: ' + event.type
      if event.type is 'fail'
        @failed = true
        @failureMsg = event.details.message if event.details?.message
        @failureType = event.details.type if event.details?.type
      else if event.type is 'exception'
        @failed = true
        @failureMsg = event.details.message if event.details?.message
        @failureType = 'exception'
        @stack = event.details.stack
        @done = true
      else if event.type is 'finish'
        @done = true
    log.debug logMsg
    

  toVelocityResult: ()->
    expect(@done).to.be.true

    velocityResult = {
      id: '' + new Mongo.ObjectID()
      name: @initialReport.test
      framework: 'tinytest'
      ancestors: @initialReport.groupPath
    }

    if @initialReport.server
      velocityResult.isServer = true
      velocityResult.isClient = false
    else
      velocityResult.isServer = false
      velocityResult.isClient = true

    velocityResult.result = if @failed then 'failed' else 'passed'
    velocityResult.failureMessage = @failureMsg if @failureMsg
    velocityResult.failureType = @failureType if @failureType
    velocityResult.failureStackTrace = @stack if @stack

    return velocityResult
