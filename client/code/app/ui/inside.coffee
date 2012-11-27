_ = require('underscore')
exports.center_circle = (element, radius)->
  r2 = radius*radius
  return (e)->
    el = $(element)
    lt = el.offset()
    center_x = lt.left + el.width()/2
    center_y = lt.top + el.height()/2
    x = e.clientX - center_x
    y = e.clientY - center_y
    return (x*x + y*y) < r2

exports.polygon = (polygon, obj)->
  #below_horizontal = (limit, left, right)-> 
  lines = []
  lt = obj.offset()
  for i in _.range(polygon.length)
    # for each interval check if the point is above
    lines[i] = do ->
      a = polygon[i]
      b = polygon[i+1] ? polygon[0]
      left = _.min([a.x, b.x])
      right = _.max([a.x, b.x])
      if a.y == b.y
        #below_horizontal(a.y, left, right)
        (x,y)-> y<a.y and x>left and x<right
      else if a.x == b.x
        #lines[i] = (x,y) -> false
        (x,y) -> false
      else
        #k = (b.x - a.x)/(b.y - a.y)
        #c = a.y + lt.top - k*(a.x+lt.left)
        (x,y) ->
          return false if x < left or x > right
          (x - a.x) / (b.x - a.x) > (y - a.y) / (b.y - a.y)
  return (e)->
    res = _.map(lines, (f)->f(e.clientX - lt.left, e.clientY - lt.top))
    console.log(obj) if res.length > 0
    console.log(res) if res.length > 0
    #console.log("Polygon res: #{res}") if res > 0
    _.compact(res).length %2 == 1

