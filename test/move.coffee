require('./world')
movement = require('../server/models/movement')
chai = require('chai')
chai.Assertion.includeStack = true
chai.should()

describe 'movement', ->
  src = {lat: 0.01, lon:0.01}
  dst = {lat: 0.0101, lon: 0.0101}
  beforeEach ->
    @move = movement(src, {fly: 0.05})
  
  it 'should change to stop', (done)->
    @move.on 'change:movement', (m)->
      m.waypoints.should.deep.equal [m.src]
      m.src.should.deep.equal src
      done()
    @move.move('stop')

  it 'should change movement in fly', (done)->
    @move.on 'change:movement', (m)=>
      #console.log(m)
      if m.waypoints.length == 1
        done()
      else
        m.waypoints.length.should.equal 2
        m.waypoints[1].should.deep.equal dst
    @move.move('fly', [dst])

  it 'should change direction in fly', (done)->
    @move.on 'change:direction', start = (m)=>
      m.src.should.deep.equal src
      m.heading.should.be.within 44.9, 45.1
      @move.removeListener('change:direction',start)
      @move.on 'change:direction', (m)=>
        if m.waypoints
          m.waypoints.should.deep.equal [dst]
          m.src.should.deep.equal dst
          done()
    @move.move 'fly', [dst]
