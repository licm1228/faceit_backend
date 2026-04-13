-- 对齐旧库中的面试岗位命名与题库配置
-- 适用场景：
-- 1. 数据库已执行过 schema_pg.sql / init_data_pg.sql / upgrade_interview_schema.sql
-- 2. 数据库已存在旧的面试岗位与题库数据
-- 3. 需要把旧库升级到当前分支使用的岗位与题库命名体系

BEGIN;

-- 1. 统一核心岗位名称
UPDATE t_position
SET name = 'Java后端开发工程师',
    description = '负责后端系统开发',
    update_time = CURRENT_TIMESTAMP,
    deleted = 0
WHERE id = '1';

UPDATE t_position
SET name = 'Web前端开发工程师',
    description = '负责前端页面开发',
    update_time = CURRENT_TIMESTAMP,
    deleted = 0
WHERE id = '2';

-- 2. 新增 Python 算法岗位
INSERT INTO t_position (id, name, description, required_skills, interview_focus, create_time, update_time, deleted)
VALUES (
    '8',
    'Python算法开发工程师',
    '负责 Python 算法设计与实现',
    'Python, 数据结构, 算法分析, 动态规划, 图论',
    'Python基础, 数据结构, 算法复杂度, 编码实现',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    0
)
ON CONFLICT (id) DO UPDATE SET
name = EXCLUDED.name,
description = EXCLUDED.description,
required_skills = EXCLUDED.required_skills,
interview_focus = EXCLUDED.interview_focus,
update_time = CURRENT_TIMESTAMP,
deleted = 0;

-- 3. 补齐 Python 算法题库
INSERT INTO t_question (id, position_id, question_type, difficulty, question_text, reference_answer, keywords, create_time, update_time, deleted)
VALUES
(
    '16',
    '8',
    '算法题',
    3,
    '请解释 Python 中列表、元组和集合的区别，以及它们各自适合的使用场景。',
    '列表是有序、可变的序列，适合需要频繁增删改的场景；元组是有序、不可变的序列，适合作为只读数据或字典键；集合是无序且元素唯一的容器，适合去重、集合运算和快速判断成员是否存在。',
    '{"Python", "列表", "元组", "集合"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    0
),
(
    '17',
    '8',
    '算法题',
    4,
    '请说明动态规划的核心思想，并用一个经典问题举例说明状态定义和转移方程。',
    '动态规划的核心思想是将原问题拆解为有重叠子问题的最优子结构问题，通过保存子问题结果避免重复计算。以爬楼梯问题为例，设 dp[i] 表示到达第 i 级台阶的方法数，则状态转移方程为 dp[i] = dp[i-1] + dp[i-2]。',
    '{"动态规划", "状态转移", "算法"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    0
),
(
    '18',
    '8',
    '算法题',
    5,
    '请分析 Python 中堆排序与快速排序在时间复杂度、空间复杂度和实际工程使用上的差异。',
    '堆排序最坏时间复杂度稳定为 O(n log n)，空间复杂度通常为 O(1)，但缓存友好性较差；快速排序平均时间复杂度为 O(n log n)，最坏为 O(n^2)，递归实现需要额外栈空间，但通常常数更小、工程实践更常用。实际使用中会结合随机化、三数取中和小数组插排优化。',
    '{"Python", "堆排序", "快速排序", "时间复杂度"}',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    0
)
ON CONFLICT (id) DO UPDATE SET
position_id = EXCLUDED.position_id,
question_type = EXCLUDED.question_type,
difficulty = EXCLUDED.difficulty,
question_text = EXCLUDED.question_text,
reference_answer = EXCLUDED.reference_answer,
keywords = EXCLUDED.keywords,
update_time = CURRENT_TIMESTAMP,
deleted = 0;

COMMIT;

-- 4. 验证
SELECT id, name, deleted
FROM t_position
WHERE id IN ('1', '2', '8')
ORDER BY id;

SELECT id, position_id, difficulty, question_text
FROM t_question
WHERE position_id = '8'
ORDER BY id;
