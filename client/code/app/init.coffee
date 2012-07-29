Pc = require('./model/pc')
exports.loadMap = ->
  window.osm ?= new L.Map 'map', attributionControl: false
  window.cloudmade ?= new L.TileLayer('http://{s}.tile.cloudmade.com/fbc6f9297a964ee5830cbeeaf0985e29/997/256/{z}/{x}/{y}.png', {
    maxZoom: 18
  })
  #loadPC (err,pc_data)->
  Pc.load (err,pc)->
    if err != null
      alert(err)
      return
    # Create map
    #pc = new Pc({loc: pc_data.loc})
    pc_pos = pc.get('latlng')
    osm.setView(pc_pos, 13).addLayer(cloudmade)
    window.pc = pc
    #pc.get('marker').bindPopup("Your PC, ", pc_data.name)
    osm.on 'click', (e)->
      ss.rpc 'pc.move', 'fly', [e.latlng.lat, e.latlng.lng], (err, movement)->
        if err
                console.log(err)
        else
                pc.startMovement(movement)

loadPC = (fn)->
  ss.rpc 'pc.get', fn

window.requestAnimationFrame ?=
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    (callback) -> window.setTimeout(callback, 1000 / 60)
