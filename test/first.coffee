ss = require('socketstream').start()
pc = require '../server/rpc/pc'
chai = require 'chai'
user = require '../server/models/user'
sinon = require 'sinon'
chai.should()
wrapRPC = (done)-> ([args])->done(args)
global.cache = pc: {}

describe 'login', ->
  login = '12345'
  password = '09876'
  stub = sinon.stub(user, 'findOne')
  stub.withArgs({login, password}).yields(null,{ _id: 1 })
  stub.throws
  
  it 'should login with good password', (done)->
    ss.rpc 'login.login', login, password, wrapRPC done

describe 'PC', ->
  before ->
    #stub_user = sinon.stub(user, 'findOne').yields(null,{_id:1})
    #stub_pc = sinon.stub(require('../server/models/pc'), 'findOne').yields(null, {_id:1})
    stub_session = sinon.stub(ss.session, 'find').yields {userId: 1, pc_id: 1}
    cache.pc = {1: {loc: [0,0]}}

  it 'should not move by magic', (done)->
    ss.rpc 'pc.move', 'magic', [0, 0], wrapRPC (err, m)->
        err.should.not.be.null
        done()
