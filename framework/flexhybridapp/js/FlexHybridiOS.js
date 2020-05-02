'use strict';
var k = keysfromios;
var lib = `(function() {
const keys = k;
const script = lib;
const listeners = [];
const logs = { log: console.log, debug: console.debug, error: console.error, info: console.info }
window.$flex = {};
Object.defineProperties($flex,
    {
        version: { value: '0.1.3.1', writable: false },
        addEventListener: { value: function(event, callback) { listeners.push({ e: event, c: callback }) }, writable: false },
        init: { value: function() { window.Function(script)(); }, writable: false },
        web: { value: {}, writable: false }
    }
)
const genFName = () => {
    const name = 'f' + Math.random().toString(10).substr(2,8);
    if(window[name] === undefined) {
        return Promise.resolve(name)
    } else {
        return Promise.resolve(genFName())
    }
}
const triggerEventListener = (name, val) => {
    listeners.forEach(element => {
        if(element.e === name && typeof element.c === 'function') {
            element.c(val);
        }
    });
}
JSON.parse(k).forEach(key => {
    if($flex[key] === undefined) {
        $flex[key] =
        function(...args) {
            return new Promise(resolve => {
                genFName().then(name => {
                    window[name] = (r) => {
                        resolve(r);
                        delete window[name];
                    };
                    webkit.messageHandlers[key].postMessage(
                        {
                            funName: name,
                            arguments: args
                        }
                    );
                });
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
    frames[i].Function("var k=" + keys + ",var lib=" + script + ";window.Function(lib)(),k=void 0,lib=void 0;")();
}
setTimeout(() => {
    if(typeof window.onFlexLoad === 'function') {
        window.onFlexLoad()
    }
},0)
})();`;
window.Function(lib)();
k = undefined;
lib = undefined;
