!function(e){var o={};function n(r){if(o[r])return o[r].exports;var t=o[r]={i:r,l:!1,exports:{}};return e[r].call(t.exports,t,t.exports,n),t.l=!0,t.exports}n.m=e,n.c=o,n.d=function(e,o,r){n.o(e,o)||Object.defineProperty(e,o,{enumerable:!0,get:r})},n.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},n.t=function(e,o){if(1&o&&(e=n(e)),8&o)return e;if(4&o&&"object"==typeof e&&e&&e.__esModule)return e;var r=Object.create(null);if(n.r(r),Object.defineProperty(r,"default",{enumerable:!0,value:e}),2&o&&"string"!=typeof e)for(var t in e)n.d(r,t,function(o){return e[o]}.bind(null,t));return r},n.n=function(e){var o=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(o,"a",o),o},n.o=function(e,o){return Object.prototype.hasOwnProperty.call(e,o)},n.p="",n(n.s=0)}([function(e,o){!function(){"use strict";const e=keysfromios,o=optionsfromios,n=deviceinfofromios,r=[],t={log:console.log,debug:console.debug,error:console.error,info:console.info},l={timeout:6e4,flexLoadWait:10},i=()=>{const e="f"+Math.random().toString(10).substr(2,8);return void 0===$flex.flex[e]?Promise.resolve(e):Promise.resolve(i())},f=(e,o)=>{r.forEach(n=>{n.e===e&&"function"==typeof n.c&&n.c(o)})},u=(...e)=>{const o=[];return e.forEach(e=>{o.push(String(e))}),o};Object.keys(o).forEach(e=>{("timeout"===e&&"number"==typeof o[e]||"flexLoadWait"===e&&"number"==typeof o[e])&&Object.defineProperty(l,e,{value:o[e],writable:!1,enumerable:!0})}),Object.defineProperty(window,"$flex",{value:{},writable:!1,enumerable:!0}),Object.defineProperties($flex,{version:{value:"0.6.2",writable:!1,enumerable:!0},isAndroid:{value:!1,writable:!1,enumerable:!0},isiOS:{value:!0,writable:!1,enumerable:!0},device:{value:n,writable:!1,enumerable:!0},addEventListener:{value:function(e,o){r.push({e:e,c:o})},writable:!1,enumerable:!0},web:{value:{},writable:!1,enumerable:!0},options:{value:l,writable:!1,enumerable:!0},flex:{value:{},writable:!1,enumerable:!1}}),e.forEach(e=>{void 0===$flex[e]&&Object.defineProperty($flex,e,{value:function(...o){return new Promise((n,r)=>{i().then(t=>{let i;l.timeout>0&&(i=setTimeout(()=>{$flex.flex[t](!1,"timeout error"),f("timeout",{function:e})},l.timeout)),$flex.flex[t]=(o,u,a)=>{if(l.timeout>0&&clearTimeout(i),delete $flex.flex[t],o)n(a);else{let o;o="string"==typeof u?Error(u):Error("$flex Error occurred in function -- $flex."+e),r(o),f("error",{function:e,err:o})}};try{"flexlog"===e||"flexdebug"===e||"flexerror"===e||"flexinfo"===e?webkit.messageHandlers[e].postMessage({funName:t,arguments:u(...o)}):webkit.messageHandlers[e].postMessage({funName:t,arguments:o})}catch(e){$flex.flex[t](!1,e.toString())}})})},writable:!1,enumerable:!1})}),console.log=function(...e){$flex.flexlog(...e),t.log(...e)},console.debug=function(...e){$flex.flexdebug(...e),t.debug(...e)},console.error=function(...e){$flex.flexerror(...e),t.error(...e)},console.info=function(...e){$flex.flexinfo(...e),t.info(...e)},setTimeout(()=>{let e=()=>{};"function"==typeof window.onFlexLoad&&(e=window.onFlexLoad),Object.defineProperty(window,"onFlexLoad",{set:function(e){window._onFlexLoad=e,"function"==typeof e&&Promise.resolve(e()).then(e=>{setTimeout(()=>{$flex.flexload()},l.flexLoadWait)})},get:function(){return window._onFlexLoad}}),window.onFlexLoad=e;const o=e=>{for(let n=0;n<e.frames.length;n++){if(void 0===e.frames[n].$flex){Object.defineProperty(e.frames[n],"$flex",{value:window.$flex,writable:!1,enumerable:!0});let o=void 0;"function"==typeof e.frames[n].onFlexLoad&&(o=e.frames[n].onFlexLoad),Object.defineProperty(e.frames[n],"onFlexLoad",{set:function(e){window.onFlexLoad=e},get:function(){return window._onFlexLoad}}),"function"==typeof o&&(e.frames[n].onFlexLoad=o)}o(e.frames[n])}};o(window)},0)}()}]);