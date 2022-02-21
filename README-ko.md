[Android Version](https://github.com/Kyun-J/FlexHybridApp-Android)

[Typescript Support](https://github.com/Kyun-J/FlexHybridApp-Scripts)

# FlexibleHybrid

WKWebView와 Native간 인터페이스 간소화, 비동기 처리를 비롯하여  
WKWebView사용에 여러 편의 기능을 제공하는 프레임워크입니다.

# framework 추가 방법

Podfile에 다음을 추가

```
  pod 'FlexHybridApp'
```

**_iOS Deployment Target은 10.0 입니다._**

# Flex 프레임워크 주요 특징

1. [Android 버전](https://github.com/Kyun-J/FlexHybridApp-Android)과 서로 유사한 개발 규칙 및 기능을 가집니다.
2. WKWebView와 Native간의 인터페이스가 비동기적으로 동작합니다.
   1. Web에서 **Promise로 호출 및 반환**됩니다.
   2. Native에서는 별도의 **Concurrent한 Queue**에서 동작합니다.
3. **Swift Closure**로 인터페이스시 동작을 정의합니다.
4. **Model Object**로 인터페이스 할 수 있습니다.
5. 인터페이스 동작이 가능한 Url을 지정하여, **원하지 않는 사이트에서의 Native호출**을 막을 수 있습니다.

외 여러 기능들 포함

## FlexComponent

FlexWebView의 기능들을 활용하기 위해선, FlexComponent를 사용해야 합니다.  
FlexComponent는 FlexWebView와 함께 생성되며, FlexWebView 선언시에 세팅 할 수도 있습니다.  
FlexComponent는 해당 WebView의 WKWebViewConfiguration도 인자로 포함하고 있습니다.

# 인터페이스 기본 사용법

기본적으로 아래와 같은 패턴으로 인터페이스 등록 및 사용이 가능하며,  
모든 인터페이스는 비동기적으로 동작합니다.  
Web에서는 응답이 발생할 때 까지 **pending상태**가 됩니다.

## Web to Native

### 인터페이스 등록

FlexWebView에 페이지가 로드되기 전 인터페이스가 설정되어야 합니다.

```swift
// in swift
var component = FlexComponent()
component.setInterface("funcName") { args in
    return "received from web - \(args[0]?.toString() ?? "no value"), return to web - \(100)"
}
var flexWebView = FlexWebView(frame: self.view.frame, component: component)
flexWebView.load(someUrl)
```

### 인터페이스 사용

```js
// in js
const test = async (req) => {
  const res = await $flex.funcName(req);
  console.log(res); // received from web - 200, return to web - 100
};
test(200);
```

## Native to Web

### 인터페이스 등록

\$flex 객체가 로드 된 후 (`window.onFlexLoad` 함수로 \$flex 로드 시점 확인 가능) 인터페이스를 등록하여햐 합니다.

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

### 인터페이스 사용

```swift
// in swift
component.evalFlexFunc("funcName", "sendData") { response in
    print(response.toString()!) // received from web - sendData
}
```

# 인터페이스 고급 사용법

## FlexData

Web에서 전달받은 데이터는 TypeSafe하게 불러오기 위하여 FlexData 객체로 변환됩니다.  
Web to native 인터페이스시, Web의 함수에서 전달하는 Arguments들은 Array\<FlexData\>로 전달됩니다.

```js
// in js
$flex.funcName("test1", 2, 3.1, true, [0, 1, 2], { test: "object" }, "reified");
```

```swift
component.setInterface("funcName") { args in
    if (args == nil) return

    var first = args[0].asString() // "test"
    var second = args[1].asInt() // 2
    var third = args[2].asDouble() // 3.1
    var fourth = args[3].asBool() // true
    var fifth = args[4].asArray() // array of FlexData(0), FlexData(1), FlexData(2)
    var sixth = args[5].asDictionary() // map of first key - test, value - FlexData("object")
    var seventh: String? = args[6].reified() // "reified"
}
```

## Model Obejct 활용

인터페이스에 사용할 데이터를 Model Obejct로 사용 할 수 있습니다.  
이때 아래의 규칙이 적용됩니다.

1. Model Object는 **Codable를 Inheritance** 해야 합니다.
2. Web에서는 Object 형태로 변환됩니다.
3. Native에서 Model Object를 Arguments로 받을 때는, Web에서 해당 Model에 대응되는 Object 하나만 전달해야 합니다.

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

## Action 인터페이스

Web to Native 인터페이스시, 지정된 closure 코드블럭 이외의 코드에서 값을 리턴할 수 있는 방식입니다.  
Action객체를 통해 원하는 위치의 코드에서 값을 리턴 할 수 있습니다.  
이때, Web에서는 응답이 발생할 때 까지 **pending** 상태가 됩니다.  
또한, 한번 응답한 Action객체는 다시 사용할 수 없습니다.

```swift
var mAction: FlexAction? = null

struct LocationResult: Codable {
  var latitude: Double
  var longtitude: Double
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
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
      self.locationManager.startUpdatingLocation()
      let coor = self.locationManager.location?.coordinate
      mAction?.promiseReturn(
        LocationResult(latitude: Double(coor?.latitude ?? 0), longtitude: Double(coor?.longitude ?? 0))
      )
      break
  default:
    mAction?.promiseReturn()
    break
  }
}
```

## closure를 미리 선언하여 사용

인터페이스시 동작을 정의하는 closure를 쉽게 선언 및 정리하기 위한 기능입니다.  
FlexClosure 클래스에서 미리 정의되어있는 함수를 통해 closure를 생성 할 수 있습니다.

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

## Web to native 인터페이스 timeout 설정

인터페이스가 비동기로 동작하기 때문에, Web에서는 무한 pending상태로 빠질 우려가 있습니다.  
따라서 인터페이스의 timeout을 설정할 수 있으며, timeout이 발생하면 reject로 전환됩니다.  
timeout을 설정하지 않을 시, 기본값은 60000ms 입니다.

### timeout 기본값 지정

timeout의 기본값을 지정할 수 있습니다. 인터페이스별 timeout이 설정되지 않으면, 해당 값이 기본적으로 설정됩니다.  
0을 설정하면 timeout이 발생하지 않고 무한 대기합니다.  
단위는 ms입니다.

```swift
var timeout = 1000
component.setInterfaceTimeout(timeout)
```

### 인터페이스별 timeout 지정

인터페이스를 설정 할 때 해당 인터페이스의 timeout을 지정 할 수 있습니다.  
0을 설정하면 timeout이 발생하지 않고 무한 대기합니다.  
단위는 ms입니다.

```swift
var timeout = 200
component.setInterface("funcName", timeout) { args in }
```

## 인터페이스 이벤트 리스너

인터페이스 모듈 초기화, 인터페이스 성공, 실패, 타임아웃에 대한 이벤트를 청취 할 수 있습니다.

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

# FlexWebView 기능들

## URL 제한

의도하지 않은 사이트로의 로드를 막고, URL별 인터페이스 허용 여부를 설정하는 기능입니다.  
이 기능은 WKContentRule을 사용하여 구현되었으며, 따라서 WKWebViewConfiguration의 removeAllContentRuleLists 함수를 통해 제거 될 수 있으므로 주의가 필요합니다.

### BaseUrl

BaseUrl은 url제한을 하지 않고 인터페이스 가능 여부만 설정할 때 사용할 수 있는 기능입니다.  
AllowUrlList와 BaseUrl을 모두 설정하지 않을경우 FlexWebView는 모든 사이트로의 접근을 허용하지만, 인터페이스 기능을 사용할 수 없습니다.  
BaseUrl만 설정할 경우, 모든 사이트로의 접근을 허용하며 BaseUrl에 매치되는 URL에만 인터페이스 기능이 열립니다.

```swift
component.setBaseUrl("www.myurl.com")
```

url 설정시 정규표현식을 사용할 수 있습니다

```swift
component.setBaseUrl(".*.myurl.com")
```

### AllowUrlList

**iOS 11.0 이상에서만 사용할 수 있습니다.**

AllowUrlList을 설정하면, 설정된 url들과 BaseUrl을 제외한 모든 url의 접근이 차단됩니다.

```swift
component.addAllowUrl(".*.myurl.com")
```

URL설정 시 인터페이스를 허용하려면 setAllowUrl함수의 두번째 canFlexLoad 프로퍼티에 true를 추가하면 됩니다.

```swift
component.addAllowUrl(".*.myurl.com", canFlexLoad: true)
```

## cookie 유지

**iOS 11.0 이상에서만 사용할 수 있습니다.**  
**이 기능은 아주 기본적인 기능으로, 문제 발생시 직접 cookie 관련 기능을 구현하여 사용하시기 바랍니다.**

쿠키를 자동으로 유지하는 기능입니다.  
기본값은 비활성이며, 기능 활성 시 자동으로 동작합니다.  
앱 내에 해당 기능이 활성화된 FlexWebView들은 모든 쿠키를 공유합니다.

```swift
component.setAutoCookieManage(true) // activate
component.setAutoCookieManage(true, clearAll: true) // activate and delete all cookies
```

## Web console 메시지 출력

web의 console.log, debug, error, info, warn의 메시지를 xcode의 output창에 표시합니다.  
기본값으로 활성화되어 있습니다.

**이 출력은 web의 console 메시지와 같지 않을 수 있습니다.**

```swift
component.setShowWebViewConsole(true)
```

## FileAccess

allowFileAccessFromFileURLs, allowUniversalAccessFromFileURLs 항목을 한번에 설정하는 기능.

```swift
component.setAllowsUrlAccessInFile(true)
```

# js에서의 사용

## $flex Object

\$flex Object는 FlexWebView를 와 Promise 형태로 상호간 인터페이스가 구성되어있는 객체입니다.  
\$flex는 웹뷰에 웹페이지 로드 후, 런타임으로 웹페이지에 선언됩니다.  
\$flex가 로드 완료되는 시점은, window.onFlexLoad함수를 통해 확인할 수 있습니다.  
\$flex는 액세스 가능한 모든 하위 프레임에서도 사용 할 수 있습니다. (Ex)Cross-Origin을 위반하지 않는 iframe)  
\$flex Object의 구성 요소는 다음과 같습니다.

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

swift5.5 이상에서 async await 적용  
Flutter 버전 FlexHybirdApp
