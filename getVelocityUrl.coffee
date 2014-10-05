expect(process.env.VELOCITY_URL, 'VELOCITY_URL').to.be.not.empty

Meteor.methods {
  getVelocityUrl: ->
    return process.env.VELOCITY_URL
}
