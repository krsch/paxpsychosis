// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
function show(obj) {
        var info = obj.get('look');
        if ($('#npcinfo').empty()) { $(document.body).append('<div id="npcinfo"></div>'); }
        var el = $('#npcinfo').dialog();
        el.append(info);
}

module.exports = function look(data) {
        var actions = this.get('actions'),
                self = this,
                action = {
                        id: 'look',
                        name: 'look',
                        self: this,
                        click: function() {
                                if (this.has('look')){
                                        show(this);
                                } else {
                                        ss.rpc('pc.look.start', this.get('_id'));
                                }
                        }
                };
        actions.push(action);
};

ss.event.on('look', function(obj){
        var _ = require('lodash');
        people[obj.id].set('look', obj.look);
        var actions = people[obj.id].get('actions');
        var action = _.where(actions, {id: 'look'});
        action[0].name = 'Observation results';
});
