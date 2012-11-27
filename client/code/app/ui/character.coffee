# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
ss = require('socketstream')
pass_event = require('./pass')
inside = require('./inside')

polygons = {
  '.up-k13': [{x: 18, y: 35}, {x:112,y: 12}, {x:112,y: 210}]
  '.up-k1' : [{x: 18, y: 6 }, {x:111,y: 29}, {x: 18,y: 204}]
  '.up-k2' : [{x:100, y: 6 }, {x:172,y: 70}, {x:  9,y: 182}]
}

$ ->
  $(document).on 'mousedown', '.dialog .up-bg-panel', (e)->
    return unless e.which == 1
    dialog= $(this).parent()
    offset = dialog.offset()
    x = e.clientX - offset.left
    y = e.clientY - offset.top
    onmove = (e)->
      dialog.offset(left: e.clientX - x, top: e.clientY - y)
      false
    onup = (e)->
      $(document).off 'mousemove', onmove
      $(document).off 'mouseup', onup
    $(document).on 'mousemove', onmove
    $(document).on 'mouseup', onup
    false
  $(document).on 'click', '.dialog .close-button', (e)->
    $(this).closest('.dialog').hide()
  
exports.show = ->
  if $('#character').length == 0
    $(document.body).append('<div id="character" class="dialog"></div>')
  $('#character').show()
  pc.on('change', update)
  update()

exports.update = update = ->
  html = ss.tmpl['character'].render(pc.toJSON())
  ch = $('#character')
  ch.html(html)
  pass_event.wrapPassEvent('#character .up-bg-panel',
    #target_by_class: 'up-bg-panel', selector: '.up-bg-panel',
    inside: inside.center_circle('#character .up-bg-panel', 128))
  for style of polygons
    pass_event.wrapPassEvent(ch.find(style), inside: inside.polygon(polygons[style], ch.find(style)))

exports.hide = ->
  $('#character').hide()
  pc.off('change', update)
