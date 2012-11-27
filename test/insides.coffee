inside = require('../client/code/app/ui/inside')
sinon = require('sinon')
chai = require('chai')
chai.should()

event = (x,y) ->
  this.clientX = x
  this.clientY = y

describe 'inside', ->
  beforeEach ->
    @element = { offset: -> {left: 0, top: 0} }
  describe 'polygon', ->
    describe 'square', ->
      beforeEach ->
        @square = [{x:1, y:1}, {x:10, y:1}, {x:10, y:10}, {x:1, y:10}]
        @f = inside.polygon(@square, @element)
      it 'can be inside', ->
        @f( new event( 5,  5) ).should.be.true
      it 'can be outside', ->
        @f( new event(11,  1) ).should.be.false
        @f( new event(-1,  1) ).should.be.false
        @f( new event(11, 11) ).should.be.false
        @f( new event(11, -1) ).should.be.false
        @f( new event(11,-11) ).should.be.false
    describe 'rotated square', ->
      beforeEach ->
        @square = [{x:1, y:1}, {x:10, y:2}, {x:9, y:10}, {x:2, y:9}]
        @f = inside.polygon(@square, @element)
      it 'can be inside', ->
        @f( new event( 5,  5) ).should.be.true
      it 'can be outside', ->
        @f( new event(11,  1) ).should.be.false
        @f( new event(-1,  1) ).should.be.false
        @f( new event(11, 11) ).should.be.false
        @f( new event(11, -1) ).should.be.false
        @f( new event(11,-11) ).should.be.false
    describe 'triangle', ->
      beforeEach ->
        @triangle = [{x:1, y:1}, {x:10, y:1}, {x:1, y:10}]
        @f = inside.polygon(@triangle, @element)
      it 'can be inside', ->
        @f( new event( 4,  4) ).should.be.true
      it 'can be outside', ->
        @f( new event(11,  1) ).should.be.false
        @f( new event(-1,  1) ).should.be.false
        @f( new event(11, 11) ).should.be.false
        @f( new event(11, -1) ).should.be.false
        @f( new event(6,6) ).should.be.false
