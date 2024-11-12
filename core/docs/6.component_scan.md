## 컴포넌트 스캔

### 컴포넌트 스캔과 의존관계 자동 주입 시작하기
- 지금까지 스프링 빈을 등록할 때는 자바 코드의 @Bean이나 XML의 <bean> 등을 통해서 설정 정보에 직접 등록할 스프링 빈을 나열했다.
- 등록해야 할 스프링 빈의 개수가 늘어날수록 설정 정보도 커지고, 누락하는 문제가 발생할 수도 있다.
- 스프링은 설정 정보가 없어도 자동으로 스프링 빈을 등록하는 **컴포넌트 스캔**이라는 기능을 제공한다.
- 의존관계도 자동으로 주입하는 `@Autowired`라는 기능 또한 제공한다.

#### 예제 코드 - AutoAppConfig.java
```java
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;

import static org.springframework.context.annotation.ComponentScan.*;

@Configuration
@ComponentScan(
        // 기존 예제 코드를 최대한 남기고 유지하기 위해서 excludeFilters를 사용했다.
        excludeFilters = @Filter(type = FilterType.ANNOTATION, classes = 
        Configuration.class))

public class AutoAppConfig {
}
```
- 컴포넌트 스캔을 사용하려면 먼저 `@ComponentScan`을 설정 정보에 붙여준다.
- 기존의 AppConfig와는 다르게 `@Bean`으로 등록한 클래스가 없다!

#### MemoryMemberRepository @Component 추가
```java
@Component
public class MemoryMemberRepository implements MemberRepository {}
```

#### RateDiscountPolicy @Component 추가
```java
@Component
public class RateDiscountPolicy implements DiscountPolicy {}
```

#### MemberServiceImpl @Component, @AutoWired 추가
```java
@Component
public class MemberServiceImpl implements MemberSerive {
    
    private final MemberRepository memberRepository;
    
    @Autowired
    public MemberServiceImpl(MemberRepository memberRepository) {
        this.memberRepository = memberRepository;
    }
}
```
- AppConfig에서는 `@Bean`으로 직접 설정 정보를 작성했고, 의존관계도 직접 명시했다.
- 이제는 이런 설정 정보 자체가 없기 때문에, 의존관계 주입도 클래스 안에서 해결해야 한다.
- `@Autowired`는 의존관계를 자동으로 주입해준다.

#### OrderServiceImpl @Component, @Autowired 추가
```java
@Component
public class OrderServiceImpl implements OrderService {
    
    private final MemberRepository memberRepository;
    private final DiscountPolicy discountPolicy;
    
    @Autowired
    public OrderServiceImpl(MemberRepository memberRepository, DiscountPolicy discountPolicy) {
        this.memberRepository = memberRepository;
        this.discountPolicy = discountPolicy;
    }
}
```
- `@Autowired`를 사용하면 생성자에 여러 의존관계도 한 번에 주입할 수 있다.

#### 예제 코드 - AutoAppConfigTest.java
```java
public class AutoAppConfigTest {
    
    @Test
    void basicScan() {
        ApplicationContext ac = new AnnotationConfigApplicationContext(AutoAppConfig.class);
        
        MemberService memberService = ac.getBean(MemberService.class);
        
        Assertions.assertThat(memberService).isInstanceOf(MemberService.class);
    }
}
```
- `AnnotationConfigApplicationContext`를 사용하는 것은 기존과 동일하다.
- 설정 정보로 `AutuAppConfig` 클래스를 넘겨준다.
- 실행해보면 기존과 같이 동작한다.

### 컴포넌트 스캔과 자동 의존관계 주입의 동작 방식

1. **@ComponentScan**
   - `@ComponentScan`은 `@Component`가 붙은 모든 클래스를 스프링 빈으로 등록한다.
   - 이 때 스프링 빈의 기본 이름은 클래스명을 사용하되 맨 앞글자만 소문자를 사용한다.
     - **빈 이름 기본 전략**: MemberServiceImpl 클래스 => memberServiceImpl
     - **빈 이름 사용자 지정**: `@Component("myMemberService")` 이런 식으로 이름을 부여하면 된다.
2. **@Autowired**
   - 생성자에 `@Autowired`를 지정하면, 스프링 컨테이너가 자동으로 해당 스프링 빈을 찾아서 주입한다.
   - 이 때 기본 조회 전략은 타입이 같은 빈을 찾아서 주입한다.
     - `getBean(MemberRepository.class)`와 동일하다고 이해하면 된다.
   - 생성자에 파라미터가 많아도 다 찾아서 자동으로 주입한다.

### 탐색 위치와 기본 스캔 대상
- 모든 자바 클래스를 컴포넌트 스캔하면 시간이 오래 걸린다. 그래서 꼭 필요한 위치부터 탐색하도록 시작 위치를 지정할 수 있다.
```java
@ComponentScan(
        basePackages = "hello.core",
)
```
- `basePackages`: 탐색할 패키지의 시작 위치를 지정한다. 해당 패키지를 포함한 하위 패키지 모두 탐색한다.
  - `basePackages = {"hello.core", "hello.service"}` 시작 위치를 여러 개 지정할 수도 있다.
- `basePackageClasses`: 지정한 클래스의 패키지를 탐색 시작 위치로 지정한다.
- 지정하지 않으면, `@ComponentScan`이 붙은 설정 정보 클래스의 패키지가 시작 위치가 된다.
- **패키지 위치를 지정하지 않고, 설정 정보 클래스의 위치를 프로제그 최상단에 두는 것을 권장한다.**
  - 최근 스프링 부트도 이 방법을 기본으로 제공한다.
  - `com.hello` => 프로젝트 시작 루트. 여기에 AppConfig 같은 메인 설정 정보를 두고, `@ComponentScan` 애노테이션을 붙인다.

#### 컴포넌트 스캔 기본 대상
- `@Component`: 컴포넌트 스캔에서 사용
- `@Controller`: 스프링 MVC 컨트롤러에서 사용
- `@Service`: 스프링 비즈니스 로직에서 사용
- `@Repository`: 스프링 데이터 접근 계층에서 사용
- `@Configuration`: 스프링 설정 정보에서 사용

해당 클래스의 소스 코드를 보면 `@Component`를 포함하고 있는 것을 확인할 수 있다.
```java
@Component
public @interface Controller {
}

@Component
public @interface Service {
}

@Component
public @interface Configuration {
}
```

#### 애노테이션의 부가 기능
- `@Controller`: 스프링 MVC 컨트롤러로 인식
- `@Repository`: 스프링 데이터 접근 계층으로 인식하고, 데이터 계층의 예외를 스프링 예외로 변환해준다.
- `@Configuration`: 스프링 설정 정보로 인식하고, 스프링 빈이 싱글톤을 유지하도록 추가 처리를 한다.
- `@Service`: 사실 `@Service@는 특별한 처리를 하기 보다는 개발자들이 '핵심 비즈니스 로직이 여기 있겠구나' 라고 인식하게 한다.

#### 필터
- `includeFilters`: 컴포넌트 스캔 대상을 추가로 지정한다.
- `excludeFilters`: 컴포넌트 스캔에서 제외할 대상을 지정한다.

### 중복 등록과 충돌

컴포넌트 스캔에서 같은 빈 이름을 등록하면 어떻게 될까?
<br>
다음 두 가지 상황이 있다.

1. 자동 빈 등록 vs 자동 빈 등록
2. 수동 빈 등록 vs 자동 빈 등록

#### 자동 빈 등록 vs 자동 빈 등록
- 컴포넌트 스캔에 의해 자동으로 스프링 빈이 등록되는데, 이름이 같은 경우 스프링은 오류를 발생시킨다.
  - `ConflictingBeanDefinitionException` 예외가 발생한다.

#### 수동 빈 등록 vs 자동 빈 등록
- 이 경우 수동 빈 등록이 우선권을 가진다.
  - 수동 빈이 자동 빈을 오버라이딩 해버린다.
- 수동이 우선권을 가지는 것이 개발자의 의도로 만들어지기 보다는 여러 설정이 꼬여서 이런 결과가 만들어지는 경우가 대부분이다
  - 그래서 최근 스프링 부트에서는 수동 빈 등록과 자동 빈 등록이 충돌이 나면 오류가 발생하도록 기본 값을 바꾸었다.