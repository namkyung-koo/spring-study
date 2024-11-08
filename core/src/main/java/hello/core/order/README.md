### 주문과 할인 도메인 개발

#### 예제 코드 - 할인 정책 인터페이스

```java
import hello.core.member.Member;

public interface DiscountPolicy {
    /**
     * @return 할인 대상 금액
     */
    int discount(Member, int price);
}
```

#### 예제 코드 - 정액 할인 정책 구현체

```java
import hello.core.discount.DiscountPolicy;
import hello.core.member.Grade;
import hello.core.member.Member;

public class FixDiscountPolicy implements DiscountPolicy {

    private int discountFixAmount = 1000; // 1000원 할인

    @Override
    public int discount(Member member, int price) {
        if (member.getGrade() == Grade.VIP) {
            return discountFixAmount;
        } else {
            return 0;
        }
    }
}
```

#### 예제 코드 - 주문 엔티티
```java
public class Order {
    
    private Long memberId;
    private String itemName;
    private int itemPrice;
    private int discountPrice;
    
    public Order(Long memberId, String itemName, int itemPrice, int discountPrice) {
        this.memberId = memberId;
        this.itemName = itemName;
        this.itemPrice = itemPrice;
        this.discountPrice = discountPrice;
    }
    
    public int calculatePrice() {
        return itemPrice - discountPrice;
    }
    
    public Long getMemberId() {
        return memberId;
    }
    
    public String getItemName() {
        return itemName;
    }
    
    public int getItemPrice() {
        return itemPrice;
    }
    
    public int getDiscountPrice() {
        return discountPrice;
    }
    
    @Override
    public String toString() {
        return "Order{" + 
                "memberId=" + memberId + 
                ", itemName=" + itemName + '\'' + 
                ", itemPrice=" + itemPrice + 
                ", discountPrice=" + discountPrice + 
                '}'; 
    }
}
```

#### 에제 코드 - 주문 서비스 인터페이스

```java
import hello.core.order.Order;

public interface OrderService {
    Order createOrder(Long memberId, String itemName, int itemPrice);
}
```

#### 에제 코드 - 주문 서비스 구현체

```java
import hello.core.discount.DiscountPolicy;
import hello.core.discount.FixDiscountPolicy;
import hello.core.member.Member;
import hello.core.member.MemberRepository;
import hello.core.member.MemoryMemberRepository;
import hello.core.order.Order;
import hello.core.order.OrderService;

public class OrderServiceImpl implements OrderService {
    private final MemberRepository memberRepository = new MemoryMemberRepository();
    private final DiscountPolicy discountPolicy = new FixDiscountPolicy();

    @Override
    public Order createOrder(Long memberId, String itemName, int itemPrice) {

        Member member = memberRepository.findById(memberId);
        int discountPrice = discountPolicy.discount(member, itemPrice);

        return new Order(memberId, itemName, itemPrice, discountPrice);
    }
}
```

### 주문과 할인 도메인 실행과 테스트

#### 예제 코드 - 주문과 할인 정책 실행

```java
import hello.core.member.Grade;
import hello.core.member.Member;
import hello.core.member.MemberService;
import hello.core.member.MemberServiceImpl;
import hello.core.order.Order;
import hello.core.order.OrderService;
import hello.core.order.OrderServiceImpl;

public class OrderApp {

    public static void main(String[] args) {
        MemberService memberService = new MemberServiceImpl();
        OrderService orderService = new OrderServiceImpl();

        long memberId = 1L;
        Member member = new Member(memberId, "memberA", Grade.VIP);
        memberService.join(member);

        Order order = orderService.createOrder(memberId, "itemA", 10000);

        System.out.println("order = " + order);
        
    }
}
```

#### 실행 결과
```java
order = Order{memberId=1, itemName='itemA', itemPrice=10000, discountPrice=1000}
```

#### 예제 코드 - JUnit 프레임워크를 사용한 주문과 할인 정책 테스트 코드

```java
import hello.core.member.Grade;
import hello.core.member.Member;
import hello.core.member.MemberService;
import hello.core.member.MemberServiceImpl;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.
        *;

class OrderServiceTest {

    MemberService memberService = new MemberServiceImpl();
    OrderService orderService = new OrderServiceImpl();
    
    @Test
    void createOrder() {
        long memberId = 1L;
        Member member = new Member(memberId, "memberA", Grade.VIP);
        memberService.join(member);
        
        Order order = orderService.createOrder(memberId, "itemA", 10000);
        Assertions.assertThat(order.getDiscountPrice()).isEqualTo(1000);
    }
}
```