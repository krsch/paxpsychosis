// Generated by CoffeeScript 1.3.3
"use strict";
(function(w){
        if (w.performance && w.performance.now) { return; }
        var perfNow;
        var perfNowNames = ['now', 'webkitNow', 'msNow', 'mozNow'];
        if(!!w['performance']) for(var i = 0; i < perfNowNames.length; ++i) {
                var n = perfNowNames[i];
                if(!!w['performance'][n])
                        {
                                perfNow = function(){return w['performance'][n]()};
                                break;
                        }
        }
        if(!perfNow) {
                perfNow = Date.now;
        }
        if (!w.performance) { w.performance = {}; }
        w.performance.now = perfNow;
})(window);
(function() {
    var lastTime = 0;
    var vendors = ['ms', 'moz', 'webkit', 'o'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelRequestAnimationFrame = window[vendors[x]+
          'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = performance.now();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); }, 
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };

    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}())
window.swap = function(f, a, b) {
        return f(b, a);
};
