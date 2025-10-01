package com.back.controller;

import com.back.dto.UserRequestDto;
import com.back.dto.UserResponseDto;
import com.back.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * User Controller
 * - REST API 엔드포인트를 제공하는 컨트롤러
 * - @RestController: @Controller + @ResponseBody (JSON 응답 자동 변환)
 * - @RequestMapping: 기본 경로를 /api/users로 설정
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;

    /**
     * 모든 사용자 조회
     * GET /api/users
     */
    @GetMapping
    public ResponseEntity<List<UserResponseDto>> getAllUsers() {
        log.info("GET /api/users - 모든 사용자 조회 요청");
        List<UserResponseDto> users = userService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    /**
     * ID로 사용자 조회
     * GET /api/users/{id}
     * 
     * @PathVariable: URL 경로의 변수를 메서드 파라미터로 바인딩
     */
    @GetMapping("/{id}")
    public ResponseEntity<UserResponseDto> getUserById(@PathVariable Long id) {
        log.info("GET /api/users/{} - 사용자 조회 요청", id);
        UserResponseDto user = userService.getUserById(id);
        return ResponseEntity.ok(user);
    }

    /**
     * 사용자명으로 사용자 조회
     * GET /api/users/username/{username}
     */
    @GetMapping("/username/{username}")
    public ResponseEntity<UserResponseDto> getUserByUsername(@PathVariable String username) {
        log.info("GET /api/users/username/{} - 사용자명으로 조회 요청", username);
        UserResponseDto user = userService.getUserByUsername(username);
        return ResponseEntity.ok(user);
    }

    /**
     * 사용자 생성
     * POST /api/users
     * 
     * @RequestBody: HTTP 요청 본문을 객체로 변환
     * @Valid: Bean Validation 수행 (DTO의 @NotBlank, @Email 등 검증)
     * 
     * 성공 시 201 Created 상태 코드와 생성된 사용자 정보 반환
     */
    @PostMapping
    public ResponseEntity<UserResponseDto> createUser(@Valid @RequestBody UserRequestDto requestDto) {
        log.info("POST /api/users - 사용자 생성 요청: {}", requestDto.getUsername());
        UserResponseDto createdUser = userService.createUser(requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }

    /**
     * 사용자 정보 수정
     * PUT /api/users/{id}
     * 
     * PUT은 전체 리소스 수정에 사용 (PATCH는 부분 수정)
     */
    @PutMapping("/{id}")
    public ResponseEntity<UserResponseDto> updateUser(
            @PathVariable Long id,
            @Valid @RequestBody UserRequestDto requestDto) {
        log.info("PUT /api/users/{} - 사용자 수정 요청", id);
        UserResponseDto updatedUser = userService.updateUser(id, requestDto);
        return ResponseEntity.ok(updatedUser);
    }

    /**
     * 사용자 삭제
     * DELETE /api/users/{id}
     * 
     * 성공 시 204 No Content 상태 코드 반환 (응답 본문 없음)
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        log.info("DELETE /api/users/{} - 사용자 삭제 요청", id);
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * 헬스 체크 엔드포인트
     * GET /api/users/health
     * 
     * API 서버가 정상 동작하는지 확인용
     */
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("User API is running!");
    }
}
