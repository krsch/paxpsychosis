var ko = require('knockout');
var nodes = exports.nodes = ko.observableArray();
var current_question_id = exports.current_question_id  = ko.observable(0),
    current_question = exports.current_question = ko.computed(function() {return nodes()[current_question_id()];});

window.max_id = 2;
var ss = require('socketstream');
var dialog_id =  "50e0c0a406ef29987ee02b66";
ss.rpc('dialog.load', dialog_id, function(err, json) {
    if (err) { console.error(err); }
    console.log(json);
    var Question = require('./question'),
        Answer = require('./answer');
    json.forEach(function(q){
        nodes.push(new Question(q._id, q.text, q._id));
    });
    json.forEach(function(q){
        var question = ko.utils.arrayFirst(nodes(), function(item) {return item.id===q._id;});
        q.answers.forEach(function(ans){
            question.answer(ans.to, ans.text);
        });
    });
});

function save() {
    var json = nodes().map(function (question) {
        return {
            _id: question.oid,
            newid: question.id,
            text: question.text(),
            dialog: dialog_id,
            answers: question.answers().map(function(ans) {
                return {
                    to: ans.to(),
                    text: ans.text()
                };
            })
        };
    });
    ss.rpc('dialog.save', json, function(err,status) {
        if (err) { console.log(err); }
        console.log(status);
    });
}

exports.save = save;
