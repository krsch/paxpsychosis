mongoose = require 'mongoose'
Geo = require('geojs')
ss = require('socketstream').api
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Pc = new Schema {
  name: String
  factionId: ObjectId
  userId: {type: ObjectId, unique: true}
  speed: { fly: {type: Number, default: 0.005} }
  loc: [{type: Number, index: {"2d": true}}]
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
          pos = @movement.way.traverse(distance)
          @loc = [pos.lat, pos.lon]
          model.update {_id: @_id}, {$set: {loc: @loc}}, (err, num)->
            if num != 1 || err
              console.error err
          ss.publish.user @userId, 'pcMove',
              waypoints: [@loc.toObject()].concat @movement.way.positions[1..].map((p)->[p.lat,p.lon])
              speed: @movement.speed
        else
          ss.publish.user(@userId, 'pcPosition', @loc)


move =
  fly: (dst)->
    @movement.way= new Geo.Line([@loc.toObject(), dst].map (loc)-> new Geo.Pos(loc...))
    distance = @movement.way.distance().total
    time = distance / @movement.speed
    setTimeout(@updatePos.bind(this), time)

Pc.methods.move = (type, other...) ->
  @updatePos(ss)
  @movement = type: type, start: (new Date).getTime(), speed: @speed[type]
  move[type].apply(this, other)
        
module.exports = model = mongoose.model('PC', Pc)
