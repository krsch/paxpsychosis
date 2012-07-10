pc = require('./model/pc')
exports.loadMap = ->
  loadPC (err,pc)->
    if err != null
      alert(err)
      return
    # Create map
    window.osm = new L.Map 'map', attributionControl: false
    cloudmade = new L.TileLayer('http://{s}.tile.cloudmade.com/fbc6f9297a964ee5830cbeeaf0985e29/997/256/{z}/{x}/{y}.png', {
      maxZoom: 18
    })
    pc_pos = new L.LatLng(pc.loc...)
    osm.setView(pc_pos, 13).addLayer(cloudmade)
    marker = new L.Marker(pc_pos)
    osm.addLayer(marker)
    pc.marker = marker
    window.pc = pc
    marker.bindPopup("Your PC, ", pc.name)
    osm.on 'click', (e)->
      ss.rpc 'pc.move', 'fly', [e.latlng.lat, e.latlng.lng], (e)->
        #console.log(e)
        pc.waypoints = e.waypoints.map (e) -> new L.LatLng(e.lat, e.lon)
        pc.speed = e.speed
        pc.start_time = (new Date).getTime()
        if pc.dst_marker
          osm.removeLayer pc.dst_marker
        pc.dst_marker = new L.CircleMarker(pc.waypoints[1])
        osm.addLayer pc.dst_marker
        requestAnimationFrame -> movePc(pc)
        #console.log pc.waypoints[0].distanceTo(pc.waypoints[1])

loadPC = (fn)->
  ss.rpc 'pc.get', (pc)->
    if pc == false
      fn('auth error',null)
    else
      fn(null,pc)

movePc = (pc)->
  pc_pos = []
  time = (new Date).getTime() - pc.start_time
  distance = time * pc.speed
  overall_distance = pc.waypoints[0].distanceTo(pc.waypoints[1]) / 1000
  if overall_distance < 0.001
    return
  l = distance / overall_distance
  #pc_pos = pc.waypoints.traverse distance
  pc_pos[0] = l*pc.waypoints[1].lat + (1-l)*pc.waypoints[0].lat
  pc_pos[1] = l*pc.waypoints[1].lng + (1-l)*pc.waypoints[0].lng
  pc.loc = pc_pos
  pc.pos = new L.LatLng(pc_pos...)
  pc.marker.setLatLng(pc.pos)
  if l < 1
    requestAnimationFrame -> movePc(pc)
  else
    osm.removeLayer pc.dst_marker

window.requestAnimationFrame ?=
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    (callback) -> window.setTimeout(callback, 1000 / 60)
