var graphjs = require('./graph'),
    graph = graphjs.graph,
    graphics = graphjs.graph,
    ko = require('knockout');

var Answer = module.exports = function(question, go_to, text){
    this.question = question;
    this.to = ko.observable(go_to.id);
    this.text = ko.observable(text);
    graph.addLink(question, go_to.id);
    var old_to = go_to.id;
    this.update = ko.computed(function(){
        graph.removeLink( graph.hasLink(this.question, old_to) );
        var link = graph.addLink(this.question, this.to());
        old_to = this.to();
        return link;
    }, this);
};
Answer.prototype.point = function() {
    var self = this;
    selectNode(function(node) {
        self.to( node.id );
    });
};
Answer.prototype.addQuestion = function() {
    var Question = require('./question');
    var state = require('./state');
    var q = new Question(++max_id, '');
    state.nodes.push(q);
    this.to(q.id);
};
Answer.prototype.remove = function() {
    graph.removeLink( graph.hasLink(this.question, this.to()) );
};

