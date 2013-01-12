var ss = require('socketstream');
ss.rpc('dialog.list', function(err, dialogs){
    jQuery(function(){
        var list = $('#dialog-list');
        dialogs.forEach(function(dialog) {
            list.append(
                '<option value="' + dialog._id + '">'+dialog.title+'</option>'
            );
        });
        list.change(function (){
            var id = list.val();
            var state = require('./state');
            state.load(id);
        });
        list.change();
    }); 
});
$(function(){
    var graph = require('./graph'),
        vm = require('./viewmodel-ko');
});
