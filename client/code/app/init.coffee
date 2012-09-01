Pc = require('./model/pc')
Moving = require('./model/moving')

inside_bgava = (e)->
  x = e.clientX
  y = e.clientY
  return y<(220+120) and x<80 or y<(70+7) and x<(190+185) or (x*x + y*y < 200*200)

exports.loadMap = ->
  $('.lt').on('click dblclick mousedown mouseup mouseover mouseout contextmenu mousenter mouseleave', passEvent.bind(this, '.lt', inside_bgava))
  window.osm ?= new L.Map 'map', attributionControl: false
  L.tileLayer('http://{s}.tile.cloudmade.com/fbc6f9297a964ee5830cbeeaf0985e29/997/256/{z}/{x}/{y}.png', { maxZoom: 18 }).addTo(osm)
  Pc.load (err,pc)->
    return alert(err) if err
    # Create map
    pc_pos = pc.get('loc')
    osm.setView(pc_pos, 13)
    window.pc = pc
    #pc.get('marker').bindPopup("Your PC, ", pc_data.name)
    osm.on 'click', (e)->
      ss.rpc 'pc.move', 'fly', [e.latlng.lat, e.latlng.lng], (err, movement)->
        if err
          console.error(err)
        else
          pc.startMovement(movement)

loadPC = (fn)->
  ss.rpc 'pc.get', fn

swap = (f,a,b)->f(b,a)
int_id = swap setInterval, 10000, ->
  ss.rpc 'pc.lookAround', (err, new_people)->
    if err
      console.error(err)
      return
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

window.passEvent = (src, inside, e)->
  if !inside(e)
    e.stopPropagation()
    e.preventDefault()
    event = document.createEvent('MouseEvents')
    event.initMouseEvent(e.type, e.bubbles, e.cancelable, window, e.detail?,
         e.screenX, e.screenY, e.clientX, e.clientY, e.ctrlKey, e.altKey, e.shiftKey,
         e.metaKey, e.button, e.relatedTarget)
    $(src).hide()
    dst = document.elementFromPoint(e.clientX, e.clientY)
    $(src).show()
    dst.dispatchEvent(event)

