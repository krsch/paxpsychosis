Geo = require('geojs')
exports.actions = (req,res,ss) ->
  req.use('session')
  req.use('auth.authenticated')

  get: ->
    if req.session.pc_id
      res(cache.pc[req.session.pc_id])
      return
    userid = req.session.userId
    pc = require('./../models/pc')
    pc.findOne {userId: userid}, (err,doc)->
      if err
        console.log(err)
        res(null)
      else
        req.session.pc_id = doc._id
        req.session.save()
        cache.pc[doc._id] = doc
        res(doc)
  move: (type, dst) ->
    if type != 'fly'
      return res('Wrong move type',null)
    pc = cache.pc[req.session.pc_id]
    if pc.updatePos
      pc.updatePos(ss)
    pc.movement =
        way: new Geo.Line([pc.loc, dst].map (loc)-> new Geo.Pos(loc...))
        speed: 0.005 / 1000
        start: (new Date).getTime()
    # FIXME: add multisegment support
    distance = pc.movement.way.distance().total
    time = distance / pc.movement.speed
    pc.updatePos ?= updatePos
    setTimeout((-> pc.updatePos(ss)), time)
    res null, {
      waypoints: pc.movement.way.positions.map (p) -> [p.lat, p.lon]
      speed: pc.movement.speed
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
      console.log err
  if @movement
    ss.publish.user @userId, 'pcMove',
        waypoints: [@loc].concat @movement.way.positions[1..].map((p)->[p.lat,p.lon])
        speed: @movement.speed
  else
    ss.publish.user(@userId, 'pcPosition', @loc)

