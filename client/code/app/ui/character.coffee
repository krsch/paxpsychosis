# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
ss = require('socketstream')

$ ->
  $(document).on 'mousedown', '.dialog > h1', (e)->
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
  $('#character').html(html)

exports.hide = ->
  $('#character').hide()
  pc.off('change', update)
