# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
Pc = require('./model/pc')
Moving = require('./model/moving')
require('./ui')

exports.loadMap = ->
  window.osm ?= new L.Map 'map', attributionControl: false
  L.tileLayer('http://{s}.tile.cloudmade.com/fbc6f9297a964ee5830cbeeaf0985e29/997/256/{z}/{x}/{y}.png', { maxZoom: 18 }).addTo(osm)
  Pc.load (err,pc)->
    return alert("Error on logon: #{err}") if err
    # Create map
    pc_pos = pc.get('loc')
    osm.setView(pc_pos, 13)
    window.pc = pc
    osm.on 'click', (e)->
      ss.rpc 'pc.move', 'fly', {lat: e.latlng.lat, lon: e.latlng.lng}, (err, movement)->
        if err
          console.error(err)
        #else
        #  pc.startMovement(movement)

