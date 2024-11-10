## 스프링 컨테이너와 스프링 빈

### 스프링 컨테이너 생성

#### 예제 코드 - 스프링 컨테이너 생성
```java
ApplicationContext applicationContext = new AnnotationConfigApplicationContext(Appconfig.class);
```
- `ApplicationContext`를 스프링 컨테이너라 한다.
- `ApplicationContext`는 인터페이스이다.
- 스프링 컨테이너는 XML을 기반으로 만들 수도 있고, 애노테이션 기반의 자바 설정 클래스로도 만들 수 있다.
- 자바 설정 클래스를 기반으로 스프링 컨테이너(`ApplicationContext`)를 만들어보자
  - `new AnnotationConfigApplicationContext(AppConfig.class);`
  - 이 클래스는 `ApplicationContext` 인터페이스의 구현체이다.

#### 스프링 컨테이너의 생성 과정

1. **스프링 컨테이너 생성**
- `new AnnotationConfigApplicationContext(AppConfig.class)`
- 스프링 컨테이너를 생성할 때는 구성 정보를 지정해주어야 한다.
- 위의 예에서는 `AppConfig.class`를 구성 정보로 지정했다.
2. **스프링 빈 등록**
- 스프링 컨테이너는 파라미터로 넘어온 설정 클래스의 정보를 사용해서 스프링 빈을 등록한다.
- 빈 이름
  - 빈 이름은 메서드 이름을 사용한다.
  - 빈 이름을 직접 부여할 수도 있다.
  - `@Bean(name="exampleService")`
  - **빈 이름은 항상 다른 이름을 부여해야 한다.**
3. **스프링 빈 의존관계 설정 - 준비**
- 컨테이너 내부에 빈을 생성한다.
4. **스프링 빈 의존관계 설정 - 완료**
- 스프링 컨테이너는 설정 정보를 참고해서 의존관계를 주입(DI)한다.
- 단순히 자바 코드를 호출하는 것과는 차이가 있다. (싱글톤 컨테이너 파트에서 설명)

#### 참고
스프링은 빈을 생성하고, 의존관계를 주입하는 단계가 나누어져 있다.
그런데 자바 코드로 스프링 빈을 등록하면 생성자를 호출하면서 의존관계 주입도 한 번에 처리된다.

### 컨테이너에 등록된 모든 빈 조회

#### 예제 코드 - 컨테이너에 등록된 모든 빈 조회하기
```java
class ApplicationContextInfoTest {
    
    AnnotationConfigApplicationContext ac = new AnnotationConfigApplicaiontContext(AppConfig.class);
    
    @Test
    @DisplayName("모든 빈 출력하기")
    void findAllBean() {
        String[] beanDefinitionNames = ac.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            Object bean = ac.getBean(beanDefinitionName);
            System.out.println("name = " + beanDefinitionName + ", object = " + bean);
        }
    }
    
    @Test
    @DisplayName("애플리케이션 빈 출력하기")
    void findApplicationBean() {
        String[] beanDefinitionNames = ac.getBeanDefinitionNames();
        for (String beanDefinitionName : beanDefinitionNames) {
            BeanDefinition beanDefinition = ac.getBeanDefinition(beanDefinitionName);
            
            // Role ROLE_APPLICATION: 직접 등록한 애플리케이션 빈
            // Role ROLE_INFRASTRUCTURE: 스프링이 내부에서 사용하는 빈
            if (beanDefinition.getRole() == BeanDefinition.ROLS_APPLICATION) {
                Object bean = ac.getBean(beanDefinitionName);
                System.out.println("name = " + beanDefinitionName + ", object = " + bean);
            }
        }
    }
}
```
- 모든 빈 출력하기
  - 실행하면 스프링에 등록된 모든 빈 정보를 출력할 수 있다.
  - `ac.getBeanDefinitionNames()`: 스프링에 등록된 모든 빈 이름을 조회한다.
  - `ac.getBean()`: 빈 이름으로 빈 객체(인스턴스)를 조회한다.
- 애플리케이션 빈 출력하기
  - 스프링 내부에서 사용하는 빈은 제외하고, 내가 등록한 빈만 출력해보자
  - 스프링이 내부에서 사용하는 빈은 `getRole()`로 구분할 수 있다.
    - `ROLE_APPLICATION`: 일반적으로 사용하자가 정의한 빈
    - `ROLE_INFRASTRUCTURE`: 스프링이 내부에서 사용하는 빈

### 스프링 빈 조회 - 기본
스프링 컨테이너에서 스프링 빈을 찾는 가장 기본적인 조회 방법
- `ac.getBean(빈이름, 타입)`
- `ac.getBean(타입)`
- 조회 대상 스프링 빈이 없으면 예외가 발생한다.
  - `NoSuchBeanDefinitionException: No bean named 'xxxxx' available`

### 스프링 빈 조회 - 동일한 타입이 둘 이상
- 타입으로 조회 시 같은 타입의 스프링 빈이 둘 이상이면 오류가 발생한다. 이 때는 빈 이름을 지정해주어야 한다.
- `ac.getBeansOfType()`을 사용하면 해당 타입의 모든 빈을 조회할 수 있다. (반환 값은 `Map 타입`)

#### 예제 코드 - 동일한 타입이 둘 이상 존재하는 빈 조회하기

```java
import java.beans.BeanProperty;
import java.util.Map;

class ApplicationContextSameBeanFindTest {

    AnnotationConfigApplicationContext ac = new AnnotationConfigApplicationContext(SameBeanConfig.class);

    @Test
    @DisplayName("타입으로 조회 시, 같은 타입이 둘 이상 있으면 중복 오류가 발생한다.")
    void findBeanByTypeDuplicate() {
        assertThrows(NoUniqueBeanDefinitionException.class, () ->
                ac.getBean(MemberRepository.class));
    }

    @Test
    @DisplayName("타입으로 조회 시, 같은 타입이 둘 이상 있으면 빈 이름을 지정하면 된다.")
    void findBeanByName() {
        MemberRepository memberRepository = ac.getBean("memberRepository1", MemberRepository.class);
        assertThat(memberRepository).isInstanceOf(MemberRepository.class);
    }

    @Test
    @DisplayName("특정 타입을 모두 조회하기")
    void findAllBeanByType() {
        Map<String, MemberRepository> beansOfType = ac.getBeansOfType(MemberRepository.class);
        for (String key : beansOfType.keySet()) {
            System.out.println("key = " + key + ", value = " + beansOfType.get(key));
        }
        System.out.println("beansOfType = " + beansOfType);
        assertThat(beansOfType.size()).isEqualTo(2);
    }

    @Configuration
    static class SameBeanConfig {

        @Bean
        public MemberRepository memberRepository1() {
            return new MemoryMemberRepository();
        }
        
        @Bean
        public MemberRepository memberRepository2() {
            return new MemoryMemberRepository();
        }
    }
}
```

### 스프링 빈 조회 - 상속 관계
- 부모 타입으로 조회하면, 자식 타입도 함께 조회한다.
- 그래서 모든 자바 객체의 최고 부모인 `Object`타입으로 조회하면, 모든 스프링 빈을 조회한다.

### BeanFactory와 ApplicationContext

#### BeanFactory
- 스프링 컨테이너의 최상위 인터페이스이다.
- 스프링 빈을 관리하고 조회하는 역할을 담당한다.
- `getBean()`을 제공한다.
- 지금까지 사용했던 대부분의 기능은 BeanFactory가 제공하는 기능이다.

#### ApplicationContext
- BeanFactory 기능을 모두 상속 받아서 제공한다.
- 빈을 관리하고 조회하는 기능을 제외한, 수많은 부가기능을 제공한다.

#### ApplicationContext가 제공하는 부가 기능
- **메시지소스를 활용한 국제화 기능**
  - 예를 들어, 한국에서 들어오면 한국어로 영어권에서 들어오면 영어로 출력해준다.
- **환경변수**
  - 로컬, 개발, 운영 등을 구분해서 처리한다.
- **애플리케이션 이벤트**
  - 이벤트를 발행하고 구독하는 모델을 편리하게 지원한다.
- **편리한 리소스 조회**
  - 파일, 클래스패스, 외부 등에서 리소스를 편하게 조회한다.

### 스프링 빈 설정 메타 정보 - BeanDefinition
- `BeanDefinition`이라는 추상화 덕분에 스프링은 애노테이션 기반 뿐만 아니라 xml 기반의 설정 형식을 지원한다.
- `BeanDefinition`을 빈 설정 메타 정보라 한다.
  - `@Bean`, `<bean>` 당 하나씩 메타 정보가 생성된다.
  - 스프링 컨테이너는 이 메타 정보를 기반으로 스프링 빈을 생성한다.

#### 코드 레벨에서의 분석
- `AnnotationConfigApplicationContext`는 `AnnotationBeanDefinitionReader`를 사용해서 `AppConfig.class`를 읽고 `BeanDefinition`을 생성한다.
- `GenericXmlApplicationContext`는 `XmlBeanDefinitionReader`를 사용해서 `appConfig.xml` 설정 정보를 읽고 `BeanDefinition`을 생성한다.
- 새로운 형식의 설정 정보가 추가되면, XxxBeanDefinitionReader를 만들어서 `BeanDefinition`을 생성하면 된다.

#### BeanDefinition 정보
- BeanClassName: 생성할 빈의 클래스 명(자바 설정처럼 팩토리 역할의 빈을 사용하면 없다.)
- factoryBeanName: 팩토리 역할의 빈을 사용할 경우의 이름. 예) appConfig
- factoryMethodName: 빈을 생성할 팩토리 메서드 지정. 예) memberService
- Scope: 싱글톤(기본 값)
- lazyInit: 스프링 컨테이너를 생성할 때 빈을 생성하는 것이 아니라, 실제 빈을 사용할 때까지 최대한 생성을 지연 처리하는 지 여부
- InitMethodName: 빈을 생성하고, 의존관계를 적용한 뒤 호출되는 초기화 메서드 명
- DestroyMethodName: 빈의 생명주기가 끝나서 제거하기 직전에 호출되는 메서드 명
- Constructor arguments, Properties: 의존관계 주입에서 사용한다. (자바 설정처럼 팩토리 역할의 빈을 사용하면 없다.)