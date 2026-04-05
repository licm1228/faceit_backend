package com.nageoffer.ai.ragent.interview.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("t_interview_session")
public class InterviewSessionEntity {
    @TableId(type = IdType.ASSIGN_ID)
    private String id;
    private String userId;
    private String positionId;
    private String status; // pending, in_progress, completed
    private Integer totalScore;
    private String evaluationReport;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer deleted;
    private Integer currentQuestionCount; // 新增
    private Integer timeLimit; // 新增
    private Integer totalQuestions; // 新增
}
