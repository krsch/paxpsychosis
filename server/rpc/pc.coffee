Geo = require('geojs')
Pc = require('../models/pc')
exports.actions = (req,res,ss) ->
  req.use('session')
  req.use('auth.authenticated')

  get: ->
    if req.session.pc_id
      res(null,cache.pc[req.session.pc_id])
      return
    userid = req.session.userId
    Pc.findOne {userId: userid}, (err,doc)->
      if err
        console.log(err)
        res(err)
      else
        req.session.pc_id = doc._id
        req.session.save()
        cache.pc[doc._id] = doc
        res(null,doc)
  move: (type, dst) ->
    Pc.by_id req.session.pc_id, (err,pc) ->
      return res(err) if err
      unless type of pc.speed
        return res(new Error('Wrong move type'),null)
      #pc = cache.pc[req.session.pc_id]
      pc.updatePos(ss)
      pc.movement =
          way: new Geo.Line([pc.loc.toObject(), dst].map (loc)-> new Geo.Pos(loc...))
          start: (new Date).getTime()
          type: type
      # FIXME: add multisegment support
      distance = pc.movement.way.distance().total
      time = distance / pc.speed[type]
      setTimeout(pc.updatePos.bind(pc,ss), time)
      res null, {
        waypoints: pc.movement.way.positions.map (p) -> [p.lat, p.lon]
        speed: pc.speed[type]
        distance: distance
        time: time
      }

updatePos = (ss)->
  time = (new Date).getTime() - @movement.start
  distance = time * @movement.speed
  pos = @movement.way.traverse(distance)
  @loc = [pos.lat, pos.lon]
  
  Pc = require('./../models/pc')
  Pc.update {_id: @_id}, {$set: {loc: @loc}}, (err, num)->
    if num != 1 || err
      debugger
      console.error err
  if @movement
    ss.publish.user @userId, 'pcMove',
        waypoints: [@loc].concat @movement.way.positions[1..].map((p)->[p.lat,p.lon])
        speed: @movement.speed
  else
    ss.publish.user(@userId, 'pcPosition', @loc)

