
[한국어 README](https://github.com/Kyun-J/FlexHybridApp-iOS/blob/master/README-ko.md)

[DEMO](https://github.com/Kyun-J/FlexHybridApp-iOS-DEMO)

[Android Version](https://github.com/Kyun-J/FlexHybridApp-Android)


# FlexibleHybrid

FlexHybridApp is the Framework that provides various convenience functions to develop HybridApp, such as implementing Web-> Native Call as a promise.

# Add Framework

add to podFile

```
    pod 'FlexHybridApp'
```

# JSInterface Return Promise

Unlike the existing WKWebView `userContentController`, interface patterns can be defined similar to functions in the form of closures.
```swift
component.addInterface("FuncName") { (arguments) -> String? in
    if arguments != nil {
        return String(arguments![0] as! Int + 1)
    } else {
        return "novalue"
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
component.addInterface("likeThis") { (arguments) -> String? in
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
#### `$flex.version`
> Get the version of the framework.

#### `$flex.addEventListener(event, callback)`
> *developing*  
> Add an event listener.

#### `$flex.init()`
> Initialize $ flex Object.  
> The function, eventListener in $ flex.web added by the user disappears.  
Interfaces added with FlexComponent.addInterface are retained.

#### `$flex.web`
> If you add a function through the `$flex.web` object argument, you can easily call those functions from Native through `evalFlexFunc`.

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

### `configration: WKWebViewConfiguration`
> Returns WKWebViewConfiguration. This is the same object as the configured FlexComponent configration.

## **FlexComponent**
FlexComponent is a required component of FlexWebView and includes WKWebViewConfiguration.
You can add FlexWebView's JS interface through `addInterface` of FlexComponent.
`addInterface` must be set before FlexWebView is created.

#### `func addInterface(_ name: String, _ action: @escaping (_ argumentss: Array<Any?>?) -> String?)`
```swift
component.addInterface("FunctionName") { (arguments) -> String? in
    if arguments != nil {
        return String(arguments![0] as! Int + 1)
    } else {
        return nil
    }
}
```
> Add JS interface of FlexWebView. It is available only before FlexWebView is Init.
> The parameters passed from the web are passed in the form of `Array<Any?>` And can return a String or nil value.
> The set Closure operates in the Background.

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

### `configration: WKWebViewConfiguration`
> Returns WKWebViewConfiguration. This is the same object as the FlexWebView's configration.

## **FlexAction**
FlexAction is a class that can freely control the point when Retrun is given to the Web when called through `$flex`.
```swift
component.addAction("testAction", FlexAction { (this, arguments) -> Void in
    // do Anything....
    // when js function ready to call
    this.onReady = { () -> Void in
        this.PromiseReturn("testSuccess!") // Promise return at anytime
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

#### `func PromiseReturn(_ response: String?)`
> Return value in the form of Promise to web. If FlexAction is not ready to return, nothing will happen.  
> Use `isReady: Bool` or `onReady: (()-> Void)?` to check if `PromiseReturn` is callable.

# Todo Next
1. When return value is returned to web, basic data type, Array, and Dictionary value are transmitted.