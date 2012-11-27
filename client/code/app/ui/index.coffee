character_window = require('./character')
pass_event = require('./pass')

inside_bgava = (e)->
  x = e.clientX
  y = e.clientY
  return y<(220+120) and x<80 or y<(70+7) and x<(190+185) or (x*x + y*y < 200*200)

inside_kman = (e)->
  true

$ ->
  #$('.lt').on(mouse_events, passEvent('.lt', inside_bgava))
  pass_event.wrapPassEvent('.lt')
  pass_event.wrapPassEvent('.bgava', inside: inside_bgava, hide: '.lt')
  pass_event.wrapPassEvent '.kman', inside: inside_kman, fn: (e)->
    if e.type == 'click'
      character_window.show()
      #false
    #else true

