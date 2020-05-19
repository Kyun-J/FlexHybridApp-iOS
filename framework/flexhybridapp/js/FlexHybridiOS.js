'use strict';
var lib = `(function() {
const keys = keysfromios;
const script = lib;
const listeners = [];
const logs = { log: console.log, debug: console.debug, error: console.error, info: console.info }
window.$flex = {};
Object.defineProperties($flex,
    {
        version: { value: '0.2.2', writable: false, enumerable: true },
        //addEventListener: { value: function(event, callback) { listeners.push({ e: event, c: callback }) }, writable: false },
        web: { value: {}, writable: false, enumerable: true },
        flex: { value: {}, writable: false, enumerable: false }
    }
);
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
keys.forEach(key => {
    if($flex[key] === undefined) {
        Object.defineProperty($flex, key, {
            value:
            function(...args) {
                return new Promise(resolve => {
                    genFName().then(name => {
                        $flex.flex[name] = (r) => {
                            resolve(r);
                            delete $flex.flex[name];
                        };
                        webkit.messageHandlers[key].postMessage(
                            {
                                funName: name,
                                arguments: args
                            }
                        );
                    });
                });
            },
            writable: false,
            enumerable: true
        });
    }
});
console.log = function(...args) { $flex.flexlog(...args); logs.log(...args); };
console.debug = function(...args) { $flex.flexdebug(...args); logs.debug(...args); };
console.error = function(...args) { $flex.flexerror(...args); logs.error(...args); };
console.info = function(...args) { $flex.flexinfo(...args); logs.info(...args); };
const frames = window.frames;
for(let i = 0 ; i < frames.length; i++) {
    frames[i].Function("var lib=" + script + ";window.Function(lib)(),lib=void 0;")();
}
setTimeout(() => {
    if(typeof window.onFlexLoad === 'function') {
        window.onFlexLoad()
    }
},0)
})();`;
window.Function(lib)();
lib = undefined;
