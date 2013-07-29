"use strict";
mouse_events = 'click dblclick mousedown mouseup mouseover mouseout contextmenu mousenter mouseleave'

exports.get_inside_image = get_inside_image = (img, threshold)->
        canvas = document.createElement("canvas");  #Create HTML5 canvas: supported in latest firefox/chrome/safari/konquerer.  Support in IE9
        canvas.width = img.width;                   #Set width of your rendertarget
        canvas.height = img.height;                 # \  height \   \     \
        ctx = canvas.getContext("2d");              #Get the 2d context [the thing you draw on]
        ctx.drawImage(img, 0, 0);                   #Draw the picture on it.
        id = ctx.getImageData(0,0, img.width+1, img.height+1);  #Get the pixelData of image
        #id.data[(y*width+x)*4+3] for the alpha value of pixel at x,y, 0->255
        # console.log("loaded transparency for image #{img.width}x#{img.height}. Array length is #{id.data.length}")
        # for i in [3...id.data.length] by 4
                # res[i] = id.data[i]
        # width = img.width
        return (e)-> 
                idx = e.clientY*id.width + e.clientX
                if (e.clientY>=id.width || e.clientX>=id.height)
                        return false
                # console.log("x #{e.clientX}, y #{e.clientY}, #{id.data[idx*4+3]}")
                id.data[idx*4+3]>threshold

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

