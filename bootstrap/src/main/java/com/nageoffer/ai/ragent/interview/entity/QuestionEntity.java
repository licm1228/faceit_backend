package com.nageoffer.ai.ragent.interview.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("t_question")
public class QuestionEntity {
    @TableId(type = IdType.ASSIGN_ID)
    private String id;
    private String positionId;
    private String questionType;
    private Integer difficulty;
    private String questionText;
    private String referenceAnswer;
    private String keywords;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer deleted;
    private String parentQuestionId; // 新增
}
