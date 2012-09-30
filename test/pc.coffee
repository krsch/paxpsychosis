require('./world')
ss = require('socketstream').start()
pc = require '../server/rpc/pc'
chai = require 'chai'
user = require '../server/models/user'
sinon = require 'sinon'
deepEqual = require('deep-equal')
chai.should()
wrapRPC = (done)-> (args)->done(args...)
{model: Pc, create: create_pc} = require('../server/models/pc')
process.on 'uncaughtException', (e)->
  if e instanceof RangeError
    process.abort()

arrayEqual = (a,b)->
  eq = true
  for i in a
    if a[i] != b[i]
      eq = false
  eq

describe 'PC', ->
  describe 'move', ->
    stub_session = null
    session = null
    pc = null
    stubs = []
    beforeEach ->
          cache.pc = {}
          pc = create_pc({_id: 1, userId: 1, loc: [0.02,0.02], speed: {fly: 0.005}, update: (->)})
          session = {pc_id:pc._id, userId: 1, save: ->true}
          stubs = []
          @stub = -> stubs.push sinon.stub(arguments)
    afterEach ->
      stubs.forEach (stub)->stub.restore()
    before ->
      stub_session = sinon.stub(ss.session, 'find', (a,b,cb)->cb(session))
    after ->
      stub_session.restore()

    it 'should not move by magic', (done)->
      ss.rpc 'pc.move', 'magic', [0, 0], wrapRPC (err, m)->
          err.should.not.be.null
          done()

    it 'should move by fly', (done)->
      dst = {lat: 0.01, lon: 0.01}
      stubs.push sinon.stub(Pc, 'update').returns(null).yields(null,1)
      pc.movement.on 'change:movement', (move)->
        if move.waypoints?
          move.waypoints.should.deep.equal [pc.doc.loc, dst]
        else
          pc.doc.loc.should.deep.equal dst
        done()
      ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
        chai.expect(err).to.be.null

    it 'should update position in fly', (done)->
      dst = {lat: 0.019, lon: 0.001}
      stubs.push sinon.stub Pc, 'update', (who, how, cb)->
        unless who._id == pc._id
          setTimeout -> cb(new Error('not found'))
          return
        pc.loc = how['$set'].loc
        setTimeout -> cb(null, 1)
      stubs.push sinon.stub ss.publish, 'user', (userId, messageId, m)->
        if messageId == 'pcMove' and deepEqual(m.waypoints[0], dst)
          pc.loc.should.deep.equal [dst.lon, dst.lat]
          m.waypoints.should.deep.equal [dst]
          done()
        else if messageId == 'pcPosition' and deepEqual(m, dst)
          loc.should.equal [dst.lon, dst.lat]
          done()
        #else
        #  console.log("received #{messageId} with ", m ," not ", dst)
      ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
        chai.expect(err).to.be.null

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
