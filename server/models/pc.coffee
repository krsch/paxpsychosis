mongoose = require 'mongoose'
$ = require('interlude')
deepEqual = require('deep-equal')
_ = require('underscore')
Geo = require('geojs')
ss = require('socketstream').api
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
movements = require('./movement')
pc_schema = new Schema {
  name: String
  factionId: ObjectId
  userId: {type: ObjectId, unique: true}
  speed: { fly: {type: Number, default: 5e-6} }
  loc: {type: [Number], index: "2d"}
  skills: [{name: String, value: Number}]
}

log_error = (err)->(console.error(err) if err)

class Pc
  constructor: (@doc)->
    if @doc._id of cache.pc
      throw new Error("PC document not loaded into cache but trying to be created")
    @_id = @doc._id
    @around = []
    @movement = new movements(doc.loc, doc.speed)
    @movement.on 'change:movement', (movement)=>
      @publish 'pcMove', movement
    @movement.on 'change:direction', (movement)=>
      @notify_movement(movement)
    @movement.on 'change:position', (loc)=>
      @doc.loc = loc
      model.update {_id: @_id}, {$set: {loc: [loc.lon, loc.lat]}}, log_error
      look_around(@)
  @create: (doc)->
    if doc._id of cache.pc
      console.error("PC document not loaded into cache but trying to be created")
      cache.pc[doc._id]
    else
      cache.pc[doc._id] = new Pc(doc)
  publish: (topic, message)->
    ss.publish.user(@doc.userId, topic, message)
  updatePos: ->
    @movement.force()
  move: ->
    @movement.move(arguments...)
  notify_movement: (message)->
    @around.forEach (pc)=>
      if pc of cache.pc and @_id in cache.pc[pc].around
        cache.pc[pc].publish 'you see', [message]
  toJSON: ->
    {
      @name
      @loc
      skills: @skills.map (skill)->{name: skill.name, value: skillLevel2Value(skill.level)}
    }
        

look_around = (pc)->
  return

by_user = (userId, cb) ->
  model.findOne {userId}, (err, doc)->
    return cb(arguments) if err
    cb(null, Pc.create(doc))
by_id = (_id, cb) ->
  if _id of cache.pc
    cb(null, cache.pc[_id])
  else
    model.findOne {_id}, (err,doc)->
      return cb(arguments) if err
      cb(null, Pc.create(doc))

Pc.prototype.sees_only = (pc)->
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

model = mongoose.model('PC', pc_schema)
module.exports =
  model: model
  by_id: by_id
  by_user: by_user
  create: Pc.create
  find: (query, cb)->
    model.find query, (err, docs)->
      cb(arguments) if err
      cb null, docs.map (doc)->
        if cache.pc[doc._id]
          cache.pc[doc._id]
        else
          cache.pc[doc._id] = doc
