login = require('./login')
init = require('./init')
exports.startup = ->
  login.login (err,ok) ->
    # TODO: check for errors
    init.loadMap()

exports.startup()

ss.event.on 'pcPosition', (pos)->
  pc.setPosition(pos)
  #pc.get('movement').animate = false if pc.has('movement')
  pc.unset('movement') if pc.has('movement')

ss.event.on 'pcMove', (movement)->
  pc.startMovement(movement)
