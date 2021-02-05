(function() {
    "use strict";
    const keys = keysfromios;
    const options = optionsfromios;
    const device = deviceinfofromios;
    const checkBool = checkboolfromios;
    const defineFlex = defineflexfromios;
    const listeners = [];
    const logs = { log: console.log, debug: console.debug, error: console.error, info: console.info };
    const option = {
        timeout: 60000,
        flexLoadWait: 10
    };
    const genFName = () => {
        const name = 'f' + Math.random().toString(10).substr(2,8);
        if($flex.flex[name] === undefined) {
            return Promise.resolve(name);
        } else {
            return Promise.resolve(genFName());
        }
    }
    const triggerEventListener = (name, val) => {
        listeners.forEach(element => {
            if(element.e === name && typeof element.c === 'function') {
                element.c(val);
            }
        });
    }
    const setOptions = () => {
        Object.keys(options).forEach(k => {
            if(k === 'timeout' && typeof options[k] === 'number') {
                Object.defineProperty(option, k, {
                    value: options[k], writable: false, enumerable: true
                });
            } else if(k === 'flexLoadWait' && typeof options[k] === 'number') {
                Object.defineProperty(option, k, {
                    value: options[k], writable: false, enumerable: true
                });
            }
        });
    }
    setOptions();
    const booleanToboolData = function(v) {
        const o = v;
        v = {};
        v[checkBool] = o;
        return v;
    }
    Object.defineProperty(window, "$flex", { value: {}, writable: false, enumerable: true });
    Object.defineProperties($flex,
        {
            version: { value: '0.6.9', writable: false, enumerable: true },
            isAndroid: { value: false, writable: false, enumerable: true },
            isiOS: { value: true, writable: false, enumerable: true },
            device: { value: device, writable: false, enumerable: true },
            addEventListener: { value: function(event, callback) { listeners.push({ e: event, c: callback }) }, writable: false, enumerable: true },
            web: { value: {}, writable: false, enumerable: true },
            options: { value: option, writable: false, enumerable: true },
            flex: { value: {}, writable: false, enumerable: false },
            convertBoolForiOS: { value: function(v) {
                if(typeof v == "boolean") {
                    return booleanToboolData(v);
                } else if(typeof v == "object" && v) {
                    const keys = Object.keys(v);
                    for(let i = 0; i < keys.length; i++) {
                        v[keys[i]] = $flex.convertBoolForiOS(v[keys[i]]);
                    }
                    return v;
                } else {
                    return v;
                }
            }, writable: false, enumerable: false  }
        }
    );
    keys.forEach(key => {
        if($flex[key] === undefined) {
            Object.defineProperty($flex, key, {
                value:
                function(...args) {
                    return new Promise((resolve, reject) => {
                        genFName().then(name => {
                            let counter;
                            if(option.timeout > 0) {
                                counter = setTimeout(() => {
                                    $flex.flex[name](false, "timeout error");
                                    $flex.flexTimeout(key, "timeout error\ntimeout set - " + option.timeout);
                                    triggerEventListener('timeout', { "function" : key });
                                }, option.timeout);
                            }
                            $flex.flex[name] = (j, e, r) => {
                                if(option.timeout > 0) clearTimeout(counter);
                                delete $flex.flex[name];
                                if(j) {
                                    resolve(r);
                                    if(!defineFlex.contains(key)) {
                                        $flex.flexSuccess(key, "flex interface success\nFunction - $flex." + key);
                                    }
                                } else {
                                    let err;
                                    if(typeof e === 'string') err = Error(e);
                                    else err = Error('$flex Error occurred in function -- $flex.' + key);
                                    reject(err);
                                    triggerEventListener('error', {
                                        "function" : key,
                                        "err": err
                                    });
                                    $flex.flexException(key, err);
                                }
                            };
                            try {
                                webkit.messageHandlers[key].postMessage(
                                    {
                                        funName: name,
                                        arguments: $flex.convertBoolForiOS(args)
                                    }
                                );
                            } catch (e) {
                                $flex.flex[name](false, e.toString());
                            }
                        });
                    });
                },
                writable: false,
                enumerable: false
            });
        }
    });
    console.log = function(...args) { $flex.flexlog(...args); logs.log(...args); };
    console.debug = function(...args) { $flex.flexdebug(...args); logs.debug(...args); };
    console.error = function(...args) { $flex.flexerror(...args); logs.error(...args); };
    console.info = function(...args) { $flex.flexinfo(...args); logs.info(...args); };
    setTimeout(() => {
        let f = () => {};
        if(typeof window.onFlexLoad === 'function') {
            f = window.onFlexLoad;
        }
        Object.defineProperty(window, "onFlexLoad", {
            set: function(val){
                window._onFlexLoad = val;
                if(typeof val === 'function') {
                    (function() {
                        return Promise.resolve(val());
                    })().then( _ => {
                        setTimeout(() => { $flex.flexload(); }, option.flexLoadWait);
                    });
                }
            },
            get: function(){
                return window._onFlexLoad;
            }
        });
        window.onFlexLoad = f;
        const evalFrames = (w) => {
            for(let i = 0 ; i < w.frames.length; i++) {
                if(typeof w.frames[i].$flex === 'undefined') {
                    Object.defineProperty(w.frames[i], "$flex", { value: window.$flex, writable: false, enumerable: true });
                    let f = undefined;
                    if(typeof w.frames[i].onFlexLoad === 'function') {
                        f = w.frames[i].onFlexLoad;
                    }
                    Object.defineProperty(w.frames[i], "onFlexLoad", {
                        set: function(val) {
                            window.onFlexLoad = val;
                        },
                        get: function() {
                            return window._onFlexLoad;
                        }
                    });
                    if(typeof f === 'function') {
                        w.frames[i].onFlexLoad = f;
                    }
                }
                evalFrames(w.frames[i]);
            }
        }
        evalFrames(window);
        $flex.flexInit('flexInit', "$flex init on page - "+location.href);
    }, 0);
})();
