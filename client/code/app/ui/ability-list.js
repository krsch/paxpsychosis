"use strict";

$('#human-button').click(function(){
        var $el = $('#ability-list');
        if ($el.length === 0) {
                $el = $(ss.tmpl['ability-list'].r()).appendTo(document.body);
                $el.draggable();
                $el.on('click', '.close', function(){ $el.remove(); });
        }
        // $el.dialog();
});
