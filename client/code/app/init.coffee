Pc = require('./model/pc')
Moving = require('./model/moving')
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

swap = (f,a,b)->f(b,a)
int_id = swap setInterval, 1000, ->
  ss.rpc 'pc.lookAround', (err, new_people)->
    return if err
    return if new_people == true
    window.people ?= {}
    new_people.forEach (e)->
      if e._id of people
        #TODO add supoort for other fields
        people[e._id].set('loc', e.loc)
      else
        people[e._id] = new Moving(e)
alert('no interval') unless int_id

window.requestAnimationFrame ?=
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    (callback) -> window.setTimeout(callback, 1000 / 60)
