require('../world')
ss = require('socketstream').start()
Dialog = require('../../server/models/dialog')
Question = require('../../server/models/question')
Answer = require('../../server/models/answer')
chai = require('chai')
chai.Assertion.includeStack = true
chai.should()
sinon = require('sinon')
Q = require('q')
_ = require('lodash')

wrapRPC = (done)-> (args)->done.apply(this,args);
describe 'dialog', ->
    beforeEach ->
        @mocks = [];
    afterEach ->
        @mocks.forEach (mock)-> mock.verify();
    describe 'save', ->
        it 'creates single question', (done)->
            questions = [{text: 'nothing', _id: '---fds'}];
            newid = 5;
            @mocks.push mock=sinon.mock(Question);
            mock.expects('create').once().withArgs(text: questions[0].text).yields(null, {_id: newid});
            ss.rpc 'dialog.save', _.cloneDeep(questions), [], wrapRPC (err, map)->
                good_map = {};
                good_map[questions[0]._id] = newid;
                chai.expect(map).to.deep.equal good_map;
                done(err);

        it 'updates single question', (done)->
            questions = [{text: 'nothing', _id: 'fds'}];
            @mocks.push mock=sinon.mock(Question);
            mock.expects('findByIdAndUpdate').once().withArgs(questions[0]._id, text: questions[0].text).yields(null);
            ss.rpc 'dialog.save', _.cloneDeep(questions), [], wrapRPC (err, map)->
                chai.expect(map).to.deep.equal {};
                done(err);
