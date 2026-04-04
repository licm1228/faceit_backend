package com.nageoffer.ai.ragent.interview.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("t_position")
public class PositionEntity {
    @TableId(type = IdType.ASSIGN_ID)
    private String id;
    private String name;
    private String description;
    private String requiredSkills;
    private String interviewFocus;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer deleted;
}