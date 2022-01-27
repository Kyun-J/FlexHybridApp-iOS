(function () {
  "use strict";
  if (window.$flex && window.$flex.isScript === false) {
    return;
  }
  const keys = keysfromios;
  const timeouts = timesfromios;
  const options = optionsfromios;
  const device = deviceinfofromios;
  const checkBool = checkboolfromios;
  const defineFlex = defineflexfromios;
  const listeners = [];
  const logs = {
    log: console.log,
    debug: console.debug,
    error: console.error,
    info: console.info,
    warn: console.warn,
  };
  const _option = {
    timeout: 60000,
    flexLoadWait: 10,
  };
  const genFName = () => {
    const name = "f" + String(Math.random()).substr(2, 8);
    if ($flex.flex[name] === undefined) {
      return Promise.resolve(name);
    } else {
      return Promise.resolve(genFName());
    }
  };
  const triggerEventListener = (name, val) => {
    listeners.forEach((element) => {
      if (element.e === name && typeof element.c === "function") {
        element.c(val);
      }
    });
  };
  const setOptions = () => {
    Object.keys(options).forEach((k) => {
      if (k === "timeout" && typeof options[k] === "number") {
        Object.defineProperty(_option, k, {
          value: options[k],
          writable: false,
          enumerable: true,
        });
      } else if (k === "flexLoadWait" && typeof options[k] === "number") {
        Object.defineProperty(_option, k, {
          value: options[k],
          writable: false,
          enumerable: true,
        });
      }
    });
  };
  setOptions();
  const booleanToboolData = function (v) {
    const o = v;
    v = {};
    v[checkBool] = o;
    return v;
  };
  const convertBoolForiOS = function (v) {
    if (typeof v == "boolean") {
      return booleanToboolData(v);
    } else if (typeof v == "object" && v) {
      const keys = Object.keys(v);
      for (let i = 0; i < keys.length; i++) {
        const key = keys[i];
        if (key !== checkBool) {
          v[key] = convertBoolForiOS(v[key]);
        }
      }
      return v;
    } else {
      return v;
    }
  };
  let _preSetWeb = {};
  if (window.$flex && typeof window.$flex.web === "object") {
    _preSetWeb = window.$flex.web;
  }
  Object.defineProperty(window, "$flex", {
    value: {},
    writable: false,
    enumerable: true,
  });
  Object.defineProperties(window.$flex, {
    version: { value: versionFromiOS, writable: false, enumerable: true },
    isAndroid: { value: false, writable: false, enumerable: true },
    isiOS: { value: true, writable: false, enumerable: true },
    isScript: { value: false, writable: false, enumerable: true },
    device: { value: device, writable: false, enumerable: true },
    addEventListener: {
      value: function (event, callback) {
        listeners.push({ e: event, c: callback });
      },
      writable: false,
      enumerable: true,
    },
    web: { value: _preSetWeb, writable: false, enumerable: true },
    options: { value: _option, writable: false, enumerable: true },
    flex: { value: {}, writable: false, enumerable: false },
  });
  keys.forEach((key) => {
    if (window.$flex[key] !== undefined) return;
    Object.defineProperty(window.$flex, key, {
      value: function (...args) {
        return new Promise((resolve, reject) => {
          genFName().then((name) => {
            let counter;
            let wait = 0;
            if (typeof timeouts[key] !== "undefined" && timeouts[key] !== 0) {
              wait = timeouts[key];
            } else if (_option.timeout !== 0) {
              wait = _option.timeout;
            }
            if (wait !== 0) {
              counter = setTimeout(() => {
                window.$flex.flex[name] = () => {
                  delete window.$flex.flex[name];
                  console.error(
                    `Function ${key} was returned after a specified timeout.`
                  );
                };
                setTimeout(() => {
                  delete window.$flex.flex[name];
                }, wait * 10);
                reject("timeout error");
                window.$flex.flexTimeout(key, location.href);
                triggerEventListener("timeout", { function: key });
              }, wait);
            }
            window.$flex.flex[name] = (j, e, r) => {
              delete window.$flex.flex[name];
              if (typeof counter !== "undefined") clearTimeout(counter);
              if (j) {
                resolve(r);
                if (!defineFlex.includes(key)) {
                  window.$flex.flexSuccess(key, location.href, r);
                  triggerEventListener("success", {
                    function: key,
                    data: r,
                  });
                }
              } else {
                let err;
                if (typeof e === "string") err = Error(e);
                else
                  err = Error(
                    "$flex Error occurred in function -- $flex." + key
                  );
                reject(err);
                if (!defineFlex.includes(key)) {
                  window.$flex.flexException(
                    key,
                    location.href,
                    err.toString()
                  );
                  triggerEventListener("error", {
                    function: key,
                    err: err,
                  });
                }
              }
            };
            try {
              webkit.messageHandlers[key].postMessage({
                funName: name,
                arguments: convertBoolForiOS(args),
              });
            } catch (e) {
              window.$flex.flex[name](false, e.toString());
            }
          });
        });
      },
      writable: false,
      enumerable: false,
    });
  });
  console.log = function (...args) {
    window.$flex.flexlog(...args);
    logs.log(...args);
  };
  console.debug = function (...args) {
    window.$flex.flexdebug(...args);
    logs.debug(...args);
  };
  console.error = function (...args) {
    window.$flex.flexerror(...args);
    logs.error(...args);
  };
  console.info = function (...args) {
    window.$flex.flexinfo(...args);
    logs.info(...args);
  };
  console.warn = function (...args) {
    window.$flex.flexwarn(...args);
    logs.warn(...args);
  };
  setTimeout(() => {
    let f = () => {};
    if (typeof window.onFlexLoad === "function") {
      f = window.onFlexLoad;
    }
    Object.defineProperty(window, "onFlexLoad", {
      set: function (val) {
        window._onFlexLoad = val;
        if (typeof val === "function") {
          (function () {
            return Promise.resolve(val());
          })().then((_) => {
            setTimeout(() => {
              window.$flex.flexload();
            }, _option.flexLoadWait);
          });
        }
      },
      get: function () {
        return window._onFlexLoad;
      },
    });
    const evalFrames = (w) => {
      for (let i = 0; i < w.frames.length; i++) {
        const fw = w.frames[i];
        if (typeof fw.$flex === "undefined") {
          Object.defineProperty(fw, "$flex", {
            value: window.$flex,
            writable: false,
            enumerable: true,
          });
          const logs = {
            log: fw.console.log,
            debug: fw.console.debug,
            error: fw.console.error,
            info: fw.console.info,
            warn: fw.console.warn,
          };
          fw.console.log = function (...args) {
            fw.$flex.flexlog(...args);
            logs.log(...args);
          };
          fw.console.debug = function (...args) {
            fw.$flex.flexdebug(...args);
            logs.debug(...args);
          };
          fw.console.error = function (...args) {
            fw.$flex.flexerror(...args);
            logs.error(...args);
          };
          fw.console.info = function (...args) {
            fw.$flex.flexinfo(...args);
            logs.info(...args);
          };
          fw.console.warn = function (...args) {
            fw.$flex.flexwarn(...args);
            logs.warn(...args);
          };
          let f = () => {};
          if (typeof fw.onFlexLoad === "function") {
            f = fw.onFlexLoad;
          }
          Object.defineProperty(fw, "onFlexLoad", {
            set: function (val) {
              fw._onFlexLoad = val;
              if (typeof val === "function") {
                val();
              }
            },
            get: function () {
              return fw._onFlexLoad;
            },
          });
          fw.onFlexLoad = f;
        }
        evalFrames(fw);
      }
    };
    window.onFlexLoad = f;
    evalFrames(window);
    window.$flex.flexInit("INIT", location.href);
  }, 0);
})();
