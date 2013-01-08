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

    it 'works for complicated cases', (done)->
      questions = [
        {_id: 'fds', text: 'nothing'}
        {_id: '---ghs', text: 'something'}
      ];
      answers = [
        {_id: '---1', from: '---ghs', to: '---ghs', text: '1'}
        {_id: '2', from: '---ghs', to: 'fds', text: '2'}
        {_id: '---3', from: 'fds', to: '---ghs', text: '3'}
        {_id: '4', from: 'fds', to: 'fds', text: '4'}
      ];
      @mocks.push mock=sinon.mock(Question);
      newid = '5';
      mock.expects('create').once()
        .withArgs(text: questions[1].text)
        .yields(null, {_id: newid});
      mock.expects('findByIdAndUpdate').once()
        .withArgs(questions[0]._id, text: questions[0].text)
        .yields(null);

      @mocks.push ans=sinon.mock(Answer);
      ans.expects('create')
        .withArgs(from: newid, to: newid, text: answers[0].text)
        .once().yields(null, {_id: '1'});
      ans.expects('create')
        .withArgs(from: questions[0]._id, to: newid, text: answers[2].text)
        .once().yields(null, {_id: '3'});
      ans.expects('findByIdAndUpdate')
        .withArgs('2', from: newid, to: questions[0]._id, text: answers[1].text)
        .once().yields(null);
      ans.expects('findByIdAndUpdate')
        .withArgs('4', from: questions[0]._id, to: questions[0]._id, text: answers[3].text)
        .once().yields(null);
      ss.rpc 'dialog.save', _.cloneDeep(questions), _.cloneDeep(answers), wrapRPC (err, map)->
        good_map = {};
        good_map[questions[1]._id] = newid;
        good_map[answers[0]._id] = '1';
        good_map[answers[2]._id] = '3';
        chai.expect(map).to.deep.equal good_map unless err;
        done(err);
