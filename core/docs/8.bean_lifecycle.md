## 빈 생명주기 콜백

### 빈 생명주기 콜백 - 시작
- 데이터베이스 커넥션 풀이나 네트워크 소켓처럼 애플리케이션 시작 시점에 필요한 연결을 미리해두고, 애플리케이션 종료 시점에 연결을 모두 종료하는 작업을 진행하려면 객체의 초기화와 종료 작업이 필요하다.
- 스프링은 통한 초기화 작업과 종료 작업을 어떻게 진행하는지 알아보자!

#### 예제 코드 - 외부 네트워크에 연결하는 객체

```java
import java.security.PublicKey;

public class NetworkClient {

    private String url;

    public NetworkClient() {
        System.out.println("생성자 호출, url = " + url);
        connect();
        call("초기화 연결 메시지");
    }
    
    public void setUrl(String url) {
        this.url = url;
    }
    
    // 서비스 시작 시 호출
    public void connect() {
        System.out.println("connect: " + url);
    }
    
    public void call(String message) {
        System.out.println("call: " + url + ", message = " + message);
    }
    
    // 서비스 종료 시 호출
    public void disconnect() {
        System.out.println("close: " + url);
    }
}
```
#### 예제 코드 - 스프링 환경설정과 실행

```java
public class BeanLifeCycleTest {
    @Test
    public void lifeCycleTest() {
        ConfigurableApplicationContext ac = new AnnotationConfigApplicationContext(LifeCycleConfig.class);
        NetworkClient client = ac.getBean(NetworkClient.class);
        ac.close();
    }

    @Configuration
    static class LifeCycleConfig {
        @Bean
        public NetworkClient networkClient() {
            NetworkClient networkClient = new NetworkClient();
            networkClient.setUrl("http://hello-spring.dev");
            return networkClient;
        }
    }
}
```

#### 실행 결과
```java
생성자 호출, url = null
connect: null
call: null, message = 초기화 연결 메시지
```

- 생성자 부분을 보면 url 정보 없이 connect가 호출되는 것을 확인할 수 있다.
- 객체를 생성한 다음에 외부에서 수정자 주입을 통해서 `setUrl()`이 호출되어야 url이 존재하게 된다.

#### 스프링 빈의 Life Cycle
- 객체 생성 => 의존관계 주입
- 스프링 빈은 객체를 생성하고 의존관계 주입이 끝난 후에야 필요한 데이터를 사용할 수 있는 준비가 완료된다.
- 따라서 초기화 작업은 의존관계 주입이 모두 완료된 후에 호출해야 한다.
- 개발자는 의존관계 주입이 모두 완료된 시점을 어떻게 알 수 있을까?
- **스프링은 의존관계 주입이 완료되면 스프링 빈에게 콜백 메서드를 통해서 초기화 시점을 알려주는 다양한 기능을 제공한다.**
- 뿐만 아니라 **스프링은 스프링 컨테이너가 종료되기 직전에 소멸 콜백을 준다**

#### 스프링 빈의 이벤트 Life Cycle
- 스프링 컨테이너 생성 => 스프링 빈 생성 => 의존관계 주입 => 초기화 콜백 => 사용 => 소멸 전 콜백 => 스프링 종료

#### 참고: 객체의 생성과 초기화를 분리하자
- 생성자는 필수 정보(파라미터)를 받고, 메모리를 할당해서 객체를 생성하는 책임을 가진다.
- 초기화는 생성된 값들을 활용해서 외부 커넥션을 연결하는 등의 무거운 동작을 수행한다.
- 따라서 객체를 생성하는 부분과 초기화 하는 부분을 명확하게 나누는 것이 유지보수 관점에서 좋다.

#### 스프링은 크게 3가지 방법으로 빈 생명주기 콜백을 지원한다.
- 인터페이스(InitializingBean, DisposableBean)
- 설정 정보에 초기화 메서드, 종료 메서드 지정
- @PostConstruct, @PreDestory 애노테이션 지원

### 인터페이스 InitializingBean, DisposableBean

#### 예제 코드
```java
public class NetworkClient implements InitializingBean, DisposableBean {
    
    private String url;
    
    public NetworkClient() {
        System.out.println("생성자 호출, url = " + url);
    }
    
    public void setUrl(String url) {
        this.url = url;
    }
    
    // 서비스 시작 시 호출
    public void connect() {
        System.out.println("connect: " + url);
    }
    
    public void call(String message) {
        System.out.println("call: " + url + ", message = " + message);
    }
    
    // 서비스 종료 시 호출
    public void disconnect() {
        System.out.println("close: " + url);
    }
    
    @Override
    public void afterPropertiesSet() throws Exception {
        connect();
        call("초기화 연결 메시지");
    }
    
    @Override
    public void destroy() throws Exception {
        disconnect();
    }
}
```
- `InitializingBean`은 `afterPropertiesSet()` 메서드로 초기화를 지원한다.
- `DisposableBean`은 `destroy()` 메서드로 소멸을 지원한다.

#### 출력 결과
```java
생성자 호출, url = null
NetworkClient.afterPropertiesSet
connect: http://hello-spring.dev
call: http://hello-spring.dev, message = 초기화 연결 메시지
13:24:49.043 [main] DEBUG
org.springframework.context.annotation.AnnotationConfigApplicationContext = Closing NetworkClient.destory
close: http://hello-spring.dev
```
- 초기화 메서드가 주입 완료 후에 적절하게 호출된 것을 확인할 수 있다.
- 스프링 컨테이너의 종료가 호출되자 소멸 메서드가 호출된 것도 확인할 수 있다.

#### 초기화, 소멸 인터페이스의 단점
- 이 인터페이스는 스프링 전용 인터페이스다. 해당 코드가 스프링 전용 인터페이스에 의존한다.
- 초기화, 소멸 메서드의 이름을 변경할 수 없다.
- 사용자가 코드를 수정할 수 없는 외부 라이브러리에는 적용할 수 없다.
- 지금은 더 나은 방법들이 있어서 거의 사용하지 않는다.

### 빈 등록 초기화, 소멸 메서드 지정
- 설정 정보에 `@Bean(initMethod = "init", destroyMethod = "close")`처럼 초기화, 소멸 메서드를 지정할 수 있다.

#### 예제 코드 - 설정 정보에 초기화 및 소멸 메서드 지정
```java
@Configuration
public class LifeCycleConfig {
    
    @Bean(initMethod = "init", destroyMethod = "close")
    public NetworkClient networkClient() {
        NetworkClient networkClient = new NetworkClient();
        networkClient.setUrl("http://hello-spring.dev");
        return networkClient;
    }
    
}
```
#### 실행 결과
```java
생성자 호출, url = null
NetworkClient.init
connect: http://hello-spring.dev
call: http://hello-spring.dev, message = 초기화 연결 메시지
13:33:10.129 [main] DEBUG
org.springframework.context.annotaion.AnnotaionConfigApplicationContext - Closing NetworkClient.close
close: http://hello-spring.dev
```
- 메서드 이름을 자유롭게 줄 수 있다.
- 스프링 빈이 스프링 코드에 의존하지 않는다.
- 코드가 아닌 설정 정보를 사용하기 때문에 코드를 수정할 수 없는 외부 라이브러리에도 초기화, 종료 메서드를 적용할 수 있다.

#### 종료 메서드의 추론
- `@Bean의 destroyMethod` 속성에는 특별한 기능이 있다.
- 라이브러리는 대부분 `close`, `shutdown`이라는 이름의 종료 메서드를 사용한다.
- @Bean의 `destroyMethod`는 기본 값이 `(inferred)`(추론)으로 등록되어 있다.
- 이 추론 기능은 `close`, `shutdown`라는 이름의 메서드를 자동으로 호출해준다. 이름 그대로 종료 메서드를 추론해서 호출해준다.
- 따라서 직접 스프링 빈으로 등록하면 종료 메서드는 따로 적어주지 않아도 잘 동작한다.
- 추론 기능을 사용하기 싫으면 `destroyMethod=""`처럼 빈 공백을 지정하면 된다.

### 애노테이션 @PostConstruct, @PreDestroy

#### 예제 코드

```java
public class NetworkClient {
    
    private String url;
    
    public NetworkClient() {
        System.out.println("생성자 호출, url = " + url);
    }
    
    public void setUrl(String url) {
        this.url = url;
    }
    
    // 서비스 시작 시 호출
    public void connect() {
        System.out.println("connect: " + url);
    }
    
    public void call(String message) {
        System.out.println("call: " + url + ", message = " + message);
    }
    
    // 서비스 종료 시 호출
    public void disconnect() {
        System.out.println("close: " + url);
    }
    
    @PostConstruct
    public void init() {
        System.out.println("NetworkClient.init");
        connect();
        call("초기화 연결 메시지");
    }
    
    @PreDestroy
    public void close() {
        System.out.println("NetworkClient.close");
        disconnect();
    }
}
```

```java
@Configuration
public class LifeCycleConfig {
    
    @Bean
    public NetworkClient networkClient() {
        NetworkClient networkClient = new NetworkClient();
        networkClient.setUrl("http://hello-spring.dev");
        return networkClient;
    }
}
```

#### 실행 결과
```java
생성자 호출, url = null
NetworkClient.init
connect: http://hello-spirng.dev
call: http://hello-spirng.dev, message = 초기화 연결 메시지
19:40:50.269 [main] DEBUG
org.springframework.context.annotation.AnnotationConfigApplicationContext - Closing NetworkClient.close
close: http://hello-spring.dev
```
- `@PostConstruct`, `@PreDestroy` 이 두 애노테이션을 사용하면 가장 편리하게 초기화와 종료를 실행할 수 있다.

#### @PostConstruct, @PreDestroy 애노테이션 특징
- 최신 스프링에서 가장 권장하는 방법이다.
- 애노테이션만 붙이면 됨으로 매우 편리하다.
- `javax.annotation.PostConstruct` 패키지로 스프링에 종속적인 기술이 아니라 자바 표준이다.
- 컴포넌트 스캔과 잘 어울린다.
- 유일한 단점은 외부 라이브러리에는 적용하지 못한다는 점이다. 외부 라이브러리를 초기화, 종료할 시에는 @Bean의 기능을 사용하자.