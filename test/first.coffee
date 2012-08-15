ss = require('socketstream').start()
pc = require '../server/rpc/pc'
chai = require 'chai'
user = require '../server/models/user'
sinon = require 'sinon'
chai.should()
wrapRPC = (done)-> (args)->done(args...)
global.cache = pc: {}
Pc = require('../server/models/pc')

describe 'login', ->
  login = '12345'
  password = '09876'
  stub = null
  before ->
    stub = sinon.stub(user, 'findOne')
    stub.withArgs({login, password}).yields(null,{ _id: 1 })
    stub.yields(new Error('bad password'))
  after ->
    stub.restore()
  
  it 'should login with good password', (done)->
    ss.rpc 'login.login', login, password, wrapRPC done

  it 'should not login with bad password', (done)->
    ss.rpc 'login.login', login, password+'123', wrapRPC (err)->
      err.should.not.be.null
      done()

describe 'PC', ->
  stub_session = null
  session = null
  beforeEach ->
        session = {pc_id:1, userId: 1, save: ->true}
        cache.pc = {1: new Pc({userId: 1, loc: [0,0], speed: {fly: 0.005}})}
        #cache.pc = {1: {_id: 1, userId: 1, loc: [0,0], speed: {fly: 0.005}}}
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
    stub_update = sinon.stub(Pc, 'update').returns(null).yields(null,1)
    cache.pc[1].updatePos = (ss) -> if @movement then done()
    ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
      stub_update.restore()
      chai.expect(err).to.be.null
      m.waypoints.should.deep.equal [cache.pc[1].loc.toObject(), dst]
      m.speed.should.equal cache.pc[1].speed.fly

  it 'should update position in fly', (done)->
    dst = [0.01,0.01]
    mock = sinon.mock(Pc)
    mock.expects('update').returns(null).yields(null,1)
    stub_publish = sinon.stub ss.publish, 'user', (userId, messageId, m)->
      return unless messageId == 'pcMove'
      stub_publish.restore()
      mock.verify()
      #userId.should.equal 1
      messageId.should.equal 'pcMove'
      debugger
      m.waypoints.should.deep.equal [dst, dst]
      done()
    ss.rpc 'pc.move', 'fly', dst, wrapRPC (err,m)->
      chai.expect(err).to.be.null

  it 'should get pc', (done)->
    delete session.pc_id
    mock = sinon.mock(Pc)
    mock.expects('findOne').yields(null,cache.pc[1]).returns(null)
    ss.rpc 'pc.get', wrapRPC (err,pc)->
      chai.expect(err).to.be.null
      mock.verify()
      pc.should.equal cache.pc[1]
      #session.pc_id.should.equal 1
      done(err)
