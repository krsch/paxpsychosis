character_window = require('./character')
inside_bgava = (e)->
  x = e.clientX
  y = e.clientY
  return y<(220+120) and x<80 or y<(70+7) and x<(190+185) or (x*x + y*y < 200*200)

inside_kman = (e)->
  true

mouse_events = 'click dblclick mousedown mouseup mouseover mouseout contextmenu mousenter mouseleave'

$ ->
  #$('.lt').on(mouse_events, passEvent('.lt', inside_bgava))
  wrapPassEvent('.lt')
  wrapPassEvent('.bgava', inside: inside_bgava, hide: '.lt')
  wrapPassEvent '.kman', inside: inside_kman, fn: (e)->
    if e.type == 'click'
      character_window.show()
      #false
    #else true

wrapPassEvent = (src, opts)->
  $(src).on(mouse_events, '', passEvent(src, opts))

passEvent = (src, opts)->
  opts ?= {}
  el = $(src)
  hidden = $(opts.hide ? src)
  return (e)->
    return unless el.is(e.target)
    if opts.inside?(e)
      opts.fn?(e)
    else
      e.stopPropagation()
      e.preventDefault()
      event = document.createEvent('MouseEvents')
      detail = e.detail ? null
      event.initMouseEvent(e.type, e.bubbles, e.cancelable, window, detail,
           e.screenX, e.screenY, e.clientX, e.clientY, e.ctrlKey, e.altKey, e.shiftKey,
           e.metaKey, e.button, e.relatedTarget)
      hidden.hide()
      dst = document.elementFromPoint(e.clientX, e.clientY)
      hidden.show()
      dst?.dispatchEvent(event)

