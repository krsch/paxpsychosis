var graph = exports.graph = Viva.Graph.graph(),
    graphics = exports.graphics = Viva.Graph.View.svgGraphics(),
    ko = require('knockout'),
    selectingNode = exports.selectingNode = false,
    nodes, current_question_id;

graphics.node(function(node) {
    var ui = Viva.Graph.svg('circle').attr('class', 'node')
          .attr('r', 7);
    
    $(ui).mousedown(function(e){
        var nx = node.position.x,
            ny = node.position.y,
            ex = e.clientX,
            ey = e.clientY,
            dx = nx-ex,
            dy = ny-ey,
            elem = $(ui);
        function move(e) {
            graphics.updateNodePosition(node.ui, {x: e.clientX+dx, y: e.clientY+dy});
        }
        function up(e) {
            $(document).off('mousemove', move);
            $(document).off('mouseup', up);
        }
        $(document).mousemove(move);
        $(document).mouseup(up);
    }).click(function(e) {
        if (!selectingNode) {
            var match = ko.utils.arrayFirst(nodes(), function(item) {
                return node.id === item.id;
            });
            current_question_id(nodes.indexOf(match)); 
        }
        $(document).trigger('nodeclick', [e, node]);
    });
    return ui;
}).placeNode(function(nodeUI, pos) {
    nodeUI.attr('cx', pos.x).attr('cy', pos.y);
}); 
graphics.link(function(link){
    return Viva.Graph.svg('line').attr('class', 'link');
});

var renderer = Viva.Graph.View.renderer(graph,{graphics: graphics, container: document.getElementById("graph")});
renderer.run();

// Rendering arrow shape is achieved by using SVG markers, part of the SVG  
// standard: http://www.w3.org/TR/SVG/painting.html#Markers
var createMarker = function(id) {
        return Viva.Graph.svg('marker')
                   .attr('id', id)
                   .attr('viewBox', "0 0 10 10")
                   .attr('refX', "10")
                   .attr('refY', "5")
                   .attr('markerUnits', "strokeWidth")
                   .attr('markerWidth', "10")
                   .attr('markerHeight', "5")
                   .attr('orient', "auto");
    },
    marker = createMarker('Triangle');
marker.append('path').attr('d', 'M 0 0 L 10 5 L 0 10 z');

// Marker should be defined only once in <defs> child element of root <svg> element:
var defs = graphics.getSvgRoot().append('defs');
defs.append(marker);
state = require('./state');
nodes = state.nodes;
current_question_id = state.current_question_id;
