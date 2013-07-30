ss = require('socketstream').start()
pc = require '../server/rpc/pc/pc'
chai = require 'chai'
user = require '../server/models/user'
sinon = require 'sinon'
chai.should()
wrapRPC = (done)-> (args)->done(args...)
global.cache = pc: {}

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
  afterEach (done)->
    ss.rpc 'login.logout', wrapRPC done
  
  it 'should login with good password', (done)->
    ss.rpc 'login.login', login, password, wrapRPC ->
      ss.rpc 'login.isLoggedin', wrapRPC (err, ok)->
        ok.should.be.ok unless err
        done(err)

  it 'should not login with bad password', (done)->
    ss.rpc 'login.login', login, password+'123', wrapRPC (err)->
      err.should.not.be.null
      ss.rpc 'login.isLoggedin', wrapRPC (err, ok)->
        ok.should.be.not.ok if ok
        done(err)

