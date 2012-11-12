Geo = require('geojs')
Pc = require('../models/pc')
exports.actions = (req,res,ss) ->
  #req.use('session')
  #req.use('auth.authenticated')
  req.use('pc.load', req)

  get: ->
    #req.pc.around.forEach (seen)->
    #  req.pc.see(seen)
    return res(null, req.pc)
  move: (type, dst) ->
    pc = req.pc
    #console.log("(#{pc.doc.name}) moves by #{type} to ", dst)
    if type == 'fly'
      pc.move(type, [dst])
    else if type == 'stop'
      pc.move(type)
    else return res('Wrong move type')
    res(null)
  lookAround: ->
    pc = req.pc
    pc.updatePos()
    Pc.find {loc: {$within: $centerSphere: [pc.doc.loc, m2deg(200)]}, _id: $ne: pc._id }, (err, near)->
      console.error(err) if err
      return res(err.message) if err
      near.forEach (e)->
        cache.pc[e._id]?.updatePos()
      Pc.find {loc: {$within: $centerSphere: [pc.doc.loc, m2deg(100)]}, _id: $ne: pc._id }, (err, near)->
        console.error(err) if err
        return res(err.message) if err
        pc_export = near.map (e)->{_id: e._id, loc: e.loc, type: 'person'}
        pc.sees_only pc_export
        #near.forEach (e)->e.seen_by pc._id
        return res(null, true)

m2deg = (m)->m/6321000/3.1415926*180
