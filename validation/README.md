## 검증1- Validation

### 검증 요구사항

상품 관리 시스템에 새로운 요구사항이 추가됐다.
<br><br>
**요구사항: 검증 로직 추가**

- 타입 검증
  - 가격, 수량에 문자가 들어가면 검증 오류 처리
- 필드 검증
  - 상품명: 필수(공백 불가)
  - 가격: 1,000원 ~ 1,000,000원 이하
  - 수량: 최대 9999개
- 특정 필드의 범위를 넘어서는 검증
  - 가격 * 수량의 합은 10,000원 이상

기존 로직은 검증 오류가 발생하면 오류 화면으로 바로 이동했다.<br>
사용자는 처음부터 해당 폼으로 **다시 이동**해서 입력을 해야했다.<br>
웹 서비스는 고객이 입력한 데이터를 유지한 상태로 어떤 오류가 발생했는지 친절하게 알려주어야 한다.<br><br>

**컨트롤러의 중요한 역할 중 하나는 HTTP 요청이 정상인지 검증하는 것이다.**

### 검증 직접 처리 - 소개

고객이 상품 등록 폼에서 상품명을 입력하지 않거나 가격, 수량 등이 너무 작거나 커서 검증 범위를 넘어서면 서버 검증 로직이 실패해야 한다.

### 검증 직접 처리 - 개발

#### ValidationItemControllerV1 - addItem()수정

```java
import java.util.HashMap;

@PostMapping("/add")
public String addItem(@ModelAttribute Item item, RedirectAttributes redirectAttributes, Model model) {

    // 검증 오류 결과를 보관
    Map<String, String> errors = new HashMap<>();
    
    // 검증 로직
    if (!StringUtils.hasText(item.getItemName())) {
        errors.put("itemName", "상품 이름은 필수입니다.");
    }
    if (item.getPrice() == null || item.getPrice() < 1000 || item.getPrice() > 1000000) {
        errors.put("price", "가격은 1,000 ~ 1,000,000 까지 허용합니다.");
    }
    if (item.getQuantity() == null || item.getQuantity() > 9999) {
        errors.put("quantity", "수량은 최대 9,999 까지 허용합니다.")
    }
    
    // 특정 필드가 아닌 복합 룰 검증
    if (item.getPrice() != null && item.getQuantity() != null) {
        int resultPrice = item.getPrice() * item.getQuantity();
        if (resultPrice < 10000) {
            errors.put("globalError", "가격 * 수량의 합은 10,000원 이상이어야 합니다. 현재 값 = " + resultPrice);
        }
    }
    
    // 검증에 실패하면 다시 입력 폼으로
    if (!errors.isEmpty()) {
        model.addAttribute("errors", errors);
        return "validation/v1/addForm";
    }
    
    // 성공 로직
    Item savedItem = itemRepository.save(item);
    redirectAttributes.addAttribute("itemId", savedItem.getId());
    redirectAttributes.addAttribute("status", true);
    return "redirect:/validation/v1/items/{itemId}";
}
```

#### 검증 오류 보관
`Map<String, String> errors = new HashMap<>();`<br>
만약 검증 시 오류가 발생하면 어떤 검증에서 오류가 발생했는지 정보를 담아둔다.

#### 글로벌 오류 메시지 - addForm.html

```html
<div th:if="${errors?.containsKey('globalError'))">
  <p class="field-error" th:text="${errors['globalError']}">전체 오류 메시지</p>
</div>
```

오류 메시지는 `errors`에 내용이 있을 때만 출력하면 된다. 타임리프의 `th:if`를 사용하면 조건에 만족할 때만 해당 HTML 태그를 출력할 수 있다.

#### 정리
- 검증 오류가 발생하면 입력 폼을 다시 보여준다.
- 검증 오류들을 고객에게 친절하게 안내해서 다시 입력할 수 있게 한다.
- 검증 오류가 발생해도 고객이 입력한 데이터가 유지된다.

#### 남은 문제점
- 뷰 템플릿에서 중복 처리가 많다.
- 타입 오류 처리가 안된다. `Item`의 `price`, `quantity` 같은 숫자 필드는 타입이 `Integer`이므로 문자 타입으로 설정하는 것이 불가능하다.
- 그런데 이러한 오류는 스프링 MVC에서 컨트롤러에 진입하기도 전에 예외가 발생하기 때문에 컨트롤러가 호출되지도 않고 400 예외가 발생하면서 오류 페이지를 띄어준다.
- `Item`의 `price`에 문자를 입력하는 것처럼 타입 오류가 발생해도 고객이 입력한 문자를 화면에 남겨야 한다.
- 결국 고객이 입력한 값도 어딘가에 별도로 관리가 되어야 한다.

### BindingResult1

지금부터 스프링이 제공하는 검증 오류 방법을 알아보자. 여기서 핵심은 **BindingResult**이다.

#### ValidationItemControllerV2 - addItemV1
```java
@PostMapping("/add")
public String addItemV1(@ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes) {
    
    if (!StringUtils.hasText(item.getItemNae())) {
        bindingResult.addError(new FieldError("item", "itemName", "상품 이름은 필수입니다."));
    }
    if (item.getPrice() == null || item.getPrice() < 1000 || item.getPrice() > 1000000) {
        bindingResult.addError(new FieldError("item", "quantity", "수량은 최대 9,999 까지 허용합니다."));
    }
    
    // 특정 필드 예외가 아닌 전체 예외
    if (item.getPrice() == null && item.getQuantity() != null) {
        int resultPrice = item.getPrice() * item.getQuantity();
        if (resultPrice < 10000) {
            bindingResult.addError(new ObjectError("item", "가격 * 수량의 합은 10,000원 이상이어야 합니다. 현재값 = " + redirectAttributes));
        }
    }
    
    if (bindingResult.hasErrors()) {
        log.info("errors={}", bindingResult);
        return "validation/v2/addForm";
    }
    
    // 성공 로직
    Item savedItem = itemRepository.save(item);
    redirectAttributes.addAttribute("itemId", savedItem.getId());
    redirectAttributes.addAttribute("status", true);
    return "redirect:/validation/v2/items/{itemId}";
}
```

#### 주의
`BindingResult bindingResult` 파라미터 위치는 `@ModelAttribute Item item` 다음에 와야 한다.

#### 필드 오류 - FieldError
```java
if (!StringUtils.hasText(item.getItemName())) {
    bindingResult.addError(new FieldError("item", "itemName", "상품 이름은 필수입니다."));
}
```

#### FieldError 생성자 요약
```java
public FieldError(String objectName, String field, String defaultMessage) {}
```

필드에 오류가 있으면 `FieldError` 객체를 생성해서 `bindingResult`에 담아두면 된다.
- `objectName`: `@ModelAttribute` 이름
- `field`: 오류가 발생한 필드 이름
- `defaultMessage`: 오류 기본 메시지

#### 글로벌 오류 - ObjectError
```java
public ObjectError(String objectName, String defaultMessage) {}
```

- `objectName`: `@ModelAttribute`의 이름
- `defaultMessage`: 오류 기본 메시지

#### 타임리프 스프링 검증 오류 통합 기능

타임리프는 스프링의 `BindingResult`를 활용해서 편리하게 검증 오류를 표현하는 기능을 제공한다.
- `#field`: `#field`로 `BindingResult`가 제공하는 검증 오류에 접근할 수 있다.
- `th:errors`: 해당 필드에 오류가 있는 경우에 태그를 출력한다. `th:if`의 편의 버전이다.
- `th:errorclass`: `th:field`에서 지정한 필드에 오류가 있으면 `class` 정보를 추가한다.

### BindingResult2

- 스프링이 제공하는 검증 오류를 보관하는 객체이다. 검증 오류가 발생하면 여기에 보관하면 된다.
- `BindingResult`가 있으면 `@ModelAttribute`에 데이터 바인딩 시 오류가 발생해도 컨트롤러가 호출된다!

#### 예시. @ModelAttribute에 바인딩 시 타입 오류가 발생하면 ?
- `BindingResult`가 없으면 -> 400 오류가 발생하면서 컨트롤러가 호출되지 않고, 오류 페이지로 이동한다.
- `BindingResult`가 있으면 -> 오류 정보(`FieldError`)를 `BindingResult`에 담아서 컨트롤러를 정상 호출한다.

#### BindingResult에 검증 오류를 적용하는 3가지 방법
- `@ModelAttribute`의 객체에 타입 오류 등으로 바인딩이 실패하는 경우 스프링이 `FieldError` 생성해서 `BindingResult`에 넣어준다.
- 개발자가 직접 넣어준다.
- `Validator` 사용

#### 타입 오류 확인
숫자가 입력되어야 할 곳에 문자를 입력해서 타입을 다르게 해서 `BindingResult`를 호출하고 `bindingResult`의 값을 확인해보자.

#### 주의
- `BindingResult`는 검증할 대상 바로 다응메 와야한다. 순서가 중요하다. 예를 들어서 `@ModelAttribute Item item`, 바로 다음에 `BindingResult`가 와야 한다.
- `BindingResult`는 Model에 자동으로 포함된다.

#### BindingResult와 Errors
- `org.springframework.validation.Errors`
- `org.springframwork.validation.BindingResult`

`BindingResult`는 인터페이스이고, `Errors` 인터페이스를 상속 받고 있다.<br>
실제 넘어오는 구현체는 `BeanPropertyBindingResult`라는 것인데, 둘 다 구현하고 있으므로 `BindingResult` 대신에 `Errors`를 사용해도 된다.
`Errors` 인터페이스는 단순한 오류 저장과 조회 기능을 제공한다.<br>
`BindingResult`는 여기에 더해서 추가적인 기능들을 제공한다. `addForm()`도 `BindingResult`가 제공하므로 여기서는 `BindingResult`를 사용하자.

#### 정리
`BindingResult`, `FieldError`, `ObjectError`를 사용해서 오류 메시지를 처리하는 방법을 알아보았다.<br>
그런데 오류가 발생하는 경우 고객이 입력한 내용이 모두 사라진다. 이 문제를 해결해보자.

### FieldError, ObjectError

#### 목표

- 사용자 입력 오류 메시지가 화면에 남도록 하자.
  - 예시. 가격을 1000원 미만으로 설정 시 입력한 값이 남아있어야 한다.
- `FieldError`, `ObjectError`에 대해서 더 자세히 알아보자.

#### ValidationItemControllerV2 - addItemV2

```java
@PostMapping("/add")
public String addItemV2(@ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes) {
    if (!StringUtils.hasText(item.getItemName())) {
        bindingResult.addError(new FieldError("item", "itemName", item.getItemName(), false, null, null, "상품 이름은 필수입니다."));
    }
    
    if (item.getPrice() == null || item.getPrice() < 1000 || item.getPrice() > 1000000) {
        bindingResult.addError(new FieldError("item", "price", item.getPrice(), false, null, null, "가격은 1,000 ~ 1,000,000 까지 허용합니다."));
    }
    if (item.getQuantity() == null || item.getQuatity() >= 10000) {
        bindingResult.addError(new FieldError("item", "quantity", item.getQuantity(), false, null, null, "수량은 최대 9,999 까지 허용합니다."));
    }
    
    // 특정 필드 예외가 아닌 전체 예외
    if (item.getPrice() != null && item.getQuantity() != null) {
        int resultPrice = item.getPrice() * item.getQuantity();
        if (resultPrice < 10000) {
            bindingResult.addError(new ObjectError("item", null, null, "가격 * 수량의 합은 10,000원 이상이어야 합니다. 현재 값 = " + resultPrice));
        }
    }
    
    if (bindingResult.hasErrors()) {
        log.info("errors={}", bindingResult);
        return "validation/v2/addForm";
    }
    
    // 성공 로직
    Item savedItem = itemRepository.save(item);
    redirectAttributes.addAttributes("itemId", savedItem.getId());
    redirectAttributes.addAttributes("status",  true);
    return "redirect:/validation/v2/items/{itemId}";
}
```

#### FieldError 생성자
`FieldError`는 두 가지 생성자를 제공한다.

```java
public FieldError(String objectName, String field, String defaultMessage);
public FieldError(String objectName, String field, @Nullable Object rejectedValue, boolean bindingFailure, @Nullable String[] codes, @Nullable Object[] arguments, @Nullable String defaultMessage);
```

파라미터 목록
- `objectName`: 오류가 발생한 객체 이름
- `field`: 오류 필드
- `rejectedValue`: 사용자가 입력한 값(거절된 값)
- `bindingFailure`: 타입 오류 같은 바인딩 실패인지, 검증 실패인지 구분 값
- `codes`: 메시지 코드
- `arguments`: 메시지에서 사용하는 인자
- `defaultMessage`: 기본 오류 메시지

`OjbectError`도 유사하게 두 가지 생성자를 제공한다.

#### 오류 발생 시 사용자 입력 값 유지
```java
new FieldError("item", "price", item.getPrice(), false, null, null, "가격은 1,000 ~ 1,000,000 까지 허용합니다.")
```

`FieldError`는 오류 발생 시 사용자 입력 값을 저장하는 기능을 제공한다.<br>
`rejectedValue`가 바로 오류 발생 시 사용자 입력 값을 저장하는 필드다.

#### 타임리프의 사용자 입력 값 유지

`th:field="*{price}"`<br>
타임리프의 `th:field`는 매우 똑똑하게 동작하는 데, 정상 상황에서는 모델 객체의 값을 사용하지만, 오류가 발생하면 `FieldError`에서 보관한 값을 사용해서 값을 출력한다.

#### 스프링의 바인딩 오류 처리

타입 오류로 바인딩에 실패하면 스프링은 `FieldError`를 생성하면서 사용자가 입력한 값을 넣어둔다. 그리고 해당 오류를 `BindingResult`에 담아서 컨트롤러를 호출한다.
따라서 타입 오류 같은 바인딩 실패 시에도 사용자의 오류 메시지를 정상 출력할 수 있다.

### 오류 코드와 메시지 처리1

`FieldError`, `ObjectError`의 생성자는 `codes`, `arguments`를 제공한다. 이것은 오류 발싱 새 오류 코드로 메시지를 찾기 위해 사용된다.

#### errors 메시지 파일 생성
`messages.properties`를 사용해도 되지만, 오류 메시지를 구분하기 쉽게 `errors.properties`라는 별도의 파일로 관리해보자.<br><br>

먼저 스프링부트가 해당 메시지 파일을 인식할 수 있게 다음 설정을 추가한다.
이렇게 하면 `messages.properties`, `errors.properties` 두 파일 모두 인식한다. (생략하면 `messages.properites`를 기본으로 인식한다.)

#### 스프링 부트 메시지 설정 추가
`application.properties`<br>
```properties
spring.messages.basename=messages,errors
```

#### errors.properties 추가
`src/main/resources/errors.properties`<br>
```properties
required.item.itemName=상품 이름은 필수입니다.
range.item.price=가격은 {0} ~ {1} 까지 허용합니다.
max.item.quantity=수량은 최대 {0} 까지 허용합니다.
totalPriceMin=가격 * 수량의 합은 {0}원 이상이어야 합니다. 현재 값 = {1}
```

#### ValidationItemControllerV2 - addItemV3 추가

```java
@PostMapping("/add")
public String addItemV3(@ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes) {
    if (!StringUtils.hasText(item.getItemName())) {
        bindingResult.addError(new FieldEror("item", "itemName", item.getItemName(), false, new String[]{"required.item.itemName"}, null, null));
    }
    if (item.getPrice() == null || item.getPrice() < 1000 || item.getPrice() > 1000000) {
        bindingResult.addError(new FieldError("item", "price", item.getPrice(), false, new String[]{range.item.price}, new Object[]{1000, 1000000}, null));
    }
    if (item.getQuantity() == null || item.getQuantity() > 10000) {
        bindingResult.addError(new FieldError("item", "quantity", item.getQuantity(), false, new String[]{max.item.quantity}, new Object[]{9999}, null));
    }
    
    // 특정 필드 예외가 아닌 전체 예외
    if (item.getPrice() != null && item.getQuantity() != null) {
        int resultPrice = item.getPrice() * item.getQuantity();
        if (resultPrice < 10000) {
            bindingResult.addError(new OjbectError("item", new String[]{"totalPriceMin"}, new Object[]{10000, resultPrice}, null));
        }
    }
    if (bindingResult.hasErrors()) {
        log.info("errors={}", bindingResult);
        return "validation/v2/addForm";
    }
    
    // 성공 로직
    Item savedItem = itemRepository.save(item);
    redirectAttributes.addAttributes("itemId", savedItem.getId());
    redirectAttributes.addAttributes("status", true);
    return "redirect:/validation/v2/items/{itemId}";
}
```

### 오류 코드와 메시지 처리2
### 오류 코드와 메시지 처리3
### 오류 코드와 메시지 처리4
### 오류 코드와 메시지 처리5
### 오류 코드와 메시지 처리6

### Validator 분리1

#### 목표
- 복잡한 검증 로직을 별도로 분리하자.

```java
@Component
public class ItemValidator implements Validator {
    
    @Override
    public boolean supports(Class<?> clazz) {
        return Item.class.isAssignableFrom(clazz);
    }
    
    @Override
    public void validate(Object tartget, Errors errors) {
        
        Item item = (Item) tartget;
        
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "itemName", "required");
        
        if (item.getPrice() == null || item.getPrice() < 1000 || item.getPrice() > 1000000) {
            errors.rejectValue("price", "range", new Object[]{1000, 1000000}, null);
        }
        if (item.getQuantity() == null || item.getQuantity() > 10000) {
            errors.rejectValue("quantity", "max", new Object[]{9999}, null);
        }
        
        // 특정 필드 예외가 아닌 전체 예외
        if (item.getPrice() != null && item.getQuantity() != null) {
            int resultPrice = item.getPrice() * item.getQuantity();
            if (resultPrice < 10000) {
                errors.reject("totalPriceMin", new Object[]{10000, resultPrice}, null);
            }
        }
    }
}
```

스프링은 검증을 체계적으로 제공하기 위해 다음 인터페이스를 제공한다.
```java
public interface Validator {
    boolean supports(Class<?> clazz);
    void validate(Object target, Errors errors);
}
```

- `supports() {}`: 해당 검증기를 지원하는 여부 확인
- `validate(Object target, Errors errors)`: 검증 대상 객체와 `BindingResult`

#### ItemValidator 직접 호춣하기

```java
private final ItemValidator itemValidator;

@PostMapping("/add")
public String addItemV5(@ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes) {
    
    itemValidator. validate(item, bindingResult);
    
    if (bindingResult.hasErrors()) {
        log.info("error={}", bindingResult);
        return "validation/v2/addForm";
    }
    
    // 성공 로직
    Item savedItem = itemRepository.save(item);
    redirectAttributes.addAttribute("itemId", savedItem.getId());
    redirectAttributes.addAttribute("status", true);
    return "redirect:/validation/v2/items/{itemId}";
}
```

`ItemValidator`를 스프링 빈으로 주입 받아서 직접 호출했다.

### Validator 분리2

`Validator` 인터페이스를 사용해서 검증기를 만들면 스프링의 추가적인 도움을 받을 수 있다.

#### WebDataBinder를 통해서 사용하기
`WebDataBinder`는 스프링의 파라미터 바인딩의 역할을 해주고 검증 기능도 내부에 포함한다.

#### ValidationItemControllerV2에 다음 코드를 추가하자

```java
@InitBinder
public void init(WebDataBinder dataBinder) {
    log.info("init binder {}", dataBinder);
    dataBinder.addValidators(itemValidator);
}
```

이렇게 `WebDataBinder`에 검증기를 추가하면 해당 컨트롤러에서는 검증기를 자동으로 적용할 수 있다.

#### @Validated 적용

```java
@PostMapping("/add")
public String addItemV6(@Validated @ModelAttribute Item item, BindingResult bindingResult, RedirectAttributes redirectAttributes) {
    if (bindingResult.hasErrors()) {
        log.info("errors={}", bindingResult);
        return "validation/v2/addForm";
    }
    
    // 성공 로직
    Item savedItem = itemRepository.save(item);
    redirectAttributes.addAttribute("itemId", savedItem.getId());
    redirectAttributes.addAttribute("status", true);
    return "redirect:/validation/v2/items/{itemId}";
}
```

#### 동작 방식
`@Validated`는 검증기를 실행하라는 애노테이션이다.<br>
이 애노테이션이 붙으면 앞서 `WebDataBinder`에 등록한 검증기를 찾아서 실행한다.<br>
이 때 여러 검증기가 등록되어 있다면 `supports()`를 사용해, 해당 class에 맞는 검증기를 호출한다.

#### 글로벌 설정 - 모든 컨트롤러에 전부 적용

```java
@SpringBootApplication
public class ItemServiceApplication implements WebMvcConfigurer {
    
    public static void main(String[] args) {
        SpringApplication.run(ItemServiceApplication.class, args);
    }
    
    @Override
    public Validator getValidator() {
        return new ItemValidator();
    }
}
```
