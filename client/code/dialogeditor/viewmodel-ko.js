var graphjs = require('./graph'),
    graph = graphjs.graph,
    graphics = graphjs.graphics,
    ko = require('knockout'),
    state = require('./state'),
    nodes = state.nodes,
    current_question = state.current_question,
    Question = require('./question'),
    Answer = require('./answer');

ko.applyBindings({
    question: current_question, 
    add_question: function(){
        var q = new Question('---' + (++max_id), '');
        var idx = nodes.push(q);
        current_question_id(idx-1);
    }, 
    save: state.save,
    create_dialog: state.create
});
