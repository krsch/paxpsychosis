# This file automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

ss.server.on 'disconnect', ->
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  console.log('Connection back up :-)')

ss.server.on 'ready', ->

  # Wait for the DOM to finish loading
  jQuery ->
    # Create map
    window.osm = new L.Map 'map'
    cloudmade = new L.TileLayer('http://{s}.tile.cloudmade.com/fbc6f9297a964ee5830cbeeaf0985e29/997/256/{z}/{x}/{y}.png', {
      attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>[…]',
      maxZoom: 18
    })
    osm.setView(new L.LatLng(51.505, -0.09), 13).addLayer(cloudmade)
    # Load app
    require('/app')
