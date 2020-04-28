
[한국어 README](https://github.com/Kyun-J/FlexHybridApp-iOS/blob/master/README-ko.md)

[DEMO](https://github.com/Kyun-J/FlexHybridApp-iOS-DEMO)

[Android Version](https://github.com/Kyun-J/FlexHybridApp-Android)


# FlexibleHybrid

FlexibleHybridApp is a Framework that provides various convenience functions to develop HybridApp, such as implementing Web-> Native Call as a promise.

# Add Framework

add to podFile

```
    pod 'FlexHybridApp'
```

# JSInterface Return Promise

Unlike the existing WKWebView `userContentController`, interface patterns can be defined similar to functions in the form of closures.
```swift
component.addInterface("FuncName") { (property) -> String? in
    if property != nil {
        return String(property![0] as! Int + 1)
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
`$flex` Object is responsible for the interface between Web <-> Native in the Web of FlexHybrid library.  
In `$flex`, functions registered as`addInterface(name, action)`in FlexComponent are created, and these functions return Promise.
```swift
//in native
component.addInterface("likeThis") { (property) -> String? in
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
> Get the version of the library.

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
## **FlexComponent**
FlexComponent is a required component of FlexWebView and includes WKWebViewConfiguration.
You can add FlexWebView's JS interface through `addInterface` of FlexComponent.
`addInterface` must be set before FlexWebView is created.

#### `func addInterface(_ name: String, _ action: @escaping (_ propertys: Array<Any?>?) -> String?)`
> Add JS interface of FlexWebView. It is available only before FlexWebView is Init.
> The parameters passed from the web are passed in the form of `Array<Any?>` And can return a String or nil value.
> The set Closure operates in the Background.

#### `func setInterface(_ name: String, _ action: @escaping (_ propertys: Array<Any?>?) -> String?)`
> Reset the Closure of an interface already added with addInterface. 

#### `func getFlexWebView() -> FlexWebView?`
> Get the assigned FlexWebView. Before FlexWebView is created, it returns nil.

#### `func flexInitInPage()`
> Initialize the `$flex` Object in FlexWebView.
> Same as `$flex.init ()`.

## **FlexWebView**
**FlexWebView is based on WKWebView** FlexComponent including WKWebViewConfiguration is required.

#### `FlexWebView(frame: CGRect, configuration: WKWebViewConfiguration)`
> Create FlexWebView. However, the interface added as userContentController in WKWebViewConfiguration cannot be used.

#### `FlexWebView(frame: CGRect, component: FlexComponent)`
> Create FlexWebView. Interfaces added by addInterface of FlexComponent are implemented as functions in `$flex` in the web.

#### `func evalFlexFunc(_ funcName: String)`
#### `func evalFlexFunc(_ funcName: String, prompt: String)`
> Call the function declared in `$flex.web`. When passing a value, only String format can be passed.

#### `func getComponent() -> FlexComponent`
> Retrun the FlexComponent set when creating the FlexWebView

#### `var parentViewController: UIViewController?`
> Return ViewController that contains FlexWebView.