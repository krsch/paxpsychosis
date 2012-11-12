require('./world')
ss = require('socketstream').start()
pc = require '../server/rpc/pc'
Geo = require('geojs')
chai = require 'chai'
chai.Assertion.includeStack = true
user = require '../server/models/user'
sinon = require 'sinon'
deepEqual = require('deep-equal')
chai.should()
wrapRPC = (done)-> (args)->done(args...)
{model: Pc, create: create_pc} = require('../server/models/pc')
process.on 'uncaughtException', (e)->
  if e instanceof RangeError
    process.abort()

print_time = (name, zero_time, f)->
  return ->
    time = (new Date).getTime()
    console.log("Entering #{name} at #{time-zero_time}")
    f.apply(this, arguments)
    after_time = (new Date).getTime()
    console.log("Exiting #{name} at #{after_time-zero_time} after #{after_time-time}")

arrayEqual = (a,b)->
  eq = true
  for i in a
    if a[i] != b[i]
      eq = false
  eq

describe 'PC', ->
  stub_session = null
  session = null
  pc = null
  beforeEach ->
    cache.pc = {}
    pc = create_pc({_id: 1, userId: 1, loc: [0.02,0.02], speed: {fly: 0.005}})
    session = {pc_id:pc._id, userId: 1, save: ->true}
    @stubs = []
    @stub = => @stubs.push sinon.stub(arguments)
  afterEach ->
    @stubs.forEach (stub)->stub.restore()
  before ->
    stub_session = sinon.stub(ss.session, 'find', (a,b,cb)->cb(session))
  after ->
    stub_session.restore()
  describe 'move', ->

    it 'should not move by magic', (done)->
      ss.rpc 'pc.move', 'magic', [0, 0], wrapRPC (err, m)->
        err.should.not.be.null
        done()

    it 'should move by fly', (done)->
      dst = pc.loc.to(45, 1e-3).toJSON()
      @stubs.push sinon.stub(Pc, 'update').returns(null).yields(null,1)
      pc.movement.on 'change:movement', (move)->
        if move.waypoints?.length > 1
          move.waypoints.should.deep.equal [{lat: pc.doc.loc[1], lon: pc.doc.loc[0]}, dst]
        else
          pc.doc.loc.should.deep.equal [dst.lon, dst.lat]
          done()
      ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
        chai.expect(err).to.be.null

    it 'should move by stop', (done)->
      loc = {lat: pc.doc.loc[1], lon: pc.doc.loc[0]}
      @stubs.push sinon.stub(Pc, 'update').returns(null).yields(null,1)
      pc.movement.on 'change:movement', (move)->
        move.src.should.deep.equal loc
        move.waypoints.should.deep.equal [loc]
        done()
      ss.rpc 'pc.move', 'stop', wrapRPC (err, m)->
        chai.expect(err).to.be.null

    it 'should fly at place', (done)->
      dst = {lat: pc.doc.loc[1], lon: pc.doc.loc[0]}
      @stubs.push sinon.stub(Pc, 'update').returns(null).yields(null,1)
      pc.movement.removeAllListeners()
      pc.movement.on 'change:movement', (move)->
        #move.src.should.deep.equal dst
        move.waypoints.forEach (m)-> m.should.deep.equal dst
        done() if move.src?
      ss.rpc 'pc.move', 'fly', dst, wrapRPC (err, m)->
        chai.expect(err).to.be.null

    it 'should update position in fly', (done)->
      loc = pc.doc.loc
      dst = pc.loc.to(135, 1e-3).toJSON()
      @stubs.push sinon.stub Pc, 'update', (who, how, cb)->
        unless who._id == pc._id
          setTimeout -> cb(new Error('not found'))
          return
        loc = how['$set'].loc
        setTimeout -> cb(null, 1)
      @stubs.push sinon.stub ss.publish, 'user', (userId, messageId, m)->
        if messageId == 'pcMove' and deepEqual(m.waypoints[0], dst)
          loc.should.deep.equal [dst.lon, dst.lat]
          pc.doc.loc.should.deep.equal [dst.lon, dst.lat]
          m.waypoints.should.deep.equal [dst]
          done()
        else if messageId == 'pcPosition' and deepEqual(m, dst)
          loc.should.equal [dst.lon, dst.lat]
          done()
      ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
        chai.expect(err).to.be.null
    it 'should use the correct speed'

  it 'should get pc', (done)->
    pc_id = session.pc_id
    pc_doc = cache.pc[pc_id].doc
    delete session.pc_id
    cache.pc = {}
    mock = sinon.mock(Pc)
    mock.expects('findOne').yields(null,pc_doc).returns(null)
    ss.rpc 'pc.get', wrapRPC (err,new_pc)->
      chai.expect(err).to.be.null
      mock.verify()
      new_pc.doc.should.equal pc_doc
      #session.pc_id.should.equal 1
      done(err)

  describe 'look around', ->
    beforeEach ->
      cache.pc = {1: {}, 2: {}}
