# This file automatically gets called first by SocketStream and must always exist
"use strict";

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

ss.server.on 'disconnect', ->
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  console.log('Connection back up :-)')

ss.event.on 'login', (err)->
        alert(err)
        window.location = '/login.html'

ss.event.on 'selectpc', (err)->
        alert(err)
        window.location = '/selectpc'

require('./common')
ss.server.on 'ready', ->

  # Wait for the DOM to finish loading
  jQuery(require('./init').loadMap)
