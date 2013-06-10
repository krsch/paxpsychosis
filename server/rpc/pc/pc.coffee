# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
Geo = require('geojs')
Pc = require('../../models/pc')
exports.actions = (req,res,ss) ->
  #req.use('session')
  #req.use('auth.authenticated')
  req.use('pc.load', req)

  get: ->
        res(null, req.pc)
        setTimeout ->
            req.pc.around.forEach (seen)->
                    Pc.by_id seen, (err, pc)->
                      req.pc.see(pc) unless err
  observe: (id)->
          if id
                  res
                        interfaces:
                                talk: {}
                                look: {}
          else
                  res
                        interfaces: []
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
