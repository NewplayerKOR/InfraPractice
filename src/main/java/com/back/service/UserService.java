package com.back.service;

import com.back.dto.UserRequestDto;
import com.back.dto.UserResponseDto;
import com.back.entity.User;
import com.back.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * User Service
 * - 비즈니스 로직을 처리하는 서비스 계층
 * - @Transactional을 통해 트랜잭션 관리
 * - Repository를 통해 데이터베이스와 상호작용
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    /**
     * 모든 사용자 조회
     * - readOnly 트랜잭션으로 성능 최적화
     */
    public List<UserResponseDto> getAllUsers() {
        log.info("모든 사용자 조회");
        return userRepository.findAll().stream()
                .map(UserResponseDto::from)
                .collect(Collectors.toList());
    }

    /**
     * ID로 사용자 조회
     * - 사용자가 없을 경우 IllegalArgumentException 발생
     */
    public UserResponseDto getUserById(Long id) {
        log.info("사용자 조회 - ID: {}", id);
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. ID: " + id));
        return UserResponseDto.from(user);
    }

    /**
     * 사용자명으로 사용자 조회
     */
    public UserResponseDto getUserByUsername(String username) {
        log.info("사용자 조회 - Username: {}", username);
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. Username: " + username));
        return UserResponseDto.from(user);
    }

    /**
     * 사용자 생성
     * - @Transactional을 통해 쓰기 트랜잭션 활성화
     * - 중복 사용자명 체크 후 생성
     */
    @Transactional
    public UserResponseDto createUser(UserRequestDto requestDto) {
        log.info("사용자 생성 요청 - Username: {}", requestDto.getUsername());
        
        // 중복 체크
        if (userRepository.existsByUsername(requestDto.getUsername())) {
            throw new IllegalArgumentException("이미 존재하는 사용자명입니다: " + requestDto.getUsername());
        }

        // Entity 생성 및 저장
        User user = User.builder()
                .username(requestDto.getUsername())
                .email(requestDto.getEmail())
                .phone(requestDto.getPhone())
                .build();

        User savedUser = userRepository.save(user);
        log.info("사용자 생성 완료 - ID: {}, Username: {}", savedUser.getId(), savedUser.getUsername());
        
        return UserResponseDto.from(savedUser);
    }

    /**
     * 사용자 정보 수정
     * - 더티 체킹(Dirty Checking)을 활용한 업데이트
     * - 트랜잭션 커밋 시점에 자동으로 UPDATE 쿼리 실행
     */
    @Transactional
    public UserResponseDto updateUser(Long id, UserRequestDto requestDto) {
        log.info("사용자 수정 요청 - ID: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다. ID: " + id));

        // Entity의 메서드를 통해 업데이트 (더티 체킹)
        user.updateInfo(requestDto.getEmail(), requestDto.getPhone());
        
        log.info("사용자 수정 완료 - ID: {}", id);
        return UserResponseDto.from(user);
    }

    /**
     * 사용자 삭제
     */
    @Transactional
    public void deleteUser(Long id) {
        log.info("사용자 삭제 요청 - ID: {}", id);
        
        if (!userRepository.existsById(id)) {
            throw new IllegalArgumentException("사용자를 찾을 수 없습니다. ID: " + id);
        }

        userRepository.deleteById(id);
        log.info("사용자 삭제 완료 - ID: {}", id);
    }
}
