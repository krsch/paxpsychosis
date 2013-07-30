require('./world');
var ss = require('socketstream').start();
var sinon = require('sinon');
var cache = global.cache = {};
var Pc = require('../server/models/pc');
var User = require('../server/models/user');
var Q = require('q');

describe('talk', function(){
        beforeEach(function(){
                cache.pc = {};
                var self = this;
                var pc = Pc.adopt({_id: 1, userId: 1, loc: [0.02,0.02]});
                this.other = Pc.adopt({_id:2, userId: 1, loc: [0.02, 0.02]});
                this.session = {pc_id:pc._id, userId: 1, save: function(){}};
                this.stub_session = sinon.stub(ss.session, 'find', function(a,b,cb){cb(self.session);});
        });
        afterEach(function(){
                this.stub_session.restore();
        });
        it('should notify about chats', function(done){
                ss.rpc('pc.talk.start chat', this.other._id, wrapRPC(done));
                       // function(err){
                       //  if (err) { done(err); }
                       //  else { done(); }
                // });
        });
});
