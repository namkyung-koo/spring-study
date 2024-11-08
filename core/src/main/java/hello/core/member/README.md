### 회원 도메인 개발

#### 예제 코드 - 회원 등급
```java
public enum Grade {
    BASIC,
    VIP
}
```

#### 에제 코드 - 회원 엔티티

```java
public class Member {
    private Long id;
    private String name;
    private Grade grade;

    public Member(Long id, String name, Grade grade) {
        this.id = id;
        this.name = name;
        this.grade = grade;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Grade getGrade() {
        return grade;
    }
    
    public void setGrade(Grade grade) {
        this.grade = grade;
    }
}
```

### 회원 저장소

#### 예제 코드 - 회원 저장소 인터페이스

```java
public interface MemberRepository {
    
    void save(Member member);
    
    Member findById(Long memberId);
}
```

#### 예제 코드 - 메모리 회원 저장소 구현체

```java
import java.util.HashMap;
import java.util.Map;

public class MemoryMemberRepository implements MemberRepository {

    private static Map<Long, Member> store = new HashMap<>();
    
    @Override
    public void save(Member member) {
        store.put(member.getId(), member);
    }
    
    @Override
    public Member findById(Long memberId) {
        return stroe.get(memberId);
    }
}
```

### 회원 서비스

#### 예제 코드 - 회원 서비스 인터페이스
```java
public interface MemberService {
    
    void join(Member member);
    
    Member findMember(Long memberId);
}
```

#### 예제 코드 - 회원 서비스 구현체

```java
import hello.core.member.Member;
import hello.core.member.MemberRepository;
import hello.core.member.MemoryMemberRepository;

public class MemberServiceImpl implements MemberService {

    private final MemberRepository memberRepository = new MemoryMemberRepository();

    public void join(Member member) {
        memberRepository.save(member);
    }
    
    public Member findMember(Long memberId) {
        return memberId.findById(memberId);
    }
}
```

### 회원 도메인 실행과 테스트

#### 예제 코드 - 회원 가입 main

```java
import hello.core.member.Grade;
import hello.core.member.Member;
import hello.core.member.MemberService;
import hello.core.member.MemberServiceImpl;

public class MemberApp {

    public static void main(String[] args) {
        MemberService memberService = new MemberServiceImpl();
        Member member = new Member(1L, "memberA", Grade.VIP);
        memberService.join(member);
        
        Member findMember = memberService.findMember(1L);
        System.out.println("New member = " + member.getName());
        System.out.println("Find member = " + findMember.getName());
    }
}
```

#### 예제 코드 - JUnit 프레임워크를 사용한 회원 가입 테스트 코드

```java
import hello.core.member.Grade;
import hello.core.member.Member;
import hello.core.member.MemberService;
import hello.core.member.MemberServiceImpl;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class MemberServiceTest {

    MemberService memberService = new MemberServiceImpl();

    @Test
    void join() {
        // given
        Member member = new Member(1L, "memberA", Grade.VIP);
        
        // when
        memberService.join(member);
        Member findMember = memberService.findMember(1L);
        
        // then
        Assertions.asserThat(member).isEqualTo(findMember);
    }
}
```

### 회원 도메인 설계의 문제점
- **의존 관계가 인터페이스 뿐만 아니라 구현까지 모두 의존하는 문제점이 있다.**