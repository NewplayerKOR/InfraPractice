package com.back.exception;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * 에러 응답 DTO
 * - 클라이언트에게 일관된 형식의 에러 정보 전달
 */
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ErrorResponse {
    
    private LocalDateTime timestamp;  // 에러 발생 시각
    private int status;                // HTTP 상태 코드
    private String error;              // 에러 유형
    private String message;            // 에러 메시지
    private Map<String, String> errors; // 필드별 에러 (Validation 용)
}
