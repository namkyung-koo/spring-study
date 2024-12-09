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




### 상품 상세
### 상품 등록 폼
### 상품 등록 처리 - @ModelAttribute
### 상품 수정
### PRG - POST/REDIRECT/GET
### RedirectAttributes