[Android Version](https://github.com/Kyun-J/FlexHybridApp-Android)

[Typescript Support](https://github.com/Kyun-J/FlexHybridApp-Script)

# FlexibleHybrid

WKWebView와 Native간 인터페이스 간소화, 비동기 처리를 비롯하여  
WKWebView사용에 여러 편의 기능을 제공하는 라이브러리입니다.

# framework 추가 방법

podFile에 다음을 추가

```
    pod 'FlexHybridApp'
```

***iOS Deployment Target은 10.0 입니다.***  

# Flex 라이브러리 주요 특징

1. [Android 버전]()과 서로 유사한 개발 규칙 및 기능을 가집니다.
2. WKWebView와 Native간의 인터페이스가 비동기적으로 동작합니다.
   1. Web에서 **Promise로 호출 및 반환**됩니다.
   2. Native에서는 별도의 **Concurrent한 Queue**에서 동작합니다.
3. **Swift Closure**로 인터페이스시 동작을 정의합니다.
4. **Model Object**로 인터페이스 할 수 있습니다.
5. 인터페이스 동작이 가능한 Url을 지정하여, **원하지 않는 사이트에서의 Native호출**을 막을 수 있습니다.

외 여러 기능들 포함

# 인터페이스 기본 사용법

기본적으로 아래와 같은 패턴으로 인터페이스 등록 및 사용이 가능하며,  
모든 인터페이스는 비동기적으로 동작합니다.  
Web에서는 응답이 발생할 때 까지 **pending상태**가 됩니다.

## Web to Native
### 인터페이스 등록

FlexWebView에 페이지가 로드되기 전 인터페이스를 설정합니다.

```swift
// in swift
flexWebView.setInterface("funcName") { args -> String? in
    return "received from web - \(args[0]?.toString() ?? "no value"), return to web - \(100)"
}
flexWebView.load(somUrl)
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

1. [FlexHybridApp-Script](https://github.com/Kyun-J/FlexHybridApp-Scripts) 적용시

```js
// in js
$flex.web.funcName = async (req) => {
  return await new Promise((resolve) => {
    setTimeout(() => resolve(`received from web - ${req}`), 100);
  });
};
```

2. 미적용시

`window.onFlexLoad` 함수를 통해 $flex 객체가 로드된 후 인터페이스를 등록하여햐 합니다.

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
flexWebView.evalFlexFunc("funcName", "sendData") { response in
    print(response.toString()!) // received from web - sendData
}
```