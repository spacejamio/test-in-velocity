class Velocity

  velocityUrl: null

  # A meteor DDP connection to the meteor server running the velocity reporter.
  ddp: null

  ready: false
  isReadyDep: new Tracker.Dependency

  instance = null
  @get: ->
    instance ?= new Velocity();

  constructor: ()->
    Meteor.call 'getVelocityUrl', (err, velocityUrl)=>
      if err
        console.error 'velocity method getVelocityUrl returned an error:\n' + err
        throw err
      expect(velocityUrl, 'velocityUrl').to.be.a 'string'
      @velocityUrl = velocityUrl
      @ddp = DDP.connect velocityUrl
      Tracker.autorun @onConnectionStatusChanged

  onConnectionStatusChanged: =>
    console.log "Velocity DDP connection status: " + @ddp.status().status
    if @ddp.status().connected
      @_resetReports() if not @ready


  isReady: ->
    # We use our own dep because the first time we are called, it maybe that ddp is still null,
    # so no dependency will be created since ddp.status() will not be called.
    @isReadyDep.depend()
    return @ready


  postResult: (result)->
    @ddp.call 'postResult', result


#  _registerTestingFramework: ()=>
#    @ddp.call 'registerTestingFramework', 'tinytest', {}, (err, data)=>
#      if err
#        console.error 'velocity method registerTestingFramework returned an error:\n' + err
#        throw err
#      _resetReports()


  _resetReports: ()=>
    @ddp.call 'resetReports', (err, data)=>
      if err
        console.error 'velocity method resetReports returned an error:\n' + err
        throw err
      @ready = true
      @isReadyDep.changed()


@velocity = Velocity.get()
