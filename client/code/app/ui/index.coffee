# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
"use strict";
character_window = require('./character')
pass_event = require('./pass')

require('./avatar')

$ ->
        $('[data-pointer-map]').each ->
                img = new Image()
                el = $(this)
                img.src = el.data('pointer-map')
                img.onload = ->
                        pass_event.wrapPassEvent(el, inside: pass_event.get_inside_image(img, 10));
                img.src = el.data('pointer-map')
        $('[data-pointer-none]').each ->
                pass_event.wrapPassEvent(this, inside: ->false)

