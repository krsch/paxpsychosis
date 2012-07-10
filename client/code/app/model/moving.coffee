Backbone = require('backbone')
mo = require('./map_object')
_ = require('underscore')

module.exports = mo.extend
        updatePosition: ->
                return unless @has('movement')
                m = @get('movement')
                duration = (new Date).getTime() - m.startTime
                distance = duration * m.speed
                pos = m.way.traverse(distance)
                @setPosition(pos)
                if m.animate && ! _.every(['lat','lon'], (l)->pos[l] == _.last(m.way)[l])
                        requestAnimationFrame(@updatePosition)
        startMovement: (movement)->
                @setMovement(movement) if movement
                @get('movement').animate = true
                requestAnimationFrame(@updatePosition)
        setMovement: (movement)->
                movement.way = new Geo.Line(movement.waypoints.map (loc)-> new Geo.Pos(loc...))
                movement.startTime = (new Date).getTime()
                movement.animate = false
                @setPosition @movement.waypoints[0]
