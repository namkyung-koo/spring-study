## 스프링 MVC - 기본 기능

### 로깅 간단히 알아보기
운영 시스템에서는 `System.out.println()` 대신에 별도의 로깅 라이브러리를 사용하여 로그를 출력한다.

#### 로깅 라이브러리
스프링 부트 라이브러리를 사용하면 스프링 부트 로깅 라이브러리(`spring-boot-starter-logging`)가 함께 포함된다.<br>
스프링 부트 로깅 라이브러리는 기본으로 다음 로깅 라이브러리를 사용한다.
- SLF4J
  - Logback, Log4J, Log4J2 등 수 많은 라이브러리를 통합해서 인터페이스로 제공하는 로깅 라이브러리
  - 쉽게 이야기해서 SLF4J는 인터페이스이고, 그 구현체로 Logback 같은 로그 라이브러리를 선택하면 된다.
- Logback
  - 실무에서는 스프링 부트가 기본으로 제공하는 Logback을 대부분 사용한다.

#### 로그 선언
- `private Logger log = LoggerFactory.getLogger(getClass());`
- `private static final Logger log = LoggerFactory.getLogger(Xxx.class)`
- `@Slf4j`: 롬복 사용 가능

#### 로그 호출
- `log.info("hello")`
- `System.out.println("hello")`

#### LogTestController

```java
//@Slf4j
@RestController
public class LogTestController {
    
    private final Logger log = LoggerFactory.getLogger(getClass());
    
    @RequestMapping("/log-test")
    public String logTest() {
        String name = "Spring";
        
        log.trace("trace log={}", name);
        log.debug("debug log={}", name);
        log.info(" info log={}", name);
        log.warn(" warn log={}", name);
        log.error("error log={}", name);
        
        // 로그를 사용하지 않아도 a+b 계산 로직이 먼저 실행되므로, 이런 방식으로 사용하면 안된다.
        log.debug("String concat log=" + name);
        return "ok";
    }
}
```

#### 매핑 정보
- `@RestController`
  - `@Controller`는 반환 값이 `String`이면 뷰 이름으로 인식된다. 그래서 **뷰를 찾고 뷰가 렌더링** 된다.
  - `@RestController`는 반환 값으로 뷰를 찾는 것이 아니라, **HTTP 메시지 바디에 바로 입력**한다. 따라서 실행 결과로 ok 메시지를 받을 수 있다.
  - `@ResponseBody`와 관련이 있다.

#### 테스트
- 로그가 출력되는 포맷 확인
  - 시간, 로그, 레벨, 프로세스 ID, 쓰레드 명, 클래스 명, 로그 메시지
- 로그 레벨 설정을 변경해서 출력 결과를 보자
  - LEVEL: `TRACE > DEBUG > INFO > WARN > ERROR`
  - 개발 서버는 debug 출력
  - 운영 서버는 info 출력
- `@Slf4j`로 변경

#### 로그 레벨 설정 - `application.properties`
```properties
# 전체 로그 레벨 설정 (기본 값은 info)
logging.level.root=info
# hello.springmvc 패키지와 그 하위 로그 레벨 설정
logging.level.hello.springmvc=debug
```

#### 올바른 로그 사용법
- `log.debug("data=" + data)`
  - 로그 출력 레벨을 info로 설정해도 해당 코드에 있는 "data=" + data가 실제 실행이 되어 버린다. 결과적으로 문자 더하기 연산이 발생한다. (불필요한 연산)
- `log.debug("data={}", data)`
  - 로그 출력 레벨을 info로 설정하면 아무 일도 발생하지 않는다.

#### 로그 사용 시 장점
- 쓰레드 정보, 클래스 이름 같은 부가 정보를 함께 볼 수 있고, 출력 모양을 조정할 수 있다.
- 로그 레벨에 따라 개발 서버에서는 모든 로그를 출력하고, 운영 서버에서는 출력하지 않는 등 로그를 상황에 맞게 조절할 수 있다.
- 시스템 아웃 콘솔에만 출력하는 것이 아니라, 파일이나 네트워크 등 로그를 별도의 위치에 남길 수 있다. 특히 파일로 남길 때는 일 별, 특정 용량에 따라 로그를 분할하는 것도 가능하다.
- 성능도 일반 System.out 보다 좋다.(내부 버퍼링, 멀티 쓰레드 등) **그래서 실무에서는 꼭 로그를 사용해야 한다.**

### 요청 매핑

#### MappingController

```java
@RestController
public class MappingController {

  private Logger log = LoggerFactory.getLogger(getClass());

  /**
   * 기본 요청
   * 둘 다 허용 /hello-basic, /hello-basic/ - 스프링 부트 3.0 이전
   * HTTP 메서드 모두 허용. GET, HEAD, POST, PUT, PATCH, DELETE
   */
  @RequestMapping("/hello-basic")
  public String helloBasic() {
      log.info("helloBasic");
      return "ok";
  }
}
```
- `RequestMapping("/hello-basic")`
  - `/hello-basic` URL 호출이 오면 이 메서드가 실행되도록 매핑한다.
  - 대부분의 속성을 `배열[]`로 제공하므로 다중 설정이 가능하다. `{"/hello-basic", "/hello-go"}`

#### HTTP 메서드
`@RequestMapping`에 `method` 속성으로 HTTP 메서드를 지정하지 않으면, HTTP 메서드와 무관하게 호출된다.

#### HTTP 메서드 매핑

```java
/**
 * method 특정 HTTP 메서드 요청만 허용
 */
@RequestMapping(value = "/mapping-get-v1", method = RequestMethod.GET)
public String mappingGetV1() {
    log.info("mappingGetV1");
    return "ok";
}
```
`/mapping-get-v1`에 POST 요청을 하면 스프링 MVC는 HTTP 405 상태 코드(Method Not Allowed)를 반환한다.

#### HTTP 메서드 매핑 축약

```java
/**
 * 편리한 축약 애노테이션
 * @GetMapping
 * @PostMapping
 * @PutMapping
 * @DeleteMapping
 * @PatchMappging
 */
@GetMapping(value = "/mapping-get-v2")
public String mappingGetV2() {
    log.info("mapping-get-v2");
    return "ok";
}
```
위의 예시처럼 HTTP 메서드를 축약한 애노테이션을 사용하는 것이 더 직관적이다.<br>
코드를 보면 내부에서 `@RequestMapping`과 `method`를 지정해서 사용하는 것을 알 수 있다.

#### PathVariable(경로 변수) 사용

```java
/**
 * PathVariable 사용
 * 변수 명이 같으면 생략 가능
 * @PathVariable("userId") String userId -> @PathVariable String userId
 */
@GetMapping("/mapping/{userId}")
public String mappingPath(@PathVariable("userId") String data) {
    log.info("mappingPath userId={}", data);
    return "ok";
}
```
최근 HTTP API는 다음과 같이 리소스 경로에 식별자를 넣는 스타일을 선호한다.
- `/mapping/userA`
- `/users/1`
- `@RequestMapping`은 URL 경로를 템플릿화 할 수 있는데, `@PathVariable`을 사용하면 매칭 되는 부분을 편리하게 조회할 수 있다.
- `@PathVariable`의 이름과 파라미터 이름이 같으면 생략할 수 있다.

#### PathVariable 사용 - 다중

```java
@GetMapping("/mapping/users/{userId}/orders/{orderId}")
public String mappingPath(@PathVariable String userId, @PathVariable Long orderId) {
    log.info("mappingPath userId={}, orderId={}", userId, orderId);
    return "ok";
}
```

#### 특정 파라미터 조건 매핑

```java
/**
 * 파라미터로 추가 매핑
 * params ="mode"
 * params="!mode"
 * params="mode=debug"
 * params="mode!=debug"
 * params= {"mode=debug", "data=good"}
 */
@GetMapping(value = "/mapping-param", params = "mode=debug")
public String mappingParam() {
    log.info("mappingParam");
    return "ok";
}
```
특정 파라미터가 있거나 없는 조건을 추가할 수 있다. 잘 사용하지는 않는다.

#### 특정 헤더 조건 매핑

```java
/**
 * 특정 헤더로 추가 매핑
 * headers="mode"
 * headers="!mode"
 * headers="mode=debug"
 * headers="mode!=debug"
 */
@GetMapping(value = "/mapping-header", headers = "mode=debug")
public String mappingHeader() {
    log.info("mappingHeader");
    return "ok";
}
```
파라미터 매핑과 비슷하지만, HTTP 헤더를 사용한다.

#### 미디어 타입 조건 매핑 - HTTP 요청 ContentType, consume

```java
/**
 * Content-Type 헤더 기반 추가 매핑 Media Type
 * consumes="application/json"
 * consumes="!application/json"
 * consumes="application/*"
 * consumes="*\/*"
 * consumes=MediaType.APPLICATION_JSON_VALUE
 */
@PostMapping(value = "/mapping-consume", consumes = "application/json")
public String mappingConsumes() {
    log.info("mappingConsumes");
    return "ok";
}
```
HTTP 요청의 Content-Type 헤더를 기반으로 미디어 타입으로 매핑한다.<br>
만약 맞지 않으면 HTTP 415 상태 코드(Unsupported Media Type)을 반환한다.

#### 미디어 타입 조건 매핑 - HTTP 요청 Accept, produce

```java
/**
 * Accept 헤더 기반 Media Type
 * produces = "text/html"
 * produces = "!text/html"
 * produces = "text/*"
 * produces = "*\/*"
 */
@PostMapping(value = "/mapping-produce", produces = "text/html")
public String mappingProduces() {
    log.info("mappingProduces");
    return "ok";
}
```
HTTP 요청의 Accept 헤더를 기반으로 미디어 타입으로 매핑한다.<br>
만약 맞지 않으면 HTTP 406 상태 코드(Not Acceptable)을 반환한다.

### 요청 매핑 - API 예시
회원 관리를 HTTP API로 만든다고 생각하고 매핑을 어떻게 하는지 알아보자

#### 회원 관리 API
- 회원 목록 조회: GET  `/users`
- 회원 등록    : POST `/users`
- 회원 조회    : GET  `/users/{userId}`
- 회원 수정    : PATCH `/users/{userId}`
- 회원 삭제    : DELETE `/users/{userId}`

#### MappingClassController

```java
@RestController
@RequestMapping("/mapping/users")
public class MappingClassController {
    
    @GetMapping
    public String users() {
        return "get users";
    }
    
    @PostMapping
    public String addUser() {
        return "post user";
    }
    
    @GetMapping("/{userId}")
    public String findUser(@PathVariable String userId) {
        return "get userId=" + userId;
    }
    
    @PatchMapping("/{userId}")
    public String updateUser(@PathVariable String userId) {
        return "update userId=" + userId;
    }
    
    @DeleteMapping("/{userId}")
    public String deleteUser(@PathVariable String userId) {
        return "delete userId=" + userId;
    }
}
```
- `@RequestMapping("/mapping/users")`
  - 클래스 레벨에 매핑 정보를 두면 메서드 레벨에서 해당 정보를 조합해서 사용한다.

### HTTP 요청 - 기본, 헤더 조회
매핑 방법을 이해했으니, 이제부터 HTTP 요청이 보내는 데이터들을 스프링 MVC로 어떻게 조회하는지 알아보자<br>
애노테이션 기반의 스프링 컨트롤러는 다양한 파라미터를 지원한다.<br>
HTTP 헤더 정보를 조회하는 방법에 대해 알아보자

#### RequestHeaderController

```java
@Slf4j
@RestController
public class RequestHeaderController {
    
    @RequestMapping("/headers")
    public String headers(HttpServletRequest request,
                          HttpServletResponse response,
                          HttpMethod httpMethod,
                          Locale locale,
                          @RequestHeader MultiValueMap<String, String> headerMap,
                          @RequestHeader("host") String host,
                          @CookieValue(value = "myCookie", required = false) String cookie
    ) {
        
        log.info("request={}", request);
        log.info("response={}", request);
        log.info("httpMethod={}", httpMethod);
        log.info("locale={}", locale);
        log.info("headerMap={}", headerMap);
        log.info("header host={}", host);
        log.info("myCookie={}", cookie);
        
        return "ok";
    }
}
```
- `HttpServletRequest`
- `HttpServletResponse`
- `HttpMethod`: HTTP 메서드를 조회한다. `org.springframework.http.HttpMethod`
- `Locale`: Locale 정보를 조회한다.
- `@RequestHeader MultiValueMap<String, String> headerMap`
  - 모든 HTTP 헤더를 MultiValueMap 형식으로 조회한다.
- `@RequestHeader("host") String host`
  - 특정 HTTP 헤더를 조회한다.
  - 속성
    - 필수 값 여부: `required`
    - 기본 값 속성: `defaultValue`
- `@CookieValue(value = "myCookie", required = false) String cookie`
  - 특정 쿠키를 조회한다.
  - 속성
    - 필수 값 여부: `required`
    - 기본 값: `defaultValue`
- `MultiValueMap`
  - Map과 유사하지만 하나의 키에 여러 값을 받을 수 있다.
  - HTTP header, HTTP 쿼리 파라미터와 같이 하나의 키에 여러 값을 받을 때 사용한다.
    - **keyA=value1&keyA=value2**

```java
MultiValueMap<String, String> map = new LinkedMultiValueMap();
map.add("keyA", value1);
map.add("keyA", value2);

// [value1, value2]
List<String> values = map.get("keyA");
```

#### @Slf4j
다음 코드를 자동으로 생성해서 로그를 선언해준다. 개발자는 편리하게 `log`라고 사용하면 된다.
```java
private static final org.slf4j.Logger log = 
org.slf4j.LoggerFactory.getLogger(RequestHeaderController.class);
```

### HTTP 요청 파라미터 - 쿼리 파라미터, HTML Form

#### HTTP 요청 데이터 조회 - 개요
서블릿에서 학습했던 HTTP 요청 데이터를 조회하는 방법을 다시 떠올려보자.<br>
그리고 서블릿으로 학습했던 내용을 스프링이 얼마나 깔끔하고 효율적으로 바꿔주는지 알아보자<br>
HTTP 요청 메시지를 통해 클라이언트에서 서버로 데이터를 전달하는 방법을 알아보자.
- **GET - 쿼리 파라미터**
  - /url?username=hello&age=20
  - 메시지 바디 없이 URL 쿼리 파라미터에 데이터를 포함해서 전달
  - 사용 예시. 검색, 필터, 페이징 등에서 많이 사용하는 방식
- **POST - HTML Form**
  - content-type:application/x-www-form-urlencoded
  - 메시지 바디에 쿼리 파라미터 형식으로 전달. (username=hello&age=20)
  - 사용 예시. 회원 가입, 상품 주문, HTML Form 사용
- **HTTP message body**에 데이터를 직접 담아서 요청
  - HTTP API에서 주로 사용. JSON, XML, TEXT
  - 데이터 형식은 주로 JSON 사용
  - POST, PUT, PATCH

#### 요청 파라미터 - 쿼리 파라미터, HTML Form
`HttpServletRequest`의 `request.getParameter()`를 사용하면 **GET,파라미터 전송**과 **POST,HTML Form 전송** 모두 요청 파라미터를 조회할 수 있다.<br>
이것을 간단히 **요청 파라미터(request parameter) 조회**라 한다.<br><br>
지금부터 스프링으로 요청 파라미터를 조회하는 방법을 단계적으로 알아보자.

#### RequestParamController

```java
import java.io.IOException;

@Slf4j
@Controller
public class RequestParamController {

  /**
   * 반환 타입이 없으면서 이렇게 응답에 직접 값을 집어넣으면 view 조회 X
   */
    @RequestMapping("/request-param-v1")
    public void requestParamV1(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        int age = Integer.parseInt(request.getParameter("age"));
        log.info("username={}, age={}", username, age);
        
        response.getWriter().write("ok");
    }
}
```

### HTTP 요청 파라미터 - @RequestParam
스프링이 제공하는 `@RequestParam`을 사용하면 요청 파라미터를 매우 편리하게 사용할 수 있다.

#### requestParamV2

```java
/**
 * @RequestParam 사용
 * - 파라미터 이름으로 바인딩
 * @ResponseBody 추가
 * - view 조회를 무시하고, HTTP message body에 직접 해당 내용 입력
 */
@ResponseBody
@RequestMapping("/request-param-v2")
public String requestParamV2(
        @RequestParam("username") String memberName,
        @RequestParam("age") int memberAge) {
    
    log.info("username={}, age={}", memberName, memberAge);
    return "ok";
}
```
- `@RequestParam`: 파라미터 이름으로 바인딩
- `@ResponseBody`: View 조회를 무시하고, HTTP message body에 직접 해당 내용 입력

#### @RequestParam의 `name(value)` 속성이 파라미터 이름으로 사용
- @RequestParam("username") String memberName
- -> request.getParameter("username")

#### requestParamV3

```java
/**
 * @RequestParam 사용
 * HTTP 파라미터 이름이 변수 이름과 같으면, @RequestParam(name="xx") 생략 가능
 */
@ResponseBody
@RequestMapping("/request-param-v3")
public String requestParamV3(
        @RequestParam String username,
        @RequestParam int age ) {
    log.info("username={}, age={}", username, age);
    return "ok";
}
```

#### requestParamV4

```java
/**
 * @RequestParam 사용
 * String, int 등의 단순 타입이면, @RequestParam도 생략 가능!
 * 스프링 부트 3.2부터 자바 컴파일러에 -parameters 옵션을 넣어주어야 애노테이션에 적는 이름을 생략할 수 있다.
 */
@ResponseBody
@RequestMapping("/request-param-v4")
public String requestParamV4(String username, int age) {
    log.info("username={}, age={}", username, age);
    return "ok";
}
```

#### @RequestParam, @PathVariable 관련
```java
// 애노테이션에 username이라는 이름이 명확하게 있다. 문제 없이 동작한다.
@RequestMapping("/request")
public String request(@RequestParam("username") String username) {
}

// 애노테이션에 이름이 없다. -parameters 옵션 필요
@RequestMapping("/request")
public String request(@RequestParam String username) {
}

// 애노테이션도 없고 이름도 없다. -parameters 옵션 필요
@RequestMapping("/request")
public String request(String username) {
}

// 애노테이션에 userId라는 이름이 명확하게 있다. 문제 없이 동작한다.
public String mappingPath(@PathVariable("userId") String userId) {
}

// 애노테이션에 이름이 없다. -parameters 옵션 필요
public String mappingPath(@PathVariable String userId) {
}
```

#### 해결 방안
컴파일 시점에 -parameters 옵션을 적용하기 보다는 **애노테이션에 이름을 생략하지 않고 이름을 항상 적어주는 것을 권장한다.**<br>
`@RequestParam("username") String username`<br>
`@PathVariable("userId") String userId`

#### 파라미터 필수 여부 - requestParamRequired
```java
/**
 * @RequestParam.required
 * /request-param-required -> username이 없으므로 예외
 * 
 * 주의!
 * /request-param-required?username= -> 빈 문자로 통과
 * 
 * 주의!
 * /request-param-required
 * int age -> null을 int에 입력하는 것은 불가능하다. 따라서 Integer로 변경해야 한다.(또는 defaultValue를 사용한다.)
 */
@ResponseBody
@RequestMapping("/request-param-required")
public String requestParamRequired(
        @RequestParam(required = true) String username,
        @RequestParam(required = false) Integer age) {
    log.info("username={}, age={}", username, age);
    return "ok";
}
```

#### 기본 값 적용 - requestParamDefault

```java
/**
 * @RequestParam
 * - defaultValue tkdyd
 * 
 * 참고: defaultValue는 빈 문자의 경우에도 적용된다.
 * /request-param-default?username=
 */
@ResponseBody
@RequestMapping("/request-param-default")
public String requestParamDefault(
        @RequestParam(required = true, defaultValue = "guest") String username,
        @RequestParam(required = false, defaultValue = "-1") int age) {
    log.info("username={}, age={}", username, age);
    return "ok";
}
```

#### 파라미터를 Map으로 조회하기 - requestParamMap

```java
/**
 * @RequestParamMap, MultiValueMap
 * Map(key=value)
 * MultiValueMap(key=[value1, value2, ...]) ex) (key=userIds, value = [id1, id2])
 */
@ResponseBody
@RequestMapping("/request-param-map")
public String requestParamMap(@RequestParam Map<String, Object> paramMap) {
    log.info("username={}, age={}", paramMap.get("username"),
            paramMap.get("age"));
    return "ok";
}
```

### HTTP 요청 파라미터 - @ModelAttribute
실제 개발을 하면 요청 파라미터를 받아서 필요한 객체를 만들고 그 객체에 값을 넣어주어야 한다. 보통 다음과 같이 코드를 작성할 것이다.

```java
@RequestParam String username;
@RequestParam int age;

HelloData data = new HelloData();
data.setUsername(username);
data.setAge(age);
```
스프링은 이 과정을 완전히 자동화해주는 `@ModelAttribute` 기능을 제공한다.

#### HelloData

```java
import lombok.Data;

@Data
public class HelloData {
    private String username;
    private int age;
}
```
- lombok `@Data`
  - `@Getter`, `@Setter`, `@ToString`, `@EqualsAndHashCode`, `@requiredArgsConstructor`를 자동으로 적용해준다.

#### @ModelAttribute 적용 - mdoelAttributeV1

```java
/**
 * @ModelAttribute 사용
 * 참고: model.addAttribute(helloData) 코드도 함께 자동 적용된다.
 */
@ResponseBody
@RequestMapping("/model-attribute-v1")
public String modelAttributeV1(@ModelAttribut HelloData helloData) {
    log.info("username={}, age={}", helloData.getUsername(), helloData.getAge());
    return "ok";
}
```
스프링 MVC는 `@ModelAttribute`가 있으면 다음을 실행한다.
- `HelloData` 객체를 생성한다.
- 요청 파라미터의 이름으로 `HelloData` 객체의 프로퍼티를 찾는다. 그리고 해당 프로퍼티의 setter를 호출해서 파라미터의 값을 입력(바인딩) 한다.
- 얘시. 파라미터 이름이 `username`이면 `setUsername()` 메서드를 찾아서 호출하면서 값을 입력한다.

#### 프로퍼티
객체에 `getUsername()`, `setUsername()` 메서드가 있으면 이 객체는 `username`이라는 프로퍼티를 가지고 있다.<br>
`username` 프로퍼티 값을 변경하면 `setUsername()`이 호출되고 조회하면 `getUsername()`이 호출된다.

#### 바인딩 오류
`age=abc`처럼 숫자가 들어 가야할 곳에 문자를 넣으면 `BindException`이 발생한다.

#### @ModelAttribute 생략 - modelAttributeV2

```java
/**
 * @ModelAttribute 생략 가능
 * String, int 같은 단순 타입 = @RequestParam
 * argument resolver로 지정해둔 타입 외 = @ModelAttribute
 */
@ResponseBody
@RequestMapping("/model-attribute-v2")
public String modelAttributeV2(HelloData helloData) {
    log.info("username={}, age={}", helloData.getUsername(), helloData.getAge());
    return "ok";
}
```

### HTTP 요청 메시지 - 단순 텍스트
요청 파라미터와 다르게, HTTP 메시지 바디를 통해 데이터가 직접 넘어오는 경우는 `@RequestParam`, `@ModelAttribute`를 사용할 수 없다.
- 먼저 가장 단순한 텍스트 메시지를 HTTP 메시지 바디에 담아서 전송하고 읽어보자.
- HTTP 메시지 바디의 데이터는 `InputStream`을 사용해서 읽을 수 있다.

#### RequestBodyStringController

```java
import java.io.IOException;
import java.nio.charset.StandardCharsets;

@Slf4j
@Controller
public class RequestBodyStringController {

  @PostMapping("/request-body-string-v1")
  public void requestBodyStringV1(HttpServletRequest request, HttpServletResponse response) throws IOException {
    ServletInputStream inputStream = request.getInputStream();
    String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
    
    log.info("messageBody={}", messageBody);
    
    response.getWriter().write("ok");
  }
}
```

#### Input, Output 스트림, Reader - requestBodyStringV2

```java
import java.io.IOException;
import java.io.InputStream;
import java.io.Writer;
import java.nio.charset.StandardCharsets;

/**
 * InputStream(Reader): HTTP 요청 메시지 바디의 내용을 직접 조회
 * OutputStream(Writer): HTTP 응답 메시지의 바디에 직접 결과 출력
 */
@PostMapping("/request-body-string-v2")
public void requestBodyStringV2(InputStream inputStream, Writer responseWriter) throws IOException {
    String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
    
    log.info("messageBody={}", messageBody);
    responseWriter.write("ok");
}
```

#### HttpEntity - requestBodyStringV3

```java
@PostMapping("/request-body-string-v3")
public HttpEntity<String> requestBodyStringV3(HttpEntity<String> httpEntity) {
    String messageBody = httpEntity.getBody();
    log.info("messageBody={}", messageBody);
    
    return new HttpEntity<>("ok");
}
```
스프링 MVC는 다음 파라미터를 지원한다.
- **HttpEntity**: HTTP header, body 정보를 편하게 조회
  - 메시지 바디 정보를 직접 조회
  - 요청 파라미터를 조회하는 기능과는 관계가 없다.
- **HttpEntity는 응답에도 사용 가능하다.**
  - 메시지 바디 정보 직접 반환
  - 헤더 정보 포함 가능
  - view 조회 X

`HttpEntity`를 상속받은 다음 객체들도 같은 기능을 제공한다.
- **RequestEntity**
  - HttpMethod, url 정보가 추가. 요청에서 사용
- **ResponseEntity**
  - HTTP 상태 코드 설정 가능. 응답에서 사용
  - `return new ResponseEntity<String>("Hello World", responseheaders, HttpStatus.CREATED);`

#### @RequestBody - requestBodyStringV4

```java
/**
 * @RequestBody
 * - 메시지 바디 정보를 직접 조회(@RequestParam X, @ModelAttribute X)
 * - HttpMessageConverter 사용 -> StringHttpMessageConverter 적용
 * 
 * @ResponseBody
 * - 메시지 바디 정보 직접 반환(view 조회 X)
 * - HttpMessageConverter 사용 -> StringHttpMessageConverter 적용
 */
@ResponseBody
@PostMapping("/request-body-string-v4")
public String requestBodyStringV4(@RequestBody String messageBody) {
    log.info("messageBody={}", messageBody);
    return "ok";
}
```
**@RequestBody**<br>
`@RequestBody`를 사용하면 HTTP 메시지 바디 정보를 편리하게 조회할 수 있다. 헤더 정보가 필요하면 `HttpEntity`를 사용하거나 `@RequestHeader`를 사용하면 된다.

### HTTP 요청 메시지 - JSON

#### RequestBodyJsonController

```java
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * {"username":"hello", "age":20}
 * content-type: application/json
 */
@Slf4j
@Controller
public class RequestBodyJsonController {

    private ObjectMapper objectMapper = new ObjectMapper();
  
    @PostMapping("/request-body-json-v1")
    public void requestBodyJsonV1(HttpServletRequest request, HttpServletResponse response) throws IOException {
      ServletInputStream inputStream = request.getInputStream();
      String messageBody = StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8);
      
      log.info("messageBody={}", messageBody);
      HelloData data = objectMapper.readValue(messageBody, HelloData.class);
      log.info("username={}, age={}", data.getUsername(), data.getAge());
      
      response.getWriter().write("ok");
    }
}
```
- HttpServletRequest를 사용해서 직접 HTTP 메시지 바디에서 데이터를 읽어와서 문자로 변환한다.
- 문자로 된 JSON 데이터를 Jackson 라이브러리인 `objectMapper`를 사용해서 자바 객체로 변환한다.

#### requestBodyJsonV2 - @RequestBody 문자 변환

```java
import java.io.IOException;

/**
 * @RequestBody
 * HttpMessageConverter 사용 -> StringHttpMessageConverter 적용
 * 
 * @ResponseBody
 * - 모든 메서드에 @ResponseBody 적용
 * - 메시지 바디 정보 직접 반환(view 조회 X)
 * - HttpMessageConverter 사용 -> StringHttpMessageConverter 적용
 */
@ResponseBody
@PostMapping("/request-body-json-v2")
public String requestBodyJsonV2(@RequestBody String messageBody) throws IOException {
    HelloData data = objectMapper.readValue(messageBody, HelloData.class);
    log.info("username={}, age={}", data.getUsername(), data.getAge());
    return "ok";
}
```

**문자로 변환하고 다시 json으로 변환하는 과정이 불편하다. @ModelAttribute처럼 한 번에 객체로 변환할 수는 없을까?**

#### requestBodyJsonV3 - @RequestBody 객체 변환

```java
/**
 * @RequestBody는 생략 불가능 (@ModelAttribute가 적용되어 버린다.)
 * HttpMessageConverter 사용 -> MappingJackson2HttpMessageConverter (content-type: application/json)
 */
@ResponseBody
@PostMapping("/request-body-json-v3")
public String requestBodyJsonV3(@RequestBody HelloData data) {
    log.info("username={}, age={}", data.getUsername(), data.getAge());
    return "ok";
}
```
@RequestBody 객체 파라미터
- `@RequestBody HelloData data`
- `@RequestBody`에 직접 만든 객체를 지정할 수 있다.

#### requestBodyJsonV4 - HttpEntity

```java
@ResponseBody
@PostMapping("/request-body-json-v4")
public String requestBodyJsonV4(HttpEntity<HelloData> httpEntity) {
    HelloData data = httpEntity.getBody();
    log.info("username={}, age={}", data.getUsername(), data.getAge());
    return "ok";
}
```

#### requestBodyJsonV5

```java
@ResponseBody
@PostMapping("/request-body-json-v5")
public HelloData requestBodyJsonV5(@RequestBody HelloData data) {
    log.info("username={}, age={}", data.getUsername(), data.getAge());
    return data;
}
```
`@ResponseBody`<br>
응답의 경우에도 `@ResponseBody`를 사용하면 해당 객체를 HTTP 메시지 바디에 직접 넣어줄 수 있다.<br>
물론 이 경우에도 `HttpEntity`를 사용해도 된다.

- `@RequestBody` 요청
  - JSON 요청 -> HTTP 메시지 컨버터 -> 객체
- `@ResponseBody` 응답
  - 객체 -> HTTP 메시지 컨버터 -> JSON 응답

### HTTP 응답 - 정적 리소스, 뷰 템플릿
스프링(서버)에서 응답 데이터를 만드는 방법은 크게 3가지이다.
- 정적 리소스
  - 예시. 웹 브라우저에 정적인 HTML, css, js를 제공할 때는 정적 리소스를 사용한다.
- 뷰 템플릿 사용
  - 예시. 웹 브라우저에 동적인 HTML을 제공할 때는 뷰 템플릿을 사용한다.
- HTTP 메시지 사용
  - HTTP API를 제공하는 경우에는 HTML이 아니라 데이터르 전달해야 하므로, HTTP 메시지 바디에 JSON 같은 형식으로 데이터를 실어 보낸다.

#### 정적 리소스
스프링 부트는 클래스 패스의 다음 디렉토리에 있는 정적 리소스를 제공한다.<br>
`/static`, `/public`, `/resources`, `/META-INF/resources`<br><br>

`/src/main/resources`는 리소스를 보관하는 곳이고, 클래스 패스의 시작 경로이다.<br>
따라서 다음 디렉토리에 리소스를 넣어두면 스프링 부트가 정적 리소스를 서비스를 제공한다.

#### 정적 리소스 경로
`src/main/resources/static`

#### 뷰 템플릿
뷰 템플릿을 거쳐서 HTML이 생성되고, 뷰가 응답을 만들어서 전달한다.<br>
스프링 부트는 기본 뷰 템플릿 경로를 제공한다.

#### 뷰 템플릿 경로
`/src/main/resources/templates`

#### ResponseViewController - 뷰 템플릿을 호출하는 컨트롤러

```java
@Controller
public class ResponseViewController {
    
    @RequestMapping("/response-view-v1")
    public ModelAndView responseViewV1() {
        ModelAndView mav = new ModelAndView("response/hello")
                .addObject("data", "hello!");
        
        return mav;
    }
    
    @RequestMapping("/response-view-v2")
    public String responseViewV2(Model model) {
        model.addAttribute("data", "hello!!");
        return "response/hello";
    }
    
    @RequestMapping("/response/hello")
    public void responseViewV3(Model model) {
        model.addAttribute("data", "hello!!");
    }
}
```

#### String을 반환하는 경우 - View or HTTP 메시지
`@ResponseBody`가 없으면 `response/hello`로 뷰 리졸버가 실행되어, 뷰를 찾고 렌더링 한다.<br>
`@ResponseBody`가 있으면 뷰 리졸버를 실행하지 않고, HTTP 메시지 바디에 직접 `response/hello`라는 문자가 입력된다.<br><br>

여기서는 뷰의 논리 이름인 `response/hello`를 반환하면 다음 경로의 뷰 템플릿이 렌더링 되는 것을 확인할 수 있다.
- 실행: `templates/response/hello.html`

#### void를 반환하는 경우
- `@Controller`를 사용하고, `HttpServletResponse`, `OutputStream(Writer)` 같은 HTTP 메시지 바디를 처리하는 파라미터가 없으면 요청 URL을 참고해서 논리 뷰 이름으로 사용
  - 요청 URL: `/response/hello`
  - 실행: `templates/response/hello.html`
- **참고로 이 방식은 명시성이 너무 떨어지고 이렇게 딱 맞는 경우도 많이 없어서 권장하지 않는다.**

#### HTTP 메시지
`@ResponseBody`, `HttpEntity`를 사용하면, 뷰 템플릿을 사용하는 것이 아니라 HTTP 메시지 바디에 직접 응답 데이터를 출력할 수 있다.

### HTTP 응답 - HTTP API, 메시지 바디에 직접 입력
HTTP APi를 제공하는 경우에는 HTML이 아니라 데이터를 전달해야 하므로, HTTP 메시지 바디에 JSON 같은 형식으로 데이터를 실어 보낸다.

#### ResponseBodyController

```java
import java.io.IOException;

@Slf4j
@Controller
public class ResponseBodyController {

    @GetMapping("/response-body-string-v1")
    public void responseBodyV1(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.getWriter().write("ok");
    }

    /**
     * HttpEntity, ResponseEntity(Http Status 추가)
     * @return
     */
    @GetMapping("/response-body-string-v2")
    public ResponseEntity<String> responseBodyV2() {
        return new ResponseEntity<>("ok", HttpStatus.OK);
    }
    
    @ResponseBody
    @GetMapping("/response-body-string-v3")
    public String responseBodyV3() {
        return "ok";
    }
    
    @GetMapping("/response-body-json-v1")
    public ResponseEntity<HelloData> responseBodyJsonV1() {
        HelloData helloData = new HelloData();
        helloData.setUsername("userA");
        helloData.setAge(20);
        
        return new ResponseEntity<>(helloData, HttpStatus.OK);
    }
    
    @ResponseStatus(HttpStatus.OK)
    @ResponseBody
    @GetMapping("/response-body-json-v2")
    public HelloData responseBodyJsonV2() {
        HelloData helloData = new HelloData();
        helloData.setUsername("userA");
        helloData.setAge(20);
        
        return helloData;
    }
}
```

- responseBodyV1
  - 서블릿을 직접 다룰 때 처럼 HttpServletResponse 객체를 통해서 HTTP 메시지 바디에 직접 `ok` 응답 메시지를 전달한다.
  - `response.getWriter().write("ok")`
- responseBodyV2
  - `ResponseEntity`는 `HttpEntity`를 상속 받았는데, HttpEntity는 HTTP 메시지의 헤더, 바디 정보를 가지고 있다. `ResponseEntity`는 HTTP 응답 코드를 설정할 수 있다.
  - `HttpStatus.CREATE`로 변경하면 201 응답이 나가는 것을 확인할 수 있다.
- responseBodyV3
  - `@ResponseBody`를 사용하면 view를 사용하지 않고, HTTP 메시지 컨버터를 통해서 HTTP 메시지를 직접 입력할 수 있다.
  - `ResponseEntity`도 동일한 방식으로 동작한다.
- responseBodyJsonV1
  - `ResponseEntity`를 반환한다. HTTP 메시지 컨버터를 통해서 JSON 형식으로 변환되어서 반환한다.
- responseBodyJsonV2
  - `ResponseEntity`는 HTTP 응답 코드를 설정할 수 있는데, `@ResponseBody`를 사용하면 이런 것을 설정하기가 까다롭다.
  - `@ResponseStatus(HttpStatus.OK)` 애노테이션을 사용하면 응답 코드도 설정할 수 있다.
  - 물론 애노테이션이기 때문에 응답 코드를 동적으로 변경할 수는 없다. 프로그램 조건에 따라서 동적으로 변경하려면 `ResponseEntity`를 사용하면 된다.
- @RestController
  - `@Controller` 대신에 `@RestController` 애노테이션을 사용하면, 해당 컨트롤러에 모두 `@ResponseBody`가 적용되는 효과가 있다.
  - 이름 그대로 REST API(HTTP API)를 만들 때 사용하는 컨트롤러이다.

### HTTP 메시지 컨버터

#### @ResponseBody 사용 원리
- `@ResponseBody`를 사용
  - HTTP의 body에 문자 내용을 직접 반환
  - `viewResolver` 대신에 `HttpMessageConverter`가 동작
  - 기본 문자처리: `StringHttpMessageConverter`
  - 기본 객체처리: `MappingJackson2HttpMessageConverter`
  - byte 처리 등, 기타 여러 HttpMessageConverter가 기본으로 등록되어 있다.

#### 스프링 MVC는 다음 경우에 HTTP 메시지 컨버터를 적용한다.
- HTTP 요청: `@RequestBody`, `HttpEntity(RequestEntity)`
- HTTP 응답: `@ResponseBody`, `HttpEntity(ResponseEntity)`

#### HTTP Message Converter Interface
`org.springframework.http.converter.HttpMessageConverter`

```java
import java.awt.PageAttributes.MediaType;
import java.io.IOException;
import java.util.List;

public interface HttpMessageConverter<T> {

  boolean canRead(Class<?> clazz, @Nullable MediaType mediaType);

  boolean canWrite(Class<?> clazz, @Nullable MediaType mediaType);

  List<MediaType> getSupportedMediaTypes();

  T read(Class<? extends T> clazz, HttpInputMessage inputMessage) throws IOException, HttpMessageNotReadableException;
  void write(T t, @Nullable MediaType contentType, HttpOutputMessage outputMessage) throws IOException, HttpMessageNotWritableException;
}
```
HTTP 메시지 컨버터는 HTTP 요청, HTTP 응답 둘 다 사용된다.
- `canRead()`, `canWrite()`: 메시지 컨버터가 해당 클래스, 미디어 타입을 지원하는 지 체크
- `read()`, `write()`: 메시지 컨버터를 통해서 메시지를 읽고 쓰는 기능

#### 스프링 부트 기본 메시지 컨버터
0 = ByteArrayHttpMessageConverter<br>
1 = StringHttpMessageConverter<br>
2 = MappingJackson2HttpMessageConverter<br><br>

스프링 부트는 다양한 메시지 컨버터를 제공하는데, 대상 클래스 타입과 미디어 타입을 체크해서 사용 여부를 결정한다. 만약 만족하지 않으면 다음 메시지 컨버터로 우선 순위가 넘어간다.

- `ByteArrayHttpMessageConverter`: `byte[]` 데이터를 처리한다.
  - 클래스 타입: `byte[]`, 미디어 타입: `*/*`
  - 요청 예시. `@RequestBody byte[] data`
  - 응답 예시. `@ResponseBody return byte[]` 쓰기 미디어 타입 `application/octet-stream`
- `StringHttpMessageConverter`: `String` 문자로 데이터를 처리한다.
  - 클래스 타입: `String`, 미디어 타입: `*/*`
  - 요청 예시. `@RequestBody String data`
  - 응답 예시. `@ResponseBody return "ok"` 쓰기 미디어 타입 `text/plain`
- `MappingJackson2HttpMessageConverter`: application/json
  - 클래스 타입: 객체 또는 `HashMap`, 미디어 타입: `application/json` 관련
  - 요청 예시. `@RequestBody HelloData data`
  - 응답 예시. `@ResponseBody return helloData` 쓰기 미디어 타입 `application/json` 관련

#### HTTP 요청 데이터 읽기
- HTTP 요청이 오고, 컨트롤러에서 `@RequestBody`, `HttpEntity` 파라미터를 사용한다.
- 메시지 컨버터가 메시지를 읽을 수 있는지 확인하기 위해 `canRead()`를 호출한다.
  - 대상 클래스 타입을 지원하는가
    - 예시. `@RequestBody`의 대상 클래스 (`byte[]`, `String`, `HelloData`)
  - HTTP 요청의 Content-Type 미디어 타입을 지원하는가
    - 예시. `text/plain`, `application/json`, `*/*`
- `canRead()` 조건을 만족하면 `read()`를 호출해서 객체를 생성하고 반환한다.

#### HTTP 응답 데이터 생성
- 컨트롤러에서 `@ResponseBody`, `HttpEntity`로 같이 반환된다.
- 메시지 컨버터가 메시지를 쓸 수 있는지 확인하기 위해 `canWrite()`를 호출한다.
  - 대상 클래스 타입을 지원하는가
    - 예시. return 대상 클래스 (`byte[]`, `String`, `HelloData`)
  - HTTP 요청의 Accept 미디어 타입을 지원하는가(더 정확히는 `@RequestMapping`의 `produces`)
    - 예시. `text/plain`, `application/json`, `*/*`
- `canWrite()` 조건을 만족하면 `write()`를 호출해서 HTTP 응답 메시지 바디에 데이터를 생성한다.

### 요청 매핑 핸들러 어댑터 구조
HTTP 메시지 컨버터는 스프링 MVC 어디쯤에서 사용되는 것일까?<br>
모든 비밀은 `@RequestMapping`을 처리하는 핸들러 어댑터인 `RequestMappingHandlerAdapter`(요청 매핑 핸들러 어댑터)에 있다.

#### RequestMappingHandlerAdapter 동작 방식
1. `ArgumentResolver`를 호출하여 컨트롤러(핸들러)가 필요로 하는 다양한 파라미터의 값(객체)을 생성한다.
2. 파라미터의 값이 모두 준비되면 컨트롤러를 호출하면서 값을 넘겨준다.
3. `ReturnValueHandler`에서 컨트롤러의 반환 값을 변환한다.
   - 예시. ModelAndView, @ResponseBody, HttpEntity

스프링은 30개가 넘는 `ArgumentResolver`를 기본으로 제공한다.

#### HandlerMethodArgumentResolver(ArgumentResolver) Interface

```java
public interface HandlerMethodArgumentResolver {
    
    boolean supportsParameter(MethodParameter parameter);
    
    @Nullable
    Object resolveArgument(MethodParameter parameter, 
                           @Nullable ModelAndViewContainer mavContainer,
                           NativeWebRequest webRequest,
                           @Nullable WebDataBinderFactory binderFactory) throws Exception;
}
```

#### 동작 방식
`ArgumentResolver`의 `supportsParameter()`를 호출해서 해당 파라미터를 지원하는지 체크하고, 지원한다면 `resolveArgument()`를 호출해서 실제 객체를 생성한다.

#### ReturnValueHandler
`HandlerMethodReturnValueHandler`를 줄여서 `ReturnValueHandler`라 부른다.<br>
`ArgumentResolver`와 비슷한데, 이것은 응답 값을 변환하고 처리한다.<br><br>

컨트롤러에는 String으로 뷰 이름을 반환해도, 동작하는 이유가 바로 ReturnValueHandler 덕분이다.<br>
스프링은 10여 개가 넘는 `ReturnValueHandler`를 지원한다.(`ModelAndView`, `@ResponseBody`, `HttpEntity`, `String`, ...)

#### HTTP 메시지 컨버터 위치
HTTP 메시지 컨버터를 사용하는 `@RequestBody`도 컨트롤러가 필요로 하는 파라미터 값에 사용된다.<br>
`@ResponseBody`의 경우도 컨트롤러 반환 값을 이용한다.

- **요청의 경우**
  - `@RequestBody`를 처리하는 `ArgumentResolver`가 있고, `HttpEntity`를 처리하는 `ArgumentResolver`가 있다.
  - 이 `ArgumentResolver`들이 HTTP 메시지 컨버터를 사용해서 필요한 객체를 생성하는 것이다.
- **응답의 경우**
  - `@ResponseBody`와 `HttpEntity`를 처리하는 `ReturnValueResolver`가 있다.
  - 그리고 여기에서 HTTP 메시지 컨버터를 호출해서 응답 결과를 만든다.