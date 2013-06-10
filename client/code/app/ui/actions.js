// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

module.exports = function(obj) {
        var popup = L.popup().setLatLng(obj.get('loc')),
                actions = obj.get('actions');
        var html = JT['jade-actions']({actions: actions});
        popup.setContent(html).openOn(osm);
        actions.forEach(function(act) {
                $('#actions .' + act.id + ' a').on('click', act.click.bind(act.self));
        }, this);
};
