-- 插入面试相关的意图节点

-- 1. 插入面试领域节点（DOMAIN）
INSERT INTO t_intent_node (
    intent_code, name, level, parent_code, description, examples, kind, enabled, create_by, update_by
) VALUES (
             'interview', '面试', 0, NULL, '面试相关问题，包括技术面试、算法面试等', '["我要进行Java面试", "我要进行Python算法面试", "我要准备前端面试"]', 0, 1, 'admin', 'admin'
         );

-- 2. 插入技术面试分类节点（CATEGORY）
INSERT INTO t_intent_node (
    intent_code, name, level, parent_code, description, examples, kind, enabled, create_by, update_by
) VALUES (
             'interview-tech', '技术面试', 1, 'interview', '技术面试相关问题，包括各种编程语言和技术栈的面试', '["我要进行Java技术面试", "我要进行Python技术面试", "我要进行前端技术面试"]', 0, 1, 'admin', 'admin'
         );

-- 3. 插入算法面试分类节点（CATEGORY）
INSERT INTO t_intent_node (
    intent_code, name, level, parent_code, description, examples, kind, enabled, create_by, update_by
) VALUES (
             'interview-algorithm', '算法面试', 1, 'interview', '算法面试相关问题，包括各种算法和数据结构的面试', '["我要进行算法面试", "我要进行Python算法面试", "我要进行Java算法面试"]', 0, 1, 'admin', 'admin'
         );

-- 4. 插入Python算法面试MCP节点（TOPIC）
INSERT INTO t_intent_node (
    intent_code, name, level, parent_code, description, examples, kind, mcp_tool_id, enabled, create_by, update_by
) VALUES (
             'interview-python-algorithm', 'Python算法面试', 2, 'interview-algorithm', 'Python算法面试相关问题', '["我要进行Python算法面试", "我需要Python算法面试题目", "Python算法面试准备"]', 2, 'interview-select-question', 1, 'admin', 'admin'
         );

-- 5. 插入Java技术面试MCP节点（TOPIC）
INSERT INTO t_intent_node (
    intent_code, name, level, parent_code, description, examples, kind, mcp_tool_id, enabled, create_by, update_by
) VALUES (
             'interview-java-tech', 'Java技术面试', 2, 'interview-tech', 'Java技术面试相关问题', '["我要进行Java技术面试", "我需要Java技术面试题目", "Java技术面试准备"]', 2, 'interview-select-question', 1, 'admin', 'admin'
         );

-- 6. 插入前端技术面试MCP节点（TOPIC）
INSERT INTO t_intent_node (
    intent_code, name, level, parent_code, description, examples, kind, mcp_tool_id, enabled, create_by, update_by
) VALUES (
             'interview-frontend', '前端技术面试', 2, 'interview-tech', '前端技术面试相关问题', '["我要进行前端技术面试", "我需要前端技术面试题目", "前端技术面试准备"]', 2, 'interview-select-question', 1, 'admin', 'admin'
         );