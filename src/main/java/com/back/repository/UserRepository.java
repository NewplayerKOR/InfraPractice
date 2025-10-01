package com.back.repository;

import com.back.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * User Repository
 * - JpaRepository를 상속받아 기본적인 CRUD 메서드 제공
 * - Spring Data JPA가 런타임에 구현체를 자동 생성
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * 사용자명으로 사용자 조회
     * - 메서드 이름 규칙에 따라 쿼리 자동 생성: SELECT * FROM users WHERE username = ?
     */
    Optional<User> findByUsername(String username);

    /**
     * 사용자명 중복 확인
     * - 메서드 이름 규칙에 따라 쿼리 자동 생성: SELECT COUNT(*) > 0 FROM users WHERE username = ?
     */
    boolean existsByUsername(String username);
}
