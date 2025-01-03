## 타임리프 - 스프링 통합과 폼

### 타임리프 스프링 통합

#### 스프링 통합으로 추가되는 기능들
- 스프링의 SpringEL 문법 통합
- `${@myBean.doSomething()}`처럼 스프링 빈 호출 지원
- 편리한 폼 관리를 위한 추가 속성
  - `th:object`(기능 강화, 폼 커맨드 객체 선택)
  - `th:field`, `th:errors`, `th:errorclass`
- 폼 컴포넌트 기능
  - Checkbox, Radio button, List 등을 편리하게 사용할 수 있는 기능 지원
- 스프링의 메시지, 국제화 기능의 편리한 통합
- 스프링의 검증, 오류 처리 통합
- 스프링의 변환 서비스 통합(Conversion Service)

#### 스프링 부트의 자동화
- `build.gradle`
  - `implementation 'org.springframework.boot:spring-boot-starter=thymeleaf'`
- 타임리프 관련 설정 변경
  - `application.properties`에 관련 내용을 추가하면 된다.

### 입력 폼 처리
타임리프가 제공하는 입력 폼 기능을 적용하여 기존 프로젝트 폼 코드를 개선해보자.

- `th:object`: 커맨드 객체를 지정한다.
- `*{...}`: 선택 변수 식이라고 한다. `th:object`에서 선택한 객체에 접근한다.
- `th:field`: HTML 태그의 `id`, `name`, `value` 속성을 자동으로 처리해준다.
- **렌더링 전**
  - `<input type="text" th:field="*{itemName}" />`
- **렌더링 후**
  - `<input type="text" id="itemName" name="itemName" th:value="*{itemName}" />`

#### 등록 폼
`th:object`를 적용하려면 먼저 해당 오브젝트 정보를 넘겨주어야 한다.

#### FormItemController 변경

```java
@GetMapping("/add")
public String addForm(Model model) {
    model.addAttribute("item", new Item());
    return "form/addForm";
}
```

#### `form/addForm.html` 변경 코드 부분

```html
<form action="item.html" th:action th:object="${item}" method="post">
    <div>
        <label for="itemName">상품명</label>
        <input type="text" id="itemName" th:field="*{itemName}" class="form-control" placeholder="이름을 입력하세요">
    </div>
    <div>
        <label for="price">가격</label>
        <input type="text" id="price" th:field="*{price}" class="form-control" placeholder="가격을 입력하세요">
    </div>
    <div>
        <label for="quantity">수량</label>
        <input type="text" id="quantity" th:field="*{quantity}" class="form-control" placeholder="수량을 입력하세요">
    </div>
</form>
```
- `th:object="${item}"`: `<form>`에서 사용할 객체를 지정한다. 선택 변수 식(`*{...}`)을 적용할 수 있다.
- `th:field="*{itemName}"`
  - `*{itemName}`는 선택 변수 식을 사용했는데, `${item.itemName}`과 같다. 앞서 `th:object`로 `item`을 선택했기 때문에 선택 변수 식을 사용할 수 있다.
  - `th:field`는 `id`, `name`, `value` 속성을 모두 자동으로 만들어준다.
    - `id`: `th:field`에서 지정한 변수 이름과 같다. `id="itemName"`
    - `name`: `th:field`에서 지정한 변수 이름과 같다. `name="itemName"`
    - `value`: `th:field`에서 지정한 변수의 값을 사용한다. `value=""`

#### 수정 폼
- FormItemController 유지
- 수정 폼의 경우 `id`, `name`, `value`를 모두 신경써야 했는데, 많은 부분이 `th:field` 덕분에 자동으로 처리된다.

### 요구사항 추가
타임리프를 사용해서 폼에서 체크박스, 라디오 버튼, 셀렉트 박스를 편리하게 사용하는 방법을 학습해보자.

- 판매 여부
  - 판매 오픈 여부
  - 체크 박스로 선택할 수 있다.
- 등록 지역
  - 서울, 부산, 제주
  - 체크 박스로 다중 선택할 수 있다.
- 상품 종류
  - 도서, 식품, 기타
  - 라디오 버튼으로 하나만 선택할 수 있다.
- 배송 방식
  - 빠른 배송, 일반 배송, 느린 배송
  - 셀렉트 박스로 하나만 선택할 수 있다.

#### ItemType - 상품 종류

```java
public enum ItemType {
    
    BOOK("도서"), FOOD("식품"), ETC("기타");
    
    private final String description;
    
    ItemType(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}
```

#### DeliveryCode - 배송 방식

```java
import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * FAST: 빠른 배송
 * NORMAL: 일반 배송
 * SLOW: 느린 배송
 */
@Data
@AllArgsConstructor
public class DeliveryCode {
    private String code; // FAST, NORMAL, SLOW
    private String displayName; // "빠른 배송", "일반 배송", "느린 배송"
}
```

#### Item - 상품

```java
import lombok.Data;

import java.util.List;

@Data
public class Item {
    
    private Long id;
    private String itemName;
    private Integer price;
    private Integer quantity;
    
    private Boolean open; // 판매 여부
    private List<String> regions; // 등록 지역
    private ItemType itemType; // 상품 종류
    private String deliveryCode; // 배송 방식
    
    public Item() {
    }
    
    public Item(String itemName, Integer price, Integer quantity) {
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
    }
}
```

### 체크 박스 - 단일1

#### 단순 HTML 체크 박스 - `resources/templates/form/addForm.html` 추가

```html
<hr class="my-4">

<!-- single checkbox -->
<div>판매 여부</div>
<div>
    <div class="form-check">
        <input type="checkbox" id="open" name="open" class="form-check-input">
        <label for="open" class="form-check-label">판매 오픈</label>
    </div>
</div>
```

#### 실행 로그
`FormItemController`에 `Slf4j` 애노테이션 추가

- FormItemController : item.open=true // 체크 박스를 선택하는 경우
- FormItemController : item.open=false // 체크 박스를 선택하지 않는 경우

체크 박스를 체크하면 HTML Form에서 `open=on`이라는 값이 넘어간다. 스프링은 `on`이라는 문자를 `true` 타입으로 변환해준다.<br>
**주의 - HTML에서 체크 박스를 선택하지 않고 폼을 전송하면 `open`이라는 필드 자체가 서버로 전송되지 않는다.**<br><br>

이런 문제를 해결하기 위해서 스프링 MVC는 `_open`처럼 기존 체크 박스 이름 앞에 언더스코어(_)를 붙여서 전송하여 체크를 해제했다고 인식할 수 있게 트릭을 사용한다.<br>
**히든 필드는 항상 전송되기에, `open`은 전송되지 않고 `_open`만 전송되는 경우 스프링 MVC는 체크를 해제했다고 판단한다.**

#### 기존 코드에 히든 필드 추가

```html
<!-- single checkbox -->
<div>판매 여부</div>
<div>
    <div class="form-check">
        <input type="checkbox" id="open" name="open" class="form-check-input">
        <input type="hidden" name="_open" value="on"/> <!-- 히든 필드 추가-->
        <label for="open" class="form-check-label">판매 오픈</label>
    </div>
</div>
```

#### 체크 박스 체크&미체크
- FormItemController : item.open=true // 체크 박스를 선택하는 경우
- FormItemController : item.open=false // 체크 박스를 선택하지 않는 경우
- `open=on&_open=on`
  - 체크 박스를 체크하면 스프링 MVC가 `open` 값을 확인하고 사용한다. 이 때 `_open`은 무시한다.
- `_open=on`
  - 체크 박스를 체크하지 않으면 스프링 MVC가 `_open`만 있는 것을 확인하고, `open` 값이 체크되지 않았다고 인식한다.
  - 이 경우 서버에서 `Boolean` 타입을 찍어보면 결과가 `null`이 아니라 `false`다.

### 체크 박스 - 단일2

개발을 할 때마다 히든 필드를 추가하는 것은 상당히 번거롭다.
타임리프가 제공하는 폼 기능을 사용하면 자동으로 처리할 수 있다.

#### 타임리프 - 체크 박스 코드 추가

```html
<!-- single checkbox -->
<div>판매 여부</div>
<div>
    <div class="form-check">
        <input type="checkbox" id="open" th:field="*{open}" class="form-check-input">
        <label for="open" class="form-check-label">판매 오픈</label>
    </div>
</div>
```

- `<input type="hidden" name="_open" value="on"/>`
  - HTML 생성 결과를 보면 히든 필드 부분이 자동으로 생성되어 있다.
- FormItemController : item.open=true // 체크 박스를 선택하는 경우
- FormItemController : item.open=false // 체크 박스를 선택하지 않는 경우

#### HTML 생성 결과

```html
<hr class="my-4">

<!-- single checkbox -->
<div class="form-check">
    <input type="checkbox" id="open" class="form-check-input" disabled name="open" value="true" checked="checked">
    <label for="open" class="form-check-lable">판매 오픈</label>
</div>
```

- `checked="checked"`
- 조회 시에 `checked` 속성이 추가된 것을 확인할 수 있다.
- 타임리프의 `th:field`를 사용하면, 값이 `true`인 경우 체크를 자동으로 처리해준다.

### 체크 박스 - 멀티

체크 박스를 멀티로 사용해서, 하나 이상을 체크할 수 있도록 해보자.

- 등록 지역
  - 서울, 부산, 제주
  - 체크 박스로 다중 선택할 수 있다.

#### FormItemController - 추가

```java
import java.util.LinkedHashMap;
import java.util.Map;

@ModelAttribute("regions")
public Map<String, String> regions() {
    Map<String, String> regions = new LinkedHashMap<>();
    regions.put("SEOUL", 서울);
    regions.put("BUSAN", 부산);
    regions.put("JEJU", "제주");
    return regions;
}
```

#### @ModelAttribute의 특별한 사용법

등록 폼, 상세 화면, 수정 폼에서 모두 서울, 부산, 제주라는 체크 박스를 반복해서 보여주어야 한다.
이렇게 하려면 각각의 컨트롤러에 `model.addAttribute(...)`을 사용해서 체크 박스를 구성하는 데이터를 반복해서 넣어주어야 한다.<br>
`@ModelAttribute`는 컨트롤러에 있는 별도의 메서드에 적용할 수 있다.<br>
이렇게 하면 해당 컨트롤러를 요청할 때, `regions`에서 반환한 값이 자동으로 모델(`model`)에 담기게 된다.

#### addForm.html - 추가

```html
<!-- multi checkbox -->
<div>
    <div>등록 지역</div>
    <div th:each="region : ${regions}" class="form-check form-check-inline">
        <input type="checkbox" th:field="*{regions}" th:value="${region.key}" class="form-check-input">
        <label th:for="${#ids.prev('regions')}"
               th:text="${region.value}" class="form-check-label">서울</label>
    </div>
</div>
```

- `th:for={#ids.prev('regions')}`
  - 멀티 체크 박스는 같은 이름의 여러 체크 박스를 만들 수 있다.
  - 문제는 HTML 태그를 생성할 때, HTML 태그 속성에서 `name`은 같아도 되지만 `id`는 모두 달라야 한다.
  - 타임리픈느 체크 박스를 `each` 루프 안에서 반복해서 만들 때, 임의로 1, 2, 3 숫자를 붙여준다.

### 라디오 버튼

라디오 버튼은 여러 선택지 중에 하나를 선택할 때 사용할 수 있다.

- 상품 종류
  - 도서, 식품, 기타
  - 라디오 버튼으로 하나만 선택할 수 있다.

#### FormItemController - 추가

```java
@ModelAttribute("itemTypes")
public ItemType[] itemTypes() {
    return ItemType.values();
}
```

`ItemType.values()`를 사용하면 해당 ENUM의 모든 정보를 배열로 반환한다. (예시. `[BOOK, FOOD, ETC]`)

#### addForm.html - 추가

```html
<!-- radio button -->
<div>
    <div>상품 종류</div>
    <div th:each="type : ${itemTypes}" class="form-check form-check-inline">
        <input type="radio" th:field="*{itemType}" th:value="${type.name()}" class="form-check-input">
        <label th:for="${#ids.prev('itemType')}" th:text="${type.description}" class="form-check-label">
            BOOK
        </label>
    </div>
</div>
```

- **실행 로그**
  - `item.itemType=FOOD`: 값이 있을 때
  - `item.itemType=null`: 값이 없을 때

### 셀렉트 박스

셀렉트 박스는 여러 선택지 중에 하나를 선택할 때 사용할 수 있다.

- 배송 방식
  - 빠른 배송, 일반 배송, 느린 배송
  - 셀렉트 박스로 하나만 선택할 수 있다.

#### FormItemController - 추가

```java
import java.util.ArrayList;
import java.util.List;

@ModelAttribute("deliveryCodes")
public List<DeliveryCode> deliveryCodes() {
    List<DeliveryCode> deliveryCodes = new ArrayList<>();
    deliveryCodes.add(new DeliveryCode("FAST", "빠른 배송"));
    deliveryCodes.add(new DeliveryCode("NORMAL", "일반 배송"));
    deliveryCodes.add(new DeliveryCode("SLOW", "느린 배송"));
    return  deliveryCodes;
}
```

#### addForm.html - 추가

```html
<!-- SELECT -->
<div>
    <div>배송 방식</div>
    <select th:field="*{deliveryCode}" class="form-select">
        <option value="">==배송 방식 선택==</option>
        <option th:each="deliveryCode : ${deliveryCodes}" th:value="${deliveryCode.code}"
                th:text="${deliveryCode.displayName}">FAST</option>
    </select>
</div>

<hr class="my-4">
```