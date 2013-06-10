var ko = require('knockout');
var _ = require('lodash');
var nodes = exports.nodes = ko.observableArray();
var current_question_id = exports.current_question_id  = ko.observable(0),
    current_question = exports.current_question = ko.computed(function() {return nodes()[current_question_id()];});
var current_dialog;

window.max_id = 2;
var ss = require('socketstream');
var nodemap = exports.nodemap = ko.computed(function(){
    var res = {};
    nodes().forEach(function(q){ res[q.id] = q; });
    return res;
});
exports.load = function(dialog_id) {
    ss.rpc('admin.dialog.load', dialog_id, function(err, questions, answers) {
        if (err) { console.error(err); }
        console.log(questions);
        current_dialog = dialog_id;
        var Question = require('./question'),
            Answer = require('./answer');
        nodes.removeAll();
        var graph = require('./graph');
        graph.graph.clear();
        questions.forEach(function(q){
            nodes.push(new Question(q._id, q.text));
        });
        answers.forEach(function(ans){
            nodemap()[ans.from].answer(ans.to, ans.text, ans._id);
        });
    });
};
// exports.load(dialog_id);

function save() {
    var questions = nodes().map(function (question) {
        return {
            _id: question.id,
            text: question.text(),
            dialog: current_dialog
        };
    });
    var answers = _.flatten(nodes().map(function (question) {
        return question.answers().map(function (ans){
            return {
                _id: ans.id,
                from: question.id,
                to: ans.to(),
                text: ans.text(),
                dialog: current_dialog
            };
        });
    }), true);

    ss.rpc('admin.dialog.save', questions, answers, function(err,idmap) {
        if (err) { console.log(err); }
        console.log(status);
        nodes().forEach(function(q) {
            if (q.id in idmap) { q.id = idmap[q.id]; }
            q.answers().forEach(function(ans) {
                if (ans.id in idmap) { ans.id = idmap[ans.id]; }
                if (ans.question in idmap) { ans.question = idmap[ans.question]; }
                if (ans.to in idmap) { ans.to(idmap[ans.to]); }
            });
        });
    });
}

exports.save = save;

exports.create = function (){
    var title = window.prompt('Enter new dialog title', 'new dialog');
    ss.rpc('admin.dialog.create', title, function(err,id){
        if (err) { console.error(err); return;}
        var $el = $('#dialog-list');
        $el.append(
            '<option value="' + id + '">'+title+'</option>'
        );
        $el.val(id);
        $el.change();
    });
};
