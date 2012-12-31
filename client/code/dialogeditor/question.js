var graphjs = require('./graph'),
    graph = graphjs.graph,
    graphics = graphjs.graphics,
    ko = require('knockout'),
    _ = require('lodash'),
    state = require('./state'),
    nodes = state.nodes,
    current_question = state.current_question,
    Answer;

function mousemove(node, text) {
    var tooltip;
    $(node.ui).hover(function(){
        var x = node.ui.getAttribute('cx')-5,
            y = node.ui.getAttribute('cy')+5;
        tooltip = Viva.Graph.svg('g').attr('transform', 'translate(' + x + ' ' + y + ')').attr('class', 'tooltip');
        tooltip.append('polygon')
            .attr('points', '10,10 240,10 240,100 135,100 125,120 115,100 10,100')
            .attr('fill', "#EFF5FF")
            .attr('transform', 'translate(-120 -120)');
        tooltip.append('text').text( text() )
            .attr('y', -60);
        var container = graphics.getSvgRoot().children[0];
        container.append(tooltip);
    }, function(){
        $(tooltip).remove();
    });
}
var Question = module.exports = function(id, text, original_id) {
    if (original_id) { this.oid = original_id; }
    this.id = id;
    var oText = this.text = ko.observable(text);
    var node = graph.addNode(id),
        self = this;
    var answers = this.answers = ko.observableArray();
    mousemove(node, oText);

    this.answer = function(to, text) {
        answers.push(new Answer(id, to, text));
    };
    this.del = function(answer) {
        self.answers.remove(answer);
        answer.remove();
    };
    this.classes = ko.computed(function(){
        var classes = 'node ';
        if (current_question() === undefined) {
            return classes;
        }
        var cq = current_question();
        if (this === cq) { classes = classes + 'active '; }
        if (_.some(this.answers(), function(ans) {
            return (ans.to() === cq.id); 
        }) ) { classes = classes + 'to_active '; }
        node.ui.attr('class', classes);
        return classes;
    }, this);
};

Question.prototype.addAnswer = function() {
    this.answer(this, '');
};

Answer = require('./answer');
