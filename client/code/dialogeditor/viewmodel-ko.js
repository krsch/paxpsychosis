$(function (){
    var graphjs = require('./graph'),
        graph = graphjs.graph,
        graphics = graphjs.graphics,
        ko = require('knockout'),
        state = require('./state'),
        nodes = state.nodes,
        current_question = state.current_question,
        Question = require('./question'),
        Answer = require('./answer');

    function selectNode(cb) {
        graphjs.selectingNode = true;
        $(document).one('nodeclick', function(evt, mouseevt,node) {
            graphjs.selectingNode = false;
            cb(node);
        });
    }
    ko.applyBindings({question: current_question, add_question: function(){
            var q = new Question(++max_id, '');
            var idx = nodes.push(q);
            current_question_id(idx-1);
    } });
});
