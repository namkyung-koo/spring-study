## 타임리프 - 기본 기능

### 타임리프 소개
- 공식 사이트: https://www.thymeleaf.org/
- 공식 메뉴얼 - 기본 기능: https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html
- 공식 메뉴얼 - 스프링 통합: https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html

#### 타임리프 특징
- **서버 사이드 HTML 렌더링(SSR)**
  - 타임리프는 백엔드 서버에서 HTML을 동적으로 렌더링 하는 용도로 사용된다.
- **네츄럴 템플릿**
  - 타임리프는 순수 HTML을 최대한 유지하는 특징이 있다.
- **스프링 통합 지원**
  - 타임리프는 스프링과 자연스럽게 통합되고, 스프링의 다양한 기능을 편리하게 사용할 수 있게 지원한다.

#### 타임리프 사용 선언
`<html xmlns:th="http://www.thymeleaf.org">`

#### 타임리프 - 기본 표현식
- 간단한 표현
  - 변수 표현식: ${...}
  - 선택 변수 표현식: *{...}
  - 메시지 표현식: #{...}
  - 링크 URL 표현식: @{...}
  - 조각 표현식: ~{...}
- 리터럴
  - 텍스트: 'one text', 'Another one!', ...
  - 숫자: 0, 34, 3.0, 12.3, ...
  - 불린: true, false
  - 널: null
  - 리터럴 토큰: one, sometext, main, ...
- 문자 연산
  - 문자 합치기: +
  - 리터럴 대체: |The name is ${name}|
- 산술 연산
  - Binary operators: +, -, *, /, %
  - Minus sign (unary operator): -
- 불린 연산
  - Binary operators: and, or
  - Boolean negation (unary operator): !, not
- 비교와 동등
  - 비교: >, <, >=, <=(gt, lt, ge, le)
  - 동등 연산: ==, != (eq, ne)
- 조건 연산
  - If-then: (if) ? (then)
  - If-then-else: (if) ? (then) : (else)
  - Default: (value) ?: (defaultvalue)
- 특별한 토큰
  - No-Operation: _

### 텍스트 - text, utext
타임리프는 기본적으로 HTML 태그의 속성에 기능을 정의해서 동작한다. HTML의 콘텐츠(content)에 데이터를 출력할 때는 다음과 같이 `th:text`를 사용하면 된다.<br>
`<span th:text="${data}">`<br><br>

HTML 태그의 속성이 아니라 HTML 콘텐츠 영역 안에서 직접 데이터를 출력하고 싶으면 다음과 같이 `[[...]]`를 사용하면 된다.<br>
`컨텐츠 안에서 직접 출력하기 = [[${data}]]`

#### BasicController

```java
@Controller
@RequestMapping("/basic")
public class BasicController {
    /* ... */
}
```

#### Escape
`<b>` 태그를 사용해서 Spring!이라는 단어가 진하게 나오도록 해보자.

- 웹 브라우저: `Hello <b>Spring!</b>`
  - 개발자의 의도와 다르게 `<b>` 태그가 그대로 나온다.
- 소스 보기: `Hello $lt;b&gt;Spring!&lt;/b&gt;`

#### HTML 엔티티
웹 브라우저는 `<`를 HTML 태그의 시작으로 인식한다. 따라서 `<`를 태그의 시작이 아니라 문자로 표현할 수 있는 방법이 필요한데, 이것을 HTML 엔티티라 한다.<br>
그리고 이렇게 HTML에서 시용하는 특수 문자를 HTML 엔티티로 변경하는 것을 이스케이프(escape)라 한다. 타임리프가 제공하는 `th:text`, `[[...]]`는 **기본적으로 이스케이프를 제공**한다.

- `<` -> `&lt;`
- `>` -> `&gt;`
- 기타 수 많은 HTML 엔티티가 있다.

#### Unescape
타임리프는 다음 두 기능을 제공한다.
- `th:text` -> `th:utext`
- `[[...]]` -> `[(...)]`

#### /resources/templates/basic/text-unescaped.html
```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>

<h1>text vs utext</h1>
<ul>
    <li>th:text = <span th:text="${data}"></span></li>
    <li>th:utext = <span th:utext="${data}"></span></li>
</ul>

<h1><span th:inline="none">[[...]] vs [(...)]</span></h1>
<ul>
    <li><span th:inline="none">[[...]] = </span>[[${data}]]</li>
    <li><span th:inline="none">[(...)] = </span>[(${data})]</li>
</ul>

</body>
</html>
```
- `th:inline="none"`: 타임리프는 `[[...]]`를 해석하기 때문에, 화면에 `[[...]]` 글자를 보여줄 수 없다. 이 태그 안에서는 타임리프가 해석하지 말라는 옵션이다.

실행 결과
- 웹 브라우저: Hello **Spring!**
- 소스 보기: `Hello <b>Spring!</b>`

### 변수 - SpringEL
타임리프에서 변수를 사용할 때는 변수 표현식(`${...}`)을 사용한다.<br><br>

그리고 이 변수 표현식에는 스프링 EL이라는 스프링이 제공하는 표현식을 사용할 수 있다.

#### SpringEL - 다양한 표현식 사용

- **Object**
  - `user.username`: user의 username을 프로퍼티 접근 -> `user.getUsername()`
  - `user['username']`: 위와 같다 -> `user.getUsername()`
  - `user.getUsername()`: user의 `getUsername()`을 직접 호출
- **List**
  - `users[0].username`: List에서 첫 번째 회원을 찾고 username 프로퍼티 접근 -> `list.get(0).getUsername()`
  - `users[0]['username']`: 위와 같다.
  - `users[0].getUsername()`: List에서 첫 번째 회원을 찾고 메서드 직접 호출
- **Map**
  - `userMap['userA'].username`: Map에서 userA를 찾고, username 프로퍼티 접근 -> `map.get("userA").getUsername()`
  - `userMap['userA']['username']`: 위와 같다.
  - `userMap['userA'].getUsername()`: Map에서 userA를 찾고 메서드 직접 호출

#### 자역 변수 선언
`th:with`를 사용하면 지역 변수를 선언해서 사용할 수 있다. 지역 변수는 선언한 태그 안에서만 사용할 수 있다.

#### /resources/templates/basic/variable.html에 추가

```html
<h1>지역 변수 - (th:with)</h1>
<div th:with="first=$(users[0])"
    <p>처음 사람의 이름은 <span th:text="${first.username}"></span></p>
</div>
```

### 기본 객체들
타임리프는 스프링 부트 3.0부터 더 이상 기본 객체를 제공하지 않는다.<br>
편의 객체는 사용할 수 있다

- HTTP 요청 파라미터 접근: `param`
  - 예시. `${param.paramData}`
- HTTP 세션 접근: `session`
  - 예시. `${session.sessionData}`
- 스프링 빈 접근: `@`
  - 예시. `${@helloBean.hello('Spring!)}`

#### BasicController 추가 - 스프링 부트 3.0 이상

```java
@GetMapping("/basic-objects")
public String basicObjects(Model model, HttpServletRequest request, HttpServletResponse response, HttpSession session) {
    session.setAttribute("sessionData", "Hello Session");
    model.addAttribute("request", request);
    model.addAttribute("response", response);
    model.addAttribute("servletContext", request.getServletContext());
    return "basic/basic-objects";
}

@Component("helloBean")
static class HelloBean {
    public String hello(String data) {
        return "Hello" + data;
    }
}
```

### 유틸리티 객체와 날짜
타임리프는 문자, 숫자, 날짜, URI 등을 편리하게 다루는 다양한 유틸리티 객체들을 제공한다.

#### 타임리프 유틸리티 객체들
- `#message`: 메시지, 국제화 처리
- `#uris`: URI 이스케이프 지원
- `#dates`: `java.util.Date` 서식 지원
- `#calendars`: `java.util.Calendar` 서식 지원
- `#temporals`: 자바8 날짜 서식 지원
- `#numbers`: 숫자 서식 지원
- `#strings:` 문자 관련 편의 기능
- `#objects`: 객체 관련 기능 제공
- `#bools`: boolean 관련 기능 제공
- `#arrays`: 배열 관련 기능 제공
- `#lists`, `#sets`, `#maps`: 컬렉션 관련 기능 제공
- `#ids`: 아이디 처리 관련 기능 제공

### URL 링크
타임리프에서 URL을 생성할 때는 `@{...}` 문법을 사용하면 된다.

- 단순한 URL
  - `@{/hello}` -> '/hello'
- 쿼리 파라미터
  - `@{/hello(param1=${param1}}, param2=${param2})}`
    - `/hello?param1=data1&param2=data2`
    - `()`에 있는 부분은 쿼리 파라미터로 처리된다.
- 경로 변수
  - `@{/hello/{param1}/{param2}(param1=${param1}, param2=${param2})}`
  - `/hello/data1/data2`
  - URL 경로 상에 변수가 있으면 `()` 부분은 경로 변수로 처리된다.
- 경로 변수 + 쿼리 파라미터
  - `@{/hello/{param1}(param1=${param1}, param2=${param2})}`
  - `/hello/data1?param2=data2`
  - 경로 변수와 쿼리 파라미터를 함께 사용할 수 있다.

상대 경로, 절대 경로, 프로토콜 기준을 표현할 수도 있다.
- `/hello`: 절대 경로
- `hello`: 상대 경로
  
### 리터럴
리터럴은 소스 코드 상에 고정된 값을 말하는 용어이다.<br>
예를 들어서 다음 코드에서 `"Hello"`는 문자 리터럴, `10`, `20`는 숫자 리터럴이다.
- String a = "Hello"
- int a = 10 * 20

타임리프에는 다음과 같은 리터럴이 있다.
- 문자: `'hello'`
- 숫자: `10`
- 불린: `true`, `false`
- null: `null`

타임리프에서 문자 리터럴은 항상 작은 따옴표로 감싸야 한다.<br>
그런데 문자를 항상 작음 따옴표로 감싸는 것은 너무 귀찮을 일이다. **공백 없이 쭉 이어진다면 하나의 의미있는 토큰으로 인지해서 작은 따옴표를 생략할 수 있다.**<br>
- 예시. `<span th:text="hello">`

#### 리터럴 대체(Literal substitutions)
`<span th:text="|hello ${data}|">`<br>
리터럴 대체 문법을 사용하면 마치 템플릿을 사용하는 것처럼 편리하다.

### 연산
타임리프 연산은 자바와 크게 다르지 않다. HTML 안에서 사용하기 때문에 HTML 엔티티를 사용하는 부분만 주의하자

- 비교 연산: HTML 엔티티를 사용해야 하는 부분을 주의하자
  - `>`(gt), `<`(lt), `>=`(ge), `<=`(le), `!`(not), `==`(eq), `!=`(neq, ne)
- 조건식: 자바의 조건식과 유사하다.
- Elvis 연산자: 조건식의 편의 버전
- No-Operation: `_`인 경우 마치 타임리프가 실행되지 않는 것처럼 동작한다. 이것을 잘 사용하면 HTML의 내용 그대로 사용할 수 있다.

### 속성 값 설정

#### 타임리프 태그 속성(Attribute)
타임리프는 주로 HTML 태그에 `th:*` 속성을 지정하는 방식으로 동작한다. `th:*`로 속성을 적용하면 기존 속성을 대체한다.

#### 속성 설정
`th:x` 속성을 지정하면 타임리프는 기존 속성을 `th:x`로 지정한 속성으로 대체한다. 기존 속성이 없다면 새로 만든다.<br>
`<input type="text name="mock" th:name="userA" />` -> `<input type="text name=userA />`

#### 속성 추가
- `th:attrappend`: 속성 값의 뒤에 값을 추가한다.
- `th:attrprepend`: 속성 값의 앞에 값을 추가한다.
- `th:classappend`: class 속성에 자연스럽게 추가한다.

#### checked 처리
HTML에서는 `<input type="checkbox" name="active" checked="false />`의 경우에도 checked 속성이 있기 때문에 checked 처리가 되어버린다.<br><br>

HTML에서 `checked` 속성은 `checked` 속성의 값과 상관없이 체크가 된다. 이런 부분은 `true`, `false` 값을 주로 사용하는 개발자 입장에서는 불편한다.<br><br>

타임리프의 `th:checked`는 값이 false인 경우 `checked` 속성 자체를 제거한다.<br>
`<input type="checkbox" name="active" th:checked="false" />` -> `<input type="checkbox" name="active" />`

### 반복
타임리프에서 반복은 `th:each`를 사용한다. 추가로 반복에서 사용할 수 있는 여러 상태 값을 지원한다.

#### 반복 가능
`<tr th:each="user : ${users}">`
- 반복 시 오른쪽 컬렉션(`${users}`)의 값을 하나씩 꺼내서 왼쪽 변수(`user`)에 담아서 태그를 반복 실행한다.
- `th:each`는 `List` 뿐만 아니라 배열, `java.util.Iterable`, `java.util.Enumeration`을 구현한 모든 객체를 반복에 사용할 수 있다. `Map`도 사용할 수 있는데 이 경우 변수에 담기는 값은 `Map.Entry`이다.

#### 반복 상태 유지
`<tr th:each="user, userStat : ${users}`
- 반복의 두 번째 파라미터를 설정해서 반복의 상태를 확인할 수 있다.
- 두 번째 파라미터는 생략이 가능한데, 생략하면 지정한 변수명(user) + Stat가 된다.
- 여기서는 `user` + `Stat` = `userStat`이므로 생략이 가능하다.

#### 반복 상태 유지 기능
- index: 0부터 시작하는 값
- count: 1부터 시작하는 값
- size: 전체 사이즈
- even, odd: 홀수, 짝수 여부(boolean)
- first, last: 처음, 마지막 여부(boolean)
- current: 현재 객체

### 조건부 평가
타임리프의 조건식 - `if`, `unless`(if의 반대)

#### if, unless
타임리프는 해당 조건이 맞지 않으면 태그 자체를 렌더링하지 않는다.

#### switch
`*`은 만족하는 조건이 없을 때 사용하는 디폴트이다.

### 주석

#### /resources/templates/basic/comments.html

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>

<h1>예시</h1>
<span th:text="${data}">html data</span>

<h1>1. 표준 HTML 주석</h1>
<!--
<span th:text="${data}">html data</span>
-->

<h1>2. 타임리프 파서 주석</h1>
<!--/* [[${data}]] */-->

<!--/*-->
<span th:text="${data}">html data</span>
<!--*/-->

<h1>3. 타임리프 프로토타입 주석</h1>
<!--/*/
<span th:text="${data}">html data</span>
/*/-->

</body>
</html>
```

#### 결과

```html
<h1>예시</h1>
<span>Spring!</span>

<h1>1. 표준 HTML 주석</h1>
<!--
<span th:text="${data}">html data</span>
-->

<h1>2. 타임리프 파서 주석</h1>

<h1>3. 타임리프 프로토타입 주석</h1>
<span>Spring!</span>
```
- 표준 HTML 주석
  - 자바스크립트 표준 HTML 주석은 타임리프가 렌더링 하지 않고, 그대로 남겨둔다.
- 타임리프 파서 주석
  - 타임리프 파서 주석은 타임리프의 진짜 주석이다. 렌더링에서 주석 부분을 제거한다.
- 타임리프 프로토타입 주석
  - 타임리프 프로토타입은 약간 특이한데, HTML 주석에 약간의 구문을 더했다.
  - **HTML 파일**을 웹 브라우저에 그대로 열어보면 HTML 주석이기 때문에 이 부분을 웹 브라우저가 렌더링 하지 않는다.
  - **타임리프 렌더링**을 거치면 이 부분이 정상 렌더링 된다.
  - HTML 파일을 그대로 열어보면 주석 처리가 되지만, 타임리프를 렌더링한 경우에만 보이는 기능이다.

### 블록
`<th:block>`은 HTMl 태그가 아닌 타임리프 유일한 자체 태그다. `<th:block>`은 렌더링 시 제거된다.

### 자바스크립트 인라인
타임리프는 자바스크립트에서 타임리프를 편리하게 사용할 수 있는 자바스크립트 인라인 기능을 제공한다. 자바스크립트 인라인 기능은 다음과 같이 적용하면 된다.<br>
`<script th:inline="javascript">`

#### 텍스트 렌더링
- `var username = [[${user.username}]];`
  - 인라인 사용 전 -> `var username = userA;`
  - 인라인 사용 후 -> `var username = "userA";`
- 인라인 사용 후 렌더링 결과를 보면 문자 타입인 경우 `"`를 포함해준다. 추가로 자바스크립트에서 문제가 될 수 있는 문자가 포함되어 있으면 이스케이프 처리도 해준다.
  - 예시. `"` -> `\"`

#### 객체
타임리프의 자바스크립트 인라인 기능을 사용하면 객체를 JSON으로 자동으로 변환해준다.

### 템플릿 조각
### 템플릿 레이아웃1
### 템플릿 레이아웃2