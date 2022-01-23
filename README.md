[한국어 README](https://github.com/Kyun-J/FlexHybridApp-iOS/blob/master/README-ko.md)

[Android Version](https://github.com/Kyun-J/FlexHybridApp-Android)

[Typescript Support](https://github.com/Kyun-J/FlexHybridApp-Script)

# FlexibleHybrid

FlexHybrid simplifies the interface between WKWebView and Native, including asynchronous processing.  
And it offers several convenient features to use WKWebView.

# How to add Framework

Add in Podfile

```
  pod 'FlexHybridApp'
```

***iOS Deployment Target is 10.0**  

# Key Features

1. It has similar development rules and functions to the [Android version](https://github.com/Kyun-J/FlexHybridApp-Android).
2. The interface between wkwebview and native works asynchronously.
   1. Call and return **Promise** on the Web.
   2. Native operates on a separate **Concurrent Queue**.
3. Define the operation of the interface using **Swift Closure**.
4. Data can be transferred to **Model Object**.
5. By specifying an Url capable of interface operation, you can prevent **Native calls from unwanted sites**.

and include other features...


## FlexComponent

To utilize the features of FlexWebView, you must use FlexComponent.  
FlexComponent is created with FlexWebView, and you can also set it up when you declare FlexWebView.  
FlexComponent also includes the WKWebViewConfiguration of the WebView as a factor.

# Interface Basic Usage

Basically, the interface can be registered and used in the following pattern.  
All interfaces operate asynchronously.  
On the Web, it becomes **pending state** until a response occurs.

## Web-to-native

### Interface registration

The interface must be set before the page is loaded into FlexWebView.

```swift
// in swift
var component = FlexComponent()
component.setInterface("funcName") { args in
    return "received from web - \(args[0]?.toString() ?? "no value"), return to web - \(100)"
}
var flexWebView = FlexWebView(frame: self.view.frame, component: component)
flexWebView.load(someUrl)
```

### Using interface.

```js
// in js
const test = async (req) => {
  const res = await $flex.funcName(req);
  console.log(res); // received from web - 200, return to web - 100
};
test(200);
```

## Native-to-web

### Interface registration

1. When apply [FlexHybridApp-Script](https://github.com/Kyun-J/FlexHybridApp-Scripts)

```js
// in js
$flex.web.funcName = async (req) => {
  return await new Promise((resolve) => {
    setTimeout(() => resolve(`received from web - ${req}`), 100);
  });
};
```

2. Not apply

After checking the load of the \$flex object through the `window.onFlexLoad` function, register the interface.

```js
// in js
window.onFlexLoad = () => {
  $flex.web.funcName = async (req) => {
    return await new Promise((resolve) => {
      setTimeout(() => resolve(`received from web - ${req}`), 100);
    });
  };
};
```

### Using interface.

```swift
// in swift
component.evalFlexFunc("funcName", "sendData") { response in
    print(response.toString()!) // received from web - sendData
}
```

# Interface Advanced Usage

## FlexData

Data received from the Web is converted into FlexData objects for type-safe use.  
Upon web-to-native interface, Arguments delivered from a function in Web are forwarded to Array\<FlexData\>.

```js
// in js
$flex.funcName("test1", 2, 3.1, true, [0, 1, 2], { test: "object" });
```

```swift
component.setInterface("funcName") { args in
    if (args == nil) return

    val first = args[0].asString() // "test"
    val second = args[1].asInt() // 2
    val third = args[2].asDouble() // 3.1
    val fourth = args[3].asBoolean() // true
    val fifth = args[4].asArray() // array of 0, 1, 2
    val sixth = args[5].asMap() // map of first key - test, value - "object"

    val argsArray: Array<FlexData> = args.toArray()
    val argsList: List<FlexData> = args.toList()
}
```

## Model Obejct

Data to be used for interfaces can be used as Model Obejct.  
At this time, the following rules apply.

1. Model Objects must **inherit Codable**.
2. In the Web, it is converted into an object form.
3. When receiving Model Objects from Native as Arguments, you must deliver only one object corresponding to that model on the Web.


```swift
// in swift
struct TestModel: Codable {
  var name: String
  var data2: TestModel2
}

struct TestModel2: Codable {
  var testInt: Int
}

struct ArgsTestModel: Codable {
  var testModel: TestModel
}

component.setInterface("modelTest") { args in
    return TestModel("test", TestModel2(2000))
}

component.setInterface("modelArgsTest") { (req: ArgsTestModel?) -> Void in
    print(req?.testModel.data2.testInt) // 2000
}
```

```js
// in js
const test = async () => {
  const model = await $flex.modelTest(); // model is { name: 'test', data2: { testInt: 2000 } }
  await $flex.modelArgsTest({ testModel: model });
};
test();
```

## Action inteface

On the web-to-native interface, in a code other than the specified closure code block, It's a way to return the value.  
Action objects allow you to return values from the code at the desired location.  
At this time, the Web is in **pending** state until a response occurs.  
Also, action objects that have responded once cannot be used again.

```swift
var mAction: FlexAction? = null

struct LocationResult: Codable {
  var latitude: Double?
  var longtitude: Double?
}

component.setAction("actionTest") { (action, _) in
    self.mAction = action
    self.getLocation()
}

func getLocation() {              
  let status = CLLocationManager.authorizationStatus()
  var locationResult = LocationResult();
  switch status {
  case .authorizedAlways, .authorizedWhenInUse :
      var location = Dictionary<String,String?>()
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
      self.locationManager.startUpdatingLocation()
      let coor = self.locationManager.location?.coordinate
      mAction?.promiseReturn(
        LocationResult(latitude: coor?.latitude, longtitude: coor?.longitude)
      )
      break
  default:
    mAction?.promiseReturn()
    break
  }
}
```

## Declare closure preferred

It is a feature to easily declare and organize closures that define interfaces behavior.  
You can create a closure through a predefined function in the FlexClosure class.

```swift
var closureVar = FlexClosure.interface { args in
    ... some job
}
var closureActionVar = FlexClosure.action { (action, args) in
    ... come job
}

component.setInterface("closureVarTest", closureVar)
component.setAction("closureActionVarTest", closureActionVar)
```

## Web-to-native interface timeout settings

Since the interface operates asynchronously, there is a risk of falling into an infinite pending state on the Web.  
Therefore, timeout of the interface can be set, and when timeout occurs, it is switched to reject.  
If timeout is not set, the default value is 60000 ms.

### Set default timeout

You can specify the default value for timeout. If timeout for each interface is not set, the corresponding value is set by default.  
Setting zero does not cause timeout and pending indefinitely.  
The unit is ms.

```swift
var timeout = 1000
component.setInterfaceTimeout(timeout)
```

### Specify timeout for each interface.

When setting up an interface, you can specify the timeout of that interface.  
Setting zero does not cause timeout and pending indefinitely.  
The unit is ms.

```swift
var timeout = 200
component.setInterface("funcName", timeout) { args in }
```

## Interface event listener

Initialization of interface module, interface success, failure, and events for the timeout are listened to.

```swift
// Listen for specific events
component.addEventListener(FlexEvent.EXCEPTION) { (type, url, funcName, msg) in
  print("type: \(type.name) url: \(url) funcName: \(funcName) msg: \(msg)")
}

// Listen to all events
var AllListener = { (type, url, funcName, msg) in
  print("type: \(type.name) url: \(url) funcName: \(funcName) msg: \(msg)")
}
flexWebView.addEventListener(AllListener)

// Remove specific EventListener
flexWebView.removeEventListener(AllListener)

// Remove all EventListeners
flexWebView.removeAllEventListener()
```

# FlexWebView features

## URL restrictions

It is a feature that prevents loading to unintended sites and sets whether to allow URL-specific interfaces.  
This feature was implemented using the WKContentRule, so caution is required as it can be removed through the removeAllContentRuleList function in the WKWebViewConfiguration.

### BaseUrl

BaseUrl is a feature that can be used when setting only interface availability without url restrictions.  
FlexWebView allows access to all sites if both AllowUrlList and BaseUrl are not set, but the interface functionality is not available.  
If only BaseUrl is set, access to all sites is allowed, and the interface opens only to URLs that match BaseUrl.

```swift
component.setBaseUrl("www.myurl.com")
```

Regular expressions can be used when setting url.

```swift
component.setBaseUrl(".*.myurl.com")
```

### AllowUrlList

Setting the AllowUrlList blocks access to all url except for the set url and BaseUrl.

```swift
component.setAllowUrl(".*.myurl.com")
```

To allow an interface when setting up a URL, add true to the second canFlexLoad property of the setAllowUrl function.

```swift
component.setAllowUrl(".*.myurl.com", canFlexLoad: true)
```

## Automanage cookie

**Only available for iOS 11.0 and above.**  
**This feature is a very basic feature, so please implement and use cookie-related features directly in case of a problem.**  
It's a feature that automatically maintains cookies.  
The default value is inactive and operates automatically when the feature is activated.  
FlexWebViews with that feature enabled in the app share all cookies.

```swift
component.setAutoCookieManage(true) // activate
component.setAutoCookieManage(true, clearAll: true) // activate and delete all cookies 
```

# Use in js

## $flex Object

\$flex Object is an object composed of interfaces between FlexWebView and Promise.  
\$flex is declared in the webpage at runtime when the webpage is loaded in the webview.  
When \$flex is finished loading, you can check the window.onFlexLoad function.  
\$flex can also be used in any accessible frames. (Ex) iframe that does not violate Cross-Origin)  
The components of $ flex Object are as follows.

```js
window.onFlexLoad; // $flex is called upon completion of loading.
$flex; // Object that contains functions that can call Native area as WebToNative
$flex.version; // get Library version
$flex.web; // Object used to add and use functions to be used for NativeToWeb
$flex.device; // Current Device Info
$flex.isAndroid; // false
$flex.isiOS; // true
$fles.isScript; // false
```
# ToDo

Apply async awit from Swift 5.5.  
Flutter version FlexHybirdApp.
