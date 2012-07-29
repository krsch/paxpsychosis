MapObject = require('./map_object')
_ = require('underscore')

module.exports = class MovingObject extends MapObject
        updatePosition: =>
                return unless @has('movement')
                m = @get('movement')
                duration = (new Date).getTime() - m.startTime
                distance = 1000*duration * m.speed
                pos = geo.math.destination(m.start_pos, heading:m.heading, distance:distance)
                @setPosition([pos.lat(), pos.lng()])
                if m.animate && !pos.equals(_.last(m.way)) && distance < m.distance
                        requestAnimationFrame(@updatePosition)
                else
                        m.animate = false

        startMovement: (movement)->
                if movement
                        movement.animate = true
                        @setMovement(movement)
                else
                        @get('movement').animate = true
                        requestAnimationFrame(@updatePosition)

        setMovement: (movement)->
                movement.way = movement.waypoints.map (loc)->new geo.Point(loc...)
                movement.distance = movement.way[0].distance(movement.way[1])
                movement.heading = geo.math.heading(movement.way[0..1]...)
                movement.start_pos = movement.way[0]
                movement.startTime = (new Date).getTime()
                movement.animate ?= false
                @set('movement', movement)
                @setPosition movement.waypoints[0]
                if movement.animate
                        requestAnimationFrame(@updatePosition)

