exports.loadMap = ->
  loadPC (err,pc)->
    if err != null
      alert(err)
      return
    # Create map
    window.osm = new L.Map 'map'
    cloudmade = new L.TileLayer('http://{s}.tile.cloudmade.com/fbc6f9297a964ee5830cbeeaf0985e29/997/256/{z}/{x}/{y}.png', {
      #attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
      maxZoom: 18
      attributionControl: false
    })
    pc_pos = new L.LatLng(pc.loc[0], pc.loc[1])
    osm.setView(pc_pos, 13).addLayer(cloudmade)
    marker = new L.Marker(pc_pos)
    osm.addLayer(marker)
    pc.marker = marker
    window.pc = pc
    marker.bindPopup("Your PC, ", pc.name)
    osm.on 'click', (e)->
      console.log e.latlng
      ss.rpc 'pc.move', 'fly', [e.latlng.lat, e.latlng.lng], (e)->
        console.log(e)
        pc.waypoints = e.waypoints.map (p)-> new L.LatLng(p.lat, p.lon)
        pc.speed = e.speed

loadPC = (fn)->
  ss.rpc 'pc.get', (pc)->
    if pc == false
      setTimeout -> fn('auth error',null)
    else
      setTimeout -> fn(null,pc)

