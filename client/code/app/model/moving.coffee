MapObject = require('./map_object')
_ = require('underscore')

class MovingObject extends MapObject
        updatePosition: =>
                return unless @has('movement')
                m = @get('movement')
                duration = (new Date).getTime() - m.startTime
                distance = duration * m.speed
                #pos = m.way.traverse(distance)
                pos = geo.math.destination(m.start_pos, heading:m.heading, distance:distance)
                @setPosition([pos.lat(), pos.lng()])
                if m.animate && ! _.every(['lat','lon'], (l)->pos[l] == _.last(m.way)[l])
                        requestAnimationFrame(@updatePosition)
        startMovement: (movement)->
                @setMovement(movement) if movement
                @get('movement').animate = true
                requestAnimationFrame(@updatePosition)
        setMovement: (movement)->
                movement.way = movement.waypoints.map (loc)->new geo.Point(loc...)
                movement.heading = geo.math.heading(movement.way[0..1]...)
                movement.start_pos = movement.way[0]
                movement.startTime = (new Date).getTime()
                movement.animate = false
                @set('movement', movement)
                @setPosition movement.waypoints[0]

module.exports = MovingObject
