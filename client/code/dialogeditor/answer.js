var graphjs = require('./graph'),
    graph = graphjs.graph,
    graphics = graphjs.graph,
    ko = require('knockout');

var Answer = module.exports = function(question, go_to, text){
    this.question = question;
    var Question = require('./question');
    if (go_to instanceof Question) { go_to = go_to.id; }
    this.to = ko.observable(go_to);
    this.text = ko.observable(text);
    graph.addLink(question, go_to);
    var old_to = go_to;
    this.update = ko.computed(function(){
        graph.removeLink( graph.hasLink(this.question, old_to) );
        var link = graph.addLink(this.question, this.to());
        old_to = this.to();
        return link;
    }, this);
};

function selectNode(cb) {
    graphjs.selectingNode = true;
    $(document).one('nodeclick', function(evt, mouseevt,node) {
        graphjs.selectingNode = false;
        cb(node);
    });
}
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

