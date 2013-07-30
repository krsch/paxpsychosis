"use strict";
module.exports = function confirmation(text, buttons, cb) {
        var html = '';
        var b;
        for (b in buttons) { html += '<button name="' + b + '">' + buttons[b] + '</button>'; }
        var $el = $('<div class="confirmation">'+text + html +'</div>').dialog();
        $el.on('click', 'button', function (ev) { cb(null, this.name); } );
};
