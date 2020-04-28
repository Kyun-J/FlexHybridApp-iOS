'use strict';
let k = keysfromios;
let lib = `(function() {
const keys = k;
const script = lib;
const events = [];
const logs = { log: console.log, debug: console.debug, error: console.error, info: console.info }
window.$flex = {};
Object.defineProperties($flex,
    {
        version: { value: '0.1.2.2', writable: false },
        addEventListener: { value: function(event, callback) { events.push({ e: event, c: callback }) }, writable: false },
        init: { value: function() { window.Function(script)(); }, writable: false },
        web: { value: {}, writable: false }
    }
)
JSON.parse(k).forEach(key => {
    if($flex.key === undefined) {
        $flex[key] =
        function(...args) {
            return new Promise(resolve => {
                const name = 'f' + Math.random().toString(10).substr(2,8);
                window[name] = (r) => {
                    resolve(r);
                    window[name] = undefined;
                };
                webkit.messageHandlers[key].postMessage(
                    {
                        funName: name,
                        arguments: args
                    }
                );
            });
        }
    }
});
console.log = function(...args) { $flex.flexlog(...args); logs.log(...args); };
console.debug = function(...args) { $flex.flexdebug(...args); logs.debug(...args); };
console.error = function(...args) { $flex.flexerror(...args); logs.error(...args); };
console.info = function(...args) { $flex.flexinfo(...args); logs.info(...args); };
const frames = window.frames;
for(let i = 0 ; i < frames.length; i++) {
    frames[i].Function("let k=" + keys + ",lib=" + script + ";window.Function(lib)(),k=void 0,lib=void 0;")();
}
})();`;
window.Function(lib)();
k = undefined;
lib = undefined;
