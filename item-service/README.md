## 스프링 MVC - 웹 페이지 만들기

### 요구사항 분석

상품을 관리할 수 있는 서비스를 만들어보자.

- **상품 도메인 모델**
  - 상품 ID
  - 상품명
  - 가격
  - 수량
- **상품 관리 기능**
  - 상품 목록
  - 상품 상세
  - 상품 등록
  - 상품 수정

### 상품 도메인 개발

#### Item - 상품 객체

```java
import lombok.Data;

@Data
public class Item() {
    
    private Long id;
    private String itemName;
    private Integer price;
    private Integer quantity;
    
    public Item() {
    }
    
    public Item(String itemName, Integer price, Integer quantity) {
        this.itemName = itemName;
        this.price = price;
        this.quantity = quantity;
    }
}
```

#### ItemRepository - 상품 저장소

```java
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class ItemRepository {

    private static final Map<Long, Item> store = new HashMap<>();
    private static Long sequence = 0L;
  
    public Item save(Item item) {
      item.setId(++sequence);
      store.put(item.getId(), item);
      return item;
    }
  
    public Item findById(Long id) {
      return store.get(id);
    }
  
    public List<Item> findAll() {
      return new ArrayList<>(store.values());
    }
    
    public void update(Long itemId, Item updateParam) {
        Item findItem = findById(itemId);
        findItem.setItemName(updateParam.getItemName());
        findItem.setPrice(updateParam.getPrice());
        findItem.setQuantity(updateParam.getQuantity());
    }
    
    public void clearStore() {
        store.clear();
    }
}
```

#### ItemRepositoryTest - 상품 저장소 테스트

```java
import java.util.List;

class ItemRepositoryTest {

    ItemRepository itemRepository = new ItemRepository();
  
    @AfterEach
    void afterEach() {
      itemRepository.clearStore();
    }
  
    @Test
    void save() {
      //given
      Item item = new Item("itemA", 10000, 10);
  
      //when
      Item savedItem = itemRepository.save(item);
  
      //then
      Item findItem = itemRepository.findByid(item.getId());
      assertThat(findItem).isEqualTo(savedItem);
    }
  
    @Test
    void findAll() {
      //given
      Item item1 = new Item("item1", 10000, 10);
      Item item2 = new Item("item2", 20000, 20);
  
      itemRepository.save(item1);
      itemRepository.save(item2);
  
      //when
      List<Item> items = itemRepository.findAll();
      
      //then
      assertThat(items.size()).isEqualTo(2);
      assertThat(items).contains(item1, item2);
    }
    
    @Test
    void updateItem() {
        //given
        Item item = new Item("item1", 10000, 10);
        
        Item savedItem = itemRepository.save(item);
        Long itemId = savedItem.getId();
        
        //when
        Item updateParam = new Item("item2", 20000, 30);
        itemRepository.update(itemId, updateParam);
        
        Item findItem = itemRepository.findById(itemId);
        
        //then
      assertThat(findItem.getItemName()).isEqualTo(updateParam.getItemName());
      assertThat(findItem.getPrice()).isEqualTo(updateParam.getPrice());
      assertThat(findItem.getQuantity()).isEqualTo(updateParam.getQuantity());
    }
}
```

### 상품 서비스 HTML

#### 부트스트랩(Bootstrap)
- 부트스트랩은 웹 사이트를 쉽게 만들 수 있게 도와주는 HTML, CSS, JS 프레임워크이다.
- 하나의 CSS로 휴대폰, 태블릿, 데스크탑까지 다양한 기기에서 작동한다.
- 다양한 기능을 제공하여 사용자가 쉽게 웹 사이트를 제작, 유지 보수할 수 있도록 도와준다.

#### 참고
- 정적 리소스가 공개되는 `/resources/static` 폴더에 HTML을 넣어두면, 실제 서비스에서도 공개된다.
- 서비스를 운영한다면 공개할 필요없는 HTML을 두는 것은 주의하자!

### 상품 목록 - 타임리프
본격적으로 컨트롤러와 뷰 템플릿을 개발해보자

#### BasicItemController

```java
import java.util.List;

@Controller
@RequestMapping("/basic/items")
@RequiredArgsConstructor
public class BasicItemController {

    private final ItemRepository itemRepository;
  
    @GetMapping
    public String items(Model model) {
      List<Item> items = itemRepository.findAll();
      model.addAttribute("items", items);
      return "basic/items";
    }

    /**
     * 테스트용 데이터 추가
     */
    @PostConstruct
    public void init() {
        itemRepository.save(new Item("testA", 10000, 10));
        itemRepository.save(new Item("testB", 20000, 20));
    }
}
```
컨트롤러 로직은 itemRepository에서 모든 상품을 조회한 다음에 모델에 담는다. 그리고 뷰 템플릿을 호출한다.

- `RequiredArgsConstructor`
  - `final`이 붙은 멤버 변수만 사용해서 생성자를 자동으로 만들어준다.

```java
public BasicItemController(ItemRepository itemRepository) {
    this.itemRepository = itemRepository;
}
```

- 이렇게 생성자가 딱 1개만 있으면 스프링이 해당 생성자에 `@Autowired`로 의존관계를 주입해준다.
- 따라서 **final 키워드를 빼면 안된다!**. 그러면 `ItemRepository` 의존관계 주입이 안된다.

#### 테스트용 데이터 추가
- 테스트용 데이터가 없으면 회원 목록 기능이 정상 동작하는지 확인하기 어렵다.
- `@PostConstruct`: 해당 빈의 의존관계가 모두 주입되고 나면 초기화 용도로 호출된다.
- 여기서는 간단히 테스트용 데이터를 넣기 위해서 사용했다.

#### 타임리프 간단히 알아보기

#### 타임리프 사용 선언
`<html xmlns:th="http://www.thymeleaf.org">`

#### 속성 변경
`th:href="@{/css/bootstrap.min.css}"`
- `href="value1`을 `th:href="value2"`의 값으로 변경한다.
- 타임리프 뷰 템플릿을 거치게 되면 원래 값을 `th:xxx` 값으로 변경한다. 만약 값이 없다면 새로 생성한다.
- HTML을 그대로 볼 때는 `href` 속성이 사용되고, 뷰 템플릿을 거치면 `th:href`의 값이 `href`로 대체되면서 동적으로 변경할 수 있다.
- 대부분의 HTML 속성을 `th:xxx`로 변경할 수 있다.

#### 타임리프 핵심
- 핵심은 `th:xxx`가 붙은 부분은 서버사이드에서 렌더링 되고, 기존 것을 대체한다. `th:xxx`이 없으면 기존 html의 `xxx` 속성이 그대로 사용된다.
- HTML을 파일로 직접 열었을 때, `th:xxx`가 있어도 웹 브라우저는 `th:` 속성을 알지 못하므로 무시한다.
- 따라서 HTML을 파일 보기를 유지하면서 템플릿 기능도 할 수 있다.

#### URL 링크 표현식 - @{...},
`th:href="@{/css/bootstrap.min.css}"`
- `@{...}`: 타임리프는 URL 링크를 사용하는 경우 `@{...}`을 사용한다. 이것을 URL 링크 표현식이라 한다.
- URL 링크 표현식을 사용하면 서블릿 컨텍스트를 자동으로 포함한다.

#### 상품 등록 폼으로 이동

#### 속성 변경 - th:onclick
- `onclick="location.href='addForm.html'"`
- `th:onclick="|location.href='@{/basic/items/add}'|"`

#### 리터럴 대체 - |...|
`|...|`: 이렇게 사용한다.
- 타임리프에서 문자와 표현식 등은 분리되어 있기 때문에 더해서 사용해야 한다.
  - `<span th:text="'Wecome to our application, ' + ${user.name} + '!'">`
- 다음과 같이 리터럴 대체 문법을 사용하면, 더하기 없이 편리하게 사용할 수 있다.
  - `<span th:text="|Wecome to our application, ${user.name}!|">`
- 결과를 다음과 같이 만들어야 하는데
  - `location.href='/basic/items/add'`
- 리터럴 대체 문법을 사용하면 다음과 같이 편리하게 사용할 수 있다.
  - `th:onclick="|location.href='@{/basic/items/add}'|"`

#### 반복 출력 - th:each
- `<tr th:each="item : ${items}">`
- 반복은 `th:each`를 사용한다. 이렇게 하면 모델에 포함된 `items` 컬렉션 데이터가 `item` 변수에 하나씩 포함되고, 반복문 안에서 `item` 변수를 사용할 수 있다.
- 컬렉션의 수 만큼 `<tr>..</tr>`이 하위 태그를 포함해서 생성된다.

#### 변수 표현식 - ${...}
- `<td th:text="${item.price}">10000</td>`
- 모델에 표현된 값이나 타임리프 변수로 선언한 값을 조회할 수 있다.
- 프로퍼티 접근법을 사용한다. (`item.getPrice()`)

#### 내용 변경 - th:text
- `<td th:text="${item.price}">10000</td>`
- 내용의 값을 `th:text`의 값으로 변경한다.
- 여기서는 10000을 `${item.price}`의 값으로 변경한다.

#### URL 링크 표현식2 - @{...},
- `th:href="@{/basic/items/{itemId}(itemId=${item.id})}"`
- 상품 ID를 선택하는 링크를 확인해보자
- URL 링크 표현식을 사용하면 경로를 템플릿처럼 편리하게 사용할 수 있다.
- 경로 변수(`{itemID}`) 뿐만 아니라 쿼리 파라미터도 생성한다.
- 예시. `th:href="@{/basic/items/{itemId}(itemId=${item.id}, query='test')}"`
  - 생성 링크: `http://localhost:8080/basic/items/1?query=test`

#### URL 링크 간단히
- `th:href="@{|/basic/items/${item.id}|}"`
- 상품 이름을 선택하는 링크를 확인해보자.
- 리터럴 대체 문법을 활용해서 간단히 사용할 수도 있다.

### 상품 상세

상품 상세 컨트롤러와 뷰를 개발하자.

#### BasicItemController에 추가
```java
@GetMapping("/{itemId}")
public String item(@PathVariable Long itemId, Model model) {
    Item item = itemRepository.findById(itemId);
    model.addAttribute("item", item);
    return "basic/item";
}
```
`PathVariable`로 넘어온 상품 ID로 상품을 조회하고, 모델에 담아둔다. 그리고 뷰 템플릿을 호출한다.

#### 상품 상세 뷰 - 생략

#### 속성 변경 - th:value
`th:value="${item.id}"`
- 모델에 있는 item 정보를 획득하고 프로퍼티 접근법으로 출력한다. (`item.getId()`)
- `value` 속성을 `th:value` 속성으로 변경한다.

#### 상품 수정 링크
- `th:onclick="|location.href='@{/basic/items/{itemId}/edit(itemId=${item.id})}'|"`

#### 목록으로 링크
- `th:onclick="|location.href='@{/basic/items}'|"`

### 상품 등록 폼

#### BasicItemController에 추가
```java
@GetMapping("/add")
public String addForm() {
    return "basic/addForm";
}
```
상품 등록 폼은 단순히 뷰 템플릿만 호출한다.

#### 상품 등록 폼 뷰 - 생략

#### 속성 변경 - th:action
- `th:action`
- HTML Form에서 `action`에 값이 없으면 현재 URL에 데이터를 전송한다.
- 상품 등록 폼의 URL과 실제 상품 등록을 처리하는 URL을 똑같이 맞추고 HTTP 메서드로 두 기능을 구분한다.
  - 상품 등록 폼: GET `/basic/items/add`
  - 상품 등록 처리: POST `/basic/items/add`
- 이렇게 하면 하나의 URL로 등록 폼과 등록 처리를 깔끔하게 처리할 수 있다.

#### 취소
- 취소 시, 상품 목록으로 이동한다.
- `th:onclick="|location.href='@{/basic/items}'|"`

### 상품 등록 처리 - @ModelAttribute
이제 상품 등록 폼에서 전달된 데이터로 실제 상품을 등록 처리 해보자.<br>
상품 등록 폼은 다음 방식으로 서버에 데이터를 전달한다.

- *POST - HTML Form*
  - `content-type: application/x-www-form-urlencoded`
  - 메시지 바디에 쿼리 파라미터 형식으로 전달. `itemName=itemA&price=10000&quantity=10`
  - 예시. 회원 가입, 상품 주문, HTML Form 사용

요청 파라미터 형식을 처리해야 하므로 `@RequestParam`을 사용하자

### 상품 등록 처리 - @RequestParam

#### addItemV1 - BasicItemController에 추가
```java
@PostMapping("/add")
public String addItemV1(@RequestParam String itemName,
                        @RequestParam int price,
                        @RequestParam Integer quantity,
                        Model model) {
    Item item = new Item();
    item.setItemName(itemName);
    item.setPrice(price);
    item.setQuantity(quantity);
    
    itemRepository.save(item);
    
    model.addAttribute("item", item);
    
    return "basic/item";
}
```
- 먼저 `@RequestParam String itemName`은 itemName 요청 파라미터 데이터를 해당 변수에 받는다.
- `Item` 객체를 생성하고 `itemRepository`를 통해서 저장한다.
- 저장된 `Item`을 모델에 담아서 뷰에 전달한다.

### 상품 등록 처리 - @ModelAttribute
`@RequestParam`으로 변수를 하나하나 받아서 `Item`을 생성하는 과정은 불편했다.<br>
이번에는 `@ModelAttribute`를 사용해서 한 번에 처리해보자.

#### addItemV2 - 상품 등록 처리 - ModelAttribute
```java
/**
 * @ModelAttribute("item") Item item
 * model.addAttribute("item", item); 자동 추가
 */
@PostMapping("/add")
public String addItemV2(@ModelAttribute("item") Item item, Model model) {
    itemRepository.save(item);
//    model.addAttribute("item", item); // 자동 추가, 생략 가능
    return "basic/item";
}
```

#### @ModelAttribute - 요청 파라미터 처리
`@ModelAttribute`는 `Item` 객체를 생성하고, 요청 파라미터 값을 프로퍼티 접근법(setXxx)으로 입력해준다.

#### @ModelAttribute - Model 추가
`@ModelAttribute`는 중요한 한 가지 기능이 더 있는데, 바로 모델에 `@ModelAttribute`로 지정한 객체를 자동으로 넣어준다.<br><br>

모델에 데이터를 담을 때는 이름이 필요하다. 이름은 `@ModelAttribute`에 지정한 `name(value)` 속성을 사용한다. 만약 다음과 같이 `@ModelAttribute`의 이름을 다르게 지정하면 다른 이름으로 모델에 포함된다.
<br><br>
`@ModelAttribute("hello") Item item` -> 이름을 hello로 지정<br>
model.addAttribute("hello", item); -> 모델에 hello 이름으로 저장

#### addItemV3 - 상품 등록 처리 - ModelAttribute 이름 생략
```java
/**
 * @ModelAttribute name 생략 가능
 * model.addAttribute(item); 자동 추가, 생략 가능
 * 생략 시, model에 저장되는 name은 클래스 명의 첫 글자만 소문자로 등록 Item -> item
 */
@PostMapping("/add")
public String addItemV3(@ModelAttribute Item item) {
    itemRepository.save(item);
    return "basic/item";
}
```

#### addItemV4 - 상품 등록 처리 - ModelAttribute 전체 생략
```java
/**
 * @ModelAttribute 자체 생략 가능
 * model.addAttribute(item) 자동 추가
 */
@PostMapping("/add")
public String addItemV4(Item item) {
    itemRepository.save(item);
    return "basic/item";
}
```

### 상품 수정

#### 상품 수정 폼 컨트롤러 - BasicItemController에 추가
```java
@GetMapping("/{itemId}/edit")
public String editForm(@PathVariable Long itemId, Model model) {
    Item item = itemRepository.findById(itemId);
    model.addAttribute("item", item);
    return "basic/editForm";
}
```

#### 상품 수정 폼 뷰 - 생략

#### 상품 수정 개발
```java
@PostMapping("/{itemId}/edit")
public String edit(@PathVariable Long itemId, @ModelAttribute Item item) {
    itemRepository.update(itemId, item);
    return "redirect:/basic/items/{itemId}";
}
```

상품 수정은 상품 등록과 전체 프로세스가 유사하다.
- GET `/items/{itemId}/edit`: 상품 수정 폼
- POST `/items/{itemId}/edit`: 상품 수정 처리

#### 리다이렉트
상품 수정은 마지막에 뷰 템플릿을 호출하는 대신에 상품 상세 화면으로 이동하도록 리다이렉트를 호출한다.
- 스프링은 `redirect:/...`으로 편리하게 리다이렉트를 지원헌다.
- `redirect:/basic/items/{itemId}`
  - 컨트롤러에 매핑된 `@PathVariable`의 값은 `redirect`에도 사용할 수 있다.
  - `redirect:/basic/items/{itemId}` -> `{itemId}`는 `@PathVariable Long itemId`의 값을 그대로 사용한다.

### PRG - POST/REDIRECT/GET
지금까지 진행한 상품 등록 처리 컨트롤러는 심각한 문제가 있다.<br>
상품 등록을 완료하고 웹 브라우저의 새로고침 버튼을 클릭하면 상품이 계속해서 중복 등록되는 것을 확인할 수 있다.<br>
웹 브라우저의 새로 고침은 마지막에 서버에 전송한 데이터를 다시 전송한다.<br><br>

이 문제를 어떻게 해결할 수 있을까?

#### POST, REDIRECT, GET
새로 고침 문제를 해결하려면 상품 저장 후에 뷰 템플릿으로 이동하는 것이 아니라, 상품 상제 화면으로 리다이렉트를 호출해주면 된다.

#### BasicItemController에 추가
```java
/**
 * PRG - Post/Redirect/Get
 */
@PostMapping("/add")
public String addItemV5(Item item) {
    itemRepository.save(item);
    return "redirect:/basic/items/" + item.getId();
}
```

### RedirectAttributes
상품을 저장하고 상품 상세 화면으로 리다이렉트 한 것까지는 좋았다. 그런데 고객 입장에서 저장이 잘 된 것인지 확신이 들지 않는다.<br>
그래서 저장이 잘 되었으면 상품 상세 화면에 "저장 되었습니다."라는 메시지를 보여달라는 요구사항이 왔다. 간단하게 해결 해보자.

#### BasicItemController에 추가
```java
/**
 * RedirectAttributes
 */
@PostMapping("/add")
public String addItemV6(Item item, RedirectAttributes redirectAttributes) {
    Item savedItem = itemRepository.save(item);
    redirectAttributes.addAttribute("itemId", savedItem.getId());
    redirectAttributes.addAttribute("status", true);
    return "redirect:/basic/items/{itemId}";
}
```
리다이렉트 할 때 간단히 `status=true`를 추가해보자<br><br>

실행해보면 다음과 같은 리다이렉트 결과가 나온다.<br>
`http://localhost:8080/basic/items/3?status=true`

#### RedirectAttributes
`RedirectAttributes`를 사용하면 URL 인코딩도 해주고, `pathVariable`, 쿼리 파라미터까지 처리해준다.
- `redirect:/basic/items/{itemId}`
- pathVariable 바인딩: `{itemId}`
- 나머지는 쿼리 파라미터로 처리: `?status=true`

#### 뷰 템플릿 메시지 추가 - resource/templates/basic/item.html
```html
```html
<div class="container">
  
    <div class="py-5 text-center">
        <h2>상품 상세</h2>
    </div>
  
    <!-- 추가 -->
    <h2 th:if="${param.status}" th:text="'저장 완료!'"></h2>
```
- `th:if`: 해당 조건이 참이면 실행
- `${param.status}`: 타임리프에서 쿼리 파라미터를 편리하게 조회하는 기능