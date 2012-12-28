var ko = require('knockout');
var nodes = exports.nodes = ko.observableArray();
var current_question_id = exports.current_question_id  = ko.observable(0),
    current_question = exports.current_question = ko.computed(function() {return nodes()[current_question_id()];});

window.max_id = 2;
var Question = require('./question');
var q1 = new Question(1, 'First'), q2 = new Question(2, 'Second');
q1.answer(q2, 'right answer');
q1.answer(q1, 'wrong answer');
nodes.push(q1);
nodes.push(q2);
