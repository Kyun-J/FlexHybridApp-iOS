# FlexibleHybrid

FlexibleHybridApp은 Web->Native Call을 Promise로 구현하는 등, HybridApp을 개발하기 위해 여러 편의 기능을 제공하는 라이브러리입니다.

# 라이브러리 추가 방법

podFile에 다음을 추가

```pod
    pod 'FlexHybridApp'
```

# JSInterface Return Promise

기존의 WKWebView의 `userContentController`와 달리, Closure 형태로 함수와 유사하게 인터페이스 패턴을 정의할 수 있습니다
```swift
component.addInterface("FuncName") { (property) -> String? in
    if property != nil {
        return String(property![0] as! Int + 1)
    } else {
        return "novalue"
    }
}
```
위와 같이 코드를 작성할 경우, Web상에서 FuncName으로 함수가 만들어지며, 다음과 같이 Promise 형태로 사용할 수 있습니다
```js
const t1 = async () => {
    const z = await $flex.FuncName(0); // call Native Function
    console.log('Return by Native with t1 --- ' + z); // z = 1
}
```
# `$flex` Object
`$flex` Object는 FlexHybrid 라이브러리의 Web안에서 Web <-> Native간 인터페이스를 담당합니다.   
`$flex`안에는 FlexComponent에서 `addInterface(name, action)`으로 등록한 함수들이 생성되어 있으며, 이 함수들은 Promise를 반환 합니다.  
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
`$flex.web`안에 함수를 생성하면, FlexWebView의 `evalFlexFunc`를 통해 해당 함수들을 Native에서 손쉽게 호출할 수 있습니다.   
```swift
// in native
flexWebView.evalFlexFunc('WebFunction', 'test')
```
`$flex.web`에 함수 등록시, window.onload가 호출된 이후에 등록해야 합니다.  
```js
// in js
window.onload = function() {
    $flex.web.WebFunction = (msg) => { console.log(msg); }
}
```
`$flex` Object는 FlexWebView에서 로드한 html 페이지에서 자동 생성됩니다.  
다만 `$flex`는 FlexWebView에서 BaseUrl로 등록한 페이지의 하위에서만 생성되며 그 외의 페이지를 로드할 경우에는 생성되지 않습니다.  

## $flex 구성요소
#### `$flex.version`
> 라이브러리의 버전을 가져옵니다.

#### `$flex.addEventListener(event, callback)`
> *개발중*  
> 이벤트 청취자를 추가합니다.

#### `$flex.web`
> web Object 인자를 통해 함수를 추가하면, `evalFlexFunc`를 통해 해당 함수들을 Native에서 손쉽게 호출할 수 있습니다.   

# Native 클래스
## **FlexComponent**
FlexComponent는 FlexWebView의 필수 구성요소이며 WKWebViewConfiguration를 포함하고 있습니다.  
FlexComponent의 `addInterface`를 통해 FlexWebView의 JS인터페이스를 추가할 수 있습니다.  
`addInterface`는 FlexWebView가 생성되기 전에 미리 설정되어야 합니다.

#### `func addInterface(_ name: String, _ action: @escaping (_ propertys: Array<Any?>?) -> String?)`
> FlexWebView의 JS인터페이스를 추가합니다. FlexWebView가 Init되기 전에만 사용 가능합니다.  
> Web에서 전달한 파라미터는 `Array<Any?>`형태로 전달되며, String 혹은 nil 값을 return할 수 있습니다.
> 설정한 Closure는 Background에서 동작합니다.

## **FlexWebView**

#### `FlexWebView(frame: CGRect, configuration: WKWebViewConfiguration)`
> FlexWebView를 생성합니다
> 