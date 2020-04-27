'use strict';
let k = keysfromios;
let lib = `(function() {
const keys = k;
const script = lib;
const events = [];
window.$flex = {};
Object.defineProperties($flex,
    {
        version: { value: '0.1.2', writable: false },
        addEventListener: { value: function(event, callback) { events.push({ e: event, c: callback }) }, writable: false },
        init: { value: function() { window.Function(script)(); }, writable: false },
        web: { value: {}, writable: false }
    }
)
const originW = webkit.messageHandlers;
webkit.messageHandlers = undefined;
JSON.parse(k).forEach(key => {
    $flex[key] =
    function(...args) {
        return new Promise(resolve => {
            const name = 'f' + Math.random().toString(10).substr(2,8);
            window[name] = (r) => {
                resolve(r);
                window[name] = undefined;
            };
            originW[key].postMessage(
                {
                    funName: name,
                    property: args
                }
            );
        });
    }
});
const frames = window.frames;
for(let i = 0 ; i < frames.length; i++) {
    frames[i].Function("let k=" + keys + ",lib=" + script + ";window.Function(lib)(),k=void 0,lib=void 0;")();
}
})();`;
window.Function(lib)();
k = undefined;
lib = undefined;
