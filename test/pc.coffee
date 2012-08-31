ss = require('socketstream').start()
pc = require '../server/rpc/pc'
chai = require 'chai'
user = require '../server/models/user'
sinon = require 'sinon'
deepEqual = require('deep-equal')
chai.should()
wrapRPC = (done)-> (args)->done(args...)
global.cache = pc: {}
Pc = require('../server/models/pc').model

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
    stubs = []
    beforeEach ->
          pc = new Pc({userId: 1, loc: [0,0], speed: {fly: 0.005}})
          cache.pc[pc._id] = pc
          session = {pc_id:pc._id, userId: 1, save: ->true}
          stubs = []
          #cache.pc = {1: {_id: 1, userId: 1, loc: [0,0], speed: {fly: 0.005}}}
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
      dst = [0.01,0.01]
      stubs.push sinon.stub(Pc, 'update').returns(null).yields(null,1)
      cache.pc[session.pc_id].updatePos = (ss) -> if @movement then done()
      ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
        chai.expect(err).to.be.null
        m.waypoints.should.deep.equal [cache.pc[session.pc_id].loc.toObject(), dst]
        m.speed.should.equal cache.pc[session.pc_id].speed.fly

    it 'should update position in fly', (done)->
      dst = [0.01,0.01]
      mock = sinon.mock(Pc)
      mock.expects('update').returns(null).yields(null,1)
      stubs.push sinon.stub ss.publish, 'user', (userId, messageId, m)->
        if messageId == 'pcMove' and arrayEqual(m.waypoints[0], dst)
          mock.verify()
          m.waypoints.should.deep.equal [dst]
          done()
        else if messageId == 'pcPosition' and arrayEqual(m, dst)
          mock.verify()
          #m.should.deep.equal dst
          done()
        else
          debugger
          console.log("received #{messageId} with #{m.length} #{m} not #{dst}")
      ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
        chai.expect(err).to.be.null

    it 'should get pc', (done)->
      pc_id = session.pc_id
      delete session.pc_id
      mock = sinon.mock(Pc)
      mock.expects('findOne').yields(null,cache.pc[pc_id]).returns(null)
      ss.rpc 'pc.get', wrapRPC (err,pc)->
        chai.expect(err).to.be.null
        mock.verify()
        pc.should.equal cache.pc[pc_id]
        #session.pc_id.should.equal 1
        done(err)
  describe 'look around', ->
    beforeEach ->
      cache.pc = {1: {}, 2: {}}
