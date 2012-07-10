login = require('./login')
init = require('./init')
exports.startup = ->
  login.login (err,ok) ->
    # TODO: check for errors
    init.loadMap()

exports.startup()

ss.event.on 'pcPosition', (pos)->
    #pc.loc = pos
    #pc.pos = new L.LatLng(pc.loc...)
    #pc.marker.setLatLng pc.pos
    pc.setPosition(pos)
    pc.get('movement').animate = false if pc.has('movement')
    #pc.waypoints?[0] = pc.pos
