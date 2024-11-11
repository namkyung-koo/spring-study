## 싱글톤 컨테이너

### 웹 애플리케이션과 싱글톤

#### 문제점

- 대부분이 웹 애플리케이션인 스프링 애플리케이션은 보통 여러 고객이 동시에 요청을 한다.
- 스프링이 없는 순수한 DI 컨테이너인 AppConfig는 요청을 할 때마다 객체롤 새로 생성한다.
  - 간단한 예로 고객 트래픽이 초 당 100이 나오면 초 당 100개의 객체가 생성되고 소멸된다.
  - 이로 인해 메모리 낭비를 유발한다.

#### 해결방안
- 해당 객체가 1개만 생성되고, 이를 공유하도록 설계하면 된다.
- 이것이 바로 **싱글톤 패턴**이다.

### 싱글톤 패턴
- 클래스의 인스턴스가 1개만 생성되는 것을 보장하는 디자인 패턴이다.
- `private 생성자`를 사용하여 외부에서 임의로 인스턴스를 생성하지 못하도록 막아야 한다.

#### 예제 코드 - 싱글톤 패턴을 적용한 코드
```java
public class SingletonService {
    
    private static final SingletonService instance = new SingletonService();
    
    public static SingletonService getInstance() {
        return instance;
    }
    
    private SingletonService() {}
    
    public void logic() {
        System.out.println("싱글톤 객체 로직 호출");
    }
}
```
1. static 영역에 객체를 1개만 생성한다.
2. 객체 인스턴스가 필요하면 getInstance()를 통해서만 조회하도록 한다.
3. 생성자의 접근 제어자를 private로 선언하여, 외부에서 객체 생성을 막는다.

#### 해당 싱글톤 패턴의 문제점
- 싱글톤 패턴을 구현하는 코드 자체가 많이 추가된다.
- 의존관계 상 클라이언트가 구체 클래스에 의존한다. => DIP를 위반한다.
- 클라이언트가 구체 클래스에 의존하여 OCP 원칙을 위반할 가능성이 높다.
- 테스트하기 어렵다.
- 내부 속성을 변경하거나 초기화 하기 어렵다.
- private 생성자로 자식 클래스를 만들기 어렵다.
- 결론적으로 유연성이 떨어져 `안티패턴`으로 불리기도 한다.

### 싱글톤 컨테이너
- 스프링 컨테이너는 싱글톤 패턴의 문제점을 해결하면서, 객체 인스턴스를 싱글톤(1개만 생성)으로 관리한다.
- 스프링 빈이 바로 싱글톤으로 관리되는 빈이다.

#### 스프링 컨테이너
- 스프링 컨테이너는 싱글톤 패턴을 적용하지 않아도 객체 인스턴스를 싱글톤으로 관리한다.
  - 컨테이너 생성 과정을 다시 보면, 컨테이너는 객체를 하나만 생성해서 관리한다.
- 스프링 컨테이너는 싱글톤 컨테이너 역할을 한다. 이렇게 싱글톤 객체를 생성하고 관리하는 기능을 싱글톤 레지스트리라 한다.
- 스프링 컨테이너의 이런 기능 덕분에 싱글톤 패턴의 단점을 해결하면서 객체를 싱글톤으로 유지할 수 있다.
  - 싱글톤 패턴을 위한 추가 코드가 작성되지 않아도 된다.
  - DIP, OCP, 테스트, private 생성자로부터 자유롭게 싱글톤을 사용할 수 있다.

#### 예제 코드 - 스프링 컨테이너를 사용하는 테스트 코드
```java
@Test
@DisplayName("스프링 컨테이너와 싱글톤")
void springContainer() {
    ApplicationContext ac = new AnnotationConfigApplicationContext(AppConfig.class);
    
    // 1. 조회: 호출할 때마다 같은 객체를 반환
    MemberService memberService1 = ac.getBean("memberService", MemberService.class);
    
    // 2. 조회: 호출할 때마다 같은 객체를 반환
    MemberService memberService2 = ac.getBean("memberService", MemberService.class);
    
    // 참조 값이 같은 것을 확인
    System.out.println("memberService1 = " + memberService1);
    System.out.println("memberService2 = " + memberService2);
    
    Assertions.assertThat(memberService1).isSameAs(memberService2);
}
```
- 스프링 컨테이너 덕분에 고객의 요청이 올 때 마다 객체를 생성하는 것이 아니라 이미 만들어진 객체를 공유해서 효율적으로 재사용할 수 있다.

### 싱글톤 방식의 주의점
- 싱글톤 패턴이든 스프링 컨테이너와 같은 싱글톤 컨테이너를 사용하든 객체 인스턴스를 하나만 생성해서 공유하는 싱글톤 방식은 여러 클라이언트가 하나의 객체 인스턴스를 공유하기 때문에 상태를 유지(stateful)하게 설계하면 안된다.
- `무상태(stateless)`로 설계해야 한다.
  - 특정 클라이언트에 의존적인 필드가 있으면 안된다!
  - 특정 클라이언트가 값을 변경할 수 있는 필드가 있으면 안된다!
  - 가급적 `읽기`만 가능해야 한다.
  - 필드 대신에 자바에서 공유되지 않는 지역변수, 파라미터, ThreadLocal 등을 사용해야 한다.

#### 예제 코드 - 상태를 유지할 경우 발생하는 문제점 예시
```java
public class StatefulService {
    
    private int price; // 상태를 유지하는 필드
    
    public void order(String name, int price) {
        System.out.println("name = " + name + " price = " + price);
        this.price = price; // 문제 코드
    }
    
    public int getPrice() {
        return price;
    }
}
```
```java
public class StatefulServiceTest {
    
    @Test
    void statefulServiceSingleton() {
        ApplicationContext ac = new AnnotationConfigApplicationContext(TestConfig.class);
        
        StatefulService statefulService1 = ac.getBean("statefulService", StatefulService.class);
        StatefulService statefulService2 = ac.getBean("statefulService", StatefulService.class);
        
        // Thread A: 사용자 A가 10000원 주문
        statefulService1.order("userA", 10000);
        // Thread B: 사용자 B가 20000원 주문
        statefulService2.order("userB", 20000);
        
        // Thread A: 사용자 A의 주문 금액 조회
        int price = statefulService1.getPrice();
        // Thread A: 사용자 A의 기대와는 다르게 20000원이 출력된다.
        System.out.println("price = " + price);
        
        Assertions.assertThat(statefulService1.getPrice()).isEqualTo(20000);
    }
    
    static class TestConfig {
        
        @Bean
        public StatefulService statefulService() {
            return new StatefulService();
        }
    }
}
```
- 공유 필드는 정말 조심해야 한다! 스프링 빈은 항상 무상태(stateless)로 설계하자.

### @Configuration과 싱글톤

#### 예제 코드 - AppConfig.class
```java
@Configuration
public class AppConfig {
    
    @Bean
    public MemberService memberService() {
        return new MemberServiceImpl(memberRepository());
    }
    
    @Bean
    public OrderService orderService() {
        return new OrderServiceImpl(memberRepository(), discountPolicy());
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

#### 문제 제기
- memberService 빈을 만드는 코드를 보면 `memberRepository()`를 호출한다.
  - `memberRepository()`를 호출하면 `new MemoryMemberRepository()`를 호출한다.
- orderService 빈을 만드는 코드도 동일하게 `memberRepository()`를 호출한다.
  - 동일하게 `new MemoryMemberRepository`를 호출한다.
- 결과적으로 각각 다른 2개의 `MemoryMemberRepository` 인스턴스가 생성되면서 싱글톤이 깨지는 것처럼 보인다.
  - 스프링 컨테이너는 이 문제를 어떻게 해결할까?

#### 간단한 테스트
- `memberServiceImpl`, `orderServiceImpl`에 각각 memberRepository 인스턴스를 조회할 수 있는 `getMemberRepository()`를 추가한다.
- 스프링 컨테이너 생성 후 인스턴스 참조 값 출력
  - memberService -> memberRepository
  - orderService -> memberRepository
  - memberRepository
- 테스트를 실행해보면, 모두 `같은 memberRepository 인스턴스를 참조`하고 있다.
- AppConfig 코드를 보면 분명 `new MemoryMemberRepository`가 2번 호출돼 다른 인스턴스가 생성되어야 한다.
- 어떻게 된 일일까?

### @Configuration과 바이트코드 조작의 마법
모든 비밀은 `@Configuration`을 적용한 `AppConfig`에 있다.

#### 예제 코드 - AppConfig도 스프링 빈으로 등록된다.
```java
@Test
void configurationDeep() {
    ApplicationContext ac = new AnnotationConfigApplicationContext(AppConfig.class);
    
    AppConfig bean = ac.getBean(AppConfig.class);

    System.out.println("bean = " + bean);
    //출력: bean = class hello.core.AppConfig$$EnhancerBySpringCGLIB$$bd479d70
}
```
- `AnnotationConfigApplicationContext`에 파라미터로 넘긴 값도 스프링 빈으로 등록된다.
  - 그래서 `AppConfig`도 스프링 빈이 된다.
- `AppConfig` 스프링 빈을 조회하여 클래스 정보를 출력해보자.
  - 예상과 다르게 클래스 명에 xxxCGLIB가 붙으며 복잡해진 정보를 출력한다.
  - 이것은 내가 만든 클래스가 아니라 스프링이 CGLIB라는 바이트코드 조작 라이브러리를 사용하여 AppConfig 클래스를 상속받은 임의의 다른 클래스를 만들고
  - 그 다른 클래스를 스프링 빈으로 등록한 것이다!
  - **그리고 그 클래스가 싱글톤을 보장해준다.**

#### 예제 코드 - AppConfig@CGLIB 예상 코드
```java
public MemberRepository memberRepository() {
    
    if (memoryMemberRepository가 이미 스프링 컨테이너에 등록되어 있다면) {
        return 스프링 컨테이너에서 찾아서 반환;
    } else { // 스프링 컨테이너에 없다면
        기존 로직을 호출해서 MemoryMemberRepository를 생성하고 스프링 컨테이너에 등록
        return 반환;
    }
}
```
- @Bean이 붙은 메서드마다 이미 스프링 빈이 존재하면 해당 빈을 반환하고 스프링 빈이 없으면 생성, 등록 후 반환하는 코드가 동적으로 만들어진다.
- 덕분에 싱글톤이 보장된다!

### 만약 `@Configuration`을 적용하지 않고 `@Bean`만 적용하면 어떻게 될까?
- `@Configuration`을 붙이면 바이트코드를 조작하는 CGLIB 기술을 사용해 싱글톤을 보장하지만, @Bean만 적용하면 어떻게 될까?

#### 위와 동일한 테스트를 진행
- `bean = class hello.core.AppConfig`
  - 순수한 AppConfig가 스프링 빈에 등록된다
- memberRepository()가 총 3번 호출된다.
  1. `@Bean`에 의해 스프링 컨테이너에 등록되기 위해
  2. `memberService`의 호출
  3. `orderService`의 호출

#### 정리
- `@Bean`만 사용해도 스프링 빈으로 등록되지만 싱글톤은 보장하지 않는다.
- 크게 고민할 것 없이 스프링 설정 정보는 항상 `@Configuration`을 사용하자
 


