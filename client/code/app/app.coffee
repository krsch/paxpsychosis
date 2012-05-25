login = require('./login')
init = require('./init')
exports.startup = ->
  login.login (err,ok) ->
    # TODO: check for errors
    init.loadMap()

exports.startup()

ss.event.on 'pcPosition', (pos)->
    pc.pos = pos
    pc.marker.setLatLng(new L.LatLng(pc.pos[0], pc.pos[1]))
