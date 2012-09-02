mongoose = require 'mongoose'
$ = require('interlude')
deepEqual = require('deep-equal')
_ = require('underscore')
Geo = require('geojs')
ss = require('socketstream').api
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Pc = new Schema {
  name: String
  factionId: ObjectId
  userId: {type: ObjectId, unique: true}
  speed: { fly: {type: Number, default: 5e-6} }
  loc: {type: [Number], index: "2d"}
  around: []
  skills: [{name: String, value: Number}]
}

Pc.statics.by_user = by_user = (userId, cb) ->
  model.findOne {userId}, (err, doc)->
    return cb(arguments) if err
    if doc._id of cache.pc
      cb(null, cache.pc[doc._id])
    else
      cb(null, cache.pc[doc._id]=doc)
Pc.statics.by_id = by_id = (pc_id, cb) ->
  if pc_id of cache.pc
    cb(null, cache.pc[pc_id])
  else
    model.findOne {_id: pc_id}, (err,doc)->
      return cb(arguments) if err
      if pc_id of cache.pc
        cb(null, cache.pc[pc_id])
      else
        cache.pc[pc_id] = doc unless err
        cb(err,doc)

Pc.methods.publish = (topic, message)->
  ss.publish.user(@userId, topic, message)

Pc.methods.updatePos = ->
  if cache.pc[@_id] != @
    throw new Error("updatePos for non-cached PC #{@_id}: #{@}")
  if @movement && @movement.type = 'fly'
    time = (new Date).getTime() - @movement.start
    distance = time * @speed[@movement.type]
    distances = @movement.way.distance()
    distance_segments = distances.segments
    if distance >= distances.total
      pos = _.last(@movement.way.positions)
      @loc = [pos.lat, pos.lon]
      delete @movement
      model.update {_id: @_id}, {$set: {loc: @loc}}, (err, num)->(console.error(err) if err)
      @publish('pcPosition', @loc)
    else
      pos = @movement.way.traverse(distance)
      @loc = [pos.lat, pos.lon]
      model.update {_id: @_id}, {$set: {loc: @loc}}, (err, num)->(console.error(err) if err)
      while distance > distance_segments[0]
        distance -= distance_segments[0]
        @movement.way.positions.shift()
        distance_segments.shift()
      if distance_segments.length > 0
        @movement.way.positions[0] = pos
        @movement.start += time
        distance = @movement.way.distance().total
        new_time = distance / @movement.speed
        setTimeout Pc.methods.updatePos.bind(this), new_time
      @publish 'pcMove',
        waypoints: @movement.way.positions.map (p)->[p.lat,p.lon]
        speed: @movement.speed
    @notify_movement()
  else
    ss.publish.user(@userId, 'pcPosition', @loc)
    @around.forEach (pc)=>
      if pc of cache.pc
        message = [{_id: @_id, loc: @loc}]
        ss.publish.user cache.pc[pc].userId, 'you see', message

get_message = (pc)->
  message = {_id: pc._id, loc: pc.loc}
  if pc.movement?.way.positions.length > 1
    message.movement =
      src: pc.loc
      speed: pc.movement.speed
      heading: pc.movement.way.positions[0].bearing(pc.movement.way.positions[1])
  message

Pc.methods.notify_movement = ->
  message = get_message(this)
  @around.forEach (pc)=>
    if pc of cache.pc and @_id in cache.pc[pc].around
      cache.pc[pc].publish 'you see', [message]

move =
  fly: (dst)->
    @movement.way= new Geo.Line([@loc.toObject(), dst].map (loc)-> new Geo.Pos(loc...))
    distance = @movement.way.distance().total
    time = distance / @movement.speed
    setTimeout(@updatePos.bind(this), time)
    @notify_movement()

Pc.methods.move = (type, other...) ->
  @updatePos()
  @movement = {type: type, start: (new Date).getTime(), speed: @speed[type]}
  move[type].apply this, other

Pc.methods.sees_only = (pc)->
  pc_ids = @around.map (e)->{_id: e}
  equals = (a,b)-> String(a._id) == String(b._id)
  new_pcs = $.differenceBy(equals, pc, pc_ids)
  old_pcs = $.differenceBy(equals, pc_ids, pc)
  new_pcs.forEach (pc)->
    if cache.pc[pc._id]?.movement?.way.positions.length > 1
      movement = cache.pc[pc._id].movement
      path = movement.way.positions
      pc.movement =
        speed: movement.speed
        src: pc.loc
        heading: path[0].bearing(path[1])
  #console.log(old_pcs, new_pcs)
  old_pcs.forEach (pc)=>
    if pc._id of cache.pc
      pc = cache.pc[pc._id]
      pc.around = $.delete(pc.around, @_id)
      pc.publish('you lost', [{_id: @_id}])
  new_pcs.forEach (pc)=>
    if pc._id of cache.pc
      pc = cache.pc[pc._id]
      pc.around = $.insert(pc.around, @_id)
      pc.publish('you see', [get_message(this)])
    #cache.pc[pc._id]?.not_seen_by(@_id)
  @publish('you see', new_pcs) if new_pcs.length > 0
  @publish('you lost', old_pcs) if old_pcs.length > 0
  @around = pc.map (e)->e._id

skillLevel2Value = (level)->
  if level < 0
    'лох'
  else if level < 5
    'нуб'
  else if level < 10
    'норм'
  else if level < 15
    'крут'
  else 'супер'

Pc.methods.toJSON = ->
  {
    @name
    @loc
    skills: @skills.map (skill)->{name: skill.name, value: skillLevel2Value(skill.level)}
  }
        
model = mongoose.model('PC', Pc)
module.exports =
  model: model
  by_id: by_id
  by_user: by_user
  find: (query, cb)->
    model.find query, (err, docs)->
      cb(arguments) if err
      cb null, docs.map (doc)->
        if cache.pc[doc._id]
          cache.pc[doc._id]
        else
          cache.pc[doc._id] = doc
