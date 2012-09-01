MapObject = require('./map_object')
_ = require('underscore')

module.exports = class MovingObject extends MapObject
  updatePosition: =>
    return unless @has('movement')
    m = @get('movement')
    duration = (new Date).getTime() - m.startTime
    distance = 1000*duration * m.speed
    pos = geo.math.destination(m.start_pos, heading:m.heading, distance:distance)
    @setPosition([pos.lat(), pos.lng()])
    if m.animate
      if !m.distance? || !pos.equals(_.last(m.way)) && distance < m.distance
        requestAnimationFrame(@updatePosition)
      else
        m.animate = false
        @trigger('change:movement')

  startMovement: (movement)->
    if movement
      movement.animate = true
      @setMovement(movement)
    else
      @get('movement').animate = true
      @trigger('change:movement')
      requestAnimationFrame(@updatePosition)

  setMovement: (movement)->
    if movement.waypoints
      @setPosition movement.waypoints[0]
      if movement.waypoints.length == 1
        @unset('movement')
        return
      movement.way = movement.waypoints.map (loc)->new geo.Point(loc...)
      movement.distance = movement.way[0].distance(movement.way[1])
      movement.heading = geo.math.heading(movement.way[0..1]...)
      movement.start_pos = movement.way[0]
    else
      @setPosition movement.src
      movement.start_pos = new geo.Point(movement.src...)
    movement.startTime = (new Date).getTime()
    movement.animate ?= false
    @set('movement', movement)
    return if movement.distance? == 0
    if movement.animate
      requestAnimationFrame(@updatePosition)
  remove: ->
    @unset('movement')
    super()

ss.event.on 'you see', (pcs)->
  window.people ?= {}
  console.log(pcs)
  pcs.forEach (e)->
    if e._id of people
      #TODO add support for other fields
      people[e._id].setPosition(e.loc)
    else
      people[e._id] = new MovingObject(e)
    if e.movement
      people[e._id].startMovement(e.movement)
    else if people[e._id].has('movement')
      people[e._id].unset('movement')

ss.event.on 'you lost', (pcs)->
  window.people ?= {}
  pcs.forEach (e)->
    if e._id of people
      people[e._id].remove()
      delete people[e._id]
