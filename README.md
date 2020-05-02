
[한국어 README](https://github.com/Kyun-J/FlexHybridApp-iOS/blob/master/README-ko.md)

[Android Version](https://github.com/Kyun-J/FlexHybridApp-Android)

# FlexibleHybrid

FlexibleHybridApp is an iOS and iPadOS framework that provides various convenience functions to develop HybridApp through WKWebView, such as implementing Web-> Native Call as a Promise.

# Add Framework

add to podFile

```
    pod 'FlexHybridApp'
```

*** iOS Deployment Target is 11.0. ***

# JSInterface Return Promise

Unlike the existing WKWebView `userContentController`, interface patterns can be defined similar to functions in the form of closures.
```swift
component.addInterface("FuncName") { (arguments) -> Any? in
    if arguments != nil {
        return arguments![0] as! Int + 1
    } else {
        return nil
    }
}
```
When writing the code as above, the function is created with FuncName on the web, and can be used in the form of Promise as follows.
```js
const t1 = async () => {
    const z = await $flex.FuncName(0); // call Native Function
    console.log('Return by Native with t1 --- ' + z); // z = 1
}
```
# `$flex` Object
`$flex` Object is responsible for the interface between Web <-> Native in the Web of FlexHybrid framework.  
In `$flex`, functions registered as`addInterface(name, action)`in FlexComponent are created, and these functions return Promise.
```swift
//in native
component.addInterface("likeThis") { (arguments) -> Any? in
.....
}
```
```js
// in js
....
const NatieveValue = await $flex.likeThis();
```
If you create a function in `$flex.web`, you can easily call these functions in Native through `evalFlexFunc` of FlexWebView.
```swift
// in native
flexWebView.evalFlexFunc('WebFunction', 'test')
```
When registering a function in `$flex.web`, it must be registered after window.onload is called.  
```js
// in js
window.onload = function() {
    $flex.web.WebFunction = (msg) => { console.log(msg); }
}
```
The `$flex` Object is automatically generated from the html page loaded by FlexWebView.  

## $flex component
#### `window.onFlexLoad()`
> When the `$flex` Object is loaded, only the first one is executed. After this function is executed, add functions in `$flex.web`.

#### `$flex.version`
> Get the version of the framework.

#### `$flex.addEventListener(event, callback)`
> *developing*  
> Add an event listener.

#### `$flex.init()`
> Initialize `$flex` Object.  
> The function, eventListener in `$flex.web` added by the user disappears.  
Interfaces added with FlexComponent.addInterface are retained.

#### `$flex.web`
> If you add a function through the `$flex.web` object argument, you can easily call those functions from Native through `evalFlexFunc`.  
> Add the function after window.onFlexLoad() is called.

# Native Class
## **FlexWebView**
**FlexWebView is based on WKWebView.** FlexWebView requires FlexComponent which includes WKWebViewConfiguration.

#### `FlexWebView(frame: CGRect, configuration: WKWebViewConfiguration)`
> Create FlexWebView. However, the interface added as userContentController in WKWebViewConfiguration cannot be used.

#### `FlexWebView(frame: CGRect, component: FlexComponent)`
> Create FlexWebView. Interfaces added by addInterface of FlexComponent are implemented as functions in `$flex` in the web.

#### `func evalFlexFunc(_ funcName: String)`
#### `func evalFlexFunc(_ funcName: String, prompt: String)`
> Call the function declared in `$flex.web`. When passing a value, only String format can be passed.

#### `func flexInitInPage()`
> Initialize the `$flex` Object in FlexWebView. Same as `$flex.init()`.

#### `component: FlexComponent`
> Retrun the FlexComponent set when creating the FlexWebView

#### `parentViewController: UIViewController?`
> Return ViewController that contains FlexWebView.

#### `configration: WKWebViewConfiguration`
> Returns WKWebViewConfiguration. This is the same object as the configured FlexComponent configration.

## **FlexComponent**
FlexComponent is a required component of FlexWebView and includes WKWebViewConfiguration.
You can add FlexWebView's JS interface through `addInterface` of FlexComponent.
`addInterface` must be set before FlexWebView is created.

#### `func addInterface(_ name: String, _ action: @escaping (_ arguments: Array<Any?>?) -> Any?)`
> Add JS interface of FlexWebView. It is available only before FlexWebView is Init.
> Arguments delivered from the web are delivered in the form of `Array <Any?>` And can be returned to the web with the following data types.
#### ** Int, Double, Float, Character, String, Dictionary<String, Any>, Array\<Any> **
> Int, Double and Float are passed as JS Number, String and Character are passed as JS String.
> Dictionary<String, Any> is an Object of JS, and Array\<Any> is transformed into an Array of JS, and each Any value must be (Int, Double, Float, Character, String, Dictionary<String, Any>, Array\< Any>).
> For example, it works like this:
```swift
// Example...
// in native
component.addInterface("FunctionName") { (arguments) -> Any? in
    if arguments != nil {
        var returnValue: [String:Any] = [:]
        var dictionaryValue: [String:Any] = [:]
        dictionaryValue["subkey1"] = ["dictionaryValue",0.12]
        dictionaryValue["subkey2"] = 1000.100
        returnValue["key1"] = "value1"
        returnValue["key2"] = dictionaryValue
        returnValue["key3"] = ["arrayValue1",arguments![0] as! Int]
        return returnValue
    } else {
        return nil
    }
}
```
```js
...
const example = await $flex.FunctionName(100);
// example is {key1: "value1", key3: ["arrayValue1", 100], key2: {subkey2: 1000.1, subkey1: ["dictionaryValue", 0.12]}}
...
```
> Also, the set Closure operates in the Background.

#### `func setInterface(_ name: String, _ action: @escaping (_ argumentss: Array<Any?>?) -> String?)`
> Reset the Closure of an interface already added with addInterface. 

#### `func addAction(_ name: String, _ action: FlexAction)`
> Add FlexAction class. It is available only before FlexWebView is Init.
> For detailed usage of FlexAction, refer to [FlexAction](#FlexAction).

#### `func getAction(_ name: String) -> FlexAction?`
> Get the FlexAction added by addAction.

#### `func setAction(_ name: String, _ action: FlexAction)`
> Reset the FlexAction added with addAction.

#### `FlexWebView: FlexWebView?`
> Get the assigned FlexWebView. Before FlexWebView is created, it returns nil.

#### `configration: WKWebViewConfiguration`
> Returns WKWebViewConfiguration. This is the same object as the FlexWebView's configration.

## **FlexAction**
FlexAction is a class that can freely control the point when Retrun is given to the Web when called through `$flex`.
```swift
component.addAction("testAction", FlexAction { (this, arguments) -> Void in
    // do Anything....
    var returnValue: [String:Any] = [:]
    var dictionaryValue: [String:Any] = [:]
    dictionaryValue["subkey1"] = ["dictionaryValue",0.12]
    dictionaryValue["subkey2"] = 1000.100
    returnValue["key1"] = "value1"
    returnValue["key2"] = dictionaryValue
    returnValue["key3"] = ["arrayValue1",100]
    // when js function ready to call
    this.onReady = { () -> Void in
        this.PromiseReturn(returnValue) // Promise return at anytime
    }
    // or use like this
    // if this.isReady {
    //    this.PromiseReturn("testSuccess!")
    // }
})
```
#### `FlexAction(_ action: @escaping (_ this: FlexAction, _ arguments: Array<Any?>?) -> Void)`
> Create FlexAction. The generated FlexAction and arguments contain the arguments passed from the web.

#### `FlexAction(_ action: @escaping (_ this: FlexAction, _ arguments: Array<Any?>?) -> Void, _ readyAction: @escaping (() -> Void))`
> Create FlexAction. readyAction is a Closure that tells when `PromiseReturn` can be called.

#### `isReady: Bool`
> True if `PromiseReturn` is callable.

#### `onReady: (() -> Void)?`
> `PromiseReturn` triggers onReady when it can be called.

#### `func PromiseReturn(_ response: Any?)`
> Return return value in the form of Promise to web. If you are not ready to return, nothing will happen.
> Use `isReady: Bool` or`onReady: (()-> Void)?`at a time when it can be called.
> Passable value is the same as Action of FlexComponent.addInterface.
#### ** Int, Double, Float, Character, String, Dictionary<String, Any>, Array\<Any> **

# Todo Next
1. The $flex.web function passes the value to Native
2. Add multiple event points to $flex