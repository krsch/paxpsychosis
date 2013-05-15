// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
module.exports = function(data) {
        var actions = this.get('actions'),
                self = this,
                action = {
                        id: 'look',
                        name: 'look',
                        self: this,
                        click: function() {
                                if (this.has('look')){
                                        alert(this.get('look'));
                                } else {
                                        ss.rpc('look.start', this.get('_id'));
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
