package com.nageoffer.ai.ragent.interview.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("t_interview_answer")
public class InterviewAnswerEntity {
    @TableId(type = IdType.ASSIGN_ID)
    private String id;
    private String sessionId;
    private String questionId;
    private String userAnswer;
    private Integer score;
    private String feedback;
    private String suggestions;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer deleted;
    private Integer technicalScore; // 新增
    private Integer expressionScore; // 新增
    private Integer logicScore; // 新增
    private Integer knowledgeScore; // 新增
    private Boolean isCorrect; // 新增
}
