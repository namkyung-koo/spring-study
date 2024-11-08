## 스프링의 핵심 원리 이해1 - 예제 만들기

### 비즈니스 요구사항과 설계
- 회원
  - 회원을 가입하고 조회할 수 있다.
  - 회원은 일반과 VIP 두 가지 등급이 있다.
  - 회원 데이터는 자체 DB를 구축할 수 있고, 외부 시스템과 연동할 수 있다.(미확정)
- 주문과 할인 정책
  - 회원은 상품을 주문할 수 있다.
  - 회원 등급에 따라 할인 정책을 적용할 수 있다.
  - 할인 정책은 모든 VIP는 1000원을 할인해주는 고정 금액 할인을 적용해달라. (나중에 변경될 수 있다.)
  - 할인 정책은 변경 가능성이 높다. 회사의 기본 할인 정책을 아직 정하지 못했고, 오픈 직전까지 고민을 미루고 싶다. 최악의 경우 할인을 적용하지 않을 수도 있다. (미확정)

정책이 결정되지 않은 부분에 대해선, 객체 지향 설계 방법으로 인터페이스를 만들고 구현체를 갈아끼울 수 있도록 설계하자

### 회원 도메인 설계

#### 회원 도메인 협력 관계
클라이언트는 회원 서비스(인터페이스)에 의존한다.
<br>
회원 서비스는 회원 저장소(인터페이스)에 의존한다. 회원 저장소를 **메모리 회원 저장소, DB 회원 저장소, 외부 시스템 연동 회원 저장소**가 구현한다.

#### 회원 클래스 다이어그램
인터페이스인 MemberService를 MemberServiceImpl이 구현한다.
<br>
MemberServiceImpl은 MemberRepository 인터페이스에 의존한다.
<br>
MemberRepository는 MemoryMemberRepository와 DbMemberRepository가 각각 구현해, 언제든 갈아 끼울 수 있다.

### 주문과 할인 도메인 설계

#### 주문 도메인 협력, 역할, 책임

클라이언트는 주문 서비스 역할에 의존한다.
<br>
주문 서비스 역할은 각각 **회원 조회 - 회원 저장소 역할(인터페이스)**, **할인 적용 - 할인 정책 역할(인터페이스)** 에 의존한다.
1. **주문 생성**: 클라이언트는 주문 서비스에 주문 생성을 요청한다.
2. **회원 조회**: 할인을 위해서는 회원 등급이 필요하다. 그래서 주문 서비스는 회원 저장소에서 회원을 조회한다.
3. **할인 적용**: 주문 서비스는 회원 등급에 따른 할인 여부를 할인 정책에 위임한다.
4. **주문 결과 반환**: 주문 서비스는 할인 결과를 포함한 주문 결과를 반환한다.

#### 주문 도메인 클래스 다이어그램
인터페이스인 OrderService를 OrderServiceImpl이 구현한다.
<br>
OrderServiceImpl은 MemberRepository 인터페이스와 DiscountPolicy 인터페이스 의존한다.
<br>
MemberRepository는 MemoryMemberRepository와 DbMemberRepository가 각각 구현해, 언제든 갈아 끼울 수 있다.
<br>
DiscountPolicy는 FixDiscountPolicy와 RateDiscountPolicy가 각각 구현해, 언제든 갈아 끼울 수 있다.

## 스프링 핵심 원리 이해2 - 객체 지향 원리 적용

### 새로운 할인 정책 개발

#### RateDiscountPolicy 추가

### 새로운 할인 정책 적용과 문제점
할인 정책을 변경하려면 클라이언트인 `OrderServiceImpl` 코드를 고쳐야 한다.

#### 에제 코드 - OrderServiceImple 코드 수정
```java
import hello.core.discount.DiscountPolicy;
import hello.core.discount.FixDiscountPolicy;
import hello.core.discount.RateDiscountPolicy;
import hello.core.order.OrderService;

public class OrderServiceImpl implements OrderService {
//  private final DiscountPolicy discountPolicy = new FixDiscountPolicy();
  private final DiscountPolicy discountPolicy = new RateDiscountPolicy();
}
```

#### 문제점 발견
- 우리는 역할과 구현을 충실하게 분리했다.
- 다형성도 활용하고, 인터페이스와 구현 객체를 분리했다.
- OCP, DIP 같은 객체 지향 설계 원칙을 충실히 준수한 것 같지만, **사실을 그렇지 않다.**
  - 추상(인터페이스) 뿐만 아니라 **구체(구현) 클래스에도 의존**하고 있다.
    - 추상(인터페이스) 의존: `DiscountPolicy`
    - 구체(구현) 클래스: `FixDiscountPolicy`, `RateDiscountPolicy`
- `FixDiscountPolicy`를 `RateDiscountPolicy`로 변경하는 순간 `OrderServiceImpl`의 소스 코드도 함께 변경해야 한다. 따라서 **OCP를 위반**한다.

#### 인터페이스에만 의존하도록 설계를 변경하자 !!

#### 해결 방안
- 누군가가 클라이언트인 `OrderServiceImpl`에 `DiscountPolicy`의 구현 객체를 대신 생성하고 주입해주어야 한다.

### AppConfig 등장
- 애플리케이션의 전체 동작 방식을 구성(config)하기 위해, **구현 객체를 생성**하고, **연결**하는 책임을 가지는 별도의 설정 클래스를 만들자

#### 예제 코드 - AppConfig(리팩터링 전)

```java
import hello.core.discount.FixDiscountPolicy;
import hello.core.member.MemberService;
import hello.core.member.MemberServiceImpl;
import hello.core.member.MemoryMemberRepository;
import hello.core.order.OrderService;
import hello.core.order.OrderServiceImpl;

public class AppConfig {

  public MemberService memberService() {
    return new MemberServiceImpl(new MemoryMemberRepository());
  }

  public OrderService orderService() {
    return new OrderServiceImpl(
            new MemoryMemberRepository(), 
            new FixDiscountPolicy());
  }
}
```
- AppConfig는 애플리케이션의 실제 동작에 필요한 **구현 객체를 생성**한다.
  - `MemberServiceImpl`
  - `MemoryMemberRepository`
  - `OrderServiceImpl`
  - `FixDiscountPolicy`
- AppConfig는 생성한 객체 인스턴스의 참조(레퍼런스)를 **생성자를 통해 주입(연결)** 해준다.
  - `MemberServiceImpl` => `MemoryMemberRepository`
  - `OrderServiceImpl` => `MemoryMemberRepository`, `FixDiscountPolicy`

#### 예제 코드 - MemberServiceImpl - 생성자 주입

```java
import hello.core.member.Member;
import hello.core.member.MemberRepository;
import hello.core.member.MemberService;

public class MemberServiceImpl implements MemberService {

  private final MemberRepository memberRepository;

  public MemberServiceImpl(MemberRepository memberRepository) {
    this.memberRepository = memberRepository;
  }

  public void join(Member member) {
      memberRepository.save(member);
  }
  
  public Member findMember(Long memberId) {
      return memberRepository.findById(memberId);
  }
}
```
- 설계 변경으로 `MemberServiceImpl`은 `MemoryMemberRepository`를 의존하지 않는다..
- 단지 `MemberRepository` 인터페이스에만 의존한다.
- `MemberServiceImpl` 입장에서 생성자를 통해 어떤 구현 객체가 들어올지는 알 수 없다.
- `MemberServiceImpl`의 생성자를 통해서 어떤 구현 객체를 주입할 지는 오직 외부(`AppConfig`)에서 결정된다.
- `MemberServiceImpl`은 이제부터 **의존 관계에 대한 고민은 외부**에 맡기고 **실행에만 집중**하면 된다.
- 객체의 생성과 연결은 `AppConfig`가 담당한다.
- **DIP** 완성: `MemberServiceImpl`은 `MemberRepository`인 추상에만 의존하면 된다. 이제 구체 클래스를 몰라도 된다.
- **관심사의 분리**: 객체를 생성하고 연결하는 역할과 실행하는 역할이 명확히 분리되었다.
- `appConfig` 객체는 `memoryMemberRepository` 객체를 생성하고 그 참조값을 `memberServiceImpl`을 생성하면서 생성자로 전달한다.
- 클라이언트인 `memberServiceImpl` 입장에서 보면 의존관계를 마치 외부에서 주입해주는 것 같다고 해서 DI(Dependency Injection) 의존관계 주입 또는 의존성 주입이라 한다.

#### 예제 코드 - OrderServiceImpl - 생성자 주입

```java
import hello.core.discount.DiscountPolicy;
import hello.core.member.Member;
import hello.core.member.MemberRepository;
import hello.core.order.Order;

public class OrderServiceImpl implements OrderService {

  private final MemberRepository memberRepository;
  private final DiscountPolicy discountPolicy;

  public OrderServiceImpl(MemberRepository memberRepository, DiscountPolicy discountPolicy) {
    this.memberRepository = memberRepository;
    this.discountPolicy = discountPolicy;
  }

  @Override
  public Order createOrder(Long memberId, String itemName, int itemPrice) {

    Member member = memberRepository.findById(memberId);
    int discountPrice = discountPolicy.discount(member, itemPrice);

    return new Order(memberId, itemName, itemPrice, discountPrice);
  }
}
```
- 설계 변경으로 `OrderServiceImpl`은 `FixDiscountPolicy`를 의존하지 않는다.
- 단지 `DiscountPolicy` 인터페이스만 의존한다.
- `OrderServiceImpl`에는 `MemoryMemberRepository`, `FixDiscountPolicy` 객체의 의존관계가 주입된다.

### AppConfig 실행

#### 예제 코드 - MemberApp

```java
import hello.core.AppConfig;
import hello.core.member.Grade;
import hello.core.member.Member;
import hello.core.member.MemberService;

public class MemberApp {

  public static void main(String[] args) {
    AppConfig appConfig = new AppConfig();
    MemberService memberService = appConfig.memberService();
    Member member = new Member(1L, "memberA", Grade.VIP);
    memberService.join(member);
    
    Member findMember = memberService.findMember(1L);
    System.out.println("New member = " + member.getName());
    System.out.println("Find member = " + findMember.getName());
  }
}
```

#### 예제 코드 - 테스트 코드 오류 수정

```java
import hello.core.AppConfig;
import hello.core.member.MemberService;
import hello.core.order.OrderService;

class MemberServiceTest {

  MemberService memberService;

  @BeforeEach
  public void beforeEach() {
    AppConfig appConfig = new AppConfig();
    memberService = appConfig.memberService();
  }
}

class OrderServiceTest {

  MemberService memberService;
  OrderService orderService;
  
  @BeforeEach
  public void beforeEach() {
      AppConfig appConfig = new AppConfig();
      memberService = appConfig.memberService();
      orderService = appConfig.orderService();
  }
}
```

테스트 코드에서 `@BeforeEach`는 각 테스트를 실행하기 전에 호출된다.

### AppConfig 리팩터링
현재 AppConfig는 **중복**이 있고, **역할**에 따른 **구현**이 잘 안보인다.

#### 예제 코드 - AppConfig(리팩터링 후)

```java
import hello.core.discount.DiscountPolicy;
import hello.core.discount.FixDiscountPolicy;
import hello.core.discount.RateDiscountPolicy;
import hello.core.member.MemberRepository;
import hello.core.member.MemberService;
import hello.core.member.MemberServiceImpl;
import hello.core.member.MemoryMemberRepository;
import hello.core.order.OrderService;
import hello.core.order.OrderServiceImpl;

public class AppConfig {

  public MemberService memberService() {
    return new MemberServiceImpl(memberRepository());
  }

  public OrderService orderService() {
    return new OrderServiceImpl(
            memberRepository(),
            discountPolicy());
  }

  public MemberRepository memberRepository() {
    return new MemoryMemberRepository();
  }

  public DiscountPolicy discountPolicy() {
//    return new FixDiscountPolicy();
    return new RateDiscountPolicy(); // 할인 정책 변경
  }
}
```
- `new MemoryMemberRepository()` 이 부분의 중복이 제거되었다. 이제 `MemoryMemberRepository`를 다른 구현체로 변경할 때 해당 부분만 변경하면 된다.
- `AppConfig`를 보면 역할과 구현 클래스가 한 눈에 들어온다. 애플리케이션 전체 구성이 어떻게 되어있는지 빠르게 파악할 수 있다.

### IoC(Inversion of Control) 컨테이너, DI(Dependency Injection) 컨테이너
- AppConfig 처럼 객체를 생성하고 관리하면서 의존관계를 연결해 주는 것을
- IoC 컨테이너 또는 **DI 컨테이너**라 한다.
- 의존관계 주입에 초점을 맞추어 최근에는 주로 DI 컨테이너라 한다.
- 또는 어샘블러, 오브젝트 팩토리 등으로 불리기도 한다.

### 스프링으로 전환하기

#### 예제 코드 - AppConfig 스프링 기반으로 변경

```java
import hello.core.discount.DiscountPolicy;
import hello.core.discount.RateDiscountPolicy;
import hello.core.member.MemberRepository;
import hello.core.member.MemberService;
import hello.core.member.MemberServiceImpl;
import hello.core.member.MemoryMemberRepository;
import hello.core.order.OrderService;
import hello.core.order.OrderServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

  @Bean
  public MemberService memberService() {
    return new MemberServiceImpl(memberRepository());
  }

  @Bean
  public OrderService orderService() {
    return new OrderServiceImpl(
            memberRepository(),
            discountPolicy());
  }

  @Bean
  public MemberRepository memberRepository() {
    return new MemoryMemberRepository();
  }

  @Bean
  public DiscountPolicy discountPolicy() {
    return new RateDiscountPolicy();
  }
}
```
- AppConfig에 설정을 구성한다는 뜻의 `@Configuration`을 붙여준다.
- 각 메서드에 `@Bean`을 붙여준다. 이렇게 함으로써 스프링 컨테이너에 스프링 빈으로 등록한다.

#### 예제 코드 - MemberApp에 스프링 컨테이너 적용

```java
import hello.core.AppConfig;
import hello.core.member.Grade;
import hello.core.member.Member;
import hello.core.member.MemberService;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class MemberApp {

  public static void main(String[] args) {
    ApplicationContext applicationContext = new AnnotationConfigApplicationContext(AppConfig.class);

    MemberService memberService = applicationContext.getBean("memberService", MemberService.class);

    Member member = new Member(1L, "memberA", Grade.VIP);
    memberService.join(member);
    
    Member findMember = memberService.findMember(1L);
    System.out.println("New member = " + member.getName());
    System.out.println("Find member = " + findMember.getName());
  }
}
```

#### 스프링 컨테이너
- `ApplicationContext`를 스프링 컨테이너라 한다.
- 기존에는 개발자가 `AppConfig`를 사용해서 직접 객체를 생성하고 DI를 했지만, 이제부터는 스프링 컨테이너를 통해서 사용한다.
- 스프링 컨테이너는 `@Configuration`이 붙은 `AppConfig`를 설정(구성) 정보로 사용한다. 여기서 `@Bean`이라 적힌 메서드를 모두 호출해서 반환된 객체를 스프링 컨테이너에 등록한다. 이렇게 스프링 컨테이너에 등록된 객체를 스프링 빈이라 한다.
- 스프링 빈은 `@Bean`이 붙은 메서드의 명을 스프링 빈의 이름으로 사용한다. (`memberService`, `orderService`)
- 이전에는 개발자가 필요한 객체를 `AppConfig`를 사용해서 직접 조회했지만, 이제부터는 스프링 컨테이너를 통해서 필요한 스프링 빈(객체)를 찾아야 한다. 스프링 빈은 `applicationContext.getBean()` 메서드를 사용해서 찾을 수 있다.
- 기존에는 개발자가 직접 자바 코드로 모든 것을 했다면 이제부터는 스프링 컨테이너에 객체를 스프링 빈으로 등록하고, 스프링 컨테이너에서 스프링 빈을 찾아서 사용하도록 변경되었다.