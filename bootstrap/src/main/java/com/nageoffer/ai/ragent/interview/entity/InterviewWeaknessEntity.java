package com.nageoffer.ai.ragent.interview.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("t_interview_weakness")
public class InterviewWeaknessEntity {
    @TableId(type = IdType.ASSIGN_ID)
    private String id;
    private String userId;
    private String knowledgePoint;
    private String relatedQuestions;
    private Integer weaknessLevel;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer deleted;
}
