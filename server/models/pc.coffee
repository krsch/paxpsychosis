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
  _seen_by: []
  _sees: []
}

Pc.statics.by_user = (userId, cb) ->
        model.find({userId}, cb)
Pc.statics.by_id = (pc_id, cb) ->
        if pc_id of cache.pc
                cb(null, cache.pc[pc_id])
        else
                model.findOne {_id: pc_id}, (err,doc)->
                        cache.pc[pc_id] = doc unless err
                        cb(err,doc)

Pc.methods.updatePos = ->
        if @movement && @movement.type = 'fly'
          time = (new Date).getTime() - @movement.start
          distance = time * @speed[@movement.type]
          distance_segments = @movement.way.distance().segments
          pos = @movement.way.traverse(distance)
          @loc = [pos.lat, pos.lon]
          while distance > distance_segments[0]
            distance -= distance_segments[0]
            @movement.way.positions.shift()
            distance_segments.shift()
          if distance_segments.length > 0
            distance = @movement.way.distance().total
            new_time = distance / @movement.speed - time
            setTimeout Pc.methods.updatePos.bind(this), new_time
          model.update {_id: @_id}, {$set: {loc: @loc}}, (err, num)->
            if num != 1 || err
              console.error err
          ss.publish.user @userId, 'pcMove',
              waypoints: [@loc.toObject()].concat @movement.way.positions[1..].map((p)->[p.lat,p.lon])
              speed: @movement.speed
        else
          ss.publish.user(@userId, 'pcPosition', @loc)
          @_sees.forEach (pc)=>
            if pc of cache.pc
              message = [{_id: @_id, loc: @loc}]
              ss.publish.user cache.pc[pc].userId, 'you see', message
        @notify_movement()

Pc.methods.notify_movement = ->
  @_sees.forEach (pc)=>
    if pc of cache.pc
      message = {_id: @_id, loc: @loc}
      if @movement?.way.positions.length > 1
        message.movement =
          src: @loc
          speed: @movement.speed
          heading: @movement.way.positions[0].bearing(@movement.way.positions[1])
      ss.publish.user cache.pc[pc].userId, 'you see', [message]

move =
  fly: (dst)->
    @movement.way= new Geo.Line([@loc.toObject(), dst].map (loc)-> new Geo.Pos(loc...))
    distance = @movement.way.distance().total
    time = distance / @movement.speed
    setTimeout(@updatePos.bind(this), time)
    @notify_movement()

Pc.methods.move = (type, other...) ->
  @updatePos()
  @movement = type: type, start: (new Date).getTime(), speed: @speed[type]
  move[type].apply this, other

Pc.methods.sees_only = (pc)->
  pc_ids = @_sees.map (e)->{_id: e}
  equals = (a,b)-> String(a._id) == String(b._id)
  #new_pcs = $.differenceBy(equals, pc, pc_ids)
  old_pcs = $.differenceBy(equals, pc_ids, pc)
  pc.forEach (pc)->
    if pc._id of cache.pc and cache.pc[pc._id].movement?.way.positions.length > 1
      movement = cache.pc[pc._id].movement
      path = movement.way.positions
      pc.movement =
        speed: movement.speed
        src: pc.loc
        heading: path[0].bearing(path[1])
  #console.log(old_pcs, new_pcs)
  old_pcs.forEach (pc)->pc.not_seen_by(@_id)
  ss.publish.user(@userId, 'you see', pc)
  ss.publish.user(@userId, 'you lost', old_pcs) unless old_pcs.length == 0
  @_sees = pc.map (e)->e._id
  #@_sees.push(pc...)
        
Pc.methods.seen_by = (pc)->
  @_seen_by = $.insert(@_seen_by, pc)

Pc.methods.not_seen_by = (pc)->
  @_seen_by ?= []
  @_seen_by = $.delete(@_seen_by, pc)

module.exports = model = mongoose.model('PC', Pc)
