"use strict";
$(function(){
        var $el = $('.avatar-bg');
        $el.on('click', function() {
                osm.setView(pc.get('loc'), 15);
        });
});
