## 메시지, 국제화

### 메시지, 국제화 소개

만약 **상품명**이라는 단어를 모두 **상품 이름**으로 수정해야 한다면 어떻게 해야할까?<br>
화면 수가 적으면 문제가 되지 않지만, 화면 수가 수십 개 이상이라면 파일을 모두 고치는 데에 상당한 시간이 소요될 것이다.<br><br>

다양한 메시지를 한 곳에서 관리하도록 하는 기능을 메시지 기능이라고 한다.

#### 예시 - messages.properties

```properties
item=상품
item.id=상품 ID
item.itemName=상품명
item.price=가격
item.quantity=수량
```

#### 사용 방법

- **addForm.html**
  - `<label for="itemName" th:text="#{item.itemName}"></label>`
- **editForm.html**
  - `<label for="itemName" th:text="#{item.itemName}"></label>`

#### 국제화

메시지에서 설명한 메시지 파일(`messages.properties`)을 나라 별로 관리하면 서비스를 국제화 할 수 있다.

#### messages_en.properties

```properties
item=Item
item.id=Item ID
item.itemName=Item Name
item.price=price
item.quantity=quantity
```

#### messages_ko.properties

```properties
item=상품
item.id=상품 ID
item.itemName=상품명
item.price=가격
item.quantity=수량
```

어느 나라에서 접근한 것인지 인식하는 방법은 HTTP `accept-language` 헤더 값을 사용하거나 사용자가 직접 언어를 선택하도록 하고 쿠키 등을 사용해서 처리하면 된다.

### 스프링 메시지 소스 설정

메시지 관리 기능을 사용하려면 스프링이 제공하는 `MessageSource`를 스프링 빈으로 등록하면 된다.

```java
@Bean
public MessageSource messageSource() {
    ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
    messageSource.setBaseNames("messages", "errors");
    messageSource.setDefaultEncoding("utf-8");
    return messageSource;
}
```

- `basenames`: 설정 파일의 이름을 지정한다.
  - `messages`로 지정하면 `messages.properties` 파일을 읽어서 사용한다.
  - 국제화 기능을 적용하려면 `messages_en.properties`와 같이 파일 명 마지막에 언어 정볼르 주면 된다. 만약 찾을 수 없다면 언어 정보가 없는 파일명을 기본으로 사용한다.
  - 파일의 위치는 `/resources/messages.properties`에 두면 된다.
  - 여러 파일을 한 번에 지정할 수 있다. (예시. `messages`, `errors`)
- `defaultEncoding`: 인코딩 정보를 지정한다. `utf-8`을 사용하면 된다.

#### 스프링 부트

스프링 부트를 사용하면 `MessageSource`를 자동으로 스프링 빈으로 등록한다.

#### 스프링 부트 메시지 소스 설정 - application.properties

```properties
spring.messages.basename=messages, config.i18n.messages

# 스프링 부트 메시지 소스 기본 값
spring.messages.basename=messages
```

### 스프링 메시지 소스 사용

#### MessageSource 인터페이스

```java
public interface MessageSource {
    
    String getMessage(String code, @Nullable Object[] args, @Nullable String defaultMessage, Locale locale);
    
    String getMessage(String code, @Nullable Object[] args, Locale locale) throws NoSuchMessageException;
}
```

#### 메시지 소스 사용 방법 - 테스트 코드

```java
@SpringBootTest
public class MessageSourceTest {
    
    @Autowired
    MessageSource ms;
    
    @Test
    void notFoundMessageCode() {
        assertThatThrownBy(() -> ms.getMessage("no_code", null, null))
                .isInstanceOf(NoSuchMessageException.class);
    }
    
    @Test
    void notFoundMessageCodeDefaultMessage() {
        String result = ms.getMessage("no_code", null, "기본 메시지", null);
        assertThat(result).isEqualTo("기본 메시지");
    }
    
    // 매개 변수 사용 예시
    @Test
    void argumentMessage() {
        String result = ms.getMessage("hello.name", new Object[]{"Spring!!"}, null);
        assertThat(result).isEqualTo("안녕 Spring!!");
    }
}
```

### 웹 애플리케이션에 메시지 적용하기

#### messages.properties

```properties
label.item=상품
label.item.id=상품 ID
label.item.itemName=상품명
label.item.price=가격
label.item.quantity=수량

page.items=상품 목록
page.item=상품 상세
page.addItem=상품 등록
page.updateItem=상품 수정

button.save=저장
button.cancel=취소
```

#### 타임리프 메시지 적용
타임리프의 메시지 표현식 `#{...}`을 사용하면 스프링의 메시지를 편리하게 조회할 수 있다.<br>
방금 등록한 상품이라는 이름을 조회하려면 `#{label.item}`이라고 하면 된다.

### 웹 애플리케이션에 국제화 적용하기

#### messages_en.properties

```properties
label.item=Item
label.item.id=Item ID
label.item.itemName=Item Name
label.item.price=price
label.item.quantity=quantity

page.items=Item List
page.item=Item Detail
page.addItem=Item Add
page.updateItem=Item Update

button.save=Save
button.cancel=Cancel
```