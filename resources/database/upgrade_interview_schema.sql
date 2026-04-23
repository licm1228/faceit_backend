-- 升级面试系统数据库结构
-- 执行顺序：先创建新表，再修改现有表，最后迁移数据

-- ============================================
-- 1. 创建新表
-- ============================================

-- 创建能力维度评分表
CREATE TABLE IF NOT EXISTS t_interview_dimension_score (
    id VARCHAR(20) NOT NULL PRIMARY KEY,
    conversation_id VARCHAR(20) NOT NULL,
    technical_depth INTEGER,
    expression_ability INTEGER,
    logical_thinking INTEGER,
    knowledge_coverage INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_dimension_conversation ON t_interview_dimension_score (conversation_id);
COMMENT ON TABLE t_interview_dimension_score IS '能力维度评分表';

-- 创建用户薄弱点表
CREATE TABLE IF NOT EXISTS t_user_weakness (
    id VARCHAR(20) NOT NULL PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    knowledge_point VARCHAR(256) NOT NULL,
    weakness_level INTEGER,
    related_questions TEXT,
    last_occurrence TIMESTAMP,
    occurrence_count INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_weakness_user ON t_user_weakness (user_id);
COMMENT ON TABLE t_user_weakness IS '用户薄弱点表';

-- 创建题目知识关联表
CREATE TABLE IF NOT EXISTS t_question_knowledge (
    id VARCHAR(20) NOT NULL PRIMARY KEY,
    question_id VARCHAR(20) NOT NULL,
    knowledge_point VARCHAR(256) NOT NULL,
    relevance_score FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted SMALLINT DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_knowledge_question ON t_question_knowledge (question_id);
COMMENT ON TABLE t_question_knowledge IS '题目知识关联表';

-- ============================================
-- 2. 修改现有表结构
-- ============================================

-- 修改 t_interview_session 表
ALTER TABLE t_interview_session ADD COLUMN IF NOT EXISTS total_duration INTEGER;
ALTER TABLE t_interview_session ADD COLUMN IF NOT EXISTS knowledge_graph JSONB;
ALTER TABLE t_interview_session ADD COLUMN IF NOT EXISTS current_question_count INTEGER DEFAULT 0;
ALTER TABLE t_interview_session ADD COLUMN IF NOT EXISTS time_limit INTEGER;
ALTER TABLE t_interview_session ADD COLUMN IF NOT EXISTS total_questions INTEGER;

-- 修改 t_interview_answer 表
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS is_follow_up BOOLEAN DEFAULT FALSE;
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS parent_question_id VARCHAR(20);
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS conversation_order INTEGER;
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS technical_score INTEGER;
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS expression_score INTEGER;
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS logic_score INTEGER;
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS knowledge_score INTEGER;
ALTER TABLE t_interview_answer ADD COLUMN IF NOT EXISTS is_correct BOOLEAN;

-- 修改 t_question 表
ALTER TABLE t_question ADD COLUMN IF NOT EXISTS parent_question_id VARCHAR(20);
ALTER TABLE t_question ADD COLUMN IF NOT EXISTS knowledge_points JSONB;

-- ============================================
-- 3. 添加索引
-- ============================================

-- 为现有表添加缺失的索引
CREATE INDEX IF NOT EXISTS idx_session_duration ON t_interview_session (total_duration);
CREATE INDEX IF NOT EXISTS idx_session_current_question ON t_interview_session (current_question_count);
CREATE INDEX IF NOT EXISTS idx_answer_follow_up ON t_interview_answer (is_follow_up);
CREATE INDEX IF NOT EXISTS idx_answer_parent ON t_interview_answer (parent_question_id);
CREATE INDEX IF NOT EXISTS idx_answer_order ON t_interview_answer (conversation_order);
CREATE INDEX IF NOT EXISTS idx_question_parent ON t_question (parent_question_id);

-- 为新表添加索引
CREATE INDEX IF NOT EXISTS idx_weakness_knowledge ON t_user_weakness (knowledge_point);
CREATE INDEX IF NOT EXISTS idx_knowledge_point ON t_question_knowledge (knowledge_point);

-- ============================================
-- 4. 数据迁移
-- ============================================

-- 为现有回答设置对话顺序
UPDATE t_interview_answer SET conversation_order = ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY create_time);

-- 为现有题目添加知识点关联
-- Java开发工程师题目
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, 'Java基础', 0.9 FROM t_question WHERE position_id = '1' AND question_text LIKE '%多线程%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '垃圾回收', 0.9 FROM t_question WHERE position_id = '1' AND question_text LIKE '%垃圾回收%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, 'Spring框架', 0.9 FROM t_question WHERE position_id = '1' AND question_text LIKE '%Spring%';

-- 前端开发工程师题目
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, 'React', 0.9 FROM t_question WHERE position_id = '2' AND question_text LIKE '%React%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '前端路由', 0.9 FROM t_question WHERE position_id = '2' AND question_text LIKE '%路由%';

-- 全栈开发工程师题目
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, 'RESTful API', 0.9 FROM t_question WHERE position_id = '3' AND question_text LIKE '%RESTful%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '微服务', 0.9 FROM t_question WHERE position_id = '3' AND question_text LIKE '%微服务%';

-- 数据工程师题目
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, 'SQL', 0.9 FROM t_question WHERE position_id = '4' AND question_text LIKE '%SQL%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '数据仓库', 0.9 FROM t_question WHERE position_id = '4' AND question_text LIKE '%数据仓库%';

-- DevOps工程师题目
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, 'CI/CD', 0.9 FROM t_question WHERE position_id = '5' AND question_text LIKE '%CI/CD%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, 'Docker', 0.9 FROM t_question WHERE position_id = '5' AND question_text LIKE '%Docker%';

-- 测试工程师题目
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '软件测试', 0.9 FROM t_question WHERE position_id = '6' AND question_text LIKE '%软件测试%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '自动化测试', 0.9 FROM t_question WHERE position_id = '6' AND question_text LIKE '%自动化测试%';

-- 产品经理题目
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '产品经理', 0.9 FROM t_question WHERE position_id = '7' AND question_text LIKE '%产品经理%';
INSERT INTO t_question_knowledge (id, question_id, knowledge_point, relevance_score)
SELECT gen_random_uuid()::VARCHAR(20), id, '敏捷开发', 0.9 FROM t_question WHERE position_id = '7' AND question_text LIKE '%敏捷开发%';

-- ============================================
-- 5. 验证升级
-- ============================================

-- 检查表结构
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name IN ('t_interview_session', 't_interview_answer', 't_question', 't_interview_dimension_score', 't_user_weakness', 't_question_knowledge')
ORDER BY table_name, ordinal_position;

-- 检查数据完整性
SELECT 't_interview_session' AS table_name, COUNT(*) AS count FROM t_interview_session UNION ALL
SELECT 't_interview_answer' AS table_name, COUNT(*) AS count FROM t_interview_answer UNION ALL
SELECT 't_question' AS table_name, COUNT(*) AS count FROM t_question UNION ALL
SELECT 't_question_knowledge' AS table_name, COUNT(*) AS count FROM t_question_knowledge;