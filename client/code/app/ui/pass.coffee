mouse_events = 'click dblclick mousedown mouseup mouseover mouseout contextmenu mousenter mouseleave'

exports.wrapPassEvent = wrapPassEvent = (src, opts)->
  $(src).on(mouse_events, opts?.selector ? null, '', passEvent(src, opts))

exports.passEvent = passEvent = (src, opts)->
  opts ?= {}
  el = $(src)
  hidden = $(opts.hide ? src)
  return (e)->
    if opts.target_by_class?
      return unless $(e.target).hasClass(opts.target_by_class)
    else
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
      dst?.dispatchEvent(event)
      hidden.show()

