Geo = require('geojs')
EventEmitter = require('events').EventEmitter
get_time = ->(new Date).getTime()

reduce_path = (path, distance) ->
  if !isFinite(distance)
    throw new Error("bad distance")
  while path.length > 1
    segment = path[0].distanceTo(path[1])
    if distance < segment
      break
    distance -= segment
    path.shift()
  if path.length > 1
    path[0] = path[0].to(path[1], distance)
  path

class Fly
  constructor: (@event, loc, path, @speed)->
    debugger
    path.unshift(loc)
    @path = path.map (p)->new Geo.Pos(p)
    @time = get_time()
    @update_position()
    return

  update_position: ->
    return @path[0] if @path.length == 1 # prevent infinite loop
    time = get_time()
    distance = @speed * (time-@time)
    old_length = @path.length
    @path = reduce_path(@path, distance)
    @event.emit('change:position', @path[0].toJSON())
    if @path.length != old_length && @path.length > 1
      @event.emit('change:direction', src: @path[0], heading: @path[0].heading(@path[1]))
    else if @path.length == 1
      @event.move('stop')
    if @path.length > 1
      @schedule_update()
    return @path[0]

  toJSON: ->
    waypoints: @path.map (e)->e.toJSON()
    speed: @speed
    time: @time

  schedule_update: ->
    clearTimeout(@timeout_id) if @timeout_id
    if @path.length > 1
      @timeout_id = setTimeout @update_position.bind(@), @path[0].distanceTo(@path[1]) / @speed
    else
      delete @timeout_id

  destroy: ->
    clearTimeout @timeout_id

class Stop
  constructor: (@event, @loc)->
  update_position: -> @loc
  destroy: ->
  toJSON: ->
    loc: @loc.toJSON()
    waypoints: [@loc.toJSON()]

movement = (loc,speed)->
  self = new EventEmitter()
  move = new Stop(self, loc)
  self.force = ->
    move.update_position()
  self.move = (type, args...)->
    loc = move.update_position()
    move.destroy()
    if type == 'fly'
      move = new Fly(self, loc, args..., speed[type])
    else if type == 'stop'
      move = new Stop(self, loc, args...)
    self.emit('change:movement', move.toJSON())
  self.toJSON = -> move.toJSON()
  #self.move(arguments)
  return self

module.exports = movement

