-- FaceIt 最小可用默认配置
-- 适用于 PostgreSQL，本脚本可重复执行

-- ============================================
-- 默认意图树
-- ============================================

INSERT INTO t_intent_node (
    id, intent_code, name, level, parent_code, description, examples, kind,
    sort_order, enabled, create_by, update_by, deleted
)
SELECT
    '2040000000000000001', 'interview', '面试', 0, NULL,
    'FaceIt 面试场景根节点，统一承载岗位知识问答和模拟面试发起。',
    '["我要准备面试","我要开始模拟面试","帮我复习面试知识点"]',
    0, 10, 1, 'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_intent_node WHERE intent_code = 'interview' AND deleted = 0
);

INSERT INTO t_intent_node (
    id, intent_code, name, level, parent_code, description, examples, kind,
    sort_order, enabled, create_by, update_by, deleted
)
SELECT
    '2040000000000000002', 'interview-kb', '岗位知识问答', 1, 'interview',
    '针对具体岗位知识库做定向检索，适合八股、原理、概念、实战类提问。',
    '["帮我讲讲 Java 线程池","解释一下 Python 生成器","前端闭包是什么"]',
    0, 20, 1, 'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-kb' AND deleted = 0
);

INSERT INTO t_intent_node (
    id, intent_code, name, level, parent_code, description, examples, kind,
    sort_order, enabled, create_by, update_by, deleted
)
SELECT
    '2040000000000000003', 'interview-mock', '模拟面试', 1, 'interview',
    '发起具体岗位的模拟面试，调用面试题选择 MCP 工具返回题目和相关知识片段。',
    '["帮我开始 Java 模拟面试","我要刷 Python 算法面试","来一轮前端模拟面试"]',
    2, 30, 1, 'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-mock' AND deleted = 0
);

INSERT INTO t_intent_node (
    id, kb_id, intent_code, name, level, parent_code, description, examples,
    collection_name, top_k, kind, prompt_snippet, sort_order, enabled,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000011', kb.id, 'interview-java-kb', 'Java后端知识问答', 2, 'interview-kb',
    'Java 后端岗位知识问答，优先命中 Java后端 知识库。',
    '["Java 八股有哪些重点","线程池原理是什么","Spring 事务失效场景"]',
    kb.collection_name, 6, 0,
    '回答时优先围绕 Java 后端岗位知识展开，术语准确，必要时给出面试回答思路。',
    110, 1, 'system', 'system', 0
FROM t_knowledge_base kb
WHERE kb.deleted = 0
  AND kb.name = 'Java后端'
  AND NOT EXISTS (
      SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-java-kb' AND deleted = 0
  );

INSERT INTO t_intent_node (
    id, kb_id, intent_code, name, level, parent_code, description, examples,
    collection_name, top_k, kind, prompt_snippet, sort_order, enabled,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000012', kb.id, 'interview-python-kb', 'Python算法知识问答', 2, 'interview-kb',
    'Python 算法岗位知识问答，优先命中 Python算法 知识库。',
    '["Python 算法题怎么准备","解释一下生成器和迭代器","二叉树遍历怎么写"]',
    kb.collection_name, 6, 0,
    '回答时优先围绕 Python 算法岗位知识展开，兼顾算法思路、复杂度和代码表达。',
    120, 1, 'system', 'system', 0
FROM t_knowledge_base kb
WHERE kb.deleted = 0
  AND kb.name = 'Python算法'
  AND NOT EXISTS (
      SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-python-kb' AND deleted = 0
  );

INSERT INTO t_intent_node (
    id, kb_id, intent_code, name, level, parent_code, description, examples,
    collection_name, top_k, kind, prompt_snippet, sort_order, enabled,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000013', kb.id, 'interview-frontend-kb', '前端知识问答', 2, 'interview-kb',
    '前端岗位知识问答，优先命中 web前端 知识库。',
    '["前端闭包是什么","React 和 Vue 区别","浏览器缓存怎么回答"]',
    kb.collection_name, 6, 0,
    '回答时优先围绕前端岗位知识展开，说明概念、原理和常见面试追问。',
    130, 1, 'system', 'system', 0
FROM t_knowledge_base kb
WHERE kb.deleted = 0
  AND kb.name = 'web前端'
  AND NOT EXISTS (
      SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-frontend-kb' AND deleted = 0
  );

INSERT INTO t_intent_node (
    id, intent_code, name, level, parent_code, description, examples,
    mcp_tool_id, kind, prompt_snippet, param_prompt_template, sort_order,
    enabled, create_by, update_by, deleted
)
SELECT
    '2040000000000000021', 'interview-java-mock', 'Java后端模拟面试', 2, 'interview-mock',
    '发起 Java 后端模拟面试，调用 interview-select-question 选择题目。',
    '["开始 Java 模拟面试","来一道 Java 面试题","我想练 Java 后端面试"]',
    'interview-select-question', 2,
    '这是 Java 后端模拟面试场景，先给出题目，再基于工具返回的参考信息组织回答。',
    '你要从用户输入中提取模拟面试参数，仅输出 JSON。positionId 固定取 pos_java_001。若用户明确提到难度 1-5，则输出 difficulty，否则不要输出该字段。',
    210, 1, 'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-java-mock' AND deleted = 0
);

INSERT INTO t_intent_node (
    id, intent_code, name, level, parent_code, description, examples,
    mcp_tool_id, kind, prompt_snippet, param_prompt_template, sort_order,
    enabled, create_by, update_by, deleted
)
SELECT
    '2040000000000000022', 'interview-python-mock', 'Python算法模拟面试', 2, 'interview-mock',
    '发起 Python 算法模拟面试，调用 interview-select-question 选择题目。',
    '["开始 Python 算法模拟面试","我想刷一道算法题","来一道 Python 算法面试题"]',
    'interview-select-question', 2,
    '这是 Python 算法模拟面试场景，优先呈现题目、解题思路和复杂度分析线索。',
    '你要从用户输入中提取模拟面试参数，仅输出 JSON。positionId 固定取 pos_python_001。若用户明确提到难度 1-5，则输出 difficulty，否则不要输出该字段。',
    220, 1, 'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-python-mock' AND deleted = 0
);

INSERT INTO t_intent_node (
    id, intent_code, name, level, parent_code, description, examples,
    mcp_tool_id, kind, prompt_snippet, param_prompt_template, sort_order,
    enabled, create_by, update_by, deleted
)
SELECT
    '2040000000000000023', 'interview-frontend-mock', '前端模拟面试', 2, 'interview-mock',
    '发起前端模拟面试，调用 interview-select-question 选择题目。',
    '["开始前端模拟面试","来一道前端八股题","我想练 Web 前端面试"]',
    'interview-select-question', 2,
    '这是前端模拟面试场景，优先围绕浏览器、框架、工程化等面试题展开。',
    '你要从用户输入中提取模拟面试参数，仅输出 JSON。positionId 固定取 pos_web_001。若用户明确提到难度 1-5，则输出 difficulty，否则不要输出该字段。',
    230, 1, 'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_intent_node WHERE intent_code = 'interview-frontend-mock' AND deleted = 0
);

-- ============================================
-- 默认查询词映射
-- ============================================

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000101', 'interview', 'java八股', 'Java后端', 1, 100, 1, 'Java 岗位口语映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = 'java八股' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000102', 'interview', '后端八股', 'Java后端', 1, 99, 1, '后端岗位口语映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = '后端八股' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000103', 'interview', 'java面试题', 'Java后端', 1, 98, 1, 'Java 面试题映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = 'java面试题' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000104', 'interview', 'python算法', 'Python算法', 1, 100, 1, 'Python 算法口语映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = 'python算法' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000105', 'interview', '算法题', 'Python算法', 1, 95, 1, '算法题映射到算法岗位知识库',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = '算法题' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000106', 'interview', '刷题', 'Python算法', 1, 94, 1, '刷题映射到算法岗位知识库',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = '刷题' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000107', 'interview', '前端八股', 'web前端', 1, 100, 1, '前端八股映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = '前端八股' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000108', 'interview', 'web面试', 'web前端', 1, 97, 1, 'Web 面试映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = 'web面试' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000109', 'interview', 'react面试', 'web前端', 1, 96, 1, 'React 面试映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = 'react面试' AND deleted = 0
);

INSERT INTO t_query_term_mapping (
    id, domain, source_term, target_term, match_type, priority, enabled, remark,
    create_by, update_by, deleted
)
SELECT
    '2040000000000000110', 'interview', 'vue面试', 'web前端', 1, 96, 1, 'Vue 面试映射',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_query_term_mapping WHERE source_term = 'vue面试' AND deleted = 0
);

-- ============================================
-- 默认数据通道
-- ============================================

INSERT INTO t_ingestion_pipeline (
    id, name, description, created_by, updated_by, deleted
)
SELECT
    '2040000000000000201',
    '通用文档清洗通道',
    'FaceIt 默认数据通道，适用于上传文档后执行解析、分块和索引。',
    'system', 'system', 0
WHERE NOT EXISTS (
    SELECT 1 FROM t_ingestion_pipeline WHERE name = '通用文档清洗通道' AND deleted = 0
);

INSERT INTO t_ingestion_pipeline_node (
    id, pipeline_id, node_id, node_type, next_node_id, settings_json, condition_json,
    created_by, updated_by, deleted
)
SELECT
    '2040000000000000211', '2040000000000000201', 'parse-document', 'parser', 'chunk-document',
    '{"rules":[{"mimeType":"ALL","options":{}}]}'::jsonb, NULL,
    'system', 'system', 0
WHERE EXISTS (
    SELECT 1 FROM t_ingestion_pipeline WHERE id = '2040000000000000201' AND deleted = 0
)
AND NOT EXISTS (
    SELECT 1 FROM t_ingestion_pipeline_node
    WHERE pipeline_id = '2040000000000000201' AND node_id = 'parse-document' AND deleted = 0
);

INSERT INTO t_ingestion_pipeline_node (
    id, pipeline_id, node_id, node_type, next_node_id, settings_json, condition_json,
    created_by, updated_by, deleted
)
SELECT
    '2040000000000000212', '2040000000000000201', 'chunk-document', 'chunker', 'index-document',
    '{"strategy":"structure_aware","chunkSize":512,"overlapSize":128}'::jsonb, NULL,
    'system', 'system', 0
WHERE EXISTS (
    SELECT 1 FROM t_ingestion_pipeline WHERE id = '2040000000000000201' AND deleted = 0
)
AND NOT EXISTS (
    SELECT 1 FROM t_ingestion_pipeline_node
    WHERE pipeline_id = '2040000000000000201' AND node_id = 'chunk-document' AND deleted = 0
);

INSERT INTO t_ingestion_pipeline_node (
    id, pipeline_id, node_id, node_type, next_node_id, settings_json, condition_json,
    created_by, updated_by, deleted
)
SELECT
    '2040000000000000213', '2040000000000000201', 'index-document', 'indexer', NULL,
    '{"metadataFields":["source_location","task_id","pipeline_id"]}'::jsonb, NULL,
    'system', 'system', 0
WHERE EXISTS (
    SELECT 1 FROM t_ingestion_pipeline WHERE id = '2040000000000000201' AND deleted = 0
)
AND NOT EXISTS (
    SELECT 1 FROM t_ingestion_pipeline_node
    WHERE pipeline_id = '2040000000000000201' AND node_id = 'index-document' AND deleted = 0
);
