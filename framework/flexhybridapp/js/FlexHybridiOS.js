!function(e){var o={};function n(r){if(o[r])return o[r].exports;var t=o[r]={i:r,l:!1,exports:{}};return e[r].call(t.exports,t,t.exports,n),t.l=!0,t.exports}n.m=e,n.c=o,n.d=function(e,o,r){n.o(e,o)||Object.defineProperty(e,o,{enumerable:!0,get:r})},n.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},n.t=function(e,o){if(1&o&&(e=n(e)),8&o)return e;if(4&o&&"object"==typeof e&&e&&e.__esModule)return e;var r=Object.create(null);if(n.r(r),Object.defineProperty(r,"default",{enumerable:!0,value:e}),2&o&&"string"!=typeof e)for(var t in e)n.d(r,t,function(o){return e[o]}.bind(null,t));return r},n.n=function(e){var o=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(o,"a",o),o},n.o=function(e,o){return Object.prototype.hasOwnProperty.call(e,o)},n.p="",n(n.s=0)}([function(e,o){!function(){"use strict";var e=keysfromios,o=optionsfromios,n=deviceinfofromios,r=[],t={log:console.log,debug:console.debug,error:console.error,info:console.info},i={timeout:6e4,flexLoadWait:10},f=function e(){var o="f"+Math.random().toString(10).substr(2,8);return void 0===$flex.flex[o]?Promise.resolve(o):Promise.resolve(e())},l=function(e,o){r.forEach((function(n){n.e===e&&"function"==typeof n.c&&n.c(o)}))},a=function(){for(var e=[],o=arguments.length,n=new Array(o),r=0;r<o;r++)n[r]=arguments[r];return n.forEach((function(o){e.push(String(o))})),e};Object.keys(o).forEach((function(e){("timeout"===e&&"number"==typeof o[e]||"flexLoadWait"===e&&"number"==typeof o[e])&&Object.defineProperty(i,e,{value:o[e],writable:!1,enumerable:!0})})),Object.defineProperty(window,"$flex",{value:{},writable:!1,enumerable:!0}),Object.defineProperties($flex,{version:{value:"0.6.2.8",writable:!1,enumerable:!0},isAndroid:{value:!1,writable:!1,enumerable:!0},isiOS:{value:!0,writable:!1,enumerable:!0},device:{value:n,writable:!1,enumerable:!0},addEventListener:{value:function(e,o){r.push({e:e,c:o})},writable:!1,enumerable:!0},web:{value:{},writable:!1,enumerable:!0},options:{value:i,writable:!1,enumerable:!0},flex:{value:{},writable:!1,enumerable:!1}}),e.forEach((function(e){void 0===$flex[e]&&Object.defineProperty($flex,e,{value:function(){for(var o=arguments.length,n=new Array(o),r=0;r<o;r++)n[r]=arguments[r];return new Promise((function(o,r){f().then((function(t){var f;i.timeout>0&&(f=setTimeout((function(){$flex.flex[t](!1,"timeout error"),l("timeout",{function:e})}),i.timeout)),$flex.flex[t]=function(n,a,u){var c;(i.timeout>0&&clearTimeout(f),delete $flex.flex[t],n)?o(u):(c="string"==typeof a?Error(a):Error("$flex Error occurred in function -- $flex."+e),r(c),l("error",{function:e,err:c}))};try{"flexlog"===e||"flexdebug"===e||"flexerror"===e||"flexinfo"===e?webkit.messageHandlers[e].postMessage({funName:t,arguments:a.apply(void 0,n)}):(n.forEach((function(e,o){"boolean"==typeof e&&(n[o]={thisIsBoolean:e})})),webkit.messageHandlers[e].postMessage({funName:t,arguments:n}))}catch(e){$flex.flex[t](!1,e.toString())}}))}))},writable:!1,enumerable:!1})})),console.log=function(){var e;(e=$flex).flexlog.apply(e,arguments),t.log.apply(t,arguments)},console.debug=function(){var e;(e=$flex).flexdebug.apply(e,arguments),t.debug.apply(t,arguments)},console.error=function(){var e;(e=$flex).flexerror.apply(e,arguments),t.error.apply(t,arguments)},console.info=function(){var e;(e=$flex).flexinfo.apply(e,arguments),t.info.apply(t,arguments)},setTimeout((function(){var e=function(){};"function"==typeof window.onFlexLoad&&(e=window.onFlexLoad),Object.defineProperty(window,"onFlexLoad",{set:function(e){window._onFlexLoad=e,"function"==typeof e&&Promise.resolve(e()).then((function(e){setTimeout((function(){$flex.flexload()}),i.flexLoadWait)}))},get:function(){return window._onFlexLoad}}),window.onFlexLoad=e;!function e(o){for(var n=0;n<o.frames.length;n++){if(void 0===o.frames[n].$flex){Object.defineProperty(o.frames[n],"$flex",{value:window.$flex,writable:!1,enumerable:!0});var r=void 0;"function"==typeof o.frames[n].onFlexLoad&&(r=o.frames[n].onFlexLoad),Object.defineProperty(o.frames[n],"onFlexLoad",{set:function(e){window.onFlexLoad=e},get:function(){return window._onFlexLoad}}),"function"==typeof r&&(o.frames[n].onFlexLoad=r)}e(o.frames[n])}}(window)}),0)}()}]);