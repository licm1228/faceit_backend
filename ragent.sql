DROP TABLE IF EXISTS "public"."t_conversation_summary";
-- Table Definition
CREATE TABLE "public"."t_conversation_summary" (
    "id" varchar(20) NOT NULL,
    "conversation_id" varchar(20) NOT NULL,
    "user_id" varchar(20) NOT NULL,
    "last_message_id" varchar(64) NOT NULL,
    "content" text NOT NULL,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_conversation_summary"."id" IS '主键ID';
COMMENT ON COLUMN "public"."t_conversation_summary"."conversation_id" IS '会话ID';
COMMENT ON COLUMN "public"."t_conversation_summary"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."t_conversation_summary"."last_message_id" IS '摘要最后消息ID';
COMMENT ON COLUMN "public"."t_conversation_summary"."content" IS '会话摘要内容';
COMMENT ON COLUMN "public"."t_conversation_summary"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_conversation_summary"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_conversation_summary"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_conversation_summary" IS '会话摘要表（与消息表分离存储）';


-- Indices
CREATE INDEX idx_conv_user ON public.t_conversation_summary USING btree (conversation_id, user_id);

DROP TABLE IF EXISTS "public"."t_message";
-- Table Definition
CREATE TABLE "public"."t_message" (
    "id" varchar(20) NOT NULL,
    "conversation_id" varchar(20) NOT NULL,
    "user_id" varchar(20) NOT NULL,
    "role" varchar(32) NOT NULL,
    "content" text NOT NULL,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_message"."id" IS '主键ID';
COMMENT ON COLUMN "public"."t_message"."conversation_id" IS '会话ID';
COMMENT ON COLUMN "public"."t_message"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."t_message"."role" IS '角色：user/assistant';
COMMENT ON COLUMN "public"."t_message"."content" IS '消息内容';
COMMENT ON COLUMN "public"."t_message"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_message"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_message"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_message" IS '会话消息记录表';


-- Indices
CREATE INDEX idx_conversation_user_time ON public.t_message USING btree (conversation_id, user_id, create_time);
CREATE INDEX idx_conversation_summary ON public.t_message USING btree (conversation_id, user_id, create_time);

DROP TABLE IF EXISTS "public"."t_message_feedback";
-- Table Definition
CREATE TABLE "public"."t_message_feedback" (
    "id" varchar(20) NOT NULL,
    "message_id" varchar(20) NOT NULL,
    "conversation_id" varchar(20) NOT NULL,
    "user_id" varchar(20) NOT NULL,
    "vote" int2 NOT NULL,
    "reason" varchar(255),
    "comment" varchar(1024),
    "create_time" timestamp NOT NULL,
    "update_time" timestamp NOT NULL,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_message_feedback"."id" IS '主键ID';
COMMENT ON COLUMN "public"."t_message_feedback"."message_id" IS '消息ID';
COMMENT ON COLUMN "public"."t_message_feedback"."conversation_id" IS '会话ID';
COMMENT ON COLUMN "public"."t_message_feedback"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."t_message_feedback"."vote" IS '投票 1：赞 -1：踩';
COMMENT ON COLUMN "public"."t_message_feedback"."reason" IS '反馈原因';
COMMENT ON COLUMN "public"."t_message_feedback"."comment" IS '反馈评论';
COMMENT ON COLUMN "public"."t_message_feedback"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_message_feedback"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_message_feedback"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_message_feedback" IS '会话消息反馈表';


-- Indices
CREATE UNIQUE INDEX uk_msg_user ON public.t_message_feedback USING btree (message_id, user_id);
CREATE INDEX idx_conversation_id ON public.t_message_feedback USING btree (conversation_id);
CREATE INDEX idx_user_id ON public.t_message_feedback USING btree (user_id);

DROP TABLE IF EXISTS "public"."t_sample_question";
-- Table Definition
CREATE TABLE "public"."t_sample_question" (
    "id" varchar(20) NOT NULL,
    "title" varchar(64),
    "description" varchar(255),
    "question" varchar(1024) NOT NULL,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_sample_question"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_sample_question"."title" IS '展示标题';
COMMENT ON COLUMN "public"."t_sample_question"."description" IS '描述或提示';
COMMENT ON COLUMN "public"."t_sample_question"."question" IS '示例问题内容';
COMMENT ON COLUMN "public"."t_sample_question"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_sample_question"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_sample_question"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_sample_question" IS '示例问题表';


-- Indices
CREATE INDEX idx_sample_question_deleted ON public.t_sample_question USING btree (deleted);

DROP TABLE IF EXISTS "public"."t_knowledge_base";
-- Table Definition
CREATE TABLE "public"."t_knowledge_base" (
    "id" varchar(20) NOT NULL,
    "name" varchar(128) NOT NULL,
    "embedding_model" varchar(128) NOT NULL,
    "collection_name" varchar(128) NOT NULL,
    "created_by" varchar(20) NOT NULL,
    "updated_by" varchar(20),
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_knowledge_base"."id" IS '主键 ID';
COMMENT ON COLUMN "public"."t_knowledge_base"."name" IS '知识库名称';
COMMENT ON COLUMN "public"."t_knowledge_base"."embedding_model" IS '嵌入模型标识';
COMMENT ON COLUMN "public"."t_knowledge_base"."collection_name" IS 'Collection名称';
COMMENT ON COLUMN "public"."t_knowledge_base"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."t_knowledge_base"."updated_by" IS '修改人';
COMMENT ON COLUMN "public"."t_knowledge_base"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_knowledge_base"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_knowledge_base"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_knowledge_base" IS '知识库表';


-- Indices
CREATE UNIQUE INDEX uk_collection_name ON public.t_knowledge_base USING btree (collection_name);
CREATE INDEX idx_kb_name ON public.t_knowledge_base USING btree (name);

DROP TABLE IF EXISTS "public"."t_knowledge_document";
-- Table Definition
CREATE TABLE "public"."t_knowledge_document" (
    "id" varchar(20) NOT NULL,
    "kb_id" varchar(20) NOT NULL,
    "doc_name" varchar(256) NOT NULL,
    "enabled" int2 NOT NULL DEFAULT 1,
    "chunk_count" int4 DEFAULT 0,
    "file_url" varchar(1024) NOT NULL,
    "file_type" varchar(32) NOT NULL,
    "file_size" int8,
    "process_mode" varchar(32) DEFAULT 'chunk'::character varying,
    "status" varchar(32) NOT NULL DEFAULT 'pending'::character varying,
    "source_type" varchar(32),
    "source_location" varchar(1024),
    "schedule_enabled" int2,
    "schedule_cron" varchar(128),
    "chunk_strategy" varchar(32),
    "chunk_config" jsonb,
    "pipeline_id" varchar(20),
    "created_by" varchar(20) NOT NULL,
    "updated_by" varchar(20),
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_knowledge_document"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_knowledge_document"."kb_id" IS '知识库ID';
COMMENT ON COLUMN "public"."t_knowledge_document"."doc_name" IS '文档名称';
COMMENT ON COLUMN "public"."t_knowledge_document"."enabled" IS '是否启用 1：启用 0：禁用';
COMMENT ON COLUMN "public"."t_knowledge_document"."chunk_count" IS '分块数量';
COMMENT ON COLUMN "public"."t_knowledge_document"."file_url" IS '文件存储路径';
COMMENT ON COLUMN "public"."t_knowledge_document"."file_type" IS '文件类型';
COMMENT ON COLUMN "public"."t_knowledge_document"."file_size" IS '文件大小（字节）';
COMMENT ON COLUMN "public"."t_knowledge_document"."process_mode" IS '处理模式：chunk/pipeline';
COMMENT ON COLUMN "public"."t_knowledge_document"."status" IS '状态：pending/running/success/failed';
COMMENT ON COLUMN "public"."t_knowledge_document"."source_type" IS '来源类型：file/url';
COMMENT ON COLUMN "public"."t_knowledge_document"."source_location" IS '来源地址';
COMMENT ON COLUMN "public"."t_knowledge_document"."schedule_enabled" IS '是否启用定时刷新';
COMMENT ON COLUMN "public"."t_knowledge_document"."schedule_cron" IS '定时表达式';
COMMENT ON COLUMN "public"."t_knowledge_document"."chunk_strategy" IS '分块策略';
COMMENT ON COLUMN "public"."t_knowledge_document"."chunk_config" IS '分块配置JSON';
COMMENT ON COLUMN "public"."t_knowledge_document"."pipeline_id" IS 'Pipeline ID';
COMMENT ON COLUMN "public"."t_knowledge_document"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."t_knowledge_document"."updated_by" IS '修改人';
COMMENT ON COLUMN "public"."t_knowledge_document"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_knowledge_document"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_knowledge_document"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_knowledge_document" IS '知识库文档表';


-- Indices
CREATE INDEX idx_kb_id ON public.t_knowledge_document USING btree (kb_id);

DROP TABLE IF EXISTS "public"."t_user";
-- Table Definition
CREATE TABLE "public"."t_user" (
    "id" varchar(20) NOT NULL,
    "username" varchar(64) NOT NULL,
    "password" varchar(128) NOT NULL,
    "role" varchar(32) NOT NULL,
    "avatar" varchar(128),
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_user"."id" IS '主键ID';
COMMENT ON COLUMN "public"."t_user"."username" IS '用户名，唯一';
COMMENT ON COLUMN "public"."t_user"."password" IS '密码';
COMMENT ON COLUMN "public"."t_user"."role" IS '角色：admin/user';
COMMENT ON COLUMN "public"."t_user"."avatar" IS '用户头像';
COMMENT ON COLUMN "public"."t_user"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_user"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_user"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_user" IS '系统用户表';


-- Indices
CREATE UNIQUE INDEX uk_user_username ON public.t_user USING btree (username);

DROP TABLE IF EXISTS "public"."t_conversation";
-- Table Definition
CREATE TABLE "public"."t_conversation" (
    "id" varchar(20) NOT NULL,
    "conversation_id" varchar(20) NOT NULL,
    "user_id" varchar(20) NOT NULL,
    "title" varchar(128) NOT NULL,
    "last_time" timestamp,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    "round_count" int4 DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_conversation"."id" IS '主键ID';
COMMENT ON COLUMN "public"."t_conversation"."conversation_id" IS '会话ID';
COMMENT ON COLUMN "public"."t_conversation"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."t_conversation"."title" IS '会话名称';
COMMENT ON COLUMN "public"."t_conversation"."last_time" IS '最近消息时间';
COMMENT ON COLUMN "public"."t_conversation"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_conversation"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_conversation"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_conversation" IS '会话列表';


-- Indices
CREATE UNIQUE INDEX uk_conversation_user ON public.t_conversation USING btree (conversation_id, user_id);
CREATE INDEX idx_user_time ON public.t_conversation USING btree (user_id, last_time);

DROP TABLE IF EXISTS "public"."t_knowledge_chunk";
-- Table Definition
CREATE TABLE "public"."t_knowledge_chunk" (
    "id" varchar(20) NOT NULL,
    "kb_id" varchar(20) NOT NULL,
    "doc_id" varchar(20) NOT NULL,
    "chunk_index" int4 NOT NULL,
    "content" text NOT NULL,
    "content_hash" varchar(64),
    "char_count" int4,
    "token_count" int4,
    "enabled" int2 NOT NULL DEFAULT 1,
    "created_by" varchar(20) NOT NULL,
    "updated_by" varchar(20),
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_knowledge_chunk"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."kb_id" IS '知识库ID';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."doc_id" IS '文档ID';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."chunk_index" IS '分块序号';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."content" IS '分块内容';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."content_hash" IS '内容哈希';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."char_count" IS '字符数';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."token_count" IS 'Token数';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."enabled" IS '是否启用';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."updated_by" IS '修改人';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_knowledge_chunk"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_knowledge_chunk" IS '知识库文档分块表';


-- Indices
CREATE INDEX idx_doc_id ON public.t_knowledge_chunk USING btree (doc_id);

DROP TABLE IF EXISTS "public"."t_knowledge_document_chunk_log";
-- Table Definition
CREATE TABLE "public"."t_knowledge_document_chunk_log" (
    "id" varchar(20) NOT NULL,
    "doc_id" varchar(20) NOT NULL,
    "status" varchar(20) NOT NULL,
    "process_mode" varchar(20),
    "chunk_strategy" varchar(50),
    "pipeline_id" varchar(20),
    "extract_duration" int8,
    "chunk_duration" int8,
    "embedding_duration" int8,
    "total_duration" int8,
    "chunk_count" int4,
    "error_message" text,
    "start_time" timestamp,
    "end_time" timestamp,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."doc_id" IS '文档ID';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."status" IS '状态';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."process_mode" IS '处理模式';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."chunk_strategy" IS '分块策略';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."pipeline_id" IS 'Pipeline ID';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."extract_duration" IS '提取耗时（毫秒）';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."chunk_duration" IS '分块耗时（毫秒）';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."embedding_duration" IS '向量化耗时（毫秒）';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."total_duration" IS '总耗时（毫秒）';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."chunk_count" IS '分块数量';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."error_message" IS '错误信息';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."start_time" IS '开始时间';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."end_time" IS '结束时间';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_knowledge_document_chunk_log"."update_time" IS '更新时间';


-- Comments
COMMENT ON TABLE "public"."t_knowledge_document_chunk_log" IS '知识库文档分块日志表';


-- Indices
CREATE INDEX idx_doc_id_log ON public.t_knowledge_document_chunk_log USING btree (doc_id);

DROP TABLE IF EXISTS "public"."t_knowledge_document_schedule";
-- Table Definition
CREATE TABLE "public"."t_knowledge_document_schedule" (
    "id" varchar(20) NOT NULL,
    "doc_id" varchar(20) NOT NULL,
    "kb_id" varchar(20) NOT NULL,
    "cron_expr" varchar(128),
    "enabled" int2 DEFAULT 0,
    "next_run_time" timestamp,
    "last_run_time" timestamp,
    "last_success_time" timestamp,
    "last_status" varchar(32),
    "last_error" varchar(512),
    "last_etag" varchar(256),
    "last_modified" varchar(256),
    "last_content_hash" varchar(128),
    "lock_owner" varchar(128),
    "lock_until" timestamp,
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."doc_id" IS '文档ID';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."kb_id" IS '知识库ID';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."cron_expr" IS 'Cron表达式';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."enabled" IS '是否启用';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."next_run_time" IS '下次执行时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."last_run_time" IS '上次执行时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."last_success_time" IS '上次成功时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."last_status" IS '上次状态';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."last_error" IS '上次错误';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."last_etag" IS '上次ETag';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."last_modified" IS '上次修改时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."last_content_hash" IS '上次内容哈希';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."lock_owner" IS '锁持有者';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."lock_until" IS '锁过期时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule"."update_time" IS '更新时间';


-- Comments
COMMENT ON TABLE "public"."t_knowledge_document_schedule" IS '知识库文档定时刷新任务表';


-- Indices
CREATE UNIQUE INDEX uk_doc_id ON public.t_knowledge_document_schedule USING btree (doc_id);
CREATE INDEX idx_next_run ON public.t_knowledge_document_schedule USING btree (next_run_time);
CREATE INDEX idx_lock_until ON public.t_knowledge_document_schedule USING btree (lock_until);

DROP TABLE IF EXISTS "public"."t_knowledge_document_schedule_exec";
-- Table Definition
CREATE TABLE "public"."t_knowledge_document_schedule_exec" (
    "id" varchar(20) NOT NULL,
    "schedule_id" varchar(20) NOT NULL,
    "doc_id" varchar(20) NOT NULL,
    "kb_id" varchar(20) NOT NULL,
    "status" varchar(32) NOT NULL,
    "message" varchar(512),
    "start_time" timestamp,
    "end_time" timestamp,
    "file_name" varchar(512),
    "file_size" int8,
    "content_hash" varchar(128),
    "etag" varchar(256),
    "last_modified" varchar(256),
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."schedule_id" IS '调度ID';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."doc_id" IS '文档ID';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."kb_id" IS '知识库ID';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."status" IS '状态';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."message" IS '消息';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."start_time" IS '开始时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."end_time" IS '结束时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."file_name" IS '文件名';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."file_size" IS '文件大小';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."content_hash" IS '内容哈希';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."etag" IS 'ETag';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."last_modified" IS '最后修改时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_knowledge_document_schedule_exec"."update_time" IS '更新时间';


-- Comments
COMMENT ON TABLE "public"."t_knowledge_document_schedule_exec" IS '知识库文档定时刷新执行记录';


-- Indices
CREATE INDEX idx_schedule_time ON public.t_knowledge_document_schedule_exec USING btree (schedule_id, start_time);
CREATE INDEX idx_doc_id_exec ON public.t_knowledge_document_schedule_exec USING btree (doc_id);

DROP TABLE IF EXISTS "public"."t_intent_node";
-- Table Definition
CREATE TABLE "public"."t_intent_node" (
    "id" varchar(20) NOT NULL,
    "kb_id" varchar(20),
    "intent_code" varchar(64) NOT NULL,
    "name" varchar(64) NOT NULL,
    "level" int2 NOT NULL,
    "parent_code" varchar(64),
    "description" varchar(512),
    "examples" text,
    "collection_name" varchar(128),
    "top_k" int4,
    "mcp_tool_id" varchar(128),
    "kind" int2 NOT NULL DEFAULT 0,
    "prompt_snippet" text,
    "prompt_template" text,
    "param_prompt_template" text,
    "sort_order" int4 NOT NULL DEFAULT 0,
    "enabled" int2 NOT NULL DEFAULT 1,
    "create_by" varchar(20),
    "update_by" varchar(20),
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_intent_node"."id" IS '自增主键';
COMMENT ON COLUMN "public"."t_intent_node"."kb_id" IS '知识库ID';
COMMENT ON COLUMN "public"."t_intent_node"."intent_code" IS '业务唯一标识';
COMMENT ON COLUMN "public"."t_intent_node"."name" IS '展示名称';
COMMENT ON COLUMN "public"."t_intent_node"."level" IS '层级 0：DOMAIN 1：CATEGORY 2：TOPIC';
COMMENT ON COLUMN "public"."t_intent_node"."parent_code" IS '父节点标识';
COMMENT ON COLUMN "public"."t_intent_node"."description" IS '语义描述';
COMMENT ON COLUMN "public"."t_intent_node"."examples" IS '示例问题';
COMMENT ON COLUMN "public"."t_intent_node"."collection_name" IS '关联的Collection名称';
COMMENT ON COLUMN "public"."t_intent_node"."top_k" IS '知识库检索TopK';
COMMENT ON COLUMN "public"."t_intent_node"."mcp_tool_id" IS 'MCP工具ID';
COMMENT ON COLUMN "public"."t_intent_node"."kind" IS '类型 0：RAG知识库类 1：SYSTEM系统交互类';
COMMENT ON COLUMN "public"."t_intent_node"."prompt_snippet" IS '提示词片段';
COMMENT ON COLUMN "public"."t_intent_node"."prompt_template" IS '提示词模板';
COMMENT ON COLUMN "public"."t_intent_node"."param_prompt_template" IS '参数提取提示词模板（MCP模式专属）';
COMMENT ON COLUMN "public"."t_intent_node"."sort_order" IS '排序字段';
COMMENT ON COLUMN "public"."t_intent_node"."enabled" IS '是否启用 1：启用 0：禁用';
COMMENT ON COLUMN "public"."t_intent_node"."create_by" IS '创建人';
COMMENT ON COLUMN "public"."t_intent_node"."update_by" IS '修改人';
COMMENT ON COLUMN "public"."t_intent_node"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_intent_node"."update_time" IS '修改时间';
COMMENT ON COLUMN "public"."t_intent_node"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_intent_node" IS '意图树节点配置表';

DROP TABLE IF EXISTS "public"."t_query_term_mapping";
-- Table Definition
CREATE TABLE "public"."t_query_term_mapping" (
    "id" varchar(20) NOT NULL,
    "domain" varchar(64),
    "source_term" varchar(128) NOT NULL,
    "target_term" varchar(128) NOT NULL,
    "match_type" int2 NOT NULL DEFAULT 1,
    "priority" int4 NOT NULL DEFAULT 100,
    "enabled" int2 NOT NULL DEFAULT 1,
    "remark" varchar(255),
    "create_by" varchar(20),
    "update_by" varchar(20),
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_query_term_mapping"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_query_term_mapping"."domain" IS '领域';
COMMENT ON COLUMN "public"."t_query_term_mapping"."source_term" IS '源词';
COMMENT ON COLUMN "public"."t_query_term_mapping"."target_term" IS '目标词';
COMMENT ON COLUMN "public"."t_query_term_mapping"."match_type" IS '匹配类型 1：精确 2：模糊';
COMMENT ON COLUMN "public"."t_query_term_mapping"."priority" IS '优先级';
COMMENT ON COLUMN "public"."t_query_term_mapping"."enabled" IS '是否启用';
COMMENT ON COLUMN "public"."t_query_term_mapping"."remark" IS '备注';
COMMENT ON COLUMN "public"."t_query_term_mapping"."create_by" IS '创建人';
COMMENT ON COLUMN "public"."t_query_term_mapping"."update_by" IS '修改人';
COMMENT ON COLUMN "public"."t_query_term_mapping"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_query_term_mapping"."update_time" IS '修改时间';
COMMENT ON COLUMN "public"."t_query_term_mapping"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_query_term_mapping" IS '关键词归一化映射表';


-- Indices
CREATE INDEX idx_domain ON public.t_query_term_mapping USING btree (domain);
CREATE INDEX idx_source ON public.t_query_term_mapping USING btree (source_term);

DROP TABLE IF EXISTS "public"."t_rag_trace_run";
-- Table Definition
CREATE TABLE "public"."t_rag_trace_run" (
    "id" varchar(20) NOT NULL,
    "trace_id" varchar(64) NOT NULL,
    "trace_name" varchar(128),
    "entry_method" varchar(256),
    "conversation_id" varchar(20),
    "task_id" varchar(20),
    "user_id" varchar(20),
    "status" varchar(16) NOT NULL DEFAULT 'RUNNING'::character varying,
    "error_message" varchar(1000),
    "start_time" timestamp(3),
    "end_time" timestamp(3),
    "duration_ms" int8,
    "extra_data" text,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_rag_trace_run"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_rag_trace_run"."trace_id" IS '全局链路ID';
COMMENT ON COLUMN "public"."t_rag_trace_run"."trace_name" IS '链路名称';
COMMENT ON COLUMN "public"."t_rag_trace_run"."entry_method" IS '入口方法';
COMMENT ON COLUMN "public"."t_rag_trace_run"."conversation_id" IS '会话ID';
COMMENT ON COLUMN "public"."t_rag_trace_run"."task_id" IS '任务ID';
COMMENT ON COLUMN "public"."t_rag_trace_run"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."t_rag_trace_run"."status" IS 'RUNNING/SUCCESS/ERROR';
COMMENT ON COLUMN "public"."t_rag_trace_run"."error_message" IS '错误信息';
COMMENT ON COLUMN "public"."t_rag_trace_run"."start_time" IS '开始时间';
COMMENT ON COLUMN "public"."t_rag_trace_run"."end_time" IS '结束时间';
COMMENT ON COLUMN "public"."t_rag_trace_run"."duration_ms" IS '耗时毫秒';
COMMENT ON COLUMN "public"."t_rag_trace_run"."extra_data" IS '扩展字段(JSON)';
COMMENT ON COLUMN "public"."t_rag_trace_run"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_rag_trace_run"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_rag_trace_run"."deleted" IS '是否删除';


-- Comments
COMMENT ON TABLE "public"."t_rag_trace_run" IS 'Trace 运行记录表';


-- Indices
CREATE UNIQUE INDEX uk_run_id ON public.t_rag_trace_run USING btree (trace_id);
CREATE INDEX idx_task_id ON public.t_rag_trace_run USING btree (task_id);
CREATE INDEX idx_user_id_trace ON public.t_rag_trace_run USING btree (user_id);

DROP TABLE IF EXISTS "public"."t_rag_trace_node";
-- Table Definition
CREATE TABLE "public"."t_rag_trace_node" (
    "id" varchar(20) NOT NULL,
    "trace_id" varchar(20) NOT NULL,
    "node_id" varchar(20) NOT NULL,
    "parent_node_id" varchar(20),
    "depth" int4 DEFAULT 0,
    "node_type" varchar(64),
    "node_name" varchar(128),
    "class_name" varchar(256),
    "method_name" varchar(128),
    "status" varchar(16) NOT NULL DEFAULT 'RUNNING'::character varying,
    "error_message" varchar(1000),
    "start_time" timestamp(3),
    "end_time" timestamp(3),
    "duration_ms" int8,
    "extra_data" text,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_rag_trace_node"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_rag_trace_node"."trace_id" IS '所属链路ID';
COMMENT ON COLUMN "public"."t_rag_trace_node"."node_id" IS '节点ID';
COMMENT ON COLUMN "public"."t_rag_trace_node"."parent_node_id" IS '父节点ID';
COMMENT ON COLUMN "public"."t_rag_trace_node"."depth" IS '节点深度';
COMMENT ON COLUMN "public"."t_rag_trace_node"."node_type" IS '节点类型';
COMMENT ON COLUMN "public"."t_rag_trace_node"."node_name" IS '节点名称';
COMMENT ON COLUMN "public"."t_rag_trace_node"."class_name" IS '类名';
COMMENT ON COLUMN "public"."t_rag_trace_node"."method_name" IS '方法名';
COMMENT ON COLUMN "public"."t_rag_trace_node"."status" IS 'RUNNING/SUCCESS/ERROR';
COMMENT ON COLUMN "public"."t_rag_trace_node"."error_message" IS '错误信息';
COMMENT ON COLUMN "public"."t_rag_trace_node"."start_time" IS '开始时间';
COMMENT ON COLUMN "public"."t_rag_trace_node"."end_time" IS '结束时间';
COMMENT ON COLUMN "public"."t_rag_trace_node"."duration_ms" IS '耗时毫秒';
COMMENT ON COLUMN "public"."t_rag_trace_node"."extra_data" IS '扩展字段(JSON)';
COMMENT ON COLUMN "public"."t_rag_trace_node"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_rag_trace_node"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_rag_trace_node"."deleted" IS '是否删除';


-- Comments
COMMENT ON TABLE "public"."t_rag_trace_node" IS 'Trace 节点记录表';


-- Indices
CREATE UNIQUE INDEX uk_run_node ON public.t_rag_trace_node USING btree (trace_id, node_id);

DROP TABLE IF EXISTS "public"."t_ingestion_pipeline";
-- Table Definition
CREATE TABLE "public"."t_ingestion_pipeline" (
    "id" varchar(20) NOT NULL,
    "name" varchar(100) NOT NULL,
    "description" text,
    "created_by" varchar(20) DEFAULT ''::character varying,
    "updated_by" varchar(20) DEFAULT ''::character varying,
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."name" IS '流水线名称';
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."description" IS '流水线描述';
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."updated_by" IS '更新人';
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_ingestion_pipeline"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_ingestion_pipeline" IS '摄取流水线表';


-- Indices
CREATE UNIQUE INDEX uk_ingestion_pipeline_name ON public.t_ingestion_pipeline USING btree (name, deleted);

DROP TABLE IF EXISTS "public"."t_ingestion_pipeline_node";
-- Table Definition
CREATE TABLE "public"."t_ingestion_pipeline_node" (
    "id" varchar(20) NOT NULL,
    "pipeline_id" varchar(20) NOT NULL,
    "node_id" varchar(20) NOT NULL,
    "node_type" varchar(30) NOT NULL,
    "next_node_id" varchar(20),
    "settings_json" jsonb,
    "condition_json" jsonb,
    "created_by" varchar(20) DEFAULT ''::character varying,
    "updated_by" varchar(20) DEFAULT ''::character varying,
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."pipeline_id" IS '流水线ID';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."node_id" IS '节点标识(同一流水线内唯一)';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."node_type" IS '节点类型';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."next_node_id" IS '下一个节点ID';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."settings_json" IS '节点配置JSON';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."condition_json" IS '条件JSON';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."updated_by" IS '更新人';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_ingestion_pipeline_node"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_ingestion_pipeline_node" IS '摄取流水线节点表';


-- Indices
CREATE UNIQUE INDEX uk_ingestion_pipeline_node ON public.t_ingestion_pipeline_node USING btree (pipeline_id, node_id, deleted);
CREATE INDEX idx_ingestion_pipeline_node_pipeline ON public.t_ingestion_pipeline_node USING btree (pipeline_id);

DROP TABLE IF EXISTS "public"."t_ingestion_task";
-- Table Definition
CREATE TABLE "public"."t_ingestion_task" (
    "id" varchar(20) NOT NULL,
    "pipeline_id" varchar(20) NOT NULL,
    "source_type" varchar(20) NOT NULL,
    "source_location" text,
    "source_file_name" varchar(255),
    "status" varchar(20) NOT NULL,
    "chunk_count" int4 DEFAULT 0,
    "error_message" text,
    "logs_json" jsonb,
    "metadata_json" jsonb,
    "started_at" timestamp,
    "completed_at" timestamp,
    "created_by" varchar(20) DEFAULT ''::character varying,
    "updated_by" varchar(20) DEFAULT ''::character varying,
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_ingestion_task"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_ingestion_task"."pipeline_id" IS '流水线ID';
COMMENT ON COLUMN "public"."t_ingestion_task"."source_type" IS '来源类型';
COMMENT ON COLUMN "public"."t_ingestion_task"."source_location" IS '来源地址或URL';
COMMENT ON COLUMN "public"."t_ingestion_task"."source_file_name" IS '原始文件名';
COMMENT ON COLUMN "public"."t_ingestion_task"."status" IS '任务状态';
COMMENT ON COLUMN "public"."t_ingestion_task"."chunk_count" IS '分块数量';
COMMENT ON COLUMN "public"."t_ingestion_task"."error_message" IS '错误信息';
COMMENT ON COLUMN "public"."t_ingestion_task"."logs_json" IS '节点日志JSON';
COMMENT ON COLUMN "public"."t_ingestion_task"."metadata_json" IS '扩展元数据JSON';
COMMENT ON COLUMN "public"."t_ingestion_task"."started_at" IS '开始时间';
COMMENT ON COLUMN "public"."t_ingestion_task"."completed_at" IS '完成时间';
COMMENT ON COLUMN "public"."t_ingestion_task"."created_by" IS '创建人';
COMMENT ON COLUMN "public"."t_ingestion_task"."updated_by" IS '更新人';
COMMENT ON COLUMN "public"."t_ingestion_task"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_ingestion_task"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_ingestion_task"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_ingestion_task" IS '摄取任务表';


-- Indices
CREATE INDEX idx_ingestion_task_pipeline ON public.t_ingestion_task USING btree (pipeline_id);
CREATE INDEX idx_ingestion_task_status ON public.t_ingestion_task USING btree (status);

DROP TABLE IF EXISTS "public"."t_ingestion_task_node";
-- Table Definition
CREATE TABLE "public"."t_ingestion_task_node" (
    "id" varchar(20) NOT NULL,
    "task_id" varchar(20) NOT NULL,
    "pipeline_id" varchar(20) NOT NULL,
    "node_id" varchar(20) NOT NULL,
    "node_type" varchar(30) NOT NULL,
    "node_order" int4 NOT NULL DEFAULT 0,
    "status" varchar(20) NOT NULL,
    "duration_ms" int8 NOT NULL DEFAULT 0,
    "message" text,
    "error_message" text,
    "output_json" text,
    "create_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_ingestion_task_node"."id" IS 'ID';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."task_id" IS '任务ID';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."pipeline_id" IS '流水线ID';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."node_id" IS '节点标识';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."node_type" IS '节点类型';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."node_order" IS '节点顺序';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."status" IS '节点状态';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."duration_ms" IS '执行耗时(毫秒)';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."message" IS '节点消息';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."error_message" IS '错误信息';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."output_json" IS '节点输出JSON(全量)';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."t_ingestion_task_node"."deleted" IS '是否删除 0：正常 1：删除';


-- Comments
COMMENT ON TABLE "public"."t_ingestion_task_node" IS '摄取任务节点表';


-- Indices
CREATE INDEX idx_ingestion_task_node_task ON public.t_ingestion_task_node USING btree (task_id);
CREATE INDEX idx_ingestion_task_node_pipeline ON public.t_ingestion_task_node USING btree (pipeline_id);
CREATE INDEX idx_ingestion_task_node_status ON public.t_ingestion_task_node USING btree (status);

DROP TABLE IF EXISTS "public"."t_knowledge_vector";
-- Table Definition
CREATE TABLE "public"."t_knowledge_vector" (
    "id" varchar(20) NOT NULL,
    "content" text,
    "metadata" jsonb,
    "embedding" vector,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."t_knowledge_vector"."id" IS '分块ID';
COMMENT ON COLUMN "public"."t_knowledge_vector"."content" IS '分块文本内容';
COMMENT ON COLUMN "public"."t_knowledge_vector"."metadata" IS '元数据';
COMMENT ON COLUMN "public"."t_knowledge_vector"."embedding" IS '向量';


-- Comments
COMMENT ON TABLE "public"."t_knowledge_vector" IS '知识库向量存储表';


-- Indices
CREATE INDEX idx_kv_metadata ON public.t_knowledge_vector USING gin (metadata);
CREATE INDEX idx_kv_embedding ON public.t_knowledge_vector USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_kv_embedding_hnsw ON public.t_knowledge_vector USING hnsw (embedding vector_cosine_ops);

DROP TABLE IF EXISTS "public"."t_position";
-- Table Definition
CREATE TABLE "public"."t_position" (
    "id" varchar(20) NOT NULL,
    "name" varchar(50) NOT NULL,
    "description" text,
    "required_skills" jsonb,
    "interview_focus" text,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."t_question";
-- Table Definition
CREATE TABLE "public"."t_question" (
    "id" varchar(20) NOT NULL,
    "position_id" varchar(20),
    "question_type" varchar(20) NOT NULL,
    "difficulty" int4,
    "question_text" text NOT NULL,
    "reference_answer" text,
    "keywords" _text,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    CONSTRAINT "t_question_position_id_fkey" FOREIGN KEY ("position_id") REFERENCES "public"."t_position"("id"),
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."t_wrong_question";
-- Table Definition
CREATE TABLE "public"."t_wrong_question" (
    "id" varchar(20) NOT NULL,
    "user_id" varchar(20) NOT NULL,
    "question_id" varchar(20) NOT NULL,
    "conversation_id" varchar(20) NOT NULL,
    "wrong_count" int4 DEFAULT 1,
    "mastered" bool DEFAULT false,
    "last_wrong_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    CONSTRAINT "t_wrong_question_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."t_user"("id"),
    CONSTRAINT "t_wrong_question_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "public"."t_question"("id"),
    CONSTRAINT "t_wrong_question_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "public"."t_conversation"("id"),
    PRIMARY KEY ("id")
);

DROP TABLE IF EXISTS "public"."t_assessment_report";
-- Table Definition
CREATE TABLE "public"."t_assessment_report" (
    "id" varchar(20) NOT NULL,
    "conversation_id" varchar(20) NOT NULL,
    "technical_score" jsonb NOT NULL,
    "expression_score" jsonb NOT NULL,
    "summary" text,
    "strengths" _text,
    "weaknesses" _text,
    "suggestions" _text,
    "recommended_resources" jsonb,
    "create_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "update_time" timestamp DEFAULT CURRENT_TIMESTAMP,
    "deleted" int2 DEFAULT 0,
    CONSTRAINT "t_assessment_report_conversation_id_fkey" FOREIGN KEY ("conversation_id") REFERENCES "public"."t_conversation"("id"),
    PRIMARY KEY ("id")
);

INSERT INTO "public"."t_conversation_summary" ("id", "conversation_id", "user_id", "last_message_id", "content", "create_time", "update_time", "deleted") VALUES
('2038165319159144448', '2038164091557666816', '2001523723396308993', '2038164260302905344', '历史讨论：用户咨询了Web前端面试准备（已解答）。关键词：JavaScript, Vue, 浏览器原理, 性能优化, 事件循环, 虚拟DOM', '2026-03-29 16:04:14.025', '2026-03-29 16:04:14.025', 0),
('2038165514513047552', '2038164091557666816', '2001523723396308993', '2038164675425755136', '历史讨论：用户咨询了Web前端面试准备（已解答）、事件循环机制（待确认）。关键词：JavaScript, Vue, 浏览器原理, 性能优化, 事件循环, 虚拟DOM', '2026-03-29 16:05:00.601', '2026-03-29 16:05:00.601', 0),
('2038165603860111360', '2038164091557666816', '2001523723396308993', '2038164891914756096', '历史讨论：用户咨询了Web前端面试准备（已解答）、事件循环机制（已解答）。关键词：JavaScript, Vue, 浏览器原理, 性能优化, 事件循环, 虚拟DOM', '2026-03-29 16:05:21.903', '2026-03-29 16:05:21.903', 0),
('2038165877869797376', '2038164091557666816', '2001523723396308993', '2038165105434189824', '历史讨论：用户咨询了Web前端面试准备（已解答）、事件循环机制（已解答）、闭包概念与应用（待确认）。关键词：JavaScript, Vue, 浏览器原理, 性能优化, 事件循环, 虚拟DOM, 闭包', '2026-03-29 16:06:27.232', '2026-03-29 16:06:27.232', 0),
('2038216485867905024', '2038164091557666816', '2001523723396308993', '2038165309440942080', '历史讨论：用户咨询了Web前端面试准备（已解答）、事件循环机制（已解答）、闭包概念与应用（已解答）。关键词：JavaScript, 事件循环, 闭包, 面试', '2026-03-29 19:27:33.119', '2026-03-29 19:27:33.119', 0);
INSERT INTO "public"."t_message" ("id", "conversation_id", "user_id", "role", "content", "create_time", "update_time", "deleted") VALUES
('2036458461134327808', '2036458457137156096', '2001523723396308993', 'user', '中南大学', '2026-03-24 23:01:47.361', '2026-03-24 23:01:47.361', 0),
('2036458482315563008', '2036458457137156096', '2001523723396308993', 'assistant', '未检索到与问题相关的文档内容。', '2026-03-24 23:01:52.41', '2026-03-24 23:01:52.411', 0),
('2036460691828772864', '2036458457137156096', '2001523723396308993', 'user', '1+1', '2026-03-24 23:10:39.199', '2026-03-24 23:10:39.199', 0),
('2036460701471477760', '2036458457137156096', '2001523723396308993', 'assistant', '未检索到与问题相关的文档内容。', '2026-03-24 23:10:41.498', '2026-03-24 23:10:41.498', 0),
('2037125581702701056', '2037125580805120000', '2001523723396308993', 'user', '1+1', '2026-03-26 19:12:41.298', '2026-03-26 19:12:41.298', 0),
('2037125604159004672', '2037125580805120000', '2001523723396308993', 'assistant', '未检索到与问题相关的文档内容。', '2026-03-26 19:12:46.652', '2026-03-26 19:12:46.652', 0),
('2037159068941955072', '2037159068648353792', '2001523723396308993', 'user', '我要面试web开发岗位', '2026-03-26 21:25:45.278', '2026-03-26 21:25:45.278', 0),
('2037159115813302272', '2037159068648353792', '2001523723396308993', 'assistant', '未检索到与问题相关的文档内容。', '2026-03-26 21:25:56.453', '2026-03-26 21:25:56.453', 0),
('2037159151230005248', '2037159068648353792', '2001523723396308993', 'user', 'web开发', '2026-03-26 21:26:04.897', '2026-03-26 21:26:04.897', 0),
('2037159193634418688', '2037159068648353792', '2001523723396308993', 'assistant', '未检索到与问题相关的文档内容。', '2026-03-26 21:26:15.007', '2026-03-26 21:26:15.007', 0),
('2037160207355752448', '2037160207305420800', '2001523723396308993', 'user', 'web面试', '2026-03-26 21:30:16.697', '2026-03-26 21:30:16.697', 0),
('2037160223499628544', '2037160207305420800', '2001523723396308993', 'assistant', '未检索到与问题相关的文档内容。', '2026-03-26 21:30:20.546', '2026-03-26 21:30:20.546', 0),
('2038119851347693568', '2038119850693382144', '2001523723396308993', 'user', '我要面试web开发岗位', '2026-03-29 13:03:33.654', '2026-03-29 13:03:33.654', 0),
('2038119975843024896', '2038119850693382144', '2001523723396308993', 'assistant', 'Web 开发岗位面试通常会从基础、进阶到高阶三个层次考察候选人的技术能力。以下是针对不同难度的典型问题及准备要点：

### 一、基础题：CSS 盒模型
**核心内容**：
- CSS 盒模型包含四部分：内容区（content）、内边距（padding）、边框（border）、外边距（margin）。
- **标准盒模型**：`width` 仅指内容区宽度，不包含 padding 和 border。
- **IE 盒模型**：`width` 包含 content + padding + border。
- 通过 `box-sizing` 属性切换：`content-box`（标准）、`border-box`（IE）。
- **推荐使用 `border-box`**，因为设置 width 后元素总宽度固定，布局更直观可控。

### 二、中等题：事件循环与任务队列
**核心内容**：
- JavaScript 是单线程语言，通过**事件循环**实现异步非阻塞执行。
- **宏任务**（Macro-task）：包括整体脚本、`setTimeout`、`setInterval`、I/O、DOM 事件等。
- **微任务**（Micro-task）：包括 `Promise.then`、`MutationObserver`、`queueMicrotask` 等。
- **执行顺序**：
  1. 执行当前宏任务（如同步代码）
  2. 清空所有微任务队列
  3. 执行下一个宏任务
  4. 循环往复
- **关键原则**：微任务优先级高于宏任务，每个宏任务结束后都会立即处理所有微任务。

### 三、高难题：首屏加载性能优化
**可从四个维度系统回答**：

#### ▪ 网络层优化
- 使用 CDN 加速静态资源分发
- 启用 HTTP/2 实现多路复用，减少连接开销
- 开启 Gzip 或 Brotli 压缩，减小传输体积

#### ▪ 资源加载优化
- 路由懒加载：按需加载页面组件
- 图片懒加载：首屏仅加载可视区域图片
- 代码分割：分离第三方库与业务代码
- Tree Shaking：移除未使用的代码（适用于 ES Module）

#### ▪ 缓存策略
- 强缓存：通过 `Cache-Control` 缓存长期不变资源（如 hash 命名的 JS/CSS）
- 协商缓存：使用 `ETag` 或 `Last-Modified` 验证资源是否更新

#### ▪ 渲染与加载策略
- 骨架屏：提升用户感知速度，减少等待焦虑
- 减少重排重绘：优先使用 `transform` 而非 `top/left` 改变位置
- 关键 CSS 内联，非关键 CSS 异步加载
- 预加载关键资源（`<link rel="preload">`）
- 非关键 JS 使用 `defer` 或 `async`
- 利用 Service Worker 预缓存核心资源，实现离线可用与快速加载

> 注：回答时建议结合项目经验举例，比如“我们在项目中通过路由懒加载 + CDN + 关键 CSS 内联，将首屏时间从 3.2s 降至 1.4s”，会更具说服力。', '2026-03-29 13:04:03.336', '2026-03-29 13:04:03.336', 0),
('2038120668872069120', '2038120668758822912', '2038120540551532544', 'user', 'web面试', '2026-03-29 13:06:48.567', '2026-03-29 13:06:48.567', 0),
('2038120808047464448', '2038120668758822912', '2038120540551532544', 'assistant', 'Web 开发面试通常会根据难度分为几个层次，覆盖 CSS、JavaScript 核心机制以及性能优化等关键知识点：

### 一、简单难度：CSS 盒模型
CSS 盒模型由内容区（content）、内边距（padding）、边框（border）和外边距（margin）四部分组成。  
主要有两种类型：
- **标准盒模型**：`width` 仅指内容区宽度，不包含 padding 和 border。
- **IE 盒模型**：`width` 包含 content + padding + border。

通过 `box-sizing` 属性切换模型：
- `content-box` → 标准模型
- `border-box` → IE 模型

开发中推荐使用 `border-box`，因为设置的 `width` 就是元素最终占据的宽度，布局更直观可控。

### 二、中等难度：事件循环与任务队列
JavaScript 是单线程语言，依靠**事件循环**处理异步操作，实现非阻塞 I/O。

任务分为两类：
- **宏任务（Macrotask）**：如整体脚本、`setTimeout`、`setInterval`、I/O、DOM 事件等。
- **微任务（Microtask）**：如 `Promise.then`、`MutationObserver`、`queueMicrotask` 等。

**执行顺序**：
1. 执行当前宏任务（如同步代码）
2. 清空所有微任务队列
3. 执行下一个宏任务
4. 循环往复

关键原则：**微任务优先级高于宏任务**，每个宏任务结束后都会立即处理完所有微任务，再进入下一个宏任务。

### 三、困难难度：首屏加载速度优化
首屏性能优化需从多个层面入手：

#### ▪ 网络层优化
- 使用 CDN 加速静态资源分发
- 启用 HTTP/2 实现多路复用，减少连接开销
- 开启 Gzip 或 Brotli 压缩，减小传输体积

#### ▪ 资源加载优化
- 路由懒加载：按需加载页面组件
- 图片懒加载：首屏仅加载可视区域图片
- 代码分割：分离第三方库与业务代码
- Tree Shaking：移除未引用的代码

#### ▪ 缓存策略
- 强缓存（`Cache-Control`）：用于长期不变的资源
- 协商缓存（`ETag` / `Last-Modified`）：验证资源是否更新

#### ▪ 渲染优化
- 使用骨架屏提升感知性能，缓解用户等待焦虑
- 避免频繁重排重绘，优先使用 `transform` 替代 `top/left`
- 关键 CSS 内联，非关键 CSS 异步加载

#### ▪ 加载策略
- `<link rel="preload">` 预加载关键资源
- 使用 `defer` 或 `async` 异步加载非关键 JS
- 利用 Service Worker 预缓存核心资源，支持离线访问

这些内容覆盖了 Web 面试中常见的基础、进阶和高阶问题，掌握后能有效应对不同层级的技术考察。', '2026-03-29 13:07:21.749', '2026-03-29 13:07:21.749', 0),
('2038164092195201024', '2038164091557666816', '2001523723396308993', 'user', '我要进行web前端面试', '2026-03-29 15:59:21.494', '2026-03-29 15:59:21.494', 0),
('2038164260302905344', '2038164091557666816', '2001523723396308993', 'assistant', 'Web 前端面试通常围绕核心语言特性、框架原理、浏览器机制和性能优化等方向展开，覆盖从基础到高阶的知识点。以下是几个关键领域的重点内容：

### 一、JavaScript 核心机制

**1. 闭包**  
闭包是指能访问另一个函数作用域中变量的函数。它由函数及其词法环境共同构成，常用于封装私有变量、实现防抖节流或模块化。但需注意，闭包会持有外部变量引用，若不及时释放，可能引发内存泄漏。

**2. 原型与原型链**  
每个对象都有一个隐式原型（`__proto__`），指向其构造函数的 `prototype`。当访问属性时，若自身不存在，会沿原型链向上查找，直到 `Object.prototype`（原型链顶端）。这是 JavaScript 实现继承的基础。

**3. 事件循环（Event Loop）**  
JavaScript 是单线程语言，通过事件循环处理异步任务：
- **宏任务**：如整体脚本、`setTimeout`、`setInterval`、DOM 事件等。
- **微任务**：如 `Promise.then`、`MutationObserver`、`queueMicrotask`。
- **执行顺序**：先执行当前宏任务 → 清空所有微任务 → 执行下一个宏任务。  
微任务优先级高于宏任务，每次宏任务结束后都会立即处理微任务队列。

**4. Promise 与异步编程**  
Promise 有三种状态：pending、fulfilled、rejected，状态一旦改变不可逆。它支持链式调用，有效解决“回调地狱”。`async/await` 是其语法糖，让异步代码更接近同步写法。

---

### 二、Vue 框架核心

**1. 生命周期**  
- **创建阶段**：`beforeCreate` → `created`（可访问数据，DOM 未生成）  
- **挂载阶段**：`beforeMount` → `mounted`（可操作 DOM）  
- **更新阶段**：`beforeUpdate` → `updated`  
- **销毁阶段**：`beforeDestroy` → `destroyed`  

**2. 响应式原理**  
- **Vue 2**：通过 `Object.defineProperty` 劫持数据的 getter/setter。  
- **Vue 3**：使用 `Proxy` 代理整个对象，支持监听数组和动态新增属性。  
流程：数据变化 → 触发 setter → 通知依赖 → 组件重新渲染 → 更新真实 DOM。

**3. 虚拟 DOM 与 Diff 算法**  
虚拟 DOM 是用 JS 对象描述真实 DOM 的轻量表示。Diff 算法采用**同层比较**策略，通过 `key` 标识节点以复用元素，将时间复杂度控制在 O(n)，提升更新效率。

---

### 三、浏览器工作原理

**1. 渲染流程**  
HTML → DOM 树；CSS → CSSOM 树；两者合并为渲染树 → 布局（计算位置大小）→ 绘制（生成像素）→ 合成显示。

**2. 重排与重绘**  
- **重排（回流）**：布局变化（如尺寸、位置、窗口缩放），代价高。  
- **重绘**：外观变化（如颜色、背景），不触发布局。  
**优化建议**：用 `transform` 代替 `top/left` 修改位置；批量修改样式以减少触发次数。

**3. 跨域问题**  
因浏览器同源策略（协议、域名、端口任一不同即跨域），常见解决方案包括：
- **CORS**：后端设置响应头（如 `Access-Control-Allow-Origin`）
- **开发代理**：通过 webpack 或 Vite 配置 proxy
- **JSONP**：仅支持 GET 请求
- **postMessage**：用于跨窗口通信

---

### 四、性能优化重点

**首屏加载优化** 是高频考点，可从多层入手：
- **网络层**：CDN 加速、启用 HTTP/2、开启 Gzip/Brotli 压缩  
- **资源加载**：路由懒加载、图片懒加载、代码分割（Code Splitting）、Tree Shaking 移除无用代码  
- **缓存策略**：强缓存（`Cache-Control`）用于静态资源；协商缓存（`ETag`/`Last-Modified`）验证更新  
- **渲染优化**：内联关键 CSS、骨架屏提升感知速度、用 `transform` 减少重排  
- **加载策略**：`<link rel="preload">` 预加载关键资源；`defer`/`async` 异步加载非关键 JS；Service Worker 预缓存核心内容

---

### 五、常见经典面试题示例

- **CSS 盒模型**：标准盒模型（`content-box`）的 width 仅含内容区；IE 盒模型（`border-box`）包含 padding 和 border。推荐使用 `box-sizing: border-box`，布局更直观。
- **内存泄漏**：常见原因包括意外全局变量、未清理的定时器、未解绑的 DOM 事件监听、闭包长期持有引用。解决方法是在组件销毁时主动清理资源。

这些内容构成了 Web 前端面试的核心知识体系，建议结合项目经验深入理解原理，并能清晰表达技术选型背后的思考。', '2026-03-29 16:00:01.574', '2026-03-29 16:00:01.574', 0),
('2038164636485836800', '2038164091557666816', '2001523723396308993', 'user', '你应该问我web面试的问题，然后我回答', '2026-03-29 16:01:31.263', '2026-03-29 16:01:31.263', 0),
('2038164675425755136', '2038164091557666816', '2001523723396308993', 'assistant', '！那明白了我先问你一个 Web 前端面试的经典问题，你可以试着回答：

**什么是事件循环（Event Loop）？宏任务和微任务有什么区别？**

这个问题考察的是 JavaScript 的异步执行机制，是中高级前端岗位的高频考点。你可以用自己的话讲讲看～', '2026-03-29 16:01:40.548', '2026-03-29 16:01:40.548', 0),
('2038164801837883392', '2038164091557666816', '2001523723396308993', 'user', '事件循环是 JavaScript 处理异步任务的执行模型。JS 是单线程，通过事件循环实现非阻塞 I/O。
宏任务：包括整体脚本代码、setTimeout、setInterval、I/O 操作、DOM 事件等。
微任务：包括 Promise.then、MutationObserver、queueMicrotask 等。', '2026-03-29 16:02:10.686', '2026-03-29 16:02:10.686', 0),
('2038164891914756096', '2038164091557666816', '2001523723396308993', 'assistant', '你已经准确说出了事件循环的基本定义和宏任务、微任务的典型类型，这很好！不过在面试中，光列出分类还不够，**执行顺序和优先级机制**才是体现理解深度的关键。

我来帮你补全一下完整的逻辑，也方便你后续回答更完整：

JavaScript 的事件循环运行规则是这样的：

### 一、执行流程
1. **先执行当前宏任务**（比如整个 script 脚本就是第一个宏任务）
2. **然后立即清空所有微任务队列**（把所有 Promise.then、queueMicrotask 等全部执行完）
3. **再从宏任务队列中取出下一个宏任务执行**
4. **重复这个过程**

### 二、核心原则
- **微任务优先级高于宏任务**
- **每个宏任务执行完毕后，必须先把微任务队列“清空”，才会去处理下一个宏任务**

举个例子：
```javascript
console.log(''1'');

setTimeout(() => console.log(''2''), 0);

Promise.resolve().then(() => console.log(''3''));

console.log(''4'');
```
实际输出是：`1 → 4 → 3 → 2`  
因为 `Promise.then` 是微任务，在当前宏任务（script）结束后立刻执行；而 `setTimeout` 是宏任务，要等下一轮事件循环。

你在面试时如果能结合这样的执行顺序和简单例子说明，会显得理解更扎实。要不要再试试解释一下这个例子？或者我问你下一个问题？', '2026-03-29 16:02:32.162', '2026-03-29 16:02:32.162', 0),
('2038165064430673920', '2038164091557666816', '2001523723396308993', 'user', '你应该严厉一点的问我问题，等我回答了一个问题后继续问我其他面试问题', '2026-03-29 16:03:13.294', '2026-03-29 16:03:13.294', 0),
('2038165105434189824', '2038164091557666816', '2001523723396308993', 'assistant', '好的！那我继续问你一个 Web 前端面试中非常经典且常被深入追问的问题：

**什么是闭包（Closure）？它有什么作用？在实际开发中有哪些应用场景？又需要注意什么问题？**

这个问题从定义到实践再到陷阱都有涉及，是考察 JavaScript 核心理解的重要题目。你可以按自己的思路回答～', '2026-03-29 16:03:23.069', '2026-03-29 16:03:23.069', 0),
('2038165268684890112', '2038164091557666816', '2001523723396308993', 'user', '闭包是指有权访问另一个函数作用域中变量的函数。
原理：函数 + 词法环境，内部函数可以访问外部函数的变量。
应用场景：封装私有变量、防抖节流、模块化模式。
注意事项：闭包会持有外部变量引用，可能导致内存泄漏', '2026-03-29 16:04:01.991', '2026-03-29 16:04:01.992', 0),
('2038165309440942080', '2038164091557666816', '2001523723396308993', 'assistant', '你直接复述了问题，这在面试中是**大忌**——面试官问的是“请解释”，不是让你重复题目。

我再给你一次机会，请**用自己的话完整回答**以下四点：

1. **闭包是什么？**（给出清晰定义）  
2. **它为什么能访问外部变量？**（说清原理）  
3. **举出至少两个真实开发中的应用场景**（不能只说名词，要说明怎么用）  
4. **它可能带来什么风险？如何避免？**

现在，请认真作答。', '2026-03-29 16:04:11.708', '2026-03-29 16:04:11.708', 0),
('2038165455759237120', '2038164091557666816', '2001523723396308993', 'user', '1闭包是指有权访问另一个函数作用域中变量的函数', '2026-03-29 16:04:46.593', '2026-03-29 16:04:46.593', 0),
('2038165503989538816', '2038164091557666816', '2001523723396308993', 'assistant', '闭包是指一个函数能够访问并“记住”其外部作用域中变量的特性，即使这个外部函数已经执行完毕。

更具体地说，当一个内部函数被返回或传递到其外部函数的作用域之外时，它仍然可以访问外部函数的变量、参数和内部声明。这种机制依赖于 JavaScript 的**词法作用域**——函数在定义时就确定了它能访问哪些变量，而不是在调用时。

例如：
```javascript
function outer() {
  let count = 0;
  return function inner() {
    count++;
    console.log(count);
  };
}
const counter = outer();
counter(); // 输出 1
counter(); // 输出 2
```
这里的 `inner` 函数就是一个闭包，它“捕获”了 `outer` 中的 `count` 变量，并在其生命周期结束后依然能读写该变量。', '2026-03-29 16:04:58.092', '2026-03-29 16:04:58.092', 0),
('2038165542333865984', '2038164091557666816', '2001523723396308993', 'user', '我回答的怎么样', '2026-03-29 16:05:07.234', '2026-03-29 16:05:07.234', 0),
('2038165591876984832', '2038164091557666816', '2001523723396308993', 'assistant', '你这次的回答比之前有进步——**给出了定义、提到了词法作用域、还写了一个例子**，这说明你确实理解了闭包的基本机制。

但问题在于：**你只回答了第一个小问（闭包是什么）**，而我明确要求你回答四点：
1. 定义 ✅（基本完成）  
2. 原理 ❌（只提了“词法作用域”，没说清楚“函数 + 词法环境”如何形成闭包）  
3. 应用场景 ❌（完全没答）  
4. 风险与规避 ❌（完全没答）

在真实面试中，如果面试官问“闭包有什么作用？需要注意什么？”，你只解释定义，会被认为**准备不充分、抓不住重点**。

---

现在，我继续追问下一个问题，看你能否完整作答：

**Vue 2 和 Vue 3 的响应式原理分别是什么？它们的核心区别在哪里？为什么 Vue 3 要改用 Proxy？**

请从以下角度回答：
- Vue 2 如何实现响应式（关键 API 和限制）
- Vue 3 如何实现响应式（关键 API 和优势）
- 两者在监听能力上的具体差异（比如对数组、新增属性的支持）

认真回答，别再漏点。', '2026-03-29 16:05:19.046', '2026-03-29 16:05:19.046', 0),
('2038165783695089664', '2038164091557666816', '2001523723396308993', 'user', '我回答不出来', '2026-03-29 16:06:04.779', '2026-03-29 16:06:04.779', 0),
('2038165867929296896', '2038164091557666816', '2001523723396308993', 'assistant', '没关系，说“回答不出来”比硬背或回避强——至少诚实。

但既然是准备面试，就不能停留在“不会”。我来帮你拆解这个问题的核心要点，你听完后试着复述一遍，就当是模拟面试中的“引导式回答”。

---

Vue 2 的响应式原理是基于 `Object.defineProperty` 来劫持对象属性的 **getter** 和 **setter**。当你访问数据时触发 getter（收集依赖），修改数据时触发 setter（通知更新）。  
但它有两个明显缺陷：  
- 无法监听**新增或删除的属性**（所以要用 `Vue.set`）  
- 对**数组的某些操作**（比如直接通过下标赋值 `arr[0] = x` 或修改 `length`）无法检测，需要重写数组方法

Vue 3 改用 `Proxy` 代理整个对象，而不是逐个属性去定义。Proxy 能拦截对对象的**所有操作**，包括属性增删、数组索引修改、`for...in` 遍历等，天然支持动态属性和原生数组行为，无需 hack。

所以核心区别是：  
- **Vue 2 是“属性级劫持”，有盲区；Vue 3 是“对象级代理”，更全面、更符合直觉**  
- Proxy 还支持监听 Map、Set 等数据结构（虽然 Vue 3 响应式系统主要还是处理对象和数组）

---

现在，你能不能用自己的话，把上面这段逻辑**简明扼要地说一遍**？不用一字不差，但要把关键差异讲清楚。试试看？', '2026-03-29 16:06:24.862', '2026-03-29 16:06:24.862', 0),
('2038216419207831552', '2038164091557666816', '2001523723396308993', 'user', '给我我的岗位表和题库表的生成指令', '2026-03-29 19:27:17.226', '2026-03-29 19:27:17.226', 0),
('2038216473465348096', '2038164091557666816', '2001523723396308993', 'assistant', '> 未检索到与问题相关的文档内容。', '2026-03-29 19:27:30.162', '2026-03-29 19:27:30.162', 0),
('2039001572612026368', '2039001571890606080', '2001523723396308993', 'user', '我要进行web前端面试', '2026-03-31 23:27:12.385', '2026-03-31 23:27:12.385', 0),
('2039001771086491648', '2039001771002605568', '2001523723396308993', 'user', '我要进行Python算法面试', '2026-03-31 23:27:59.705', '2026-03-31 23:27:59.705', 0),
('2039001784084639744', '2039001571890606080', '2001523723396308993', 'assistant', 'Web 前端面试通常围绕核心语言特性、框架原理、浏览器机制和性能优化等方向展开，覆盖从基础到高阶的知识点。以下是几个关键领域的重点内容：

### 一、JavaScript 核心机制

**1. 闭包**  
闭包是指能访问另一个函数作用域中变量的函数。它由函数及其词法环境共同构成，常用于封装私有变量、实现防抖节流或模块化。但需注意，闭包会持有外部变量引用，若不及时释放，可能引发内存泄漏。

**2. 原型与原型链**  
每个对象都有一个隐式原型（`__proto__`），指向其构造函数的 `prototype`。当访问属性时，若对象自身没有，会沿原型链向上查找，直到 `Object.prototype`（原型链顶端）。这是 JavaScript 实现继承的基础。

**3. 事件循环（Event Loop）**  
JavaScript 是单线程语言，通过事件循环处理异步任务：
- **宏任务**：整体脚本、`setTimeout`、`setInterval`、I/O、DOM 事件等。
- **微任务**：`Promise.then`、`MutationObserver`、`queueMicrotask` 等。  
执行顺序为：执行当前宏任务 → 清空所有微任务 → 执行下一个宏任务。**微任务优先级高于宏任务**。

**4. Promise 与异步编程**  
Promise 有三种状态：pending、fulfilled、rejected，状态一旦改变不可逆。它支持链式调用，有效解决“回调地狱”。`async/await` 是其语法糖，让异步代码更接近同步写法。

---

### 二、Vue 框架核心

**1. 生命周期**  
- **创建阶段**：`beforeCreate` → `created`（可访问数据，DOM 未生成）  
- **挂载阶段**：`beforeMount` → `mounted`（可操作 DOM）  
- **更新阶段**：`beforeUpdate` → `updated`  
- **销毁阶段**：`beforeDestroy` → `destroyed`  

**2. 响应式原理**  
- **Vue 2**：通过 `Object.defineProperty` 劫持数据的 getter/setter。  
- **Vue 3**：使用 `Proxy` 代理整个对象，支持监听数组和动态新增属性。  
流程：数据变化 → 触发 setter → 通知依赖 → 组件重新渲染 → 更新 DOM。

**3. 虚拟 DOM 与 Diff 算法**  
虚拟 DOM 是用 JS 对象描述真实 DOM 的轻量结构，减少直接操作 DOM 的开销。Diff 算法采用**同层比较**策略，通过 `key` 标识节点以复用元素，时间复杂度为 O(n)。

---

### 三、浏览器工作原理

**1. 渲染流程**  
HTML → DOM 树 → CSSOM 树 → 渲染树 → 布局（计算位置）→ 绘制（生成像素）→ 合成显示。

**2. 重排 vs 重绘**  
- **重排（Reflow）**：布局变化（如尺寸、位置、窗口大小），代价高。  
- **重绘（Repaint）**：外观变化（如颜色、背景），不改变布局。  
**优化建议**：用 `transform` 代替 `top/left` 修改位置；批量修改样式以减少触发次数。

**3. 跨域问题**  
因浏览器同源策略（协议、域名、端口任一不同即跨域），常见解决方案包括：
- **CORS**：后端设置响应头（如 `Access-Control-Allow-Origin`）
- **开发代理**：通过 webpack/vite 的 proxy 转发请求
- **JSONP**：仅支持 GET 请求
- **postMessage**：用于跨窗口通信

---

### 四、性能优化重点

**首屏加载优化** 是高频考点，可从多层入手：
- **网络层**：CDN 加速、启用 HTTP/2、Gzip/Brotli 压缩  
- **资源加载**：路由懒加载、图片懒加载、代码分割（Code Splitting）、Tree Shaking 移除无用代码  
- **缓存策略**：强缓存（`Cache-Control`）、协商缓存（`ETag`/`Last-Modified`）  
- **渲染优化**：内联关键 CSS、骨架屏提升感知速度、避免频繁重排重绘  
- **加载策略**：`<link rel="preload">` 预加载关键资源，`defer`/`async` 异步加载非关键 JS，Service Worker 预缓存核心资源

---

### 五、典型面试题示例

- **CSS 盒模型**：标准模型（`content-box`）的 width 仅含内容区；IE 模型（`border-box`）包含 padding 和 border。推荐使用 `box-sizing: border-box`，布局更直观。
- **内存泄漏**：常见原因包括意外全局变量、未清理的定时器、未解绑的 DOM 事件、闭包长期持有引用。解决方法是在组件销毁时主动清理。

这些内容构成了 Web 前端面试的核心知识体系，建议结合实际项目经验理解原理，并能举例说明优化手段的应用场景。', '2026-03-31 23:28:02.804', '2026-03-31 23:28:02.804', 0),
('2039001787951788032', '2039001771002605568', '2001523723396308993', 'assistant', '未检索到与问题相关的文档内容。', '2026-03-31 23:28:03.726', '2026-03-31 23:28:03.726', 0),
('2039007653966954496', '2039007653157453824', '2001523723396308993', 'user', '我要进行web前端面试', '2026-03-31 23:51:22.293', '2026-03-31 23:51:22.293', 0),
('2039007703199694848', '2039007653157453824', '2001523723396308993', 'assistant', '处理面试问题失败，请稍后重试', '2026-03-31 23:51:34.031', '2026-03-31 23:51:34.031', 0),
('2039007871760384000', '2039007653157453824', '2001523723396308993', 'user', '我要面试', '2026-03-31 23:52:14.219', '2026-03-31 23:52:14.219', 0),
('2039008012370231296', '2039007653157453824', '2001523723396308993', 'assistant', 'Web前端面试通常会围绕核心概念、框架原理和实际问题解决能力展开。以下是几个关键方向的要点，帮你系统准备：

### 一、JavaScript 核心机制

**闭包**  
- 是指能访问另一个函数作用域中变量的函数  
- 常用于封装私有变量、实现防抖节流、模块化  
- 注意：可能因持有外部变量引用导致内存泄漏  

**原型与原型链**  
- 每个对象都有 `__proto__`，指向其构造函数的 `prototype`  
- 属性查找沿原型链向上，直到 `Object.prototype`（链顶）  
- 是 JavaScript 实现继承的基础  

**事件循环（Event Loop）**  
- JS 单线程通过事件循环处理异步任务  
- **宏任务**：`setTimeout`、`setInterval`、I/O、DOM 事件、整体脚本  
- **微任务**：`Promise.then`、`MutationObserver`、`queueMicrotask`  
- 执行顺序：当前宏任务 → 清空所有微任务 → 下一个宏任务  

**Promise 与异步编程**  
- 状态：`pending` → `fulfilled` / `rejected`，不可逆  
- 解决回调地狱，支持链式调用  
- `async/await` 是 Promise 的语法糖，让异步代码更像同步  

---

### 二、Vue 框架重点

**生命周期钩子**  
- 创建：`beforeCreate` → `created`（可访问数据，无 DOM）  
- 挂载：`beforeMount` → `mounted`（DOM 可用）  
- 更新：`beforeUpdate` → `updated`  
- 销毁：`beforeDestroy` → `destroyed`（需在此清理定时器、事件监听）  

**响应式原理**  
- Vue 2：用 `Object.defineProperty` 劫持 getter/setter  
- Vue 3：改用 `Proxy`，支持数组索引和动态新增属性  
- 数据变 → 触发 setter → 通知依赖 → 重新渲染组件  

**虚拟 DOM 与 Diff 算法**  
- 虚拟 DOM 是 JS 对象，描述真实 DOM 结构  
- Diff 采用同层比较，靠 `key` 识别节点复用，复杂度 O(n)  

---

### 三、浏览器与性能优化

**渲染流程**  
HTML → DOM 树 → CSSOM 树 → 渲染树 → 布局（位置/大小）→ 绘制 → 合成显示  

**重排 vs 重绘**  
- **重排**：布局变化（如尺寸、增删元素），开销大  
- **重绘**：外观变化（颜色、背景），不改变布局  
- 优化：用 `transform` 代替 `top/left`，批量修改样式  

**首屏加载优化**  
- **网络层**：CDN、HTTP/2、Gzip/Brotli 压缩  
- **资源层**：路由懒加载、图片懒加载、代码分割、Tree Shaking  
- **缓存**：强缓存（`Cache-Control`）、协商缓存（`ETag`）  
- **渲染层**：骨架屏、关键 CSS 内联、非关键 JS 异步加载（`defer/async`）  
- **进阶**：`<link rel="preload">` 预加载关键资源，Service Worker 预缓存  

**跨域解决方案**  
- CORS（后端设响应头）  
- 开发代理（如 webpack devServer proxy）  
- JSONP（仅 GET）  
- `postMessage`（跨窗口通信）  

---

### 四、高频面试题示例

1. **CSS 盒模型**  
   - 标准模型（`content-box`）：`width` = 内容宽  
   - IE 模型（`border-box`）：`width` = 内容 + padding + border  
   - 推荐用 `box-sizing: border-box`，布局更直观  

2. **如何优化首屏速度？**  
   综合答：CDN + HTTP/2 + Gzip；懒加载图片/路由；代码分割；骨架屏；关键资源预加载；合理缓存策略。

3. **Vue 生命周期在哪发起 AJAX 请求？**  
   通常在 `created`（无需 DOM）或 `mounted`（需操作 DOM 后）。

建议结合项目经验，对每个知识点准备一个实际应用场景，比如“我在项目中用 `debounce` 防抖优化搜索请求，背后就是闭包实现”。这样回答更有说服力。', '2026-03-31 23:52:47.743', '2026-03-31 23:52:47.743', 0),
('2039008018082873344', '2039007653157453824', '2001523723396308993', 'user', '我要进行java 后端面试', '2026-03-31 23:52:49.105', '2026-03-31 23:52:49.105', 0),
('2039008032909737984', '2039007653157453824', '2001523723396308993', 'assistant', '处理面试问题失败，请稍后重试', '2026-03-31 23:52:52.64', '2026-03-31 23:52:52.64', 0),
('2039009707057795072', '2039009706298626048', '2001523723396308993', 'user', '我要进行web前端面试', '2026-03-31 23:59:31.788', '2026-03-31 23:59:31.788', 0),
('2039009725550481408', '2039009706298626048', '2001523723396308993', 'assistant', '根据你的需求，我为你准备了以下面试题目：

**题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？

**难度：**3

**参考答案：**Spring Boot是一个基于Spring框架的快速开发脚手架，它的主要特性包括：
1. 自动配置：根据项目依赖自动配置应用
2. 嵌入式服务器：内置Tomcat、Jetty等服务器
3.  starters依赖：提供一站式依赖管理
4. 生产就绪功能：如健康检查、监控等
5. 无代码生成和XML配置
6. 快速开发：简化了Spring应用的初始搭建和开发过程

', '2026-03-31 23:59:36.198', '2026-03-31 23:59:36.198', 0),
('2039009903435108352', '2039009706298626048', '2001523723396308993', 'user', '我要进行Python算法面试', '2026-04-01 00:00:18.608', '2026-04-01 00:00:18.608', 0),
('2039009917205008384', '2039009706298626048', '2001523723396308993', 'assistant', '根据你的需求，我为你准备了以下面试题目：

**题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？

**难度：**3

**参考答案：**Spring Boot是一个基于Spring框架的快速开发脚手架，它的主要特性包括：
1. 自动配置：根据项目依赖自动配置应用
2. 嵌入式服务器：内置Tomcat、Jetty等服务器
3.  starters依赖：提供一站式依赖管理
4. 生产就绪功能：如健康检查、监控等
5. 无代码生成和XML配置
6. 快速开发：简化了Spring应用的初始搭建和开发过程

', '2026-04-01 00:00:21.891', '2026-04-01 00:00:21.891', 0),
('2039012327910596608', '2039012327168204800', '2001523723396308993', 'user', '我要进行web前端面试', '2026-04-01 00:09:56.648', '2026-04-01 00:09:56.648', 0),
('2039012352774430720', '2039012327168204800', '2001523723396308993', 'assistant', '根据你的需求，我为你准备了以下面试题目：

**题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？

**难度：**3

**参考答案：**Spring Boot是一个基于Spring框架的快速开发脚手架，它的主要特性包括：
1. 自动配置：根据项目依赖自动配置应用
2. 嵌入式服务器：内置Tomcat、Jetty等服务器
3.  starters依赖：提供一站式依赖管理
4. 生产就绪功能：如健康检查、监控等
5. 无代码生成和XML配置
6. 快速开发：简化了Spring应用的初始搭建和开发过程

', '2026-04-01 00:10:02.576', '2026-04-01 00:10:02.576', 0),
('2039012417236688896', '2039012327168204800', '2001523723396308993', 'user', '我要进行算法面试', '2026-04-01 00:10:17.945', '2026-04-01 00:10:17.945', 0),
('2039012429861543936', '2039012327168204800', '2001523723396308993', 'assistant', '根据你的需求，我为你准备了以下面试题目：

**题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？

**难度：**3

**参考答案：**Spring Boot是一个基于Spring框架的快速开发脚手架，它的主要特性包括：
1. 自动配置：根据项目依赖自动配置应用
2. 嵌入式服务器：内置Tomcat、Jetty等服务器
3.  starters依赖：提供一站式依赖管理
4. 生产就绪功能：如健康检查、监控等
5. 无代码生成和XML配置
6. 快速开发：简化了Spring应用的初始搭建和开发过程

', '2026-04-01 00:10:20.955', '2026-04-01 00:10:20.955', 0),
('2039012603556061184', '2039012603480563712', '2001523723396308993', 'user', '什么是闭包', '2026-04-01 00:11:02.367', '2026-04-01 00:11:02.367', 0),
('2039012646799335424', '2039012603480563712', '2001523723396308993', 'assistant', '闭包是指有权访问另一个函数作用域中变量的函数。

它的核心原理是：**函数 + 词法环境**，也就是说，一个内部函数即使在其外部函数执行完毕后，仍然可以访问并操作外部函数中的变量。

### 主要应用场景包括：
- **封装私有变量**：通过闭包可以隐藏数据，避免全局污染
- **实现防抖和节流**：利用闭包保存状态，控制函数调用频率
- **模块化模式**：创建具有私有状态和公共接口的模块

### 需要注意的问题：
闭包会持续持有对外部变量的引用，如果使用不当（比如长时间不释放），可能导致**内存泄漏**。因此在组件销毁或不再需要时，应主动解除引用。', '2026-04-01 00:11:12.677', '2026-04-01 00:11:12.677', 0),
('2039015015477997568', '2039015014785937408', '2001523723396308993', 'user', '我要进行Python算法面试', '2026-04-01 00:20:37.414', '2026-04-01 00:20:37.414', 0),
('2039015033110851584', '2039015014785937408', '2001523723396308993', 'assistant', '根据你的需求，我为你准备了以下4个不同难度的面试题目：

1. **题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？
   **难度：**1

2. **题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？
   **难度：**2

3. **题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？
   **难度：**3

4. **题目：**请介绍一下你对Spring Boot的理解，以及它的主要特性是什么？
   **难度：**4

请回答完所有问题后，输入''查看答案''来获取参考答案。
', '2026-04-01 00:20:41.618', '2026-04-01 00:20:41.618', 0),
('2039019351473979392', '2039019350727393280', '2001523723396308993', 'user', '我要进行python算法面试', '2026-04-01 00:37:51.196', '2026-04-01 00:37:51.196', 0),
('2039019366510559232', '2039019350727393280', '2001523723396308993', 'assistant', '处理面试问题失败: 
### Error querying database.  Cause: org.postgresql.util.PSQLException: ERROR: function rand() does not exist
  建议：No function matches the given name and argument types. You might need to add explicit type casts.
  位置：215
### The error may exist in com/nageoffer/ai/ragent/interview/mapper/QuestionMapper.java (best guess)
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT  id,position_id,question_type,difficulty,question_text,reference_answer,keywords,create_time,update_time,deleted  FROM t_question      WHERE  (position_id = ? AND deleted = ? AND difficulty = ?) ORDER BY RAND() LIMIT 1
### Cause: org.postgresql.util.PSQLException: ERROR: function rand() does not exist
  建议：No function matches the given name and argument types. You might need to add explicit type casts.
  位置：215
; bad SQL grammar []', '2026-04-01 00:37:54.782', '2026-04-01 00:37:54.782', 0),
('2039019439260762112', '2039019350727393280', '2001523723396308993', 'user', '我要进行算法面试', '2026-04-01 00:38:12.126', '2026-04-01 00:38:12.126', 0),
('2039019450665074688', '2039019350727393280', '2001523723396308993', 'assistant', '处理面试问题失败: 
### Error querying database.  Cause: org.postgresql.util.PSQLException: ERROR: function rand() does not exist
  建议：No function matches the given name and argument types. You might need to add explicit type casts.
  位置：215
### The error may exist in com/nageoffer/ai/ragent/interview/mapper/QuestionMapper.java (best guess)
### The error may involve defaultParameterMap
### The error occurred while setting parameters
### SQL: SELECT  id,position_id,question_type,difficulty,question_text,reference_answer,keywords,create_time,update_time,deleted  FROM t_question      WHERE  (position_id = ? AND deleted = ? AND difficulty = ?) ORDER BY RAND() LIMIT 1
### Cause: org.postgresql.util.PSQLException: ERROR: function rand() does not exist
  建议：No function matches the given name and argument types. You might need to add explicit type casts.
  位置：215
; bad SQL grammar []', '2026-04-01 00:38:14.845', '2026-04-01 00:38:14.845', 0),
('2039020740363227136', '2039020739620835328', '2001523723396308993', 'user', '我要进行python 算法面试', '2026-04-01 00:43:22.333', '2026-04-01 00:43:22.334', 0),
('2039020759657025536', '2039020739620835328', '2001523723396308993', 'assistant', '根据你的需求，我为你准备了以下4个不同难度的面试题目：

1. **题目：**如何处理数据不平衡问题？
   **难度：**4

2. **题目：**Python中的列表和元组有什么区别？
   **难度：**2

3. **题目：**你在数据预处理中做过哪些工作？
   **难度：**3

4. **题目：**如何处理数据不平衡问题？
   **难度：**4

请回答完所有问题后，输入''查看答案''来获取参考答案。
', '2026-04-01 00:43:26.933', '2026-04-01 00:43:26.933', 0),
('2039205334702170112', '2039205333884280832', '2038120540551532544', 'user', '我要进行Python算法面试', '2026-04-01 12:56:53.053', '2026-04-01 12:56:53.053', 0),
('2039205351072538624', '2039205333884280832', '2038120540551532544', 'assistant', '根据你的需求，我为你准备了以下4个不同难度的面试题目：

1. **题目：**如何评估分类模型的好坏？
   **难度：**3

2. **题目：**Python中的列表和元组有什么区别？
   **难度：**2

3. **题目：**NumPy数组和Python列表有什么区别？
   **难度：**3

4. **题目：**什么是梯度消失和梯度爆炸？如何解决？
   **难度：**4

请回答完所有问题后，输入''查看答案''来获取参考答案。
', '2026-04-01 12:56:56.956', '2026-04-01 12:56:56.956', 0),
('2039209159727067136', '2039209159001452544', '2001523723396308993', 'user', '我要进行Python算法面试', '2026-04-01 13:12:05.01', '2026-04-01 13:12:05.01', 0),
('2039209176151961600', '2039209159001452544', '2001523723396308993', 'assistant', '根据你的需求，我为你准备了以下4个不同难度的面试题目：

1. 题目：Pandas中DataFrame和Series的区别？
   难度：4

2. 题目：描述一个你参与的算法项目，你负责什么？
   难度：2

3. 题目：NumPy数组和Python列表有什么区别？
   难度：3

4. 题目：如何处理数据不平衡问题？
   难度：4

请回答完所有问题后，输入''查看答案''来获取参考答案。
', '2026-04-01 13:12:08.926', '2026-04-01 13:12:08.926', 0);


INSERT INTO "public"."t_knowledge_base" ("id", "name", "embedding_model", "collection_name", "created_by", "updated_by", "create_time", "update_time", "deleted") VALUES
('2037157970269188096', 'web前端', 'qwen-emb-8b', 'web', 'admin', 'admin', '2026-03-26 21:21:23.336', '2026-03-26 21:21:23.337', 0),
('2038161065916784640', 'Java后端', 'qwen-emb-8b', 'javabackend', 'admin', 'admin', '2026-03-29 15:47:19.973', '2026-03-29 15:47:19.974', 0),
('2039211164960894976', 'Python算法', 'qwen-emb-8b', 'python', 'admin', 'admin', '2026-04-01 13:20:03.095', '2026-04-01 13:20:03.095', 0);
INSERT INTO "public"."t_knowledge_document" ("id", "kb_id", "doc_name", "enabled", "chunk_count", "file_url", "file_type", "file_size", "process_mode", "status", "source_type", "source_location", "schedule_enabled", "schedule_cron", "chunk_strategy", "chunk_config", "pipeline_id", "created_by", "updated_by", "create_time", "update_time", "deleted") VALUES
('2037158972468768768', '2037157970269188096', 'web.txt', 0, 1, 's3://web/57f6be0ed37540b4a8539e2f37dcc161.txt', 'txt', 9641, 'chunk', 'failed', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-26 21:25:22.277', '2026-03-26 21:29:18.66', 1),
('2037160142675390464', '2037157970269188096', 'web.txt', 1, 0, 's3://web/0c774dab71ae41019fb12c086aa7b98e.txt', 'txt', 9641, 'chunk', 'failed', 'file', NULL, 0, NULL, 'fixed_size', '{"chunkSize": 512, "overlapSize": 128}', NULL, 'admin', 'admin', '2026-03-26 21:30:01.276', '2026-03-26 21:32:54.552', 1),
('2037161241557872640', '2037157970269188096', 'web.txt', 0, 0, 's3://web/c38b93bf66ac41e596d2a6b3186bb607.txt', 'txt', 9641, 'chunk', 'failed', 'file', NULL, 0, NULL, 'fixed_size', '{"chunkSize": 512, "overlapSize": 128}', NULL, 'admin', 'admin', '2026-03-26 21:34:23.271', '2026-03-26 21:35:30.594', 1),
('2037162970848440320', '2037157970269188096', 'web.txt', 1, 0, 's3://web/93b5a80b192f44f4800a150b854f1d4a.txt', 'txt', 9459, 'chunk', 'failed', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-26 21:41:15.565', '2026-03-26 21:41:28.563', 1),
('2037164871325331456', '2037157970269188096', 'web.md', 1, 0, 's3://web/a6fa02b8b4f94b03a016a9503f090e41.md', 'markdown', 9459, 'chunk', 'failed', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-26 21:48:48.674', '2026-03-26 21:49:06.888', 1),
('2037165255838150656', '2037157970269188096', 'web.txt', 1, 0, 's3://web/d50f0be6d32247649e63ca92eaf972e6.txt', 'txt', 1261, 'chunk', 'failed', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-26 21:50:20.349', '2026-03-26 21:50:23.283', 1),
('2037165577587404800', '2037157970269188096', 'web.txt', 1, 0, 's3://web/3ff3bd08bfb048faa50507a339b683d9.txt', 'txt', 1261, 'chunk', 'failed', 'file', NULL, 0, NULL, 'fixed_size', '{"chunkSize": 512, "overlapSize": 128}', NULL, 'admin', 'admin', '2026-03-26 21:51:37.06', '2026-03-26 21:51:44.623', 1),
('2037165874229555200', '2037157970269188096', 'web.txt', 1, 0, 's3://web/a5d793d22b0b48449d778c69efea4754.txt', 'txt', 13, 'chunk', 'failed', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-26 21:52:47.785', '2026-03-26 21:52:50.687', 1),
('2037166857244393472', '2037157970269188096', 'web.txt', 1, 0, 's3://web/63b4429b3f1e4884bf0a63bc48ea5602.txt', 'txt', 13, 'chunk', 'failed', 'file', NULL, 0, NULL, 'fixed_size', '{"chunkSize": 512, "overlapSize": 128}', NULL, 'admin', 'admin', '2026-03-26 21:56:42.155', '2026-03-26 21:56:50.125', 1),
('2037168797202268160', '2037157970269188096', 'web.txt', 1, 1, 's3://web/c47c46f4211f4a8cabee45d0b03acea1.txt', 'txt', 13, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-26 22:04:24.676', '2026-03-26 22:15:31.111', 1),
('2038119658904637440', '2037157970269188096', 'web前端面试题库.txt', 1, 1, 's3://web/882fdd704d0049feaea85011b4a0fc23.txt', 'txt', 2473, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-29 13:02:47.772', '2026-03-29 15:48:02.674', 1),
('2038163842562809856', '2037157970269188096', 'web前端的核心概念.txt', 1, 1, 's3://web/d74a76d16e2e42be82ccd18d4aafd51a.txt', 'txt', 3922, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-03-29 15:58:21.978', '2026-03-29 15:58:28.557', 0),
('2039212967563702272', '2038161065916784640', 'Java后端的核心概念.txt', 1, 1, 's3://javabackend/742934ad60154a2fac3f68bd40aa6cfe.txt', 'txt', 5534, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-04-01 13:27:12.869', '2026-04-01 13:27:17.026', 0),
('2039213253741064192', '2038161065916784640', 'Java后端核心知识补充.txt', 1, 1, 's3://javabackend/14817a0d483b4e0ba9335276ea4b00aa.txt', 'txt', 6217, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-04-01 13:28:21.099', '2026-04-01 13:28:24.409', 0),
('2039214362530492416', '2037157970269188096', 'web前端知识点补充.txt', 1, 1, 's3://web/46e7c9a1c7d1475f89d8f1760592b1ea.txt', 'txt', 6613, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-04-01 13:32:45.455', '2026-04-01 13:33:10.124', 0),
('2039216636333993984', '2039211164960894976', 'Python算法的核心概念.txt', 1, 1, 's3://python/fe35540f667f4b9a8d0e47413047a1d7.txt', 'txt', 10519, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-04-01 13:41:47.572', '2026-04-01 13:42:01.228', 0),
('2039216759277432832', '2039211164960894976', 'Python算法补充知识点.txt', 1, 1, 's3://python/107aa363de134a1aa5249df7f0a1605c.txt', 'txt', 11077, 'chunk', 'success', 'file', NULL, 0, NULL, 'structure_aware', '{"maxChars": 1800, "minChars": 600, "targetChars": 1400, "overlapChars": 0}', NULL, 'admin', 'admin', '2026-04-01 13:42:16.884', '2026-04-01 13:42:28.405', 0);
INSERT INTO "public"."t_user" ("id", "username", "password", "role", "avatar", "create_time", "update_time", "deleted") VALUES
('2001523723396308993', 'admin', 'admin', 'admin', 'https://static.deepseek.com/user-avatar/G_6cuD8GbD53VwGRwisvCsZ6', '2026-03-24 22:16:14.061831', '2026-03-24 22:16:14.061831', 0),
('2038120540551532544', 'lcm', '123456', 'user', NULL, '2026-03-29 13:06:17.973', '2026-03-29 13:06:17.973', 0);
INSERT INTO "public"."t_conversation" ("id", "conversation_id", "user_id", "title", "last_time", "create_time", "update_time", "deleted", "round_count") VALUES
('2036458472635109376', '2036458457137156096', '2001523723396308993', '中南大学', '2026-03-24 23:10:39.2', '2026-03-24 23:01:50.102', '2026-03-24 23:01:50.102', 0, 0),
('2037125588979818496', '2037125580805120000', '2001523723396308993', '1+1', '2026-03-26 19:12:41.3', '2026-03-26 19:12:43.033', '2026-03-26 19:12:43.033', 0, 0),
('2037159103536574464', '2037159068648353792', '2001523723396308993', 'Web开发岗位面试准备', '2026-03-26 21:26:04.897', '2026-03-26 21:25:53.526', '2026-03-26 21:25:53.526', 0, 0),
('2037160210170130432', '2037160207305420800', '2001523723396308993', 'Web面试', '2026-03-26 21:30:16.697', '2026-03-26 21:30:17.368', '2026-03-26 21:30:17.368', 0, 0),
('2038119857534291968', '2038119850693382144', '2001523723396308993', 'Web开发岗位面试准备', '2026-03-29 13:03:33.656', '2026-03-29 13:03:35.129', '2026-03-29 13:03:35.129', 0, 0),
('2038120676098854912', '2038120668758822912', '2038120540551532544', 'Web面试', '2026-03-29 13:06:48.567', '2026-03-29 13:06:50.29', '2026-03-29 13:06:50.29', 0, 0),
('2038164096842489856', '2038164091557666816', '2001523723396308993', 'Web前端面试准备', '2026-03-29 19:27:17.227', '2026-03-29 15:59:22.602', '2026-03-29 15:59:22.602', 0, 0),
('2039001579201277952', '2039001571890606080', '2001523723396308993', 'Web前端面试准备', '2026-03-31 23:27:12.388', '2026-03-31 23:27:13.956', '2026-03-31 23:27:13.956', 0, 0),
('2039001773775040512', '2039001771002605568', '2001523723396308993', 'Python算法面试准备', '2026-03-31 23:27:59.707', '2026-03-31 23:28:00.346', '2026-03-31 23:28:00.346', 0, 0),
('2039007658945593344', '2039007653157453824', '2001523723396308993', 'Web前端面试准备', '2026-03-31 23:52:49.106', '2026-03-31 23:51:23.48', '2026-03-31 23:51:23.48', 0, 0),
('2039009712988540928', '2039009706298626048', '2001523723396308993', 'Web前端面试准备', '2026-04-01 00:00:18.611', '2026-03-31 23:59:33.202', '2026-03-31 23:59:33.202', 0, 0),
('2039012333409329152', '2039012327168204800', '2001523723396308993', 'Web前端面试准备', '2026-04-01 00:10:17.946', '2026-04-01 00:09:57.959', '2026-04-01 00:09:57.959', 0, 0),
('2039012610220810240', '2039012603480563712', '2001523723396308993', '什么是闭包', '2026-04-01 00:11:02.368', '2026-04-01 00:11:03.956', '2026-04-01 00:11:03.956', 0, 0),
('2039015021190639616', '2039015014785937408', '2001523723396308993', 'Python算法面试准备', '2026-04-01 00:20:37.416', '2026-04-01 00:20:38.776', '2026-04-01 00:20:38.776', 0, 0),
('2039019356389703680', '2039019350727393280', '2001523723396308993', 'Python算法面试准备', '2026-04-01 00:38:12.128', '2026-04-01 00:37:52.369', '2026-04-01 00:37:52.369', 0, 0),
('2039020746004566016', '2039020739620835328', '2001523723396308993', 'Python 算法面试准备', '2026-04-01 00:43:22.335', '2026-04-01 00:43:23.678', '2026-04-01 00:43:23.678', 0, 0),
('2039205340846825472', '2039205333884280832', '2038120540551532544', 'Python算法面试准备', '2026-04-01 12:56:53.055', '2026-04-01 12:56:54.518', '2026-04-01 12:56:54.518', 0, 0),
('2039209166932881408', '2039209159001452544', '2001523723396308993', 'Python算法面试准备', '2026-04-01 13:12:05.012', '2026-04-01 13:12:06.728', '2026-04-01 13:12:06.728', 0, 0);
INSERT INTO "public"."t_knowledge_chunk" ("id", "kb_id", "doc_id", "chunk_index", "content", "content_hash", "char_count", "token_count", "enabled", "created_by", "updated_by", "create_time", "update_time", "deleted") VALUES
('2037159371305136129', '2037157970269188096', '2037158972468768768', 0, '好的！我帮你生成一份完整的 **《Web 前端开发面试题库》** 文档，可以直接放入 `faceit_docs` 仓库。

---

# Web 前端开发面试题库

## 文档说明
- **岗位**：Web 前端开发
- **适用人群**：求职者、面试官
- **题目数量**：10 道
- **难度分布**：简单 3 道、中等 4 道、困难 3 道

---

## 一、简单难度

### 题目 1：什么是闭包？有什么作用？
**难度**：⭐ 简单  
**知识点**：JavaScript 作用域、闭包

**参考答案**：
闭包是指有权访问另一个函数作用域中变量的函数。它由函数及其相关的引用环境组成。

**主要作用**：
- 封装私有变量，避免全局污染
- 实现模块化开发
- 保存变量状态，用于回调函数

**代码示例**：
```javascript
function createCounter() {
    let count = 0;
    return function() {
        count++;
        return count;
    };
}
const counter = createCounter();
console.log(counter()); // 1
console.log(counter()); // 2
```

**常见考点**：
- 闭包会导致内存泄漏吗？（可能，如果未及时释放）
- 闭包的应用场景（防抖、节流、模块化）

---

### 题目 2：什么是事件冒泡和事件捕获？
**难度**：⭐ 简单  
**知识点**：DOM 事件流

**参考答案**：
事件流分为三个阶段：捕获阶段、目标阶段、冒泡阶段。

- **事件捕获**：从根节点向下传播到目标元素（不常用）
- **事件冒泡**：从目标元素向上传播到根节点（默认）

**代码示例**：
```javascript
// 阻止冒泡
element.addEventListener(''click'', (e) => {
    e.stopPropagation();
});

// 捕获阶段监听
element.addEventListener(''click'', handler, true);
```

**常见考点**：
- 如何阻止事件冒泡？（`stopPropagation`）
- 如何阻止默认行为？（`preventDefault`）

---

### 题目 3：CSS 盒模型是什么？
**难度**：⭐ 简单  
**知识点**：CSS 布局

**参考答案**：
CSS 盒模型由四部分组成：`content`（内容）、`padding`（内边距）、`border`（边框）、`margin`（外边距）。

**两种盒模型**：
| 类型 | width 计算方式 |
|------|---------------|
| 标准盒模型 | `width = content` |
| IE 盒模型 | `width = content + padding + border` |

**代码示例**：
```css
/* 标准盒模型（默认） */
.box {
    box-sizing: content-box;
    width: 200px;
    padding: 10px;
    border: 1px solid #000;
    /* 实际宽度：200px */
}

/* IE盒模型 */
.box {
    box-sizing: border-box;
    width: 200px;
    padding: 10px;
    border: 1px solid #000;
    /* 实际宽度：200px，content宽度自动压缩 */
}
```

---

## 二、中等难度

### 题目 4：解释一下 Promise 和 async/await 的区别
**难度**：⭐⭐ 中等  
**知识点**：异步编程

**参考答案**：
两者都用于处理异步操作，async/await 是 Promise 的语法糖。

| 特性 | Promise | async/await |
|------|---------|-------------|
| 语法 | 链式调用 `.then()` | 同步代码风格 |
| 错误处理 | `.catch()` | `try/catch` |
| 可读性 | 链式嵌套可能混乱 | 清晰直观 |
| 调试 | 较难 | 易调试 |

**代码示例**：
```javascript
// Promise 写法
fetch(''/api/user'')
    .then(res => res.json())
    .then(data => console.log(data))
    .catch(err => console.error(err));

// async/await 写法
async function getUser() {
    try {
        const res = await fetch(''/api/user'');
        const data = await res.json();
        console.log(data);
    } catch (err) {
        console.error(err);
    }
}
```

---

### 题目 5：Vue 的生命周期钩子有哪些？
**难度**：⭐⭐ 中等  
**知识点**：Vue 框架

**参考答案**：
Vue 实例从创建到销毁的整个过程，包含 8 个主要钩子：

| 阶段 | 钩子 | 说明 |
|------|------|------|
| 创建 | `beforeCreate` | 实例初始化后，数据未挂载 |
| 创建 | `created` | 数据已挂载，DOM 未生成 |
| 挂载 | `beforeMount` | 模板编译后，DOM 未渲染 |
| 挂载 | `mounted` | DOM 已渲染，可访问 DOM |
| 更新 | `beforeUpdate` | 数据更新，DOM 未更新 |
| 更新 | `updated` | DOM 已更新 |
| 销毁 | `beforeDestroy` | 实例销毁前，清理资源 |
| 销毁 | `destroyed` | 实例销毁后 |

**代码示例**：
```javascript
export default {
    mounted() {
        // 发起 API 请求
        this.fetchData();
    },
    beforeDestroy() {
        // 清除定时器、取消事件监听
        clearInterval(this.timer);
    }
}
```

---

### 题目 6：什么是跨域？如何解决？
**难度**：⭐⭐ 中等  
**知识点**：HTTP、CORS

**参考答案**：
跨域是浏览器同源策略导致的限制。同源要求：**协议、域名、端口**三者完全相同。

**解决方案**：

1. **CORS（推荐）**：后端设置响应头
   ```
   Access-Control-Allow-Origin: https://example.com
   Access-Control-Allow-Methods: GET, POST, PUT
   Access-Control-Allow-Headers: Content-Type
   ```

2. **代理转发（开发环境）**：
   ```javascript
   // vue.config.js
   module.exports = {
       devServer: {
           proxy: {
               ''/api'': {
                   target: ''http://localhost:8080'',
                   changeOrigin: true
               }
           }
       }
   }
   ```

3. **JSONP（仅 GET）**：利用 `<script>` 标签不受同源限制

---

### 题目 7：什么是虚拟 DOM？优缺点是什么？
**难度**：⭐⭐ 中等  
**知识点**：React/Vue 原理

**参考答案**：
虚拟 DOM 是用 JavaScript 对象描述真实 DOM 结构，通过 Diff 算法找出最小变更，批量更新真实 DOM。

**优点**：
- 减少直接操作 DOM 的次数，提升性能
- 跨平台能力（Web、移动端、小程序）
- 简化开发模型

**缺点**：
- 首次渲染比直接操作 DOM 慢
- 占用额外内存
- 需要学习 Diff 算法原理

**代码示例**：
```javascript
// 虚拟 DOM 结构示例
{
    tag: ''div'',
    props: { class: ''container'' },
    children: [
        { tag: ''h1'', props: {}, children: [''Hello''] }
    ]
}
```

---

## 三、困难难度

### 题目 8：浏览器从输入 URL 到页面渲染经历了什么？
**难度**：⭐⭐⭐ 困难  
**知识点**：浏览器原理、网络

**参考答案**：

**完整流程**：
1. **DNS 解析**：域名 → IP 地址（DNS 缓存查询）
2. **TCP 连接**：三次握手建立连接
3. **发送 HTTP 请求**：构建请求报文
4. **服务器处理**：处理请求并返回响应
5. **浏览器解析渲染**：
   - 解析 HTML → DOM 树
   - 解析 CSS → CSSOM 树
   - 合并 → 渲染树（Render Tree）
   - 布局（Layout）→ 计算位置和大小
   - 绘制（Paint）→ 绘制像素
   - 合成（Composite）→ 图层合并显示

**关键概念**：
- **重排（Reflow）**：布局发生变化，代价高
- **重绘（Repaint）**：外观发生变化，代价中等
- **合成（Composite）**：图层变换，代价低

---

### 题目 9：如何优化首屏加载速度？
**难度**：⭐⭐⭐ 困难  
**知识点**：性能优化

**参考答案**：

| 优化方向 | 具体措施 |
|---------|---------|
| **网络优化** | CDN 加速、HTTP/2 多路复用、Gzip 压缩 |
| **资源优化** | 图片懒加载、路由懒加载、代码分割、Tree Shaking |
| **缓存策略** | 强缓存（Cache-Control）、协商缓存（ETag） |
| **渲染优化** | 骨架屏、减少重排重绘、使用 `transform` 代替 `top/left` |
| **加载策略** | 预加载（`<link rel="preload">`）、异步加载（`defer/async`） |

**代码示例**：
```javascript
// 路由懒加载
const Home = () => import(''@/views/Home.vue'');

// 图片懒加载
<img v-lazy="imgUrl" />

// 预加载关键资源
<link rel="preload" href="critical.css" as="style">
```

---

### 题目 10：什么是事件循环？宏任务和微任务有什么区别？
**难度**：⭐⭐⭐ 困难  
**知识点**：JavaScript 运行机制

**参考答案**：
事件循环是 JavaScript 处理异步任务的执行模型。

**任务类型**：
- **宏任务**：`setTimeout`、`setInterval`、`I/O`、`DOM 事件`
- **微任务**：`Promise.then`、`MutationObserver`、`queueMicrotask`

**执行顺序**：
1. 执行当前同步代码
2. 清空微任务队列
3. 取出一个宏任务执行
4. 再清空微任务队列
5. 重复 3-4 步

**代码示例**：
```javascript
console.log(''1'');
setTimeout(() => console.log(''2''), 0);
Promise.resolve().then(() => console.log(''3''));
console.log(''4'');
// 输出顺序：1, 4, 3, 2
```

**常见考点**：
- 为什么微任务先于宏任务？（微任务队列清空优先级更高）
- 事件循环与页面渲染的关系（渲染在宏任务之间执行）

---

## 四、题目难度统计

| 难度 | 题目数 |
|------|--------|
| 简单（⭐） | 3 |
| 中等（⭐⭐） | 4 |
| 困难（⭐⭐⭐） | 3 |
| **总计** | **10** |

---

## 五、知识点分布

| 知识点领域 | 题号 |
|-----------|------|
| JavaScript | 1, 4, 10 |
| DOM 事件 | 2 |
| CSS | 3 |
| Vue 框架 | 5, 7 |
| 网络/HTTP | 6, 8 |
| 性能优化 | 9 |

---

**文档生成完成！** 你可以把这份内容保存为 `web前端面试题库.md`，放入 `faceit_docs` 仓库。', '5b5fde6c7cc1fbcc73d9c7fb16ada8f1fc6b8662078cf34b8ad160e2dca74ac5', 6305, 2319, 0, 'admin', 'admin', '2026-03-26 21:27:07.344', '2026-03-26 21:27:07.344', 1),
('2037171591070105601', '2037157970269188096', '2037168797202268160', 0, 'web开发', '230febbfe0ec52a75da6e56f3fbd1994c9fa22e9713b2b6205f3f41309105034', 5, 3, 1, 'admin', NULL, '2026-03-26 22:15:31.088', '2026-03-26 22:15:31.089', 1),
('2038119671579824129', '2037157970269188096', '2038119658904637440', 0, 'web开发面试：
 一、简单难度
 题目：什么是 CSS 盒模型？有什么区别？
知识点：CSS 布局
参考答案：
CSS 盒模型由四部分组成：内容区（content）、内边距（padding）、边框（border）、外边距（margin）。
两种盒模型：
标准盒模型：width 只包含内容区宽度，不包含 padding 和 border
IE 盒模型：width 包含内容区 + padding + border如何切换：通过 `box-sizing` 属性控制，`content-box` 为标准模型，`border-box` 为 IE 模型。
推荐理由：开发中常用 `border-box`，因为设置 width 后元素实际宽度固定，布局更直观。
 二、中等难度
 题目：什么是事件循环？宏任务和微任务有什么区别？
知识点：JavaScript 运行机制
参考答案：
事件循环是 JavaScript 处理异步任务的执行模型。JS 是单线程，通过事件循环实现非阻塞 I/O。
宏任务：包括整体脚本代码、setTimeout、setInterval、I/O 操作、DOM 事件等。
微任务：包括 Promise.then、MutationObserver、queueMicrotask 等。
执行顺序：
1. 执行当前宏任务（同步代码）
2. 清空所有微任务
3. 执行下一个宏任务
4. 重复上述过程
核心原则：微任务优先级高于宏任务，每个宏任务执行后都会先清空微任务队列，再取下一个宏任务。
 三、困难难度
 题目：如何优化首屏加载速度？
知识点：性能优能
参考答案：
网络层优化：
使用 CDN 加速静态资源分发
启用 HTTP/2 多路复用，减少连接开销
开启 Gzip/Brotli 压缩，减小传输体积
资源加载优化：
路由懒加载，按需加载页面组件
 图片懒加载，首屏只加载可视区域图片
代码分割，将第三方库与业务代码分离
Tree Shaking，移除未使用的代码
缓存策略：
强缓存（Cache-Control）缓存不常变的资源
协商缓存（ETag/Last-Modified）验证资源更新
渲染优化：
骨架屏，减少用户等待焦虑
减少重排重绘，用 transform 代替 top/left
关键 CSS 内联，非关键 CSS 异步加载
加载策略：
预加载（preload）关键资源
异步加载（defer/async）非关键 JS
使用 Service Worker 预缓存核心资源', '6fe5b97bdfa09cc5ec17397e710479bf0d384c2298684f39e58d571e4da5e662', 1050, 646, 1, 'admin', 'admin', '2026-03-29 13:02:51.674', '2026-03-29 13:02:51.674', 1),
('2038163866487119873', '2037157970269188096', '2038163842562809856', 0, 'Web前端核心概念

一、JavaScript核心

1. 闭包
定义：闭包是指有权访问另一个函数作用域中变量的函数。
原理：函数 + 词法环境，内部函数可以访问外部函数的变量。
应用场景：封装私有变量、防抖节流、模块化模式。
注意事项：闭包会持有外部变量引用，可能导致内存泄漏。

2. 原型和原型链
定义：每个对象都有一个隐式的原型对象（__proto__），指向其构造函数的prototype属性。
原型链：当访问对象属性时，如果自身没有，会沿着原型链向上查找。
核心要点：Object.prototype是原型链的顶端，原型链实现继承。

3. 事件循环
定义：JavaScript处理异步任务的执行模型。
宏任务：setTimeout、setInterval、I/O、DOM事件、script整体代码。
微任务：Promise.then、MutationObserver、queueMicrotask。
执行顺序：执行当前宏任务 -> 清空微任务队列 -> 执行下一个宏任务。

4. Promise和异步编程
Promise状态：pending、fulfilled、rejected。
特点：状态不可逆、支持链式调用、解决回调地狱。
async/await：Promise的语法糖，使异步代码更同步化。

二、Vue框架核心

1. Vue生命周期
创建阶段：beforeCreate -> created
挂载阶段：beforeMount -> mounted
更新阶段：beforeUpdate -> updated
销毁阶段：beforeDestroy -> destroyed
说明：created可访问数据但DOM未生成，mounted可访问DOM。

2. 响应式原理
Vue2：Object.defineProperty劫持数据getter/setter。
Vue3：Proxy代理整个对象，支持数组和动态属性。
流程：数据变化 -> 触发setter -> 通知依赖 -> 组件重新渲染 -> 更新DOM。

3. 虚拟DOM和Diff算法
虚拟DOM：用JavaScript对象描述真实DOM结构，减少直接操作DOM。
Diff算法：同层比较，通过key标识节点复用元素，时间复杂度O(n)。

三、浏览器核心

1. 渲染原理
流程：解析HTML生成DOM树 -> 解析CSS生成CSSOM树 -> 合并为渲染树 -> 布局计算位置 -> 绘制像素 -> 合成显示。

2. 重排和重绘
重排：布局发生变化（位置、大小），代价最高。
重绘：外观发生变化（颜色、背景），不改变布局。
触发重排的操作：添加/删除DOM元素、改变尺寸、改变窗口大小。
优化建议：用transform代替top/left，批量修改样式。

3. 跨域
定义：浏览器同源策略，协议、域名、端口任一不同即跨域。
解决方案：CORS（后端设置响应头）、代理（开发环境proxy）、JSONP（仅GET请求）、postMessage。

四、性能优化核心

1. 首屏优化
网络层：CDN加速、HTTP/2、Gzip压缩。
资源层：图片懒加载、路由懒加载、代码分割。
缓存层：强缓存、协商缓存。
渲染层：骨架屏、减少重排重绘。

2. 内存管理
常见内存泄漏：意外的全局变量、未清理的定时器、未解绑的DOM事件、闭包持有外部变量。
解决方法：严格模式、组件销毁时清理、手动解除引用。

五、常见面试题

1. 什么是闭包？有什么作用？
参考答案：闭包是指有权访问另一个函数作用域中变量的函数。作用包括封装私有变量、实现模块化、保存变量状态。

2. 什么是事件循环？宏任务和微任务有什么区别？
参考答案：事件循环是JavaScript处理异步任务的执行模型。宏任务包括setTimeout、I/O等，微任务包括Promise.then。每个宏任务执行后会先清空微任务队列。

3. Vue的生命周期有哪些？
参考答案：beforeCreate、created、beforeMount、mounted、beforeUpdate、updated、beforeDestroy、destroyed。

4. 如何优化首屏加载速度？
参考答案：CDN加速、路由懒加载、图片懒加载、代码分割、Gzip压缩、骨架屏。', '3d0760d71e0b5c0b3f6096cdad2f0a420df9b0653c8b0c66d3e09ae148cbaf0a', 1884, 1144, 1, 'admin', NULL, '2026-03-29 15:58:28.547', '2026-03-29 15:58:28.548', 0),
('2039212982331846657', '2038161065916784640', '2039212967563702272', 0, 'Java后端核心概念

一、Java基础

1. HashMap原理
HashMap基于哈希表实现，以键值对形式存储。通过put(key, value)存入，get(key)获取。当链表长度超过8且数组长度超过64时，链表转换为红黑树，提高查找效率。

扩容机制：
- 初始容量16，负载因子0.75
- 当元素个数 > 容量 × 负载因子时触发扩容
- 扩容为原容量的2倍，重新计算每个元素的位置

线程安全：
HashMap不是线程安全的，多线程环境下使用ConcurrentHashMap。

2. ConcurrentHashMap原理
ConcurrentHashMap是线程安全的HashMap实现。

JDK7实现：
- 采用分段锁（Segment），每个Segment独立加锁
- 默认16个Segment，支持16个线程并发写入

JDK8实现：
- 采用CAS + synchronized实现
- 锁粒度更细，只锁链表头节点
- 读操作不加锁，volatile保证可见性

3. JVM内存模型
内存结构：
- 程序计数器：当前线程执行的字节码行号
- 虚拟机栈：方法调用、局部变量、操作数栈
- 本地方法栈：本地方法调用
- 堆：对象实例、数组（线程共享）
- 方法区：类信息、常量、静态变量（线程共享）

堆内存划分：
- 新生代：Eden、Survivor0、Survivor1
- 老年代：存放长期存活的对象

4. 垃圾回收（GC）
判断对象是否存活：
- 可达性分析（GC Roots）

常见垃圾回收算法：
- 标记-清除：标记存活对象，清除未标记，产生内存碎片
- 复制算法：内存分为两块，存活对象复制到另一块，内存利用率低
- 标记-整理：标记存活对象，移动到一起，无碎片但移动开销大

分代收集：
- 新生代：复制算法（对象存活率低）
- 老年代：标记-清除或标记-整理（对象存活率高）

二、Spring框架

5. Spring IoC容器
IoC（控制反转）将对象的创建和管理交给Spring容器，而不是由程序员直接new。

依赖注入方式：
- 构造器注入：@Autowired public UserService(UserDao dao)
- Setter注入：@Autowired public void setUserDao(UserDao dao)
- 字段注入：@Autowired private UserDao userDao

Bean生命周期：
实例化 → 属性赋值 → 初始化 → 使用 → 销毁

6. Spring AOP
AOP（面向切面编程）将横切关注点（日志、事务、权限）从业务逻辑中分离。

核心术语：
- 切面（Aspect）：横切关注点的模块化
- 连接点（JoinPoint）：方法执行等可织入的点
- 通知（Advice）：切面执行的动作（前置、后置、环绕）
- 切入点（Pointcut）：匹配连接点的表达式

7. Spring Boot自动装配
Spring Boot通过@EnableAutoConfiguration注解开启自动装配，核心是META-INF/spring.factories文件中的配置类。

工作流程：
- 启动时扫描所有jar包下的spring.factories文件
- 加载配置类
- 根据@Conditional条件注解判断是否生效

三、数据库

8. MySQL索引
索引类型：
- B+树索引：InnoDB默认，适合范围查询
- 哈希索引：等值查询快，不支持范围
- 全文索引：文本搜索
- 空间索引：地理数据

InnoDB索引结构：
- 主键索引（聚簇索引）：叶子节点存储完整行数据
- 二级索引（辅助索引）：叶子节点存储主键值

索引优化原则：
- 区分度高的列优先
- 最左前缀匹配原则
- 避免在索引列上使用函数或计算

9. 事务隔离级别
事务特性（ACID）：
- 原子性（Atomicity）
- 一致性（Consistency）
- 隔离性（Isolation）
- 持久性（Durability）

隔离级别：
- READ UNCOMMITTED：存在脏读、不可重复读、幻读
- READ COMMITTED：存在不可重复读、幻读
- REPEATABLE READ：存在幻读（InnoDB已解决）
- SERIALIZABLE：全部解决，性能最低

四、缓存与中间件

10. Redis数据类型
- String：字符串，用于缓存、计数器
- Hash：哈希，用于对象存储
- List：列表，用于消息队列、最新列表
- Set：集合，用于去重、标签
- Sorted Set：有序集合，用于排行榜、延迟队列

11. 缓存穿透、击穿、雪崩
- 缓存穿透：查询不存在的数据，解决方案：布隆过滤器、缓存空值
- 缓存击穿：热点key过期，解决方案：互斥锁、永不过期
- 缓存雪崩：大量key同时过期，解决方案：过期时间加随机值、多级缓存

五、并发编程

12. 线程池
核心参数：
- corePoolSize：核心线程数
- maximumPoolSize：最大线程数
- keepAliveTime：非核心线程空闲存活时间
- workQueue：任务队列
- handler：拒绝策略

执行流程：
核心线程 → 任务队列 → 非核心线程 → 拒绝策略

13. synchronized和Lock
对比：
- synchronized是JVM层面实现，Lock是Java代码层面
- synchronized自动释放锁，Lock需要手动释放
- Lock支持可中断、公平锁、读写锁

六、设计模式

14. 单例模式（双重检查锁）
private static volatile Singleton instance;
private Singleton() {}
public static Singleton getInstance() {
    if (instance == null) {
        synchronized (Singleton.class) {
            if (instance == null) {
                instance = new Singleton();
            }
        }
    }
    return instance;
}

15. 代理模式
- JDK动态代理：实现接口，目标类有接口时使用
- CGLIB动态代理：继承目标类，目标类无接口时使用', 'aede2a86329153dfa8a1dc4f18dbbd3fa3d623d2b2653911bb7e5377aa6062a5', 2935, 1495, 1, 'admin', NULL, '2026-04-01 13:27:17.009', '2026-04-01 13:27:17.009', 0),
('2039213266344947713', '2038161065916784640', '2039213253741064192', 0, 'Java后端核心知识补充

一、Java基础进阶

1. String、StringBuilder、StringBuffer区别
- String：不可变，线程安全，性能最低，适用于字符串不经常变化的场景
- StringBuilder：可变，线程不安全，性能最高，适用于单线程字符串拼接
- StringBuffer：可变，线程安全，性能中等，适用于多线程字符串拼接

原理：String每次修改都会创建新对象，StringBuilder和StringBuffer在原有对象上修改。

2. ArrayList和LinkedList区别
- ArrayList底层是数组，随机访问O(1)，插入删除O(n)，内存连续
- LinkedList底层是双向链表，随机访问O(n)，插入删除O(1)，内存分散
- 适用场景：多查询少增删用ArrayList，多增删少查询用LinkedList

3. 异常体系
Throwable
├── Error（系统错误，不可处理）
│   ├── OutOfMemoryError
│   └── StackOverflowError
└── Exception
    ├── RuntimeException（非受检异常）
    │   ├── NullPointerException
    │   └── IndexOutOfBoundsException
    └── 受检异常（必须处理）
        ├── IOException
        └── SQLException

二、JVM进阶

4. 类加载机制
类加载过程：加载 → 验证 → 准备 → 解析 → 初始化 → 使用 → 卸载

类加载器：
- Bootstrap：加载rt.jar核心类库
- Extension：加载ext目录下的jar
- Application：加载classpath下的类

双亲委派机制：类加载请求先委派给父类加载器，父类无法加载才由子类加载，保证核心类库安全。

5. 垃圾回收器
- Serial：新生代，单线程，STW
- Parallel Scavenge：新生代，多线程，吞吐量优先
- CMS：老年代，并发收集，低延迟
- G1：整堆，分区回收，可预测停顿

三、多线程进阶

6. volatile关键字
作用：保证可见性、禁止指令重排序、不保证原子性
适用场景：状态标志位、双重检查锁的单例模式

7. ThreadLocal原理
原理：每个线程都有自己的ThreadLocalMap，存储线程局部变量
内存泄漏：key是弱引用，value是强引用，线程池场景需要手动remove()
使用场景：用户身份信息传递、数据库连接管理、事务管理

8. 锁升级过程（synchronized）
升级过程：无锁 → 偏向锁 → 轻量级锁 → 重量级锁
- 偏向锁：锁只被一个线程获取
- 轻量级锁：多线程交替执行，CAS自旋
- 重量级锁：多线程竞争激烈，阻塞等待

四、Spring进阶

9. Spring事务传播机制
- REQUIRED：支持当前事务，无则新建（默认）
- REQUIRES_NEW：新建事务，挂起当前事务
- SUPPORTS：支持当前事务，无则非事务执行
- NOT_SUPPORTED：非事务执行，挂起当前事务
- MANDATORY：必须存在事务，否则抛异常
- NEVER：必须非事务执行，否则抛异常
- NESTED：嵌套事务，独立提交/回滚

10. Spring循环依赖解决
三级缓存：
- 一级缓存：singletonObjects（完整对象）
- 二级缓存：earlySingletonObjects（早期对象）
- 三级缓存：singletonFactories（对象工厂）

解决原理：通过提前暴露ObjectFactory，在实例化后、属性赋值前将对象放入三级缓存
注意：构造器注入无法解决循环依赖

五、MySQL进阶

11. 联合索引最左前缀
示例：INDEX (a, b, c)
有效查询：WHERE a=1、WHERE a=1 AND b=2、WHERE a=1 AND b=2 AND c=3
无效查询：WHERE b=2（跳过了a）、WHERE c=3（跳过了a和b）

12. explain关键字段
- type：访问类型 const > eq_ref > ref > range > index > ALL
- key：实际使用的索引
- rows：预估扫描行数
- Extra：Using index（覆盖索引）、Using where、Using filesort（需优化）

13. MVCC原理
MVCC（多版本并发控制）：通过保存数据的历史版本，实现读写不阻塞
实现机制：
- 隐藏字段：DB_TRX_ID（事务ID）、DB_ROLL_PTR（回滚指针）
- ReadView：判断数据的可见性
- Undo Log：存储历史版本

六、Redis进阶

14. Redis持久化
- RDB：快照，恢复快、文件小，可能丢失数据
- AOF：追加命令，数据完整、文件大、恢复慢
- 混合持久化（Redis 4.0+）：结合RDB和AOF，兼顾恢复速度和数据完整性

15. Redis分布式锁
加锁：SET key value NX EX seconds
解锁：Lua脚本保证原子性
问题与解决：
- 锁过期业务未完成 → 看门狗自动续期
- 主从切换锁丢失 → 使用RedLock

七、消息队列

16. 消息可靠性保障
- 生产阶段：事务、确认机制
- 存储阶段：持久化、多副本
- 消费阶段：手动确认、幂等处理

17. 消息积压处理
原因：消费者处理能力不足、生产者突发流量
解决方案：临时增加消费者、优化消费逻辑、消息转移至临时队列

八、系统设计

18. 限流算法
- 计数器：固定窗口计数，简单，有临界问题
- 滑动窗口：细化窗口，更平滑
- 漏桶：匀速流出，平滑突发流量
- 令牌桶：匀速放入令牌，允许一定突发

19. 分布式ID生成
常见方案：
- UUID：无序，存储空间大
- 数据库自增：单点瓶颈
- Redis自增：依赖Redis
- 雪花算法：有序，趋势递增，依赖时钟

雪花算法结构：1位符号 + 41位时间戳 + 10位工作机器ID + 12位序列号

20. CAP理论
- C（一致性）：所有节点数据一致
- A（可用性）：请求总能得到响应
- P（分区容错性）：系统能容忍网络分区
- AP系统：保证可用性和分区容错性（如Eureka）
- CP系统：保证一致性和分区容错性（如ZooKeeper）

知识点汇总表

分类            核心知识点
Java基础        String、ArrayList、异常体系
JVM             类加载机制、垃圾回收器
多线程          volatile、ThreadLocal、锁升级
Spring          事务传播、循环依赖
MySQL           联合索引、explain、MVCC
Redis           持久化、分布式锁
消息队列        可靠性保障、消息积压
系统设计        限流算法、分布式ID、CAP', 'f3357b31f64eeb863e7810e2a068ed71e7a06099bc6e159f96328ab508dec1d6', 3225, 1668, 1, 'admin', NULL, '2026-04-01 13:28:24.404', '2026-04-01 13:28:24.404', 0),
('2039214383007084545', '2037157970269188096', '2039214362530492416', 0, 'Web前端核心知识补充

一、JavaScript进阶

1. this指向问题
- 普通函数调用：window / undefined（严格模式）
- 对象方法调用：调用该方法的对象
- 构造函数调用：新创建的实例
- call/apply/bind：指定的对象
- 箭头函数：定义时的外层作用域

箭头函数特点：
- 没有自己的this，继承外层作用域
- 不能作为构造函数
- 没有arguments对象

2. 深拷贝与浅拷贝
浅拷贝：只复制一层，引用类型共享
深拷贝：递归复制所有层级

实现方法：
- 浅拷贝：Object.assign()、扩展运算符 {...obj}
- 深拷贝：JSON.parse(JSON.stringify())（无法处理函数、undefined、循环引用）
- 深拷贝：structuredClone()（现代浏览器）、递归实现、lodash _.cloneDeep()

3. 防抖与节流
防抖：延迟执行，连续触发只执行最后一次
适用场景：搜索框输入、窗口resize

节流：固定时间间隔执行一次
适用场景：滚动加载、按钮点击

防抖实现：
function debounce(fn, delay) {
    let timer;
    return function(...args) {
        clearTimeout(timer);
        timer = setTimeout(() => fn.apply(this, args), delay);
    };
}

节流实现：
function throttle(fn, delay) {
    let lastTime = 0;
    return function(...args) {
        const now = Date.now();
        if (now - lastTime >= delay) {
            lastTime = now;
            fn.apply(this, args);
        }
    };
}

4. 数组常用方法
- map：映射生成新数组，不改变原数组
- filter：过滤元素，不改变原数组
- reduce：累加计算，不改变原数组
- forEach：遍历执行，不改变原数组
- find：查找第一个符合条件的元素
- some：是否有元素满足条件
- every：是否所有元素满足条件
- push/pop：末尾添加/删除，改变原数组
- shift/unshift：开头删除/添加，改变原数组
- splice：删除/替换元素，改变原数组
- sort：排序，改变原数组

二、ES6+核心特性

5. let / const 与 var 区别
- var：函数作用域、变量提升、允许重复声明、允许重新赋值
- let：块级作用域、暂时性死区、不允许重复声明、允许重新赋值
- const：块级作用域、暂时性死区、不允许重复声明、不允许重新赋值（引用类型可修改属性）

6. 解构赋值
数组解构：const [a, b, c] = [1, 2, 3]
对象解构：const { name, age } = { name: ''张三'', age: 18 }
函数参数解构：function fn({ name, age }) { ... }

7. 扩展运算符
- 数组展开：[...arr1, ...arr2]
- 对象展开：{...obj1, ...obj2}
- 函数参数：Math.max(...arr)
- 剩余参数：function(...args) {}

8. 模块化
- ES6：export default / export，导入用 import
- CommonJS：module.exports，导入用 require

三、Vue框架进阶

9. Vue组件通信方式
- props / emit：父子组件通信
- provide / inject：跨层级传递
- Vuex / Pinia：全局状态管理
- $refs：访问子组件实例
- $parent / $children：直接访问（不推荐）
- event bus：任意组件（已不推荐）

10. computed 和 watch 区别
- computed：有缓存，依赖变化才重新计算，不支持异步，适用于计算派生数据
- watch：无缓存，支持异步，适用于执行副作用（请求、DOM操作）

11. Vue Router核心
路由模式：
- hash：监听hashchange，无需后端配置
- history：利用HTML5 History API，需要后端支持

路由守卫：
- 全局守卫：beforeEach、afterEach
- 路由独享守卫：beforeEnter
- 组件内守卫：beforeRouteEnter、beforeRouteUpdate、beforeRouteLeave

12. Vuex / Pinia
- Vuex：单一状态树，actions处理异步，代码量较多
- Pinia：多store，类型提示强，代码简洁，Vue3推荐

四、React核心

13. React核心概念
- JSX：JavaScript语法扩展，描述UI
- 组件：函数组件 + Hooks / 类组件
- props：父组件传递数据
- state：组件内部状态
- 生命周期：componentDidMount、componentDidUpdate、componentWillUnmount

14. Hooks常用
- useState：管理状态
- useEffect：处理副作用（请求、DOM操作）
- useContext：消费Context
- useRef：获取DOM或保存变量
- useMemo：缓存计算结果
- useCallback：缓存函数

五、浏览器与网络

15. Cookie、localStorage、sessionStorage区别
- Cookie：4KB，可设置过期时间，自动携带到服务器，用于认证、会话
- localStorage：5-10MB，永久存储，不携带到服务器，用于长期存储
- sessionStorage：5-10MB，会话结束清除，不携带到服务器，用于临时存储

16. HTTP缓存
- 强缓存：Cache-Control、Expires，过期前不请求服务器
- 协商缓存：ETag、Last-Modified，向服务器验证资源是否过期

17. WebSocket
特点：全双工通信、持久连接、服务端可主动推送
适用场景：实时聊天、在线游戏、实时数据展示

六、工程化与构建工具

18. Webpack核心概念
- entry：入口文件
- output：输出配置
- loader：处理非JS文件（css、图片）
- plugin：扩展功能（压缩、热更新）
- mode：development / production

19. Vite特点
- 开发环境：原生ES模块，冷启动快
- 生产环境：Rollup打包
- 热更新：按需编译

七、常见面试题补充

20. 什么是跨域？如何解决？
跨域是浏览器同源策略导致的限制，协议、域名、端口任一不同即跨域。
解决方案：
- CORS：后端设置Access-Control-Allow-Origin
- 代理：开发环境配置proxy
- JSONP：仅支持GET请求
- postMessage：跨窗口通信

21. 什么是虚拟DOM？优缺点？
虚拟DOM是用JavaScript对象描述真实DOM结构。
优点：减少直接操作DOM、跨平台
缺点：首次渲染比直接操作DOM慢、占用内存

22. Vue和React的区别？
- 模板语法：Vue模板更接近HTML，React使用JSX
- 数据流：Vue双向绑定，React单向数据流
- 响应式：Vue自动追踪依赖，React需要setState

知识点汇总表

分类            核心知识点
JavaScript      this、深拷贝、防抖节流、数组方法
ES6+            let/const、解构、扩展运算符、模块化
Vue             生命周期、响应式、组件通信、computed/watch、Router、状态管理
React           组件、Hooks、生命周期
浏览器          存储、HTTP缓存、WebSocket、跨域
性能优化        首屏优化、内存管理
工程化          Webpack、Vite', '6c199bfc795b26c59f43feb7c2808457360adef179864aabc7d54d5be3e844b8', 3845, 1733, 1, 'admin', NULL, '2026-04-01 13:33:10.119', '2026-04-01 13:33:10.119', 0),
('2039216656022056961', '2039211164960894976', '2039216636333993984', 0, 'Python算法开发核心概念

一、Python基础进阶

1. Python可变与不可变类型
不可变类型：int、float、bool、complex、str、tuple
可变类型：list、dict、set
原理：不可变类型在内存中创建后不可修改，修改会创建新对象；可变类型在原内存上修改。

2. 深拷贝与浅拷贝
浅拷贝：只复制顶层，内部引用共享，适用对象结构简单
深拷贝：递归复制所有层级，适用对象结构复杂
import copy
list1 = [1, [2, 3]]
list2 = copy.copy(list1)      # 浅拷贝
list3 = copy.deepcopy(list1)  # 深拷贝

3. 列表推导式与生成器
列表推导式：一次性生成所有元素，占用内存，适用数据量小
生成器表达式：惰性计算，节省内存，适用数据量大
列表推导式：[x**2 for x in range(10)]
生成器表达式：(x**2 for x in range(10))

4. 装饰器
定义：在不修改原函数代码的情况下增加额外功能
应用场景：日志记录、性能计时、权限校验、缓存
def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        print(f"耗时: {time.time() - start}")
        return result
    return wrapper

5. 上下文管理器
with open(''file.txt'', ''r'') as f:
    content = f.read()
自定义上下文管理器：
class MyContext:
    def __enter__(self):
        print("进入")
        return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        print("退出")

二、数据结构与算法

6. 常见数据结构复杂度
列表：访问O(1)、查找O(n)、插入O(n)、删除O(n)
字典：访问O(1)、查找O(1)、插入O(1)、删除O(1)
集合：访问O(1)、查找O(1)、插入O(1)、删除O(1)
堆：访问O(1)、查找O(n)、插入O(log n)、删除O(log n)
队列：访问O(1)、查找O(n)、插入O(1)、删除O(1)

7. 排序算法对比
冒泡排序：最优O(n)、平均O(n²)、最差O(n²)、空间O(1)、稳定
快速排序：最优O(n log n)、平均O(n log n)、最差O(n²)、空间O(log n)、不稳定
归并排序：最优O(n log n)、平均O(n log n)、最差O(n log n)、空间O(n)、稳定
堆排序：最优O(n log n)、平均O(n log n)、最差O(n log n)、空间O(1)、不稳定
计数排序：最优O(n+k)、平均O(n+k)、最差O(n+k)、空间O(k)、稳定

8. 二分查找
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1
时间复杂度：O(log n)

9. 动态规划核心思想
核心：将大问题分解为重叠子问题，保存子问题结果避免重复计算
解题步骤：
- 定义状态（dp[i]表示什么）
- 找到状态转移方程
- 初始化边界条件
- 确定遍历顺序
经典问题：斐波那契数列、背包问题、最长递增子序列、编辑距离

三、NumPy核心

10. NumPy数组创建
import numpy as np
arr = np.array([1, 2, 3])           # 从列表创建
zeros = np.zeros((3, 4))            # 全0
ones = np.ones((3, 4))              # 全1
eye = np.eye(3)                     # 单位矩阵
arange = np.arange(0, 10, 2)        # 等差数列
linspace = np.linspace(0, 1, 5)     # 等间隔

11. 数组索引与切片
一维切片：arr[1:5]、arr[::2]
二维切片：arr[0, :]第一行、arr[:, 0]第一列、arr[1:3, 2:4]子矩阵
布尔索引：arr[arr > 5]

12. 广播机制
当两个数组形状不同时，NumPy自动扩展较小数组以匹配较大数组
arr + 10  # 每个元素加10
arr1 = np.array([[1,2,3], [4,5,6]])
arr2 = np.array([10,20,30])
result = arr1 + arr2  # arr2广播到每一行

13. 常用NumPy函数
np.sum：求和
np.mean：平均值
np.std：标准差
np.dot：点积
np.matmul：矩阵乘法
np.reshape：重塑形状
np.transpose：转置
np.concatenate：拼接

四、Pandas核心

14. Series和DataFrame
Series：一维带标签数组，pd.Series([1,2,3], index=[''a'',''b'',''c''])
DataFrame：二维表格，pd.DataFrame({''col1'': [1,2], ''col2'': [3,4]})

15. 数据选择与过滤
列选择：df[''col1'']、df[[''col1'', ''col2'']]
行选择：df.loc[''row1'']按标签、df.iloc[0]按位置
条件过滤：df[df[''col1''] > 10]、df[(df[''col1''] > 5) & (df[''col2''] < 20)]

16. 数据清洗常用操作
查看缺失值：df.isnull().sum()
删除缺失值：df.dropna()
填充缺失值：df.fillna(0)
删除重复：df.drop_duplicates()
数据类型转换：df[''col''].astype(''int'')

17. 分组与聚合
df.groupby(''category'')[''value''].mean()
df.groupby([''cat1'', ''cat2'']).agg({''col1'': ''sum'', ''col2'': ''mean''})
透视表：pd.pivot_table(df, values=''value'', index=''row'', columns=''col'', aggfunc=''mean'')

五、机器学习基础

18. 监督学习 vs 非监督学习
监督学习：有标签数据，算法包括线性回归、逻辑回归、决策树、SVM、随机森林
非监督学习：无标签数据，算法包括K-Means、PCA、聚类

19. 回归与分类
回归：预测连续值，算法包括线性回归、决策树回归
分类：预测离散类别，算法包括逻辑回归、KNN、SVM、随机森林

20. 模型评估指标
分类指标：
- 准确率 = (TP+TN)/(TP+TN+FP+FN)
- 精确率 = TP/(TP+FP)
- 召回率 = TP/(TP+FN)
- F1分数 = 2 * (精确率 * 召回率) / (精确率 + 召回率)
- AUC/ROC：模型分类能力
回归指标：
- MAE：平均绝对误差
- MSE：均方误差
- RMSE：均方根误差
- R²：决定系数

21. 过拟合与欠拟合
过拟合：训练集好，测试集差，解决方案包括增加数据、正则化、Dropout、早停、简化模型
欠拟合：训练集差，测试集差，解决方案包括增加特征、复杂模型、减少正则化

22. 正则化
L1正则化：权重绝对值之和，产生稀疏解，特征选择
L2正则化：权重平方和，防止权重过大，平滑

六、PyTorch核心

23. Tensor基础
import torch
x = torch.tensor([1, 2, 3])
x = torch.zeros(3, 4)
x = torch.randn(3, 4)  # 标准正态分布
x = torch.ones(3, 4)
设备迁移：device = torch.device(''cuda'' if torch.cuda.is_available() else ''cpu'')
x = x.to(device)

24. 自动求导
x = torch.tensor([2.0], requires_grad=True)
y = x ** 2 + 3 * x + 1
y.backward()
print(x.grad)  # 2*x + 3 = 7

25. 神经网络构建
import torch.nn as nn
class MyNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(784, 128)
        self.fc2 = nn.Linear(128, 10)
        self.relu = nn.ReLU()
    def forward(self, x):
        x = self.relu(self.fc1(x))
        x = self.fc2(x)
        return x

26. 训练流程
model = MyNet()
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
for epoch in range(num_epochs):
    for batch in dataloader:
        x, y = batch
        optimizer.zero_grad()
        output = model(x)
        loss = criterion(output, y)
        loss.backward()
        optimizer.step()

七、Scikit-learn核心

27. 标准流程
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)
model = RandomForestClassifier()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
score = model.score(X_test, y_test)

28. 交叉验证
from sklearn.model_selection import cross_val_score
scores = cross_val_score(model, X, y, cv=5)
print(f"平均得分: {scores.mean():.4f}")

29. 网格搜索调参
from sklearn.model_selection import GridSearchCV
param_grid = {
    ''n_estimators'': [50, 100, 200],
    ''max_depth'': [None, 10, 20]
}
grid_search = GridSearchCV(RandomForestClassifier(), param_grid, cv=5)
grid_search.fit(X_train, y_train)
print(grid_search.best_params_)

八、常见面试题

30. Python中列表和元组的区别？
列表可变，元组不可变；列表用方括号，元组用圆括号；列表占用内存更大，元组更轻量。

31. 什么是装饰器？有什么作用？
装饰器是一种设计模式，可以在不修改原函数代码的情况下增加额外功能。常用于日志记录、性能测试、权限校验、缓存等。

32. NumPy数组和Python列表有什么区别？
NumPy数组元素类型相同，列表可以不同；NumPy支持向量化运算，速度更快；NumPy内存连续，占用更小；NumPy提供丰富的数学函数。

33. Pandas中DataFrame和Series的区别？
Series是一维带标签数组，DataFrame是二维表格结构；DataFrame由多个Series组成；Series相当于一行或一列。

34. 什么是过拟合？如何防止过拟合？
过拟合是模型在训练集上表现好但测试集上表现差的现象。防止方法：增加数据量、正则化、Dropout、早停、数据增强、简化模型。

35. 什么是梯度消失和梯度爆炸？如何解决？
梯度消失：深层网络反向传播时梯度趋近于0；梯度爆炸：梯度变得非常大。解决方法：BatchNorm、残差连接、梯度裁剪、使用ReLU激活函数、合理初始化权重。

36. 如何处理数据不平衡问题？
数据层面：过采样（SMOTE）、欠采样；算法层面：调整类别权重、使用Focal Loss；评估指标：使用AUC、F1分数代替准确率。

37. 如何评估分类模型的好坏？
准确率、精确率、召回率、F1分数、ROC曲线、AUC值、混淆矩阵。不同场景关注不同指标。

知识点汇总表

分类            核心知识点
Python基础      可变/不可变、深拷贝/浅拷贝、装饰器、生成器、上下文管理器
数据结构        列表、字典、集合、堆、队列复杂度
算法            排序、二分查找、动态规划
NumPy           数组创建、索引切片、广播、常用函数
Pandas          Series/DataFrame、数据选择、数据清洗、分组聚合
机器学习        监督/非监督、回归/分类、评估指标、过拟合、正则化
PyTorch         Tensor、自动求导、神经网络构建、训练流程
Scikit-learn    数据划分、标准化、交叉验证、网格搜索', 'fbeed52700ac2235189918a97c116c4b8c88d94bfa60dbfe0603ad82bb8fea99', 6849, 2680, 1, 'admin', NULL, '2026-04-01 13:42:01.22', '2026-04-01 13:42:01.22', 0),
('2039216777090641921', '2039211164960894976', '2039216759277432832', 0, 'Python算法开发进阶知识点

一、算法复杂度进阶

1. 时间复杂度分析技巧
O(1)：常数时间，如数组索引、哈希表查找
O(log n)：分治，如二分查找、平衡树操作
O(n)：线性扫描，如遍历数组、链表
O(n log n)：分治排序，如快速排序、归并排序
O(n²)：双层循环，如冒泡排序、简单动态规划
O(2ⁿ)：指数级，如递归穷举、子集问题
O(n!)：阶乘，如全排列问题

2. 空间复杂度分析
O(1)：原地操作，如冒泡排序、双指针
O(n)：额外数组，如归并排序、哈希表缓存
O(n²)：二维矩阵，如动态规划表格

二、递归与分治

3. 递归三要素
- 终止条件：什么时候停止递归
- 递推公式：问题如何分解
- 返回值：每层递归返回什么

示例 - 斐波那契数列：
def fib(n):
    if n <= 1:
        return n
    return fib(n-1) + fib(n-2)

4. 分治算法框架
def divide_conquer(problem):
    if problem is trivial:
        return solve(problem)
    sub_problems = split(problem)
    sub_results = [divide_conquer(p) for p in sub_problems]
    return merge(sub_results)

三、动态规划进阶

5. 动态规划解题模板
def dp_solution(nums):
    n = len(nums)
    dp = [0] * n
    dp[0] = nums[0]
    for i in range(1, n):
        dp[i] = max(dp[i-1] + nums[i], nums[i])
    return max(dp)

6. 常见动态规划类型
线性DP：一维状态，如最长递增子序列、最大子数组和
区间DP：二维区间状态，如矩阵链乘、回文子串
背包DP：容量限制，如0-1背包、完全背包
状态压缩DP：位运算优化，如旅行商问题、集合覆盖
树形DP：树结构，如树的最大独立集、树的直径

7. 背包问题详解
0-1背包：dp[i][w] = max(dp[i-1][w], dp[i-1][w-wt[i]] + val[i])
完全背包：dp[w] = max(dp[w], dp[w-wt[i]] + val[i])
多重背包：二进制拆分优化

四、图论算法

8. 图的表示方式
邻接矩阵：稠密图，空间O(V²)
邻接表：稀疏图，空间O(V+E)
graph = {0: [1, 2], 1: [0, 3], 2: [0, 3], 3: [1, 2]}

9. 深度优先搜索（DFS）
def dfs(graph, start, visited=None):
    if visited is None:
        visited = set()
    visited.add(start)
    for neighbor in graph[start]:
        if neighbor not in visited:
            dfs(graph, neighbor, visited)
    return visited

应用：拓扑排序、连通分量、图的遍历

10. 广度优先搜索（BFS）
from collections import deque
def bfs(graph, start):
    visited = set([start])
    queue = deque([start])
    while queue:
        node = queue.popleft()
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    return visited

应用：最短路径、层级遍历、拓扑排序

11. 最短路径算法
Dijkstra：非负权图，复杂度O((V+E) log V)
Bellman-Ford：负权图，复杂度O(VE)
Floyd-Warshall：全源最短，复杂度O(V³)

Dijkstra算法实现：
import heapq
def dijkstra(graph, start):
    distances = {node: float(''inf'') for node in graph}
    distances[start] = 0
    pq = [(0, start)]
    while pq:
        dist, node = heapq.heappop(pq)
        if dist > distances[node]:
            continue
        for neighbor, weight in graph[node]:
            new_dist = dist + weight
            if new_dist < distances[neighbor]:
                distances[neighbor] = new_dist
                heapq.heappush(pq, (new_dist, neighbor))
    return distances

五、字符串算法

12. KMP字符串匹配
核心：利用部分匹配表，避免重复比较
def kmp(text, pattern):
    lps = [0] * len(pattern)
    for i in range(1, len(pattern)):
        j = lps[i-1]
        while j > 0 and pattern[i] != pattern[j]:
            j = lps[j-1]
        if pattern[i] == pattern[j]:
            j += 1
        lps[i] = j
    j = 0
    for i, ch in enumerate(text):
        while j > 0 and ch != pattern[j]:
            j = lps[j-1]
        if ch == pattern[j]:
            j += 1
        if j == len(pattern):
            return i - j + 1
    return -1

13. 常见字符串算法
KMP：字符串匹配，复杂度O(m+n)
Manacher：最长回文子串，复杂度O(n)
Trie树：前缀匹配，复杂度O(L)
AC自动机：多模式匹配，复杂度O(n)

六、树结构算法

14. 二叉树的遍历
前序遍历（根左右）：
def preorder(root):
    if not root: return
    print(root.val)
    preorder(root.left)
    preorder(root.right)

中序遍历（左根右）：
def inorder(root):
    if not root: return
    inorder(root.left)
    print(root.val)
    inorder(root.right)

后序遍历（左右根）：
def postorder(root):
    if not root: return
    postorder(root.left)
    postorder(root.right)
    print(root.val)

层序遍历（BFS）：
from collections import deque
def levelorder(root):
    if not root: return
    queue = deque([root])
    while queue:
        node = queue.popleft()
        print(node.val)
        if node.left: queue.append(node.left)
        if node.right: queue.append(node.right)

15. 二叉搜索树（BST）
操作：查找O(log n)、插入O(log n)、删除O(log n)
特点：左子树小于根，右子树大于根

16. 平衡二叉树
AVL树：严格平衡，高度差≤1，适用于查询频繁
红黑树：近似平衡，适用于插入删除频繁
B树：多路搜索树，适用于数据库索引

七、贪心算法

17. 贪心算法框架
def greedy(problems):
    problems.sort(key=lambda x: x.rule)
    result = []
    for p in problems:
        if can_choose(p):
            result.append(p)
            update_state(p)
    return result

经典问题：活动选择、区间调度、哈夫曼编码、最小生成树

八、位运算技巧

18. 常用位运算
判断奇偶：n & 1
乘除2：n << 1，n >> 1
交换两数：a ^= b; b ^= a; a ^= b
求绝对值：(n ^ (n >> 31)) - (n >> 31)
最低位1：n & -n

19. 状态压缩
枚举子集：
for mask in range(1 << n):
    for i in range(n):
        if mask >> i & 1:
            pass

子集枚举：
sub = mask
while sub:
    sub = (sub - 1) & mask

九、数学算法

20. 数论基础
最大公约数：
def gcd(a, b):
    return a if b == 0 else gcd(b, a % b)

最小公倍数：
def lcm(a, b):
    return a * b // gcd(a, b)

快速幂：
def fast_pow(a, n, mod):
    res = 1
    while n:
        if n & 1:
            res = res * a % mod
        a = a * a % mod
        n >>= 1
    return res

21. 素数判断
def is_prime(n):
    if n < 2: return False
    if n == 2: return True
    if n % 2 == 0: return False
    i = 3
    while i * i <= n:
        if n % i == 0:
            return False
        i += 2
    return True

十、高级数据结构

22. 并查集
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return
        if self.rank[rx] < self.rank[ry]:
            self.parent[rx] = ry
        elif self.rank[rx] > self.rank[ry]:
            self.parent[ry] = rx
        else:
            self.parent[ry] = rx
            self.rank[rx] += 1

23. 线段树
应用：区间查询、区间更新
class SegmentTree:
    def __init__(self, data):
        self.n = len(data)
        self.tree = [0] * (4 * self.n)
        self.build(data, 1, 0, self.n - 1)
    def build(self, data, node, left, right):
        if left == right:
            self.tree[node] = data[left]
            return
        mid = (left + right) // 2
        self.build(data, node*2, left, mid)
        self.build(data, node*2+1, mid+1, right)
        self.tree[node] = self.tree[node*2] + self.tree[node*2+1]
    def query(self, node, left, right, ql, qr):
        if ql > right or qr < left:
            return 0
        if ql <= left and right <= qr:
            return self.tree[node]
        mid = (left + right) // 2
        return self.query(node*2, left, mid, ql, qr) + \
               self.query(node*2+1, mid+1, right, ql, qr)

24. 树状数组（Fenwick Tree）
class FenwickTree:
    def __init__(self, n):
        self.n = n
        self.bit = [0] * (n + 1)
    def update(self, idx, delta):
        while idx <= self.n:
            self.bit[idx] += delta
            idx += idx & -idx
    def query(self, idx):
        res = 0
        while idx > 0:
            res += self.bit[idx]
            idx -= idx & -idx
        return res
    def range_query(self, left, right):
        return self.query(right) - self.query(left - 1)

十一、LeetCode经典题型

25. 题型分类
数组：两数之和、最大子序和，解题思路：双指针、前缀和
链表：反转链表、环形链表，解题思路：双指针、递归
二叉树：二叉树遍历、最近公共祖先，解题思路：DFS、BFS
动态规划：爬楼梯、打家劫舍，解题思路：状态定义、转移方程
回溯：全排列、子集，解题思路：递归、剪枝
贪心：跳跃游戏、分发饼干，解题思路：局部最优
滑动窗口：无重复字符的最长子串，解题思路：双指针、哈希表
二分查找：搜索旋转排序数组，解题思路：边界条件

十二、代码优化技巧

26. 常见优化方法
缓存结果：避免重复计算，如动态规划、记忆化搜索
剪枝：提前终止无效搜索，如回溯算法
双指针：减少循环嵌套，如两数之和、接雨水
预处理：提前计算，如前缀和、差分数组
位运算：加速计算，如状态压缩
空间换时间：用哈希表加速查找，如两数之和

27. Python性能优化
使用局部变量：减少全局变量查找
列表推导式：比循环快
使用集合：快速去重和查找
使用内置函数：map、filter、sum等
避免递归：递归有栈溢出风险
使用缓存装饰器：@lru_cache

知识点汇总表

分类                核心知识点
复杂度分析          时间/空间复杂度、分析技巧
递归与分治          递归三要素、分治框架
动态规划            解题模板、背包问题、常见类型
图论                DFS/BFS、最短路径、拓扑排序
字符串              KMP、Manacher、Trie树
树结构              二叉树遍历、BST、平衡树
贪心算法            算法框架、经典问题
位运算              常用技巧、状态压缩
数学算法            数论、快速幂、素数判断
高级数据结构        并查集、线段树、树状数组
题型分类            LeetCode经典题型
优化技巧            缓存、剪枝、双指针', 'a8d58a6e63f3d4dcf7206a9b85e8015193383481fce01a61729d1846b0709966', 8139, 2407, 1, 'admin', NULL, '2026-04-01 13:42:28.403', '2026-04-01 13:42:28.403', 0);
INSERT INTO "public"."t_knowledge_document_chunk_log" ("id", "doc_id", "status", "process_mode", "chunk_strategy", "pipeline_id", "extract_duration", "chunk_duration", "embedding_duration", "total_duration", "chunk_count", "error_message", "start_time", "end_time", "create_time", "update_time") VALUES
('2038163865727950848', '2038163842562809856', 'success', 'chunk', 'structure_aware', NULL, 173, 853, 26, 1056, 1, NULL, '2026-03-29 15:58:27.499', '2026-03-29 15:58:28.559', '2026-03-29 15:58:27.501', '2026-03-29 15:58:28.561'),
('2039212981971136512', '2039212967563702272', 'success', 'chunk', 'structure_aware', NULL, 78, 602, 35, 722, 1, NULL, '2026-04-01 13:27:16.303', '2026-04-01 13:27:17.027', '2026-04-01 13:27:16.304', '2026-04-01 13:27:17.028'),
('2039213266261061632', '2039213253741064192', 'success', 'chunk', 'structure_aware', NULL, 19, 297, 9, 326, 1, NULL, '2026-04-01 13:28:24.084', '2026-04-01 13:28:24.41', '2026-04-01 13:28:24.084', '2026-04-01 13:28:24.41'),
('2039214382948364288', '2039214362530492416', 'success', 'chunk', 'structure_aware', NULL, 13, 19780, 15, 19808, 1, NULL, '2026-04-01 13:32:50.323', '2026-04-01 13:33:10.132', '2026-04-01 13:32:50.323', '2026-04-01 13:33:10.132'),
('2039216655933976576', '2039216636333993984', 'success', 'chunk', 'structure_aware', NULL, 19, 8951, 14, 8985, 1, NULL, '2026-04-01 13:41:52.245', '2026-04-01 13:42:01.231', '2026-04-01 13:41:52.246', '2026-04-01 13:42:01.231'),
('2039216777031921664', '2039216759277432832', 'success', 'chunk', 'structure_aware', NULL, 13, 7269, 5, 7287, 1, NULL, '2026-04-01 13:42:21.117', '2026-04-01 13:42:28.405', '2026-04-01 13:42:21.117', '2026-04-01 13:42:28.406');



INSERT INTO "public"."t_query_term_mapping" ("id", "domain", "source_term", "target_term", "match_type", "priority", "enabled", "remark", "create_by", "update_by", "create_time", "update_time", "deleted") VALUES
('2037161714318848000', NULL, 'web', 'web', 1, 1, 1, NULL, NULL, NULL, '2026-03-26 21:36:15.986278', '2026-03-26 21:36:15.986278', 0);
INSERT INTO "public"."t_rag_trace_run" ("id", "trace_id", "trace_name", "entry_method", "conversation_id", "task_id", "user_id", "status", "error_message", "start_time", "end_time", "duration_ms", "extra_data", "create_time", "update_time", "deleted") VALUES
('2036458459448217600', '2036458459313999872', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2036458457137156096', '2036458459313999873', '2001523723396308993', 'SUCCESS', NULL, '2026-03-24 23:01:46.931', '2026-03-24 23:01:52.433', 5507, '{"questionLength":4}', '2026-03-24 23:01:46.964', '2026-03-24 23:01:52.437', 0),
('2036460691702943744', '2036460691698749440', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2036458457137156096', '2036460691698749441', '2001523723396308993', 'SUCCESS', NULL, '2026-03-24 23:10:39.168', '2026-03-24 23:10:41.501', 2333, '{"questionLength":3}', '2026-03-24 23:10:39.169', '2026-03-24 23:10:41.501', 0),
('2037125581253910528', '2037125581224550400', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2037125580805120000', '2037125581224550401', '2001523723396308993', 'SUCCESS', NULL, '2026-03-26 19:12:41.185', '2026-03-26 19:12:46.664', 5480, '{"questionLength":3}', '2026-03-26 19:12:41.195', '2026-03-26 19:12:46.667', 0),
('2037159068807737344', '2037159068803543040', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2037159068648353792', '2037159068803543041', '2001523723396308993', 'SUCCESS', NULL, '2026-03-26 21:25:45.245', '2026-03-26 21:25:56.459', 11214, '{"questionLength":11}', '2026-03-26 21:25:45.246', '2026-03-26 21:25:56.46', 0),
('2037159151192256514', '2037159151192256512', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2037159068648353792', '2037159151192256513', '2001523723396308993', 'SUCCESS', NULL, '2026-03-26 21:26:04.888', '2026-03-26 21:26:15.009', 10121, '{"questionLength":5}', '2026-03-26 21:26:04.888', '2026-03-26 21:26:15.009', 0),
('2037160207326392322', '2037160207326392320', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2037160207305420800', '2037160207326392321', '2001523723396308993', 'SUCCESS', NULL, '2026-03-26 21:30:16.69', '2026-03-26 21:30:20.548', 3858, '{"questionLength":5}', '2026-03-26 21:30:16.69', '2026-03-26 21:30:20.548', 0),
('2038119851129589760', '2038119851112812544', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038119850693382144', '2038119851112812545', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 13:03:33.598', '2026-03-29 13:03:41.246', 7648, '{"questionLength":11}', '2026-03-29 13:03:33.602', '2026-03-29 13:03:41.249', 0),
('2038120668796571650', '2038120668796571648', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038120668758822912', '2038120668796571649', '2038120540551532544', 'SUCCESS', NULL, '2026-03-29 13:06:48.549', '2026-03-29 13:07:00.75', 12201, '{"questionLength":5}', '2026-03-29 13:06:48.549', '2026-03-29 13:07:00.751', 0),
('2038164091989680128', '2038164091968708608', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038164091968708609', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 15:59:21.44', '2026-03-29 15:59:26.105', 4665, '{"questionLength":11}', '2026-03-29 15:59:21.445', '2026-03-29 15:59:26.108', 0),
('2038164636435505152', '2038164636431310848', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038164636431310849', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 16:01:31.25', '2026-03-29 16:01:38.755', 7505, '{"questionLength":19}', '2026-03-29 16:01:31.251', '2026-03-29 16:01:38.756', 0),
('2038164801800134658', '2038164801800134656', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038164801800134657', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 16:02:10.677', '2026-03-29 16:02:22.465', 11788, '{"questionLength":160}', '2026-03-29 16:02:10.677', '2026-03-29 16:02:22.465', 0),
('2038165064392925186', '2038165064392925184', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038165064392925185', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 16:03:13.284', '2026-03-29 16:03:20.861', 7577, '{"questionLength":33}', '2026-03-29 16:03:13.284', '2026-03-29 16:03:20.861', 0),
('2038165268659724290', '2038165268659724288', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038165268659724289', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 16:04:01.985', '2026-03-29 16:04:08.096', 6111, '{"questionLength":103}', '2026-03-29 16:04:01.985', '2026-03-29 16:04:08.096', 0),
('2038165455692128258', '2038165455692128256', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038165455692128257', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 16:04:46.577', '2026-03-29 16:04:52.723', 6146, '{"questionLength":23}', '2026-03-29 16:04:46.577', '2026-03-29 16:04:52.723', 0),
('2038165542275145730', '2038165542275145728', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038165542275145729', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 16:05:07.22', '2026-03-29 16:05:10.596', 3376, '{"questionLength":7}', '2026-03-29 16:05:07.22', '2026-03-29 16:05:10.596', 0),
('2038165783665729536', '2038165783661535232', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038165783661535233', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 16:06:04.771', '2026-03-29 16:06:14.531', 9760, '{"questionLength":6}', '2026-03-29 16:06:04.772', '2026-03-29 16:06:14.531', 0),
('2038216418889064448', '2038216418876481536', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2038164091557666816', '2038216418876481537', '2001523723396308993', 'SUCCESS', NULL, '2026-03-29 19:27:17.147', '2026-03-29 19:27:29.831', 12684, '{"questionLength":16}', '2026-03-29 19:27:17.15', '2026-03-29 19:27:29.832', 0),
('2039001572163235840', '2039001572154847232', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039001571890606080', '2039001572154847233', '2001523723396308993', 'SUCCESS', NULL, '2026-03-31 23:27:12.276', '2026-03-31 23:27:27.928', 15652, '{"questionLength":11}', '2026-03-31 23:27:12.28', '2026-03-31 23:27:27.931', 0),
('2039001771052937218', '2039001771052937216', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039001771002605568', '2039001771052937217', '2001523723396308993', 'SUCCESS', NULL, '2026-03-31 23:27:59.697', '2026-03-31 23:28:03.619', 3922, '{"questionLength":14}', '2026-03-31 23:27:59.697', '2026-03-31 23:28:03.62', 0),
('2039007653539135488', '2039007653501386752', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039007653157453824', '2039007653501386753', '2001523723396308993', 'SUCCESS', NULL, '2026-03-31 23:51:22.183', '2026-03-31 23:51:34.043', 11861, '{"questionLength":11}', '2026-03-31 23:51:22.195', '2026-03-31 23:51:34.047', 0),
('2039007871626166274', '2039007871626166272', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039007653157453824', '2039007871626166273', '2001523723396308993', 'SUCCESS', NULL, '2026-03-31 23:52:14.187', '2026-03-31 23:52:17.305', 3118, '{"questionLength":4}', '2026-03-31 23:52:14.187', '2026-03-31 23:52:17.306', 0),
('2039008017998987266', '2039008017998987264', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039007653157453824', '2039008017998987265', '2001523723396308993', 'SUCCESS', NULL, '2026-03-31 23:52:49.085', '2026-03-31 23:52:52.649', 3564, '{"questionLength":13}', '2026-03-31 23:52:49.085', '2026-03-31 23:52:52.649', 0),
('2039009706688696320', '2039009706663530496', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039009706298626048', '2039009706663530497', '2001523723396308993', 'SUCCESS', NULL, '2026-03-31 23:59:31.694', '2026-03-31 23:59:36.22', 4526, '{"questionLength":11}', '2026-03-31 23:59:31.702', '2026-03-31 23:59:36.222', 0),
('2039009903338639362', '2039009903338639360', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039009706298626048', '2039009903338639361', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:00:18.585', '2026-04-01 00:00:21.895', 3310, '{"questionLength":14}', '2026-04-01 00:00:18.585', '2026-04-01 00:00:21.895', 0),
('2039012327512137728', '2039012327486971904', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039012327168204800', '2039012327486971905', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:09:56.548', '2026-04-01 00:10:02.6', 6053, '{"questionLength":11}', '2026-04-01 00:09:56.557', '2026-04-01 00:10:02.603', 0),
('2039012417106665474', '2039012417106665472', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039012327168204800', '2039012417106665473', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:10:17.914', '2026-04-01 00:10:20.967', 3053, '{"questionLength":8}', '2026-04-01 00:10:17.914', '2026-04-01 00:10:20.968', 0),
('2039012603522506754', '2039012603522506752', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039012603480563712', '2039012603522506753', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:11:02.359', '2026-04-01 00:11:07.274', 4915, '{"questionLength":5}', '2026-04-01 00:11:02.359', '2026-04-01 00:11:07.275', 0),
('2039015015108898816', '2039015015079538688', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039015014785937408', '2039015015079538689', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:20:37.319', '2026-04-01 00:20:41.632', 4313, '{"questionLength":14}', '2026-04-01 00:20:37.327', '2026-04-01 00:20:41.634', 0),
('2039019351146823680', '2039019351130046464', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039019350727393280', '2039019351130046465', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:37:51.114', '2026-04-01 00:37:54.8', 3686, '{"questionLength":14}', '2026-04-01 00:37:51.119', '2026-04-01 00:37:54.804', 0),
('2039019439176876032', '2039019439172681728', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039019350727393280', '2039019439172681729', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:38:12.105', '2026-04-01 00:38:14.848', 2743, '{"questionLength":8}', '2026-04-01 00:38:12.106', '2026-04-01 00:38:14.848', 0),
('2039020739956379648', '2039020739927019520', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039020739620835328', '2039020739927019521', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 00:43:22.229', '2026-04-01 00:43:26.949', 4720, '{"questionLength":15}', '2026-04-01 00:43:22.239', '2026-04-01 00:43:26.95', 0),
('2039205334244990976', '2039205334203047936', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039205333884280832', '2039205334203047937', '2038120540551532544', 'SUCCESS', NULL, '2026-04-01 12:56:52.935', '2026-04-01 12:56:56.971', 4037, '{"questionLength":14}', '2026-04-01 12:56:52.951', '2026-04-01 12:56:56.974', 0),
('2039209159328608256', '2039209159299248128', 'rag-stream-chat', 'com.nageoffer.ai.ragent.rag.service.impl.RAGChatServiceImpl#streamChat', '2039209159001452544', '2039209159299248129', '2001523723396308993', 'SUCCESS', NULL, '2026-04-01 13:12:04.909', '2026-04-01 13:12:08.946', 4038, '{"questionLength":14}', '2026-04-01 13:12:04.917', '2026-04-01 13:12:08.948', 0);
INSERT INTO "public"."t_rag_trace_node" ("id", "trace_id", "node_id", "parent_node_id", "depth", "node_type", "node_name", "class_name", "method_name", "status", "error_message", "start_time", "end_time", "duration_ms", "extra_data", "create_time", "update_time", "deleted") VALUES
('2036458461360820224', '2036458459313999872', '2036458461331460096', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-24 23:01:47.407', '2026-03-24 23:01:50.097', 2690, NULL, '2026-03-24 23:01:47.414', '2026-03-24 23:01:50.097', 0),
('2036458461461483520', '2036458459313999872', '2036458461453094912', '2036458461331460096', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-24 23:01:47.436', '2026-03-24 23:01:50.066', 2630, NULL, '2026-03-24 23:01:47.438', '2026-03-24 23:01:50.085', 0),
('2036458472647692289', '2036458459313999872', '2036458472647692288', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-24 23:01:50.105', '2026-03-24 23:01:51.351', 1246, NULL, '2026-03-24 23:01:50.105', '2026-03-24 23:01:51.352', 0),
('2036458472664469505', '2036458459313999872', '2036458472664469504', '2036458472647692288', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-24 23:01:50.109', '2026-03-24 23:01:51.346', 1237, NULL, '2026-03-24 23:01:50.109', '2026-03-24 23:01:51.347', 0),
('2036458472668663809', '2036458459313999872', '2036458472668663808', '2036458472664469504', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-24 23:01:50.11', '2026-03-24 23:01:51.344', 1234, NULL, '2026-03-24 23:01:50.11', '2026-03-24 23:01:51.345', 0),
('2036458477898960896', '2036458459313999872', '2036458477886377984', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-24 23:01:51.354', '2026-03-24 23:01:52.351', 997, NULL, '2026-03-24 23:01:51.357', '2026-03-24 23:01:52.352', 0),
('2036458477957681153', '2036458459313999872', '2036458477957681152', '2036458477886377984', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-24 23:01:51.371', '2026-03-24 23:01:52.323', 952, NULL, '2026-03-24 23:01:51.371', '2026-03-24 23:01:52.324', 0),
('2036458477966069760', '2036458459313999872', '2036458477961875456', '2036458477957681152', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-24 23:01:51.372', '2026-03-24 23:01:52.321', 949, NULL, '2026-03-24 23:01:51.373', '2026-03-24 23:01:52.321', 0),
('2036458482101653505', '2036458459313999872', '2036458482101653504', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-24 23:01:52.359', '2026-03-24 23:01:52.402', 43, NULL, '2026-03-24 23:01:52.359', '2026-03-24 23:01:52.402', 0),
('2036458482151985152', '2036458459313999872', '2036458482147790848', '2036458482101653504', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-24 23:01:52.37', '2026-03-24 23:01:52.398', 28, NULL, '2026-03-24 23:01:52.371', '2026-03-24 23:01:52.4', 0),
('2036460691866521600', '2036460691698749440', '2036460691862327296', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-24 23:10:39.207', '2026-03-24 23:10:40.719', 1512, NULL, '2026-03-24 23:10:39.208', '2026-03-24 23:10:40.719', 0),
('2036460691874910208', '2036460691698749440', '2036460691870715904', '2036460691862327296', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-24 23:10:39.209', '2026-03-24 23:10:40.718', 1509, NULL, '2026-03-24 23:10:39.21', '2026-03-24 23:10:40.718', 0),
('2036460691883298816', '2036460691698749440', '2036460691879104512', '2036460691870715904', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-24 23:10:39.211', '2026-03-24 23:10:40.715', 1504, NULL, '2026-03-24 23:10:39.212', '2026-03-24 23:10:40.715', 0),
('2036460698212503553', '2036460691698749440', '2036460698212503552', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-24 23:10:40.721', '2026-03-24 23:10:41.479', 758, NULL, '2026-03-24 23:10:40.721', '2026-03-24 23:10:41.48', 0),
('2036460698233475072', '2036460691698749440', '2036460698229280768', '2036460698212503552', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-24 23:10:40.725', '2026-03-24 23:10:41.478', 753, NULL, '2026-03-24 23:10:40.726', '2026-03-24 23:10:41.478', 0),
('2036460698237669376', '2036460691698749440', '2036460698233475073', '2036460698229280768', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-24 23:10:40.726', '2026-03-24 23:10:41.475', 749, NULL, '2026-03-24 23:10:40.727', '2026-03-24 23:10:41.476', 0),
('2036460701400174592', '2036460691698749440', '2036460701395980288', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-24 23:10:41.48', '2026-03-24 23:10:41.49', 10, NULL, '2026-03-24 23:10:41.481', '2026-03-24 23:10:41.491', 0),
('2036460701408563201', '2036460691698749440', '2036460701408563200', '2036460701395980288', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-24 23:10:41.483', '2026-03-24 23:10:41.489', 6, NULL, '2026-03-24 23:10:41.483', '2026-03-24 23:10:41.49', 0),
('2037125581740449792', '2037125581224550400', '2037125581736255488', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 19:12:41.306', '2026-03-26 19:12:43.029', 1723, NULL, '2026-03-26 19:12:41.308', '2026-03-26 19:12:43.03', 0),
('2037125581769809920', '2037125581224550400', '2037125581765615616', '2037125581736255488', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 19:12:41.313', '2026-03-26 19:12:43.013', 1700, NULL, '2026-03-26 19:12:41.314', '2026-03-26 19:12:43.024', 0),
('2037125588992401408', '2037125581224550400', '2037125588988207104', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-26 19:12:43.035', '2026-03-26 19:12:45.197', 2162, NULL, '2026-03-26 19:12:43.036', '2026-03-26 19:12:45.2', 0),
('2037125589004984320', '2037125581224550400', '2037125589000790016', '2037125588988207104', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 19:12:43.038', '2026-03-26 19:12:45.19', 2152, NULL, '2026-03-26 19:12:43.039', '2026-03-26 19:12:45.191', 0),
('2037125589013372929', '2037125581224550400', '2037125589013372928', '2037125589000790016', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 19:12:43.041', '2026-03-26 19:12:45.185', 2144, NULL, '2026-03-26 19:12:43.041', '2026-03-26 19:12:45.187', 0),
('2037125598077263872', '2037125581224550400', '2037125598073069568', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-26 19:12:45.201', '2026-03-26 19:12:46.607', 1406, NULL, '2026-03-26 19:12:45.203', '2026-03-26 19:12:46.607', 0),
('2037125598123401216', '2037125581224550400', '2037125598119206912', '2037125598073069568', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 19:12:45.212', '2026-03-26 19:12:46.581', 1369, NULL, '2026-03-26 19:12:45.213', '2026-03-26 19:12:46.582', 0),
('2037125598140178432', '2037125581224550400', '2037125598131789824', '2037125598119206912', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 19:12:45.215', '2026-03-26 19:12:46.576', 1361, NULL, '2026-03-26 19:12:45.217', '2026-03-26 19:12:46.577', 0),
('2037125603982843905', '2037125581224550400', '2037125603982843904', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-26 19:12:46.61', '2026-03-26 19:12:46.643', 33, NULL, '2026-03-26 19:12:46.61', '2026-03-26 19:12:46.644', 0),
('2037125604028981248', '2037125581224550400', '2037125604024786944', '2037125603982843904', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-26 19:12:46.62', '2026-03-26 19:12:46.639', 19, NULL, '2026-03-26 19:12:46.621', '2026-03-26 19:12:46.64', 0),
('2037159068967120896', '2037159068803543040', '2037159068962926592', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:25:45.283', '2026-03-26 21:25:53.523', 8240, NULL, '2026-03-26 21:25:45.284', '2026-03-26 21:25:53.525', 0),
('2037159068983898113', '2037159068803543040', '2037159068983898112', '2037159068962926592', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:25:45.288', '2026-03-26 21:25:53.515', 8227, NULL, '2026-03-26 21:25:45.288', '2026-03-26 21:25:53.521', 0),
('2037159103540768769', '2037159068803543040', '2037159103540768768', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-26 21:25:53.527', '2026-03-26 21:25:55.069', 1542, NULL, '2026-03-26 21:25:53.527', '2026-03-26 21:25:55.07', 0),
('2037159103544963073', '2037159068803543040', '2037159103544963072', '2037159103540768768', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:25:53.528', '2026-03-26 21:25:55.067', 1539, NULL, '2026-03-26 21:25:53.528', '2026-03-26 21:25:55.067', 0),
('2037159103549157376', '2037159068803543040', '2037159103544963074', '2037159103544963072', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:25:53.528', '2026-03-26 21:25:55.063', 1535, NULL, '2026-03-26 21:25:53.529', '2026-03-26 21:25:55.064', 0),
('2037159110016774145', '2037159068803543040', '2037159110016774144', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-26 21:25:55.071', '2026-03-26 21:25:55.955', 884, NULL, '2026-03-26 21:25:55.071', '2026-03-26 21:25:55.957', 0),
('2037159110037745665', '2037159068803543040', '2037159110037745664', '2037159110016774144', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:25:55.076', '2026-03-26 21:25:55.947', 871, NULL, '2026-03-26 21:25:55.076', '2026-03-26 21:25:55.947', 0),
('2037159110037745667', '2037159068803543040', '2037159110037745666', '2037159110037745664', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:25:55.076', '2026-03-26 21:25:55.935', 859, NULL, '2026-03-26 21:25:55.076', '2026-03-26 21:25:55.936', 0),
('2037159113737121793', '2037159068803543040', '2037159113737121792', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-26 21:25:55.958', '2026-03-26 21:25:56.449', 491, NULL, '2026-03-26 21:25:55.958', '2026-03-26 21:25:56.449', 0),
('2037159113749704705', '2037159068803543040', '2037159113749704704', '2037159113737121792', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-26 21:25:55.961', '2026-03-26 21:25:56.446', 485, NULL, '2026-03-26 21:25:55.961', '2026-03-26 21:25:56.446', 0),
('2037159151238393857', '2037159151192256512', '2037159151238393856', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-26 21:26:04.899', '2026-03-26 21:26:08.941', 4042, NULL, '2026-03-26 21:26:04.899', '2026-03-26 21:26:08.941', 0),
('2037159151246782465', '2037159151192256512', '2037159151246782464', '2037159151238393856', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:26:04.901', '2026-03-26 21:26:08.939', 4038, NULL, '2026-03-26 21:26:04.901', '2026-03-26 21:26:08.94', 0),
('2037159151250976768', '2037159151192256512', '2037159151246782466', '2037159151246782464', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:26:04.901', '2026-03-26 21:26:08.937', 4036, NULL, '2026-03-26 21:26:04.902', '2026-03-26 21:26:08.938', 0),
('2037159168195964929', '2037159151192256512', '2037159168195964928', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-26 21:26:08.942', '2026-03-26 21:26:14.831', 5889, NULL, '2026-03-26 21:26:08.942', '2026-03-26 21:26:14.831', 0),
('2037159168204353537', '2037159151192256512', '2037159168204353536', '2037159168195964928', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:26:08.944', '2026-03-26 21:26:14.83', 5886, NULL, '2026-03-26 21:26:08.944', '2026-03-26 21:26:14.83', 0),
('2037159168208547841', '2037159151192256512', '2037159168208547840', '2037159168204353536', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:26:08.945', '2026-03-26 21:26:14.826', 5881, NULL, '2026-03-26 21:26:08.945', '2026-03-26 21:26:14.827', 0),
('2037159192904609793', '2037159151192256512', '2037159192904609792', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-26 21:26:14.833', '2026-03-26 21:26:15.004', 171, NULL, '2026-03-26 21:26:14.833', '2026-03-26 21:26:15.004', 0),
('2037159192908804097', '2037159151192256512', '2037159192908804096', '2037159192904609792', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-26 21:26:14.834', '2026-03-26 21:26:15.002', 168, NULL, '2026-03-26 21:26:14.834', '2026-03-26 21:26:15.003', 0),
('2037160207359946753', '2037160207326392320', '2037160207359946752', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:30:16.698', '2026-03-26 21:30:17.366', 668, NULL, '2026-03-26 21:30:16.698', '2026-03-26 21:30:17.367', 0),
('2037160207364141056', '2037160207326392320', '2037160207359946754', '2037160207359946752', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:30:16.698', '2026-03-26 21:30:17.364', 666, NULL, '2026-03-26 21:30:16.699', '2026-03-26 21:30:17.365', 0),
('2037160210174324736', '2037160207326392320', '2037160210170130433', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-26 21:30:17.368', '2026-03-26 21:30:19.289', 1921, NULL, '2026-03-26 21:30:17.369', '2026-03-26 21:30:19.289', 0),
('2037160210178519041', '2037160207326392320', '2037160210178519040', '2037160210170130433', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:30:17.37', '2026-03-26 21:30:19.288', 1918, NULL, '2026-03-26 21:30:17.37', '2026-03-26 21:30:19.288', 0),
('2037160210182713345', '2037160207326392320', '2037160210182713344', '2037160210178519040', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:30:17.371', '2026-03-26 21:30:19.288', 1917, NULL, '2026-03-26 21:30:17.371', '2026-03-26 21:30:19.288', 0),
('2037160218227388417', '2037160207326392320', '2037160218227388416', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-26 21:30:19.289', '2026-03-26 21:30:20.456', 1167, NULL, '2026-03-26 21:30:19.289', '2026-03-26 21:30:20.457', 0),
('2037160218244165633', '2037160207326392320', '2037160218244165632', '2037160218227388416', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-26 21:30:19.293', '2026-03-26 21:30:20.454', 1161, NULL, '2026-03-26 21:30:19.293', '2026-03-26 21:30:20.454', 0),
('2037160218248359937', '2037160207326392320', '2037160218248359936', '2037160218244165632', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-26 21:30:19.294', '2026-03-26 21:30:20.452', 1158, NULL, '2026-03-26 21:30:19.294', '2026-03-26 21:30:20.452', 0),
('2037160223126335489', '2037160207326392320', '2037160223126335488', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-26 21:30:20.457', '2026-03-26 21:30:20.543', 86, NULL, '2026-03-26 21:30:20.458', '2026-03-26 21:30:20.544', 0),
('2037160223130529793', '2037160207326392320', '2037160223130529792', '2037160223126335488', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-26 21:30:20.458', '2026-03-26 21:30:20.542', 84, NULL, '2026-03-26 21:30:20.458', '2026-03-26 21:30:20.542', 0),
('2038119851393830912', '2038119851112812544', '2038119851389636608', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 13:03:33.664', '2026-03-29 13:03:35.127', 1463, NULL, '2026-03-29 13:03:33.665', '2026-03-29 13:03:35.128', 0),
('2038119851414802432', '2038119851112812544', '2038119851410608128', '2038119851389636608', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 13:03:33.669', '2026-03-29 13:03:35.121', 1452, NULL, '2026-03-29 13:03:33.67', '2026-03-29 13:03:35.124', 0),
('2038119857542680577', '2038119851112812544', '2038119857542680576', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 13:03:35.131', '2026-03-29 13:03:36.988', 1857, NULL, '2026-03-29 13:03:35.131', '2026-03-29 13:03:36.989', 0),
('2038119857555263489', '2038119851112812544', '2038119857555263488', '2038119857542680576', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 13:03:35.134', '2026-03-29 13:03:36.986', 1852, NULL, '2026-03-29 13:03:35.134', '2026-03-29 13:03:36.986', 0),
('2038119857559457793', '2038119851112812544', '2038119857559457792', '2038119857555263488', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 13:03:35.135', '2026-03-29 13:03:36.982', 1847, NULL, '2026-03-29 13:03:35.135', '2026-03-29 13:03:36.983', 0),
('2038119865339891712', '2038119851112812544', '2038119865335697408', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 13:03:36.989', '2026-03-29 13:03:39.476', 2487, NULL, '2026-03-29 13:03:36.99', '2026-03-29 13:03:39.477', 0),
('2038119865373446144', '2038119851112812544', '2038119865369251840', '2038119865335697408', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 13:03:36.997', '2026-03-29 13:03:39.455', 2458, NULL, '2026-03-29 13:03:36.998', '2026-03-29 13:03:39.455', 0),
('2038119865377640449', '2038119851112812544', '2038119865377640448', '2038119865369251840', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 13:03:36.999', '2026-03-29 13:03:39.444', 2445, NULL, '2026-03-29 13:03:36.999', '2026-03-29 13:03:39.445', 0),
('2038119875783708673', '2038119851112812544', '2038119875783708672', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 13:03:39.48', '2026-03-29 13:03:40.494', 1014, NULL, '2026-03-29 13:03:39.48', '2026-03-29 13:03:40.495', 0),
('2038119875808874496', '2038119851112812544', '2038119875804680192', '2038119875783708672', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 13:03:39.485', '2026-03-29 13:03:40.491', 1006, NULL, '2026-03-29 13:03:39.486', '2026-03-29 13:03:40.492', 0),
('2038119880074481664', '2038119851112812544', '2038119880070287360', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 13:03:40.502', '2026-03-29 13:03:41.243', 741, NULL, '2026-03-29 13:03:40.503', '2026-03-29 13:03:41.244', 0),
('2038119880082870273', '2038119851112812544', '2038119880082870272', '2038119880070287360', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 13:03:40.505', '2026-03-29 13:03:40.512', 7, NULL, '2026-03-29 13:03:40.505', '2026-03-29 13:03:40.513', 0),
('2038120668880457729', '2038120668796571648', '2038120668880457728', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 13:06:48.569', '2026-03-29 13:06:50.289', 1720, NULL, '2026-03-29 13:06:48.569', '2026-03-29 13:06:50.289', 0),
('2038120668888846336', '2038120668796571648', '2038120668884652032', '2038120668880457728', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 13:06:48.57', '2026-03-29 13:06:50.286', 1716, NULL, '2026-03-29 13:06:48.571', '2026-03-29 13:06:50.287', 0),
('2038120676107243521', '2038120668796571648', '2038120676107243520', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 13:06:50.292', '2026-03-29 13:06:55.387', 5095, NULL, '2026-03-29 13:06:50.292', '2026-03-29 13:06:55.387', 0),
('2038120676115632129', '2038120668796571648', '2038120676115632128', '2038120676107243520', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 13:06:50.294', '2026-03-29 13:06:55.386', 5092, NULL, '2026-03-29 13:06:50.294', '2026-03-29 13:06:55.386', 0),
('2038120676119826433', '2038120668796571648', '2038120676119826432', '2038120676115632128', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 13:06:50.295', '2026-03-29 13:06:55.383', 5088, NULL, '2026-03-29 13:06:50.295', '2026-03-29 13:06:55.384', 0),
('2038120697481416705', '2038120668796571648', '2038120697481416704', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 13:06:55.388', '2026-03-29 13:06:59.857', 4469, NULL, '2026-03-29 13:06:55.388', '2026-03-29 13:06:59.858', 0),
('2038120697498193921', '2038120668796571648', '2038120697498193920', '2038120697481416704', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 13:06:55.392', '2026-03-29 13:06:59.856', 4464, NULL, '2026-03-29 13:06:55.392', '2026-03-29 13:06:59.856', 0),
('2038120697502388225', '2038120668796571648', '2038120697502388224', '2038120697498193920', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 13:06:55.393', '2026-03-29 13:06:59.853', 4460, NULL, '2026-03-29 13:06:55.393', '2026-03-29 13:06:59.854', 0),
('2038120716229955585', '2038120668796571648', '2038120716229955584', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 13:06:59.858', '2026-03-29 13:07:00.091', 233, NULL, '2026-03-29 13:06:59.859', '2026-03-29 13:07:00.091', 0),
('2038120716238344193', '2038120668796571648', '2038120716238344192', '2038120716229955584', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 13:06:59.86', '2026-03-29 13:07:00.09', 230, NULL, '2026-03-29 13:06:59.86', '2026-03-29 13:07:00.091', 0),
('2038120717211422721', '2038120668796571648', '2038120717211422720', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 13:07:00.092', '2026-03-29 13:07:00.746', 654, NULL, '2026-03-29 13:07:00.092', '2026-03-29 13:07:00.746', 0),
('2038120717215617025', '2038120668796571648', '2038120717215617024', '2038120717211422720', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 13:07:00.093', '2026-03-29 13:07:00.096', 3, NULL, '2026-03-29 13:07:00.093', '2026-03-29 13:07:00.096', 0),
('2038164092228755456', '2038164091968708608', '2038164092224561152', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 15:59:21.501', '2026-03-29 15:59:22.6', 1099, NULL, '2026-03-29 15:59:21.502', '2026-03-29 15:59:22.601', 0),
('2038164092237144065', '2038164091968708608', '2038164092237144064', '2038164092224561152', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 15:59:21.504', '2026-03-29 15:59:22.588', 1084, NULL, '2026-03-29 15:59:21.504', '2026-03-29 15:59:22.59', 0),
('2038164096850878465', '2038164091968708608', '2038164096850878464', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 15:59:22.604', '2026-03-29 15:59:24.109', 1505, NULL, '2026-03-29 15:59:22.604', '2026-03-29 15:59:24.109', 0),
('2038164096859267073', '2038164091968708608', '2038164096859267072', '2038164096850878464', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 15:59:22.606', '2026-03-29 15:59:24.107', 1501, NULL, '2026-03-29 15:59:22.606', '2026-03-29 15:59:24.107', 0),
('2038164096863461377', '2038164091968708608', '2038164096863461376', '2038164096859267072', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 15:59:22.607', '2026-03-29 15:59:24.104', 1497, NULL, '2026-03-29 15:59:22.607', '2026-03-29 15:59:24.104', 0),
('2038164103171694593', '2038164091968708608', '2038164103171694592', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 15:59:24.111', '2026-03-29 15:59:25.274', 1163, NULL, '2026-03-29 15:59:24.111', '2026-03-29 15:59:25.275', 0),
('2038164103205249024', '2038164091968708608', '2038164103201054720', '2038164103171694592', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 15:59:24.118', '2026-03-29 15:59:25.266', 1148, NULL, '2026-03-29 15:59:24.119', '2026-03-29 15:59:25.266', 0),
('2038164103209443328', '2038164091968708608', '2038164103205249025', '2038164103201054720', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 15:59:24.119', '2026-03-29 15:59:25.256', 1137, NULL, '2026-03-29 15:59:24.12', '2026-03-29 15:59:25.256', 0),
('2038164108062253057', '2038164091968708608', '2038164108062253056', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 15:59:25.277', '2026-03-29 15:59:25.513', 236, NULL, '2026-03-29 15:59:25.277', '2026-03-29 15:59:25.513', 0),
('2038164108070641665', '2038164091968708608', '2038164108070641664', '2038164108062253056', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 15:59:25.279', '2026-03-29 15:59:25.5', 221, NULL, '2026-03-29 15:59:25.279', '2026-03-29 15:59:25.501', 0),
('2038164109064691713', '2038164091968708608', '2038164109064691712', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 15:59:25.516', '2026-03-29 15:59:26.094', 578, NULL, '2026-03-29 15:59:25.516', '2026-03-29 15:59:26.095', 0),
('2038164109073080321', '2038164091968708608', '2038164109073080320', '2038164109064691712', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 15:59:25.518', '2026-03-29 15:59:25.526', 8, NULL, '2026-03-29 15:59:25.518', '2026-03-29 15:59:25.527', 0),
('2038164636511002625', '2038164636431310848', '2038164636511002624', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 16:01:31.269', '2026-03-29 16:01:35.977', 4708, NULL, '2026-03-29 16:01:31.269', '2026-03-29 16:01:35.977', 0),
('2038164636519391232', '2038164636431310848', '2038164636515196928', '2038164636511002624', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:01:31.27', '2026-03-29 16:01:35.976', 4706, NULL, '2026-03-29 16:01:31.271', '2026-03-29 16:01:35.977', 0),
('2038164636523585536', '2038164636431310848', '2038164636519391233', '2038164636515196928', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:01:31.271', '2026-03-29 16:01:35.966', 4695, NULL, '2026-03-29 16:01:31.272', '2026-03-29 16:01:35.966', 0),
('2038164656261980161', '2038164636431310848', '2038164656261980160', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 16:01:35.978', '2026-03-29 16:01:37.684', 1706, NULL, '2026-03-29 16:01:35.978', '2026-03-29 16:01:37.685', 0),
('2038164656274563073', '2038164636431310848', '2038164656274563072', '2038164656261980160', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:01:35.981', '2026-03-29 16:01:37.682', 1701, NULL, '2026-03-29 16:01:35.981', '2026-03-29 16:01:37.682', 0),
('2038164656278757377', '2038164636431310848', '2038164656278757376', '2038164656274563072', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:01:35.982', '2026-03-29 16:01:37.672', 1690, NULL, '2026-03-29 16:01:35.982', '2026-03-29 16:01:37.672', 0),
('2038164663421657089', '2038164636431310848', '2038164663421657088', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 16:01:37.685', '2026-03-29 16:01:38.019', 334, NULL, '2026-03-29 16:01:37.685', '2026-03-29 16:01:38.019', 0),
('2038164663430045697', '2038164636431310848', '2038164663430045696', '2038164663421657088', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 16:01:37.687', '2026-03-29 16:01:38.016', 329, NULL, '2026-03-29 16:01:37.687', '2026-03-29 16:01:38.016', 0),
('2038164664826748928', '2038164636431310848', '2038164664822554624', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:01:38.019', '2026-03-29 16:01:38.746', 727, NULL, '2026-03-29 16:01:38.02', '2026-03-29 16:01:38.746', 0),
('2038164664830943233', '2038164636431310848', '2038164664830943232', '2038164664822554624', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:01:38.021', '2026-03-29 16:01:38.027', 6, NULL, '2026-03-29 16:01:38.021', '2026-03-29 16:01:38.028', 0),
('2038164801858854912', '2038164801800134656', '2038164801850466304', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 16:02:10.689', '2026-03-29 16:02:17.368', 6679, NULL, '2026-03-29 16:02:10.691', '2026-03-29 16:02:17.369', 0),
('2038164801863049216', '2038164801800134656', '2038164801858854913', '2038164801850466304', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:02:10.691', '2026-03-29 16:02:17.367', 6676, NULL, '2026-03-29 16:02:10.692', '2026-03-29 16:02:17.368', 0),
('2038164801867243520', '2038164801800134656', '2038164801863049217', '2038164801858854913', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:02:10.692', '2026-03-29 16:02:17.365', 6673, NULL, '2026-03-29 16:02:10.693', '2026-03-29 16:02:17.365', 0),
('2038164829872611328', '2038164801800134656', '2038164829868417024', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 16:02:17.369', '2026-03-29 16:02:21.739', 4370, NULL, '2026-03-29 16:02:17.37', '2026-03-29 16:02:21.74', 0),
('2038164829901971456', '2038164801800134656', '2038164829893582848', '2038164829868417024', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:02:17.375', '2026-03-29 16:02:21.737', 4362, NULL, '2026-03-29 16:02:17.377', '2026-03-29 16:02:21.738', 0),
('2038164829906165761', '2038164801800134656', '2038164829906165760', '2038164829893582848', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:02:17.378', '2026-03-29 16:02:21.728', 4350, NULL, '2026-03-29 16:02:17.378', '2026-03-29 16:02:21.728', 0),
('2038164848205914113', '2038164801800134656', '2038164848205914112', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 16:02:21.741', '2026-03-29 16:02:22.003', 262, NULL, '2026-03-29 16:02:21.741', '2026-03-29 16:02:22.005', 0),
('2038164848210108417', '2038164801800134656', '2038164848210108416', '2038164848205914112', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 16:02:21.742', '2026-03-29 16:02:21.995', 253, NULL, '2026-03-29 16:02:21.742', '2026-03-29 16:02:21.995', 0),
('2038164849317404673', '2038164801800134656', '2038164849317404672', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:02:22.006', '2026-03-29 16:02:22.453', 447, NULL, '2026-03-29 16:02:22.006', '2026-03-29 16:02:22.454', 0),
('2038164849321598977', '2038164801800134656', '2038164849321598976', '2038164849317404672', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:02:22.007', '2026-03-29 16:02:22.012', 5, NULL, '2026-03-29 16:02:22.007', '2026-03-29 16:02:22.012', 0),
('2038165064447451137', '2038165064392925184', '2038165064447451136', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 16:03:13.297', '2026-03-29 16:03:16.144', 2847, NULL, '2026-03-29 16:03:13.297', '2026-03-29 16:03:16.145', 0),
('2038165064451645441', '2038165064392925184', '2038165064451645440', '2038165064447451136', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:03:13.298', '2026-03-29 16:03:16.142', 2844, NULL, '2026-03-29 16:03:13.298', '2026-03-29 16:03:16.143', 0),
('2038165064455839745', '2038165064392925184', '2038165064455839744', '2038165064451645440', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:03:13.299', '2026-03-29 16:03:16.139', 2840, NULL, '2026-03-29 16:03:13.299', '2026-03-29 16:03:16.14', 0),
('2038165076392828929', '2038165064392925184', '2038165076392828928', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 16:03:16.145', '2026-03-29 16:03:19.394', 3249, NULL, '2026-03-29 16:03:16.145', '2026-03-29 16:03:19.394', 0),
('2038165076455743489', '2038165064392925184', '2038165076455743488', '2038165076392828928', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:03:16.16', '2026-03-29 16:03:19.393', 3233, NULL, '2026-03-29 16:03:16.16', '2026-03-29 16:03:19.393', 0),
('2038165076468326400', '2038165064392925184', '2038165076464132096', '2038165076455743488', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:03:16.162', '2026-03-29 16:03:19.383', 3221, NULL, '2026-03-29 16:03:16.163', '2026-03-29 16:03:19.383', 0),
('2038165090020122625', '2038165064392925184', '2038165090020122624', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 16:03:19.394', '2026-03-29 16:03:20.308', 914, NULL, '2026-03-29 16:03:19.394', '2026-03-29 16:03:20.308', 0),
('2038165090028511233', '2038165064392925184', '2038165090028511232', '2038165090020122624', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 16:03:19.396', '2026-03-29 16:03:20.298', 902, NULL, '2026-03-29 16:03:19.396', '2026-03-29 16:03:20.298', 0),
('2038165093857910785', '2038165064392925184', '2038165093857910784', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:03:20.309', '2026-03-29 16:03:20.858', 549, NULL, '2026-03-29 16:03:20.309', '2026-03-29 16:03:20.858', 0),
('2038165093857910787', '2038165064392925184', '2038165093857910786', '2038165093857910784', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:03:20.309', '2026-03-29 16:03:20.311', 2, NULL, '2026-03-29 16:03:20.309', '2026-03-29 16:03:20.311', 0),
('2038165268701667328', '2038165268659724288', '2038165268693278720', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 16:04:01.993', '2026-03-29 16:04:05.801', 3808, NULL, '2026-03-29 16:04:01.995', '2026-03-29 16:04:05.801', 0),
('2038165268705861633', '2038165268659724288', '2038165268705861632', '2038165268693278720', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:01.996', '2026-03-29 16:04:05.8', 3804, NULL, '2026-03-29 16:04:01.996', '2026-03-29 16:04:05.801', 0),
('2038165268714250241', '2038165268659724288', '2038165268714250240', '2038165268705861632', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:01.998', '2026-03-29 16:04:05.79', 3792, NULL, '2026-03-29 16:04:01.998', '2026-03-29 16:04:05.79', 0),
('2038165284669382657', '2038165268659724288', '2038165284669382656', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 16:04:05.802', '2026-03-29 16:04:07.441', 1639, NULL, '2026-03-29 16:04:05.802', '2026-03-29 16:04:07.441', 0),
('2038165284677771265', '2038165268659724288', '2038165284677771264', '2038165284669382656', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:05.804', '2026-03-29 16:04:07.44', 1636, NULL, '2026-03-29 16:04:05.804', '2026-03-29 16:04:07.44', 0),
('2038165284681965568', '2038165268659724288', '2038165284677771266', '2038165284677771264', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:05.804', '2026-03-29 16:04:07.43', 1626, NULL, '2026-03-29 16:04:05.805', '2026-03-29 16:04:07.43', 0),
('2038165291548041217', '2038165268659724288', '2038165291548041216', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 16:04:07.442', '2026-03-29 16:04:07.651', 209, NULL, '2026-03-29 16:04:07.442', '2026-03-29 16:04:07.652', 0),
('2038165291552235520', '2038165268659724288', '2038165291548041218', '2038165291548041216', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 16:04:07.442', '2026-03-29 16:04:07.649', 207, NULL, '2026-03-29 16:04:07.443', '2026-03-29 16:04:07.649', 0),
('2038165292428845057', '2038165268659724288', '2038165292428845056', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:04:07.652', '2026-03-29 16:04:08.087', 435, NULL, '2026-03-29 16:04:07.652', '2026-03-29 16:04:08.087', 0),
('2038165292433039361', '2038165268659724288', '2038165292433039360', '2038165292428845056', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:04:07.653', '2026-03-29 16:04:07.655', 2, NULL, '2026-03-29 16:04:07.653', '2026-03-29 16:04:07.655', 0),
('2038165309516439553', '2038165268659724288', '2038165309516439552', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:11.726', '2026-03-29 16:04:14.021', 2295, NULL, '2026-03-29 16:04:11.727', '2026-03-29 16:04:14.023', 0),
('2038165309524828161', '2038165268659724288', '2038165309524828160', '2038165309516439552', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:11.728', '2026-03-29 16:04:14.013', 2285, NULL, '2026-03-29 16:04:11.728', '2026-03-29 16:04:14.013', 0),
('2038165455776014337', '2038165455692128256', '2038165455776014336', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 16:04:46.597', '2026-03-29 16:04:48.414', 1817, NULL, '2026-03-29 16:04:46.597', '2026-03-29 16:04:48.414', 0),
('2038165455776014339', '2038165455692128256', '2038165455776014338', '2038165455776014336', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:46.597', '2026-03-29 16:04:48.413', 1816, NULL, '2026-03-29 16:04:46.597', '2026-03-29 16:04:48.413', 0),
('2038165455784402945', '2038165455692128256', '2038165455784402944', '2038165455776014338', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:46.599', '2026-03-29 16:04:48.402', 1803, NULL, '2026-03-29 16:04:46.599', '2026-03-29 16:04:48.403', 0),
('2038165463401259009', '2038165455692128256', '2038165463401259008', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 16:04:48.415', '2026-03-29 16:04:51.97', 3555, NULL, '2026-03-29 16:04:48.415', '2026-03-29 16:04:51.97', 0),
('2038165463422230529', '2038165455692128256', '2038165463422230528', '2038165463401259008', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:48.42', '2026-03-29 16:04:51.968', 3548, NULL, '2026-03-29 16:04:48.42', '2026-03-29 16:04:51.968', 0),
('2038165463426424833', '2038165455692128256', '2038165463426424832', '2038165463422230528', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:48.421', '2026-03-29 16:04:51.957', 3536, NULL, '2026-03-29 16:04:48.421', '2026-03-29 16:04:51.957', 0),
('2038165478320398337', '2038165455692128256', '2038165478320398336', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 16:04:51.972', '2026-03-29 16:04:52.157', 185, NULL, '2026-03-29 16:04:51.972', '2026-03-29 16:04:52.157', 0),
('2038165478332981248', '2038165455692128256', '2038165478328786944', '2038165478320398336', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 16:04:51.974', '2026-03-29 16:04:52.152', 178, NULL, '2026-03-29 16:04:51.975', '2026-03-29 16:04:52.153', 0),
('2038165479104733185', '2038165455692128256', '2038165479104733184', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:04:52.159', '2026-03-29 16:04:52.719', 560, NULL, '2026-03-29 16:04:52.159', '2026-03-29 16:04:52.719', 0),
('2038165479108927489', '2038165455692128256', '2038165479108927488', '2038165479104733184', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:04:52.16', '2026-03-29 16:04:52.161', 1, NULL, '2026-03-29 16:04:52.16', '2026-03-29 16:04:52.161', 0),
('2038165504014704641', '2038165455692128256', '2038165504014704640', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:58.098', '2026-03-29 16:05:00.6', 2502, NULL, '2026-03-29 16:04:58.098', '2026-03-29 16:05:00.6', 0),
('2038165504018898945', '2038165455692128256', '2038165504018898944', '2038165504014704640', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:04:58.099', '2026-03-29 16:05:00.599', 2500, NULL, '2026-03-29 16:04:58.099', '2026-03-29 16:05:00.599', 0),
('2038165542350643201', '2038165542275145728', '2038165542350643200', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 16:05:07.238', '2026-03-29 16:05:09.022', 1784, NULL, '2026-03-29 16:05:07.238', '2026-03-29 16:05:09.022', 0),
('2038165542354837504', '2038165542275145728', '2038165542350643202', '2038165542350643200', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:05:07.238', '2026-03-29 16:05:09.021', 1783, NULL, '2026-03-29 16:05:07.239', '2026-03-29 16:05:09.021', 0),
('2038165542354837506', '2038165542275145728', '2038165542354837505', '2038165542350643202', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:05:07.239', '2026-03-29 16:05:09.011', 1772, NULL, '2026-03-29 16:05:07.239', '2026-03-29 16:05:09.011', 0),
('2038165549833281537', '2038165542275145728', '2038165549833281536', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 16:05:09.022', '2026-03-29 16:05:09.752', 730, NULL, '2026-03-29 16:05:09.022', '2026-03-29 16:05:09.752', 0),
('2038165549845864449', '2038165542275145728', '2038165549845864448', '2038165549833281536', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:05:09.025', '2026-03-29 16:05:09.751', 726, NULL, '2026-03-29 16:05:09.025', '2026-03-29 16:05:09.751', 0),
('2038165549845864451', '2038165542275145728', '2038165549845864450', '2038165549845864448', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:05:09.025', '2026-03-29 16:05:09.741', 716, NULL, '2026-03-29 16:05:09.025', '2026-03-29 16:05:09.742', 0),
('2038165552895123457', '2038165542275145728', '2038165552895123456', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 16:05:09.752', '2026-03-29 16:05:09.947', 195, NULL, '2026-03-29 16:05:09.752', '2026-03-29 16:05:09.947', 0),
('2038165552899317761', '2038165542275145728', '2038165552899317760', '2038165552895123456', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 16:05:09.753', '2026-03-29 16:05:09.945', 192, NULL, '2026-03-29 16:05:09.753', '2026-03-29 16:05:09.945', 0),
('2038165553721401345', '2038165542275145728', '2038165553721401344', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:05:09.949', '2026-03-29 16:05:10.592', 643, NULL, '2026-03-29 16:05:09.949', '2026-03-29 16:05:10.593', 0),
('2038165553721401347', '2038165542275145728', '2038165553721401346', '2038165553721401344', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:05:09.949', '2026-03-29 16:05:09.95', 1, NULL, '2026-03-29 16:05:09.949', '2026-03-29 16:05:09.95', 0),
('2038165591935705089', '2038165542275145728', '2038165591935705088', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:05:19.06', '2026-03-29 16:05:21.902', 2842, NULL, '2026-03-29 16:05:19.06', '2026-03-29 16:05:21.902', 0),
('2038165591944093696', '2038165542275145728', '2038165591939899392', '2038165591935705088', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:05:19.061', '2026-03-29 16:05:21.892', 2831, NULL, '2026-03-29 16:05:19.062', '2026-03-29 16:05:21.892', 0),
('2038165783703478273', '2038165783661535232', '2038165783703478272', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 16:06:04.781', '2026-03-29 16:06:08.531', 3750, NULL, '2026-03-29 16:06:04.781', '2026-03-29 16:06:08.531', 0),
('2038165783711866880', '2038165783661535232', '2038165783707672576', '2038165783703478272', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:06:04.782', '2026-03-29 16:06:08.528', 3746, NULL, '2026-03-29 16:06:04.783', '2026-03-29 16:06:08.529', 0),
('2038165783711866882', '2038165783661535232', '2038165783711866881', '2038165783707672576', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:06:04.783', '2026-03-29 16:06:08.518', 3735, NULL, '2026-03-29 16:06:04.783', '2026-03-29 16:06:08.518', 0),
('2038165799432118273', '2038165783661535232', '2038165799432118272', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 16:06:08.531', '2026-03-29 16:06:12.275', 3744, NULL, '2026-03-29 16:06:08.531', '2026-03-29 16:06:12.275', 0),
('2038165799448895489', '2038165783661535232', '2038165799448895488', '2038165799432118272', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:06:08.535', '2026-03-29 16:06:12.274', 3739, NULL, '2026-03-29 16:06:08.535', '2026-03-29 16:06:12.275', 0),
('2038165799453089792', '2038165783661535232', '2038165799448895490', '2038165799448895488', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:06:08.535', '2026-03-29 16:06:12.265', 3730, NULL, '2026-03-29 16:06:08.536', '2026-03-29 16:06:12.266', 0),
('2038165815143981056', '2038165783661535232', '2038165815135592448', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 16:06:12.275', '2026-03-29 16:06:13.724', 1449, NULL, '2026-03-29 16:06:12.277', '2026-03-29 16:06:13.724', 0),
('2038165815143981058', '2038165783661535232', '2038165815143981057', '2038165815135592448', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 16:06:12.277', '2026-03-29 16:06:13.722', 1445, NULL, '2026-03-29 16:06:12.277', '2026-03-29 16:06:13.722', 0),
('2038165821213138945', '2038165783661535232', '2038165821213138944', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:06:13.724', '2026-03-29 16:06:14.522', 798, NULL, '2026-03-29 16:06:13.724', '2026-03-29 16:06:14.522', 0),
('2038165821217333249', '2038165783661535232', '2038165821217333248', '2038165821213138944', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 16:06:13.725', '2026-03-29 16:06:13.726', 1, NULL, '2026-03-29 16:06:13.725', '2026-03-29 16:06:13.727', 0),
('2038165868000600065', '2038165783661535232', '2038165868000600064', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 16:06:24.879', '2026-03-29 16:06:27.231', 2352, NULL, '2026-03-29 16:06:24.879', '2026-03-29 16:06:27.231', 0),
('2038165868004794369', '2038165783661535232', '2038165868004794368', '2038165868000600064', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 16:06:24.88', '2026-03-29 16:06:27.22', 2340, NULL, '2026-03-29 16:06:24.88', '2026-03-29 16:06:27.221', 0),
('2038216419232997376', '2038216418876481536', '2038216419228803072', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-29 19:27:17.231', '2026-03-29 19:27:25.411', 8180, NULL, '2026-03-29 19:27:17.232', '2026-03-29 19:27:25.412', 0),
('2038216419245580289', '2038216418876481536', '2038216419245580288', '2038216419228803072', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 19:27:17.235', '2026-03-29 19:27:25.409', 8174, NULL, '2026-03-29 19:27:17.235', '2026-03-29 19:27:25.41', 0),
('2038216419258163200', '2038216418876481536', '2038216419253968896', '2038216419245580288', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 19:27:17.237', '2026-03-29 19:27:25.405', 8168, NULL, '2026-03-29 19:27:17.238', '2026-03-29 19:27:25.406', 0),
('2038216453554987008', '2038216418876481536', '2038216453542404096', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-29 19:27:25.412', '2026-03-29 19:27:27.8', 2388, NULL, '2026-03-29 19:27:25.415', '2026-03-29 19:27:27.8', 0),
('2038216453571764225', '2038216418876481536', '2038216453571764224', '2038216453542404096', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 19:27:25.419', '2026-03-29 19:27:27.798', 2379, NULL, '2026-03-29 19:27:25.419', '2026-03-29 19:27:27.798', 0),
('2038216453575958529', '2038216418876481536', '2038216453575958528', '2038216453571764224', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 19:27:25.42', '2026-03-29 19:27:27.788', 2368, NULL, '2026-03-29 19:27:25.42', '2026-03-29 19:27:27.788', 0),
('2038216463570984960', '2038216418876481536', '2038216463562596352', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-29 19:27:27.801', '2026-03-29 19:27:28.706', 905, NULL, '2026-03-29 19:27:27.803', '2026-03-29 19:27:28.706', 0),
('2038216463579373569', '2038216418876481536', '2038216463579373568', '2038216463562596352', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-29 19:27:27.805', '2026-03-29 19:27:28.695', 890, NULL, '2026-03-29 19:27:27.805', '2026-03-29 19:27:28.695', 0),
('2038216467371024385', '2038216418876481536', '2038216467371024384', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-29 19:27:28.709', '2026-03-29 19:27:29.82', 1111, NULL, '2026-03-29 19:27:28.709', '2026-03-29 19:27:29.822', 0),
('2038216467383607296', '2038216418876481536', '2038216467379412992', '2038216467371024384', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-29 19:27:28.711', '2026-03-29 19:27:28.719', 8, NULL, '2026-03-29 19:27:28.712', '2026-03-29 19:27:28.719', 0),
('2038216473540845569', '2038216418876481536', '2038216473540845568', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-29 19:27:30.18', '2026-03-29 19:27:33.118', 2938, NULL, '2026-03-29 19:27:30.18', '2026-03-29 19:27:33.118', 0),
('2038216473540845571', '2038216418876481536', '2038216473540845570', '2038216473540845568', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-29 19:27:30.18', '2026-03-29 19:27:33.116', 2936, NULL, '2026-03-29 19:27:30.18', '2026-03-29 19:27:33.116', 0),
('2039001572653969408', '2039001572154847232', '2039001572645580800', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:12.393', '2026-03-31 23:27:13.954', 1561, NULL, '2026-03-31 23:27:12.395', '2026-03-31 23:27:13.955', 0),
('2039001572683329536', '2039001572154847232', '2039001572679135232', '2039001572645580800', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:12.401', '2026-03-31 23:27:13.936', 1535, NULL, '2026-03-31 23:27:12.402', '2026-03-31 23:27:13.947', 0),
('2039001579218055168', '2039001572154847232', '2039001579213860864', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-31 23:27:13.959', '2026-03-31 23:27:15.536', 1577, NULL, '2026-03-31 23:27:13.96', '2026-03-31 23:27:15.537', 0),
('2039001579234832384', '2039001572154847232', '2039001579230638080', '2039001579213860864', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:13.963', '2026-03-31 23:27:15.534', 1571, NULL, '2026-03-31 23:27:13.965', '2026-03-31 23:27:15.534', 0),
('2039001579255803904', '2039001572154847232', '2039001579247415296', '2039001579230638080', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:13.967', '2026-03-31 23:27:15.53', 1563, NULL, '2026-03-31 23:27:13.969', '2026-03-31 23:27:15.53', 0),
('2039001585845055489', '2039001572154847232', '2039001585845055488', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-31 23:27:15.54', '2026-03-31 23:27:16.091', 551, NULL, '2026-03-31 23:27:15.54', '2026-03-31 23:27:16.092', 0),
('2039001585895387136', '2039001572154847232', '2039001585891192832', '2039001585845055488', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:15.551', '2026-03-31 23:27:16.067', 516, NULL, '2026-03-31 23:27:15.552', '2026-03-31 23:27:16.068', 0),
('2039001585899581441', '2039001572154847232', '2039001585899581440', '2039001585891192832', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:15.553', '2026-03-31 23:27:16.064', 511, NULL, '2026-03-31 23:27:15.553', '2026-03-31 23:27:16.065', 0),
('2039001588172894209', '2039001572154847232', '2039001588172894208', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-31 23:27:16.095', '2026-03-31 23:27:27.198', 11103, NULL, '2026-03-31 23:27:16.095', '2026-03-31 23:27:27.199', 0),
('2039001588214837248', '2039001572154847232', '2039001588210642944', '2039001588172894208', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-31 23:27:16.104', '2026-03-31 23:27:27.194', 11090, NULL, '2026-03-31 23:27:16.105', '2026-03-31 23:27:27.194', 0),
('2039001634763223041', '2039001572154847232', '2039001634763223040', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-31 23:27:27.203', '2026-03-31 23:27:27.925', 722, NULL, '2026-03-31 23:27:27.203', '2026-03-31 23:27:27.925', 0),
('2039001634771611649', '2039001572154847232', '2039001634771611648', '2039001634763223040', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-31 23:27:27.205', '2026-03-31 23:27:27.208', 3, NULL, '2026-03-31 23:27:27.205', '2026-03-31 23:27:27.208', 0),
('2039001771103268865', '2039001771052937216', '2039001771103268864', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:59.709', '2026-03-31 23:28:00.344', 635, NULL, '2026-03-31 23:27:59.709', '2026-03-31 23:28:00.344', 0),
('2039001771107463169', '2039001771052937216', '2039001771107463168', '2039001771103268864', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:27:59.71', '2026-03-31 23:28:00.341', 631, NULL, '2026-03-31 23:27:59.71', '2026-03-31 23:28:00.341', 0),
('2039001773779234817', '2039001771052937216', '2039001773779234816', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-31 23:28:00.347', '2026-03-31 23:28:01.879', 1532, NULL, '2026-03-31 23:28:00.347', '2026-03-31 23:28:01.88', 0),
('2039001773779234819', '2039001771052937216', '2039001773779234818', '2039001773779234816', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:28:00.347', '2026-03-31 23:28:01.878', 1531, NULL, '2026-03-31 23:28:00.347', '2026-03-31 23:28:01.878', 0),
('2039001773783429121', '2039001771052937216', '2039001773783429120', '2039001773779234818', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:28:00.348', '2026-03-31 23:28:01.874', 1526, NULL, '2026-03-31 23:28:00.348', '2026-03-31 23:28:01.875', 0),
('2039001780213297152', '2039001771052937216', '2039001780209102848', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-31 23:28:01.88', '2026-03-31 23:28:02.678', 798, NULL, '2026-03-31 23:28:01.881', '2026-03-31 23:28:02.678', 0),
('2039001780225880065', '2039001771052937216', '2039001780225880064', '2039001780209102848', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:28:01.884', '2026-03-31 23:28:02.677', 793, NULL, '2026-03-31 23:28:01.884', '2026-03-31 23:28:02.677', 0),
('2039001780230074369', '2039001771052937216', '2039001780230074368', '2039001780225880064', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:28:01.885', '2026-03-31 23:28:02.673', 788, NULL, '2026-03-31 23:28:01.885', '2026-03-31 23:28:02.675', 0),
('2039001783564546049', '2039001771052937216', '2039001783564546048', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-31 23:28:02.68', '2026-03-31 23:28:02.921', 241, NULL, '2026-03-31 23:28:02.68', '2026-03-31 23:28:02.922', 0),
('2039001783568740353', '2039001771052937216', '2039001783568740352', '2039001783564546048', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-31 23:28:02.681', '2026-03-31 23:28:02.916', 235, NULL, '2026-03-31 23:28:02.682', '2026-03-31 23:28:02.918', 0),
('2039001784587956224', '2039001771052937216', '2039001784583761920', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-31 23:28:02.923', '2026-03-31 23:28:03.608', 685, NULL, '2026-03-31 23:28:02.924', '2026-03-31 23:28:03.609', 0),
('2039001784600539136', '2039001771052937216', '2039001784596344832', '2039001784583761920', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-31 23:28:02.926', '2026-03-31 23:28:02.929', 3, NULL, '2026-03-31 23:28:02.927', '2026-03-31 23:28:02.932', 0),
('2039007654008897536', '2039007653501386752', '2039007654000508928', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:51:22.301', '2026-03-31 23:51:23.477', 1176, NULL, '2026-03-31 23:51:22.304', '2026-03-31 23:51:23.479', 0),
('2039007654034063360', '2039007653501386752', '2039007654029869056', '2039007654000508928', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:51:22.308', '2026-03-31 23:51:23.463', 1155, NULL, '2026-03-31 23:51:22.31', '2026-03-31 23:51:23.472', 0),
('2039007658962370560', '2039007653501386752', '2039007658953981952', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-31 23:51:23.482', '2026-03-31 23:51:24.815', 1333, NULL, '2026-03-31 23:51:23.484', '2026-03-31 23:51:24.815', 0),
('2039007658979147777', '2039007653501386752', '2039007658979147776', '2039007658953981952', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:51:23.488', '2026-03-31 23:51:24.812', 1324, NULL, '2026-03-31 23:51:23.489', '2026-03-31 23:51:24.812', 0),
('2039007658995924992', '2039007653501386752', '2039007658991730688', '2039007658979147776', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:51:23.491', '2026-03-31 23:51:24.809', 1318, NULL, '2026-03-31 23:51:23.492', '2026-03-31 23:51:24.81', 0),
('2039007664549183489', '2039007653501386752', '2039007664549183488', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-31 23:51:24.816', '2026-03-31 23:51:27.97', 3154, NULL, '2026-03-31 23:51:24.816', '2026-03-31 23:51:27.97', 0),
('2039007664582737920', '2039007653501386752', '2039007664574349312', '2039007664549183488', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:51:24.822', '2026-03-31 23:51:27.962', 3140, NULL, '2026-03-31 23:51:24.824', '2026-03-31 23:51:27.962', 0),
('2039007664586932225', '2039007653501386752', '2039007664586932224', '2039007664574349312', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:51:24.825', '2026-03-31 23:51:27.952', 3127, NULL, '2026-03-31 23:51:24.825', '2026-03-31 23:51:27.952', 0),
('2039007871793938432', '2039007871626166272', '2039007871789744128', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-31 23:52:14.226', '2026-03-31 23:52:15.813', 1587, NULL, '2026-03-31 23:52:14.227', '2026-03-31 23:52:15.813', 0),
('2039007871802327041', '2039007871626166272', '2039007871802327040', '2039007871789744128', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:14.229', '2026-03-31 23:52:15.811', 1582, NULL, '2026-03-31 23:52:14.229', '2026-03-31 23:52:15.812', 0),
('2039007871814909952', '2039007871626166272', '2039007871810715648', '2039007871802327040', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:14.231', '2026-03-31 23:52:15.806', 1575, NULL, '2026-03-31 23:52:14.232', '2026-03-31 23:52:15.807', 0),
('2039007878450298881', '2039007871626166272', '2039007878450298880', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-31 23:52:15.814', '2026-03-31 23:52:16.4', 586, NULL, '2026-03-31 23:52:15.814', '2026-03-31 23:52:16.4', 0),
('2039007878475464705', '2039007871626166272', '2039007878475464704', '2039007878450298880', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:15.82', '2026-03-31 23:52:16.399', 579, NULL, '2026-03-31 23:52:15.82', '2026-03-31 23:52:16.399', 0),
('2039007878479659009', '2039007871626166272', '2039007878479659008', '2039007878475464704', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:15.821', '2026-03-31 23:52:16.387', 566, NULL, '2026-03-31 23:52:15.822', '2026-03-31 23:52:16.389', 0),
('2039007880916549633', '2039007871626166272', '2039007880916549632', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-03-31 23:52:16.402', '2026-03-31 23:52:16.69', 288, NULL, '2026-03-31 23:52:16.402', '2026-03-31 23:52:16.691', 0),
('2039007880941715456', '2039007871626166272', '2039007880937521152', '2039007880916549632', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-03-31 23:52:16.407', '2026-03-31 23:52:16.68', 273, NULL, '2026-03-31 23:52:16.408', '2026-03-31 23:52:16.681', 0),
('2039007882137092097', '2039007871626166272', '2039007882137092096', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-03-31 23:52:16.693', '2026-03-31 23:52:17.294', 601, NULL, '2026-03-31 23:52:16.693', '2026-03-31 23:52:17.296', 0),
('2039007882149675008', '2039007871626166272', '2039007882145480704', '2039007882137092096', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-03-31 23:52:16.695', '2026-03-31 23:52:16.699', 4, NULL, '2026-03-31 23:52:16.696', '2026-03-31 23:52:16.7', 0),
('2039008018099650560', '2039008017998987264', '2039008018095456256', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-31 23:52:49.108', '2026-03-31 23:52:50.855', 1747, NULL, '2026-03-31 23:52:49.109', '2026-03-31 23:52:50.857', 0),
('2039008018108039168', '2039008017998987264', '2039008018103844864', '2039008018095456256', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:49.11', '2026-03-31 23:52:50.852', 1742, NULL, '2026-03-31 23:52:49.111', '2026-03-31 23:52:50.853', 0),
('2039008018112233472', '2039008017998987264', '2039008018108039169', '2039008018103844864', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:49.111', '2026-03-31 23:52:50.85', 1739, NULL, '2026-03-31 23:52:49.112', '2026-03-31 23:52:50.851', 0),
('2039008025435488257', '2039008017998987264', '2039008025435488256', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-31 23:52:50.858', '2026-03-31 23:52:51.599', 741, NULL, '2026-03-31 23:52:50.858', '2026-03-31 23:52:51.601', 0),
('2039008025460654081', '2039008017998987264', '2039008025460654080', '2039008025435488256', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:50.864', '2026-03-31 23:52:51.597', 733, NULL, '2026-03-31 23:52:50.865', '2026-03-31 23:52:51.598', 0),
('2039008025469042688', '2039008017998987264', '2039008025464848384', '2039008025460654080', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:52:50.865', '2026-03-31 23:52:51.587', 722, NULL, '2026-03-31 23:52:50.866', '2026-03-31 23:52:51.588', 0),
('2039009707095543808', '2039009706663530496', '2039009707082960896', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:59:31.794', '2026-03-31 23:59:33.199', 1405, NULL, '2026-03-31 23:59:31.797', '2026-03-31 23:59:33.201', 0),
('2039009707129098240', '2039009706663530496', '2039009707120709632', '2039009707082960896', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:59:31.803', '2026-03-31 23:59:33.186', 1383, NULL, '2026-03-31 23:59:31.805', '2026-03-31 23:59:33.195', 0),
('2039009712996929537', '2039009706663530496', '2039009712996929536', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-03-31 23:59:33.204', '2026-03-31 23:59:34.637', 1433, NULL, '2026-03-31 23:59:33.204', '2026-03-31 23:59:34.641', 0),
('2039009713013706752', '2039009706663530496', '2039009713009512448', '2039009712996929536', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:59:33.207', '2026-03-31 23:59:34.634', 1427, NULL, '2026-03-31 23:59:33.208', '2026-03-31 23:59:34.635', 0),
('2039009713022095360', '2039009706663530496', '2039009713017901056', '2039009713009512448', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:59:33.209', '2026-03-31 23:59:34.623', 1414, NULL, '2026-03-31 23:59:33.21', '2026-03-31 23:59:34.624', 0),
('2039009719032532993', '2039009706663530496', '2039009719032532992', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-03-31 23:59:34.643', '2026-03-31 23:59:35.176', 533, NULL, '2026-03-31 23:59:34.643', '2026-03-31 23:59:35.177', 0),
('2039009719095447552', '2039009706663530496', '2039009719087058944', '2039009719032532992', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-03-31 23:59:34.656', '2026-03-31 23:59:35.167', 511, NULL, '2026-03-31 23:59:34.658', '2026-03-31 23:59:35.168', 0),
('2039009719103836161', '2039009706663530496', '2039009719103836160', '2039009719087058944', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-03-31 23:59:34.66', '2026-03-31 23:59:35.166', 506, NULL, '2026-03-31 23:59:34.66', '2026-03-31 23:59:35.167', 0),
('2039009903468662785', '2039009903338639360', '2039009903468662784', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:00:18.616', '2026-04-01 00:00:20.848', 2232, NULL, '2026-04-01 00:00:18.617', '2026-04-01 00:00:20.848', 0),
('2039009903485440000', '2039009903338639360', '2039009903481245696', '2039009903468662784', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:00:18.619', '2026-04-01 00:00:20.846', 2227, NULL, '2026-04-01 00:00:18.62', '2026-04-01 00:00:20.847', 0),
('2039009903493828608', '2039009903338639360', '2039009903489634304', '2039009903481245696', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:00:18.621', '2026-04-01 00:00:20.836', 2215, NULL, '2026-04-01 00:00:18.622', '2026-04-01 00:00:20.837', 0),
('2039009912834543617', '2039009903338639360', '2039009912834543616', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:00:20.849', '2026-04-01 00:00:21.622', 773, NULL, '2026-04-01 00:00:20.849', '2026-04-01 00:00:21.622', 0),
('2039009912851320832', '2039009903338639360', '2039009912847126528', '2039009912834543616', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:00:20.852', '2026-04-01 00:00:21.621', 769, NULL, '2026-04-01 00:00:20.853', '2026-04-01 00:00:21.621', 0),
('2039009912851320834', '2039009903338639360', '2039009912851320833', '2039009912847126528', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:00:20.853', '2026-04-01 00:00:21.618', 765, NULL, '2026-04-01 00:00:20.853', '2026-04-01 00:00:21.618', 0),
('2039012327952539648', '2039012327486971904', '2039012327939956736', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:09:56.655', '2026-04-01 00:09:57.953', 1298, NULL, '2026-04-01 00:09:56.658', '2026-04-01 00:09:57.954', 0),
('2039012327981899777', '2039012327486971904', '2039012327981899776', '2039012327939956736', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:09:56.665', '2026-04-01 00:09:57.944', 1279, NULL, '2026-04-01 00:09:56.665', '2026-04-01 00:09:57.951', 0),
('2039012333426106368', '2039012327486971904', '2039012333421912064', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:09:57.962', '2026-04-01 00:09:59.644', 1682, NULL, '2026-04-01 00:09:57.963', '2026-04-01 00:09:59.644', 0),
('2039012333438689280', '2039012327486971904', '2039012333434494976', '2039012333421912064', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:09:57.965', '2026-04-01 00:09:59.642', 1677, NULL, '2026-04-01 00:09:57.966', '2026-04-01 00:09:59.642', 0),
('2039012333447077888', '2039012327486971904', '2039012333438689281', '2039012333434494976', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:09:57.966', '2026-04-01 00:09:59.639', 1673, NULL, '2026-04-01 00:09:57.968', '2026-04-01 00:09:59.64', 0),
('2039012340485120001', '2039012327486971904', '2039012340485120000', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:09:59.646', '2026-04-01 00:10:01.778', 2132, NULL, '2026-04-01 00:09:59.646', '2026-04-01 00:10:01.779', 0),
('2039012340522868737', '2039012327486971904', '2039012340522868736', '2039012340485120000', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:09:59.655', '2026-04-01 00:10:01.768', 2113, NULL, '2026-04-01 00:09:59.655', '2026-04-01 00:10:01.768', 0),
('2039012340527063041', '2039012327486971904', '2039012340527063040', '2039012340522868736', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:09:59.656', '2026-04-01 00:10:01.757', 2101, NULL, '2026-04-01 00:09:59.656', '2026-04-01 00:10:01.758', 0),
('2039012417257660416', '2039012417106665472', '2039012417253466112', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:10:17.949', '2026-04-01 00:10:19.553', 1604, NULL, '2026-04-01 00:10:17.95', '2026-04-01 00:10:19.553', 0),
('2039012417261854721', '2039012417106665472', '2039012417261854720', '2039012417253466112', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:10:17.951', '2026-04-01 00:10:19.552', 1601, NULL, '2026-04-01 00:10:17.951', '2026-04-01 00:10:19.552', 0),
('2039012417266049024', '2039012417106665472', '2039012417261854722', '2039012417261854720', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:10:17.951', '2026-04-01 00:10:19.548', 1597, NULL, '2026-04-01 00:10:17.952', '2026-04-01 00:10:19.549', 0),
('2039012423981129729', '2039012417106665472', '2039012423981129728', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:10:19.553', '2026-04-01 00:10:20.734', 1181, NULL, '2026-04-01 00:10:19.553', '2026-04-01 00:10:20.734', 0),
('2039012424002101249', '2039012417106665472', '2039012424002101248', '2039012423981129728', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:10:19.558', '2026-04-01 00:10:20.733', 1175, NULL, '2026-04-01 00:10:19.558', '2026-04-01 00:10:20.733', 0),
('2039012424006295553', '2039012417106665472', '2039012424006295552', '2039012424002101248', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:10:19.559', '2026-04-01 00:10:20.722', 1163, NULL, '2026-04-01 00:10:19.559', '2026-04-01 00:10:20.723', 0),
('2039012603572838400', '2039012603522506752', '2039012603568644096', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:11:02.37', '2026-04-01 00:11:03.956', 1586, NULL, '2026-04-01 00:11:02.371', '2026-04-01 00:11:03.956', 0),
('2039012603577032704', '2039012603522506752', '2039012603572838401', '2039012603568644096', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:11:02.371', '2026-04-01 00:11:03.952', 1581, NULL, '2026-04-01 00:11:02.372', '2026-04-01 00:11:03.952', 0),
('2039012610225004545', '2039012603522506752', '2039012610225004544', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:11:03.957', '2026-04-01 00:11:05.269', 1312, NULL, '2026-04-01 00:11:03.957', '2026-04-01 00:11:05.271', 0),
('2039012610229198849', '2039012603522506752', '2039012610229198848', '2039012610225004544', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:11:03.958', '2026-04-01 00:11:05.268', 1310, NULL, '2026-04-01 00:11:03.958', '2026-04-01 00:11:05.268', 0),
('2039012610233393152', '2039012603522506752', '2039012610229198850', '2039012610229198848', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:11:03.958', '2026-04-01 00:11:05.264', 1306, NULL, '2026-04-01 00:11:03.959', '2026-04-01 00:11:05.265', 0),
('2039012615740514304', '2039012603522506752', '2039012615736320000', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:11:05.271', '2026-04-01 00:11:06.332', 1061, NULL, '2026-04-01 00:11:05.272', '2026-04-01 00:11:06.333', 0),
('2039012615761485825', '2039012603522506752', '2039012615761485824', '2039012615736320000', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:11:05.277', '2026-04-01 00:11:06.326', 1049, NULL, '2026-04-01 00:11:05.277', '2026-04-01 00:11:06.328', 0),
('2039012615765680129', '2039012603522506752', '2039012615765680128', '2039012615761485824', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:11:05.278', '2026-04-01 00:11:06.314', 1036, NULL, '2026-04-01 00:11:05.278', '2026-04-01 00:11:06.316', 0),
('2039012620207448064', '2039012603522506752', '2039012620199059456', NULL, 0, 'RETRIEVE', 'retrieval-engine', 'com.nageoffer.ai.ragent.rag.core.retrieve.RetrievalEngine', 'retrieve', 'SUCCESS', NULL, '2026-04-01 00:11:06.335', '2026-04-01 00:11:06.59', 255, NULL, '2026-04-01 00:11:06.337', '2026-04-01 00:11:06.591', 0),
('2039012620232613889', '2039012603522506752', '2039012620232613888', '2039012620199059456', 1, 'RETRIEVE_CHANNEL', 'multi-channel-retrieval', 'com.nageoffer.ai.ragent.rag.core.retrieve.MultiChannelRetrievalEngine', 'retrieveKnowledgeChannels', 'SUCCESS', NULL, '2026-04-01 00:11:06.343', '2026-04-01 00:11:06.588', 245, NULL, '2026-04-01 00:11:06.343', '2026-04-01 00:11:06.588', 0),
('2039012621285384193', '2039012603522506752', '2039012621285384192', NULL, 0, 'LLM_ROUTING', 'llm-stream-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'streamChat', 'SUCCESS', NULL, '2026-04-01 00:11:06.594', '2026-04-01 00:11:07.271', 677, NULL, '2026-04-01 00:11:06.594', '2026-04-01 00:11:07.272', 0),
('2039012621289578497', '2039012603522506752', '2039012621289578496', '2039012621285384192', 1, 'LLM_PROVIDER', 'bailian-stream-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'streamChat', 'SUCCESS', NULL, '2026-04-01 00:11:06.595', '2026-04-01 00:11:06.598', 3, NULL, '2026-04-01 00:11:06.595', '2026-04-01 00:11:06.598', 0),
('2039015015524134912', '2039015015079538688', '2039015015515746304', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:20:37.423', '2026-04-01 00:20:38.773', 1350, NULL, '2026-04-01 00:20:37.425', '2026-04-01 00:20:38.774', 0),
('2039015015557689344', '2039015015079538688', '2039015015553495040', '2039015015515746304', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:20:37.432', '2026-04-01 00:20:38.753', 1321, NULL, '2026-04-01 00:20:37.433', '2026-04-01 00:20:38.76', 0),
('2039015021199028224', '2039015015079538688', '2039015021194833920', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:20:38.777', '2026-04-01 00:20:40.514', 1737, NULL, '2026-04-01 00:20:38.779', '2026-04-01 00:20:40.515', 0),
('2039015021211611137', '2039015015079538688', '2039015021211611136', '2039015021194833920', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:20:38.781', '2026-04-01 00:20:40.51', 1729, NULL, '2026-04-01 00:20:38.781', '2026-04-01 00:20:40.51', 0),
('2039015021224194049', '2039015015079538688', '2039015021224194048', '2039015021211611136', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:20:38.784', '2026-04-01 00:20:40.507', 1723, NULL, '2026-04-01 00:20:38.784', '2026-04-01 00:20:40.507', 0),
('2039015028497117184', '2039015015079538688', '2039015028492922880', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:20:40.517', '2026-04-01 00:20:41.535', 1018, NULL, '2026-04-01 00:20:40.518', '2026-04-01 00:20:41.536', 0),
('2039015028526477313', '2039015015079538688', '2039015028526477312', '2039015028492922880', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:20:40.525', '2026-04-01 00:20:41.521', 996, NULL, '2026-04-01 00:20:40.525', '2026-04-01 00:20:41.521', 0),
('2039015028534865921', '2039015015079538688', '2039015028534865920', '2039015028526477312', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:20:40.527', '2026-04-01 00:20:41.516', 989, NULL, '2026-04-01 00:20:40.527', '2026-04-01 00:20:41.518', 0),
('2039019351515922432', '2039019351130046464', '2039019351507533824', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:37:51.204', '2026-04-01 00:37:52.366', 1162, NULL, '2026-04-01 00:37:51.206', '2026-04-01 00:37:52.366', 0),
('2039019351541088257', '2039019351130046464', '2039019351541088256', '2039019351507533824', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:37:51.212', '2026-04-01 00:37:52.355', 1143, NULL, '2026-04-01 00:37:51.212', '2026-04-01 00:37:52.362', 0),
('2039019356402286592', '2039019351130046464', '2039019356398092288', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:37:52.37', '2026-04-01 00:37:53.858', 1488, NULL, '2026-04-01 00:37:52.371', '2026-04-01 00:37:53.858', 0),
('2039019356414869504', '2039019351130046464', '2039019356410675200', '2039019356398092288', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:37:52.373', '2026-04-01 00:37:53.853', 1480, NULL, '2026-04-01 00:37:52.374', '2026-04-01 00:37:53.855', 0),
('2039019356419063809', '2039019351130046464', '2039019356419063808', '2039019356410675200', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:37:52.375', '2026-04-01 00:37:53.85', 1475, NULL, '2026-04-01 00:37:52.375', '2026-04-01 00:37:53.85', 0),
('2039019362647605249', '2039019351130046464', '2039019362647605248', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:37:53.86', '2026-04-01 00:37:54.516', 656, NULL, '2026-04-01 00:37:53.86', '2026-04-01 00:37:54.517', 0),
('2039019362689548289', '2039019351130046464', '2039019362689548288', '2039019362647605248', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:37:53.87', '2026-04-01 00:37:54.504', 634, NULL, '2026-04-01 00:37:53.87', '2026-04-01 00:37:54.504', 0),
('2039019362697936897', '2039019351130046464', '2039019362697936896', '2039019362689548288', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:37:53.872', '2026-04-01 00:37:54.501', 629, NULL, '2026-04-01 00:37:53.872', '2026-04-01 00:37:54.502', 0),
('2039019439294316545', '2039019439172681728', '2039019439294316544', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:38:12.134', '2026-04-01 00:38:13.629', 1495, NULL, '2026-04-01 00:38:12.134', '2026-04-01 00:38:13.629', 0),
('2039019439298510849', '2039019439172681728', '2039019439298510848', '2039019439294316544', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:38:12.135', '2026-04-01 00:38:13.628', 1493, NULL, '2026-04-01 00:38:12.135', '2026-04-01 00:38:13.628', 0),
('2039019439302705153', '2039019439172681728', '2039019439302705152', '2039019439298510848', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:38:12.136', '2026-04-01 00:38:13.617', 1481, NULL, '2026-04-01 00:38:12.136', '2026-04-01 00:38:13.617', 0),
('2039019445568995329', '2039019439172681728', '2039019445568995328', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:38:13.63', '2026-04-01 00:38:14.762', 1132, NULL, '2026-04-01 00:38:13.631', '2026-04-01 00:38:14.762', 0),
('2039019445594161153', '2039019439172681728', '2039019445594161152', '2039019445568995328', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:38:13.636', '2026-04-01 00:38:14.759', 1123, NULL, '2026-04-01 00:38:13.636', '2026-04-01 00:38:14.76', 0),
('2039019445602549761', '2039019439172681728', '2039019445602549760', '2039019445594161152', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:38:13.638', '2026-04-01 00:38:14.748', 1110, NULL, '2026-04-01 00:38:13.638', '2026-04-01 00:38:14.75', 0),
('2039020740421947392', '2039020739927019520', '2039020740413558784', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:43:22.345', '2026-04-01 00:43:23.675', 1330, NULL, '2026-04-01 00:43:22.347', '2026-04-01 00:43:23.677', 0),
('2039020740459696128', '2039020739927019520', '2039020740455501824', '2039020740413558784', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:43:22.355', '2026-04-01 00:43:23.664', 1309, NULL, '2026-04-01 00:43:22.356', '2026-04-01 00:43:23.672', 0),
('2039020746012954625', '2039020739927019520', '2039020746012954624', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 00:43:23.68', '2026-04-01 00:43:25.368', 1688, NULL, '2026-04-01 00:43:23.68', '2026-04-01 00:43:25.368', 0),
('2039020746021343232', '2039020739927019520', '2039020746017148928', '2039020746012954624', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:43:23.681', '2026-04-01 00:43:25.366', 1685, NULL, '2026-04-01 00:43:23.682', '2026-04-01 00:43:25.366', 0),
('2039020746021343234', '2039020739927019520', '2039020746021343233', '2039020746017148928', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:43:23.682', '2026-04-01 00:43:25.363', 1681, NULL, '2026-04-01 00:43:23.682', '2026-04-01 00:43:25.364', 0),
('2039020753097134081', '2039020739927019520', '2039020753097134080', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 00:43:25.369', '2026-04-01 00:43:26.869', 1500, NULL, '2026-04-01 00:43:25.369', '2026-04-01 00:43:26.869', 0),
('2039020753126494209', '2039020739927019520', '2039020753126494208', '2039020753097134080', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 00:43:25.376', '2026-04-01 00:43:26.854', 1478, NULL, '2026-04-01 00:43:25.376', '2026-04-01 00:43:26.855', 0),
('2039020753130688513', '2039020739927019520', '2039020753130688512', '2039020753126494208', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 00:43:25.377', '2026-04-01 00:43:26.844', 1467, NULL, '2026-04-01 00:43:25.378', '2026-04-01 00:43:26.845', 0),
('2039205334756696064', '2039205334203047936', '2039205334748307456', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 12:56:53.064', '2026-04-01 12:56:54.512', 1448, NULL, '2026-04-01 12:56:53.066', '2026-04-01 12:56:54.514', 0),
('2039205334790250496', '2039205334203047936', '2039205334786056192', '2039205334748307456', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 12:56:53.073', '2026-04-01 12:56:54.496', 1423, NULL, '2026-04-01 12:56:53.074', '2026-04-01 12:56:54.507', 0),
('2039205340855214081', '2039205334203047936', '2039205340855214080', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 12:56:54.52', '2026-04-01 12:56:56.278', 1758, NULL, '2026-04-01 12:56:54.52', '2026-04-01 12:56:56.28', 0),
('2039205340871991296', '2039205334203047936', '2039205340867796992', '2039205340855214080', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 12:56:54.523', '2026-04-01 12:56:56.272', 1749, NULL, '2026-04-01 12:56:54.524', '2026-04-01 12:56:56.274', 0),
('2039205340897157120', '2039205334203047936', '2039205340884574208', '2039205340867796992', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 12:56:54.528', '2026-04-01 12:56:56.261', 1733, NULL, '2026-04-01 12:56:54.53', '2026-04-01 12:56:56.262', 0),
('2039205348245577728', '2039205334203047936', '2039205348241383424', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 12:56:56.281', '2026-04-01 12:56:56.884', 603, NULL, '2026-04-01 12:56:56.282', '2026-04-01 12:56:56.885', 0),
('2039205348287520769', '2039205334203047936', '2039205348287520768', '2039205348241383424', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 12:56:56.292', '2026-04-01 12:56:56.866', 574, NULL, '2026-04-01 12:56:56.292', '2026-04-01 12:56:56.867', 0),
('2039205348295909376', '2039205334203047936', '2039205348291715072', '2039205348287520768', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 12:56:56.293', '2026-04-01 12:56:56.854', 561, NULL, '2026-04-01 12:56:56.294', '2026-04-01 12:56:56.856', 0),
('2039209159760621568', '2039209159299248128', '2039209159756427264', NULL, 0, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 13:12:05.017', '2026-04-01 13:12:06.725', 1708, NULL, '2026-04-01 13:12:05.018', '2026-04-01 13:12:06.726', 0),
('2039209159789981696', '2039209159299248128', '2039209159785787392', '2039209159756427264', 1, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 13:12:05.024', '2026-04-01 13:12:06.705', 1681, NULL, '2026-04-01 13:12:05.025', '2026-04-01 13:12:06.712', 0),
('2039209166941270017', '2039209159299248128', '2039209166941270016', NULL, 0, 'REWRITE', 'query-rewrite-and-split', 'com.nageoffer.ai.ragent.rag.core.rewrite.MultiQuestionRewriteService', 'rewriteWithSplit', 'SUCCESS', NULL, '2026-04-01 13:12:06.73', '2026-04-01 13:12:08.225', 1495, NULL, '2026-04-01 13:12:06.73', '2026-04-01 13:12:08.226', 0),
('2039209166953852928', '2039209159299248128', '2039209166949658624', '2039209166941270016', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 13:12:06.732', '2026-04-01 13:12:08.223', 1491, NULL, '2026-04-01 13:12:06.733', '2026-04-01 13:12:08.224', 0),
('2039209166966435841', '2039209159299248128', '2039209166966435840', '2039209166949658624', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 13:12:06.736', '2026-04-01 13:12:08.213', 1477, NULL, '2026-04-01 13:12:06.736', '2026-04-01 13:12:08.214', 0),
('2039209173232726016', '2039209159299248128', '2039209173224337408', NULL, 0, 'INTENT', 'intent-resolve', 'com.nageoffer.ai.ragent.rag.core.intent.IntentResolver', 'resolve', 'SUCCESS', NULL, '2026-04-01 13:12:08.23', '2026-04-01 13:12:08.84', 610, NULL, '2026-04-01 13:12:08.23', '2026-04-01 13:12:08.841', 0),
('2039209173257891840', '2039209159299248128', '2039209173253697536', '2039209173224337408', 1, 'LLM_ROUTING', 'llm-chat-routing', 'com.nageoffer.ai.ragent.infra.chat.RoutingLLMService', 'chat', 'SUCCESS', NULL, '2026-04-01 13:12:08.235', '2026-04-01 13:12:08.83', 595, NULL, '2026-04-01 13:12:08.237', '2026-04-01 13:12:08.83', 0),
('2039209173270474753', '2039209159299248128', '2039209173270474752', '2039209173253697536', 2, 'LLM_PROVIDER', 'bailian-chat', 'com.nageoffer.ai.ragent.infra.chat.BaiLianChatClient', 'chat', 'SUCCESS', NULL, '2026-04-01 13:12:08.239', '2026-04-01 13:12:08.826', 587, NULL, '2026-04-01 13:12:08.239', '2026-04-01 13:12:08.828', 0);




INSERT INTO "public"."t_knowledge_vector" ("id", "content", "metadata", "embedding") VALUES
('2038163866487119873', 'Web前端核心概念

一、JavaScript核心

1. 闭包
定义：闭包是指有权访问另一个函数作用域中变量的函数。
原理：函数 + 词法环境，内部函数可以访问外部函数的变量。
应用场景：封装私有变量、防抖节流、模块化模式。
注意事项：闭包会持有外部变量引用，可能导致内存泄漏。

2. 原型和原型链
定义：每个对象都有一个隐式的原型对象（__proto__），指向其构造函数的prototype属性。
原型链：当访问对象属性时，如果自身没有，会沿着原型链向上查找。
核心要点：Object.prototype是原型链的顶端，原型链实现继承。

3. 事件循环
定义：JavaScript处理异步任务的执行模型。
宏任务：setTimeout、setInterval、I/O、DOM事件、script整体代码。
微任务：Promise.then、MutationObserver、queueMicrotask。
执行顺序：执行当前宏任务 -> 清空微任务队列 -> 执行下一个宏任务。

4. Promise和异步编程
Promise状态：pending、fulfilled、rejected。
特点：状态不可逆、支持链式调用、解决回调地狱。
async/await：Promise的语法糖，使异步代码更同步化。

二、Vue框架核心

1. Vue生命周期
创建阶段：beforeCreate -> created
挂载阶段：beforeMount -> mounted
更新阶段：beforeUpdate -> updated
销毁阶段：beforeDestroy -> destroyed
说明：created可访问数据但DOM未生成，mounted可访问DOM。

2. 响应式原理
Vue2：Object.defineProperty劫持数据getter/setter。
Vue3：Proxy代理整个对象，支持数组和动态属性。
流程：数据变化 -> 触发setter -> 通知依赖 -> 组件重新渲染 -> 更新DOM。

3. 虚拟DOM和Diff算法
虚拟DOM：用JavaScript对象描述真实DOM结构，减少直接操作DOM。
Diff算法：同层比较，通过key标识节点复用元素，时间复杂度O(n)。

三、浏览器核心

1. 渲染原理
流程：解析HTML生成DOM树 -> 解析CSS生成CSSOM树 -> 合并为渲染树 -> 布局计算位置 -> 绘制像素 -> 合成显示。

2. 重排和重绘
重排：布局发生变化（位置、大小），代价最高。
重绘：外观发生变化（颜色、背景），不改变布局。
触发重排的操作：添加/删除DOM元素、改变尺寸、改变窗口大小。
优化建议：用transform代替top/left，批量修改样式。

3. 跨域
定义：浏览器同源策略，协议、域名、端口任一不同即跨域。
解决方案：CORS（后端设置响应头）、代理（开发环境proxy）、JSONP（仅GET请求）、postMessage。

四、性能优化核心

1. 首屏优化
网络层：CDN加速、HTTP/2、Gzip压缩。
资源层：图片懒加载、路由懒加载、代码分割。
缓存层：强缓存、协商缓存。
渲染层：骨架屏、减少重排重绘。

2. 内存管理
常见内存泄漏：意外的全局变量、未清理的定时器、未解绑的DOM事件、闭包持有外部变量。
解决方法：严格模式、组件销毁时清理、手动解除引用。

五、常见面试题

1. 什么是闭包？有什么作用？
参考答案：闭包是指有权访问另一个函数作用域中变量的函数。作用包括封装私有变量、实现模块化、保存变量状态。

2. 什么是事件循环？宏任务和微任务有什么区别？
参考答案：事件循环是JavaScript处理异步任务的执行模型。宏任务包括setTimeout、I/O等，微任务包括Promise.then。每个宏任务执行后会先清空微任务队列。

3. Vue的生命周期有哪些？
参考答案：beforeCreate、created、beforeMount、mounted、beforeUpdate、updated、beforeDestroy、destroyed。

4. 如何优化首屏加载速度？
参考答案：CDN加速、路由懒加载、图片懒加载、代码分割、Gzip压缩、骨架屏。', '{"doc_id": "2038163842562809856", "chunk_index": 0, "collection_name": "web"}', '[0.08059249,-0.04552701,-0.04920792,-0.023635298,0.009202268,-0.03177204,-0.018888867,0.06819365,0.036227874,0.03642161,0.00070227834,-0.00044800516,-0.0028454382,0.04746433,0.026347546,0.03448429,-0.024410227,-0.023441566,0.020341856,0.04048998,0.008088309,0.034290556,-0.028284866,-0.027897403,-0.03855266,0.081367426,-0.036227874,-0.048820455,-0.014336165,0.017145278,-0.010800556,-0.018888867,-0.06354408,0.054244947,0.011430185,0.011381753,-0.004504268,0.0012592577,0.060831834,0.021504248,-0.0069259177,0.052307628,0.011527051,0.03351563,-4.2946438e-05,-0.037196536,-0.013948701,0.019470062,-0.014045567,0.0019857525,0.042427298,-0.02770367,0.0009928762,0.033903092,0.07013097,-0.023732165,-0.049982846,-0.024410227,-0.009638165,0.0056424434,-0.043977153,0.016467215,0.019857526,0.0035113918,0.0070227836,-0.01782334,0.007749278,0.03157831,-0.011430185,-0.040683713,-0.011236453,-0.009347567,-0.027316205,0.02576635,0.032353237,-0.059669442,-0.013851835,-0.0034629588,0.058119588,0.009347567,0.015498556,0.049595382,0.031965774,0.0040441547,0.0070712166,-0.03157831,0.015789155,0.0021431597,-0.019566927,-0.045914475,-0.0010534176,0.031190844,0.0010534176,0.028478598,-0.026928741,-0.019179463,-0.023925897,-0.012786309,-0.019082598,-0.017629609,0.033903092,-0.009928763,0.030028453,0.021213649,0.00081125257,-0.026928741,-0.018598268,-0.00082941493,-0.0036566907,-0.041846104,0.004843299,0.03990878,0.013076907,0.020535588,0.014336165,0.027316205,-0.025185155,0.03293443,-0.005230763,0.026153814,-0.049982846,0.0068290513,0.04048998,-0.0049643815,-0.021213649,0.018598268,-0.029447258,0.03661534,0.0013924484,0.05269509,-0.02964099,0.007894577,0.010461526,-0.048239257,-0.024410227,0.001319799,0.024507092,0.04165237,-0.047076866,0.008766371,0.05540734,0.0023732164,0.016951546,-0.01830767,0.010606824,-0.024410227,-0.0072649485,0.0050370307,-0.022472907,0.03157831,0.010994288,-0.038358927,-0.008282041,0.020148123,-0.036809072,0.021310516,0.021213649,0.023344701,-0.03739027,-0.015595422,-0.043202225,0.015207958,-0.02140738,-0.02169798,0.04339596,-0.012883175,-0.01782334,0.0032692268,0.005521361,0.01666095,-0.0016709381,0.033709362,-0.013076907,0.024022764,0.0042621032,0.014917361,0.0072649485,0.0067806183,0.0137549685,0.0006175206,-0.018598268,0.008814804,-0.03564668,0.04358969,-0.010461526,-0.016273484,-0.010267794,-0.023054102,0.024700824,0.036034144,0.012592577,-0.05347002,-0.0017678041,0.0010231469,0.04436462,0.019373195,0.009250701,0.024991423,0.030222185,0.040683713,0.022569774,0.06393155,-0.0005176276,-0.011720783,0.0075071133,-0.0067806183,-0.05269509,-0.03855266,-0.028478598,-0.026153814,-0.02140738,0.0333219,0.0036809072,0.0025064072,-0.013173773,0.00019297519,-0.05347002,0.0075555462,0.010170928,-0.022085443,-0.034290556,-0.05618227,0.011430185,0.02867233,0.020923052,0.040102515,-0.046883132,-0.014529897,-0.011527051,-0.018695135,0.036809072,-0.0015619639,0.012592577,0.0011926624,-0.03467802,0.021213649,-0.007700845,0.0008899562,-0.01995439,-0.005327629,-0.021891711,0.018017072,-0.008427341,-0.041846104,-0.00607834,-0.040296245,-0.031384576,-0.027316205,0.12011381,-0.023732165,0.0333219,0.025378887,-0.015304824,0.02140738,-0.0059572575,0.009686598,-0.0017193711,-0.02218231,-0.01084899,0.03739027,-0.0015498557,0.021116784,0.017532742,0.01637035,-0.013851835,-0.0019857525,-0.04262103,-0.02770367,-0.010994288,0.025378887,-0.0028938712,-0.012980041,-0.011720783,0.0006962242,-0.04630194,0.008378907,-0.019373195,-0.043977153,0.027316205,0.021988576,-0.027509937,-0.026347546,0.027316205,-0.053857483,0.0065868865,-0.02770367,0.04940165,0.06276915,0.015789155,-0.009008536,-0.0068290513,-0.024216495,0.004698,-0.005133897,0.018404536,-0.021504248,0.025960082,-0.01995439,-0.012495711,0.015595422,0.012689443,-0.027122473,0.0007295219,0.04572074,-0.050757773,-0.0072649485,-0.008717938,-0.012495711,-0.021310516,-0.010170928,-0.008766371,-0.032353237,-0.029253526,-0.014626763,-0.008669505,0.012592577,0.04920792,0.032546967,-0.013270639,0.002700139,0.019179463,-0.0050128144,-0.033128165,0.008233608,0.024700824,0.023925897,-0.0009444433,0.0070227836,-0.026153814,0.004407402,0.027316205,-0.008863237,-0.03855266,-0.01782334,-0.03584041,-0.027122473,-0.032353237,-0.053857483,0.039327588,0.011430185,0.036227874,-0.009299134,0.012883175,-0.0073618144,0.0019736444,-0.038165197,-0.009250701,0.0069259177,-0.037002806,0.026541278,-0.06625633,-0.022569774,-0.055794805,-0.001374286,-0.0004934111,0.003087603,-0.03351563,-0.0057877423,-0.03177204,0.017435877,0.0098803295,0.004407402,-0.017920205,-0.038358927,0.041264907,-0.016757814,0.0019009948,-0.012011382,-0.009541299,0.008960103,-0.039327588,0.009928763,-0.048239257,0.01070369,0.021504248,0.017629609,-0.039521318,0.0071680825,0.0038988555,0.009347567,0.023635298,-0.033128165,0.0026153815,-0.03351563,-0.0123988455,-0.01666095,-0.009686598,-0.038940124,0.017048413,-0.0031239279,0.015595422,0.037196536,-0.00039049098,-0.01666095,-0.017532742,0.015304824,0.04746433,-0.029059794,0.02964099,0.0033903092,-0.006102557,0.01830767,0.029059794,-0.008282041,-0.013658103,-0.019470062,-0.019857526,-0.016273484,0.030415917,-0.036809072,0.0515327,0.0055455775,0.00045405928,0.008330475,-0.011623917,0.053082556,0.029253526,0.012883175,-0.0046253507,-0.051145237,-0.005376062,-0.0018888866,-0.0327407,0.038358927,-0.039133854,0.0055940105,0.029834721,-0.0012350412,0.036034144,-0.002397433,0.0073133814,-0.021891711,-0.029253526,0.007700845,-0.004746433,-0.044945814,0.020051258,0.049014185,0.032159504,0.02072932,0.020923052,0.043202225,0.013367505,-0.055794805,-0.010752124,0.012495711,-0.026928741,-0.0055697937,0.018501403,-0.0016225051,0.01540169,0.010994288,-0.061219297,0.011866082,-0.015982887,-0.008766371,0.026347546,0.005085464,-0.005448711,-0.008863237,0.017532742,-0.022472907,0.026347546,-0.03157831,0.01733901,0.0010231469,-0.022957237,-0.023732165,-0.0004994652,-0.04281476,-0.05734466,-0.024022764,-0.04262103,0.02024499,0.012786309,-0.013270639,0.01927633,-0.018888867,0.023247834,0.0018767783,0.009928763,0.014045567,-0.041846104,0.024991423,0.0032934432,0.0075071133,-0.011430185,0.025572618,-0.0050370307,0.015498556,-0.006175206,-0.009492866,0.03661534,-0.05734466,0.010558392,-0.031965774,0.033128165,-0.018210804,0.013658103,-0.0327407,-0.009444433,0.029834721,-0.06393155,0.004504268,-0.04339596,0.0031723608,-0.0031481443,-0.039327588,0.056569733,-0.03351563,0.00518233,-0.01084899,-0.03448429,0.026153814,-0.02024499,0.020438721,-0.021601113,-0.005981474,0.010316227,0.034096826,-0.0056424434,0.0074586803,0.02072932,-0.005521361,-0.030028453,0.04262103,0.017532742,0.006102557,0.008814804,-0.014239299,-0.023247834,0.038165197,-0.04862672,-0.013367505,-0.0066353194,0.005521361,0.011042722,0.0048675155,-0.027122473,-0.014626763,0.008282041,0.021116784,0.00033751738,0.011236453,-0.011042722,-0.053082556,0.008233608,-0.019566927,-0.029834721,0.024507092,-0.01637035,0.003075495,0.037971463,-0.0064415876,0.00023157023,0.0070712166,-0.008427341,-0.029447258,0.020632453,0.01070369,-0.015595422,0.00041470747,-0.013851835,-0.023538433,-0.0005236817,-0.0059572575,0.011284887,-0.013464371,-0.00039957216,0.024700824,-0.0327407,0.014239299,-0.023247834,-0.0030028454,-0.013367505,0.03584041,-0.027509937,-0.04281476,0.028478598,-0.00058422296,-0.010461526,-0.027316205,-0.001961536,-0.014723629,0.0044800513,-0.02315097,-0.024022764,-0.009299134,-0.011236453,-0.014723629,0.0137549685,0.0056424434,0.005933041,0.028478598,0.018985732,-0.013367505,0.0044316184,-0.027122473,0.0032450103,0.05463241,0.037584,-0.011333319,-0.041264907,-0.0327407,0.0041410206,0.023247834,-0.0073133814,-0.030028453,0.018210804,0.036034144,-0.026541278,0.013464371,-0.032546967,-0.018017072,0.024507092,0.035065483,0.018501403,-0.0047706496,-0.030415917,0.031965774,0.013076907,-0.032546967,-0.01927633,-0.012592577,0.04572074,-0.015595422,-0.0009202268,0.036227874,-0.009492866,-0.008863237,-0.011575485,0.008282041,0.029059794,0.007749278,-0.014529897,0.0071196496,-0.0030028454,0.0022158092,0.02072932,-0.0018767783,0.013561237,-0.013076907,0.0066837524,0.0057393094,-0.015982887,-0.03448429,0.018210804,0.0035598248,-0.014626763,-4.8811373e-05,0.043008495,0.003923072,-0.0005267088,-0.038358927,0.025185155,0.05928198,-0.029834721,-0.012980041,-0.010800556,-0.009008536,-0.023441566,0.015982887,-0.0072649485,0.00096260564,0.02024499,-0.021988576,0.010025629,-0.0050612474,-0.013076907,-0.0066837524,-0.022085443,0.011962948,0.025572618,0.020535588,0.008621072,-0.011962948,0.028866062,-0.024797691,-0.0033176597,-0.0105099585,-0.04746433,-0.016757814,0.0009928762,0.0009868222,-0.0012955825,-0.0012350412,0.0007870361,-0.009202268,-0.0123988455,-0.04455835,0.008088309,-0.00064173713,-0.00014983956,0.004504268,0.017145278,0.032546967,0.0044800513,-0.012059814,0.0059088245,0.0037051237,0.0098803295,-0.034290556,-0.014723629,-0.021116784,-0.012786309,0.0049885977,0.005933041,-0.010558392,-0.02770367,-0.010122495,0.023538433,0.015789155,-0.0026153815,-0.0070712166,0.014433031,-0.0035113918,0.075942926,-0.012253546,0.0105099585,-0.024507092,0.051920164,0.0034387421,-0.02169798,-0.0137549685,-0.037971463,-0.0039472887,0.030997112,0.019470062,0.010945856,0.018598268,-0.008475773,0.035452947,-0.028478598,0.0073618144,-0.023635298,0.0151110925,-0.03971505,0.02964099,0.05269509,-0.02431336,0.0016225051,0.034290556,-0.012883175,-0.015014227,-0.047270596,0.022279175,-0.009153835,0.040877443,-0.01637035,-0.011623917,0.0025669485,-0.007749278,0.038358927,0.0015740722,0.024700824,-0.05850705,-0.0056182267,0.0024821907,0.0032934432,0.0105099585,0.0027243556,-0.013561237,0.031384576,0.016273484,0.0031239279,0.010558392,-0.030609649,0.008330475,0.026347546,0.048045527,0.030997112,0.021504248,0.019566927,0.009735031,0.05540734,0.042427298,0.0032450103,0.02024499,0.017435877,0.07206829,-0.005400278,-0.00021946199,-0.026153814,-0.03661534,-0.013367505,-0.014723629,-0.009105402,0.084854595,-0.017242145,-0.009735031,-0.0057877423,0.015014227,-0.0023368918,0.016854681,-0.008088309,0.013173773,-0.040296245,-0.032159504,0.03467802,0.0016467216,-0.035065483,0.048820455,0.026153814,-0.04572074,0.024216495,0.0029059793,0.06935604,-0.0065868865,-0.007700845,-0.104615256,-0.019373195,0.05540734,-0.011962948,-0.035065483,0.04455835,0.02024499,-0.00891167,0.013270639,0.0105099585,-0.021988576,0.034290556,0.012786309,0.005933041,0.029059794,-0.018113937,-0.0056908764,-0.06315662,0.0072649485,0.026541278,0.008088309,-0.010025629,0.016854681,-0.01588602,0.02964099,-0.018792,-0.017629609,0.0037293402,-0.011381753,-0.011962948,0.010606824,0.06315662,0.025960082,0.026153814,0.016079752,0.013561237,0.024507092,0.017629609,0.013851835,-0.0070227836,0.0018404536,-0.0069743507,-0.025960082,-0.031965774,0.0015982887,0.024700824,-0.002252134,0.03080338,0.006054124,-0.01540169,0.0026153815,-0.027509937,0.007603979,0.02286037,0.0028212217,0.018792,0.01782334,-0.02218231,0.04862672,-0.03448429,-0.019082598,0.007749278,-0.03157831,-0.04339596,0.024022764,-0.032546967,-0.021213649,-0.028478598,0.024991423,0.018792,0.009347567,-0.0058361753,-0.011091155,0.022569774,0.03971505,-0.008572639,0.004019938,0.0061994228,0.012205114,-0.015595422,-0.03564668,0.050757773,-0.03448429,-0.022472907,0.022569774,0.03467802,-0.014142433,0.03564668,0.037584,0.029834721,-0.0072165155,-0.0018404536,-0.018017072,-0.03874639,-0.015014227,-0.03661534,-0.034290556,0.046108205,-0.004310536,-0.036227874,0.026541278,-0.0036566907,-0.0017556959,0.05269509,0.0024821907,-0.004746433,0.03080338,-0.036034144,-0.05269509,0.041846104,-0.0005600064,-0.02218231,0.0005236817,-0.009686598,0.013561237,0.051145237,-0.022666639,0.017145278,0.046108205,0.01084899,-0.026928741,0.0029423041,-0.0074102473,0.036034144,0.028866062,-0.02315097,0.004358969,-0.004891732,0.035259217,-0.0123988455,-0.009638165,-0.031190844,-0.013658103,-0.011575485,-0.042039834,-0.0073133814,0.011866082,0.0029059793,0.04436462,-0.05850705,-0.008814804,0.005424495,-0.024410227,-0.025960082,0.032546967,0.0327407,0.009977195,-0.007991443,0.017048413,-0.007846144,0.009638165,-0.041071177,-0.030609649,0.0022400257,0.013658103,0.010413093,0.029834721,0.022763506,0.008136742,0.0014166649,0.003874639,-0.002300567,-0.033903092,-0.016564082,-0.008669505,-0.008330475,-0.011284887,0.056569733,0.024216495,-0.01733901,-0.020148123,0.02964099,0.017920205,-0.0069743507,0.0111395875,-0.005400278,0.019760659,0.017435877,-0.0072165155,-0.0010170927,0.12398845,0.009396,-0.0013985026,0.0041410206,0.004552701,0.07323068,0.005327629,0.012495711,-0.020051258,-0.016079752,0.03080338,0.024216495,0.035065483,0.0071196496,0.0046253507,-0.0059572575,-0.018888867,-0.009008536,-0.007700845,-0.023732165,0.04630194,0.0123988455,0.035259217,0.008814804,0.0056666597,-0.0105099585,-0.021019917,-0.016951546,0.02218231,-0.04862672,0.012205114,0.009299134,0.0058119586,-0.0024216494,-0.003923072,-0.0072165155,0.039133854,-0.007846144,-0.0038988555,0.04940165,-0.010897422,-0.009492866,0.021310516,0.00064476416,-0.009589732,0.01036466,-0.039521318,-0.013561237,-0.0064900205,-0.03739027,0.021019917,-0.008039876,0.0017193711,-0.0009565515,-0.021504248,0.033709362,0.014336165,-0.010752124,-0.025960082,-0.034290556,-0.03661534,-0.008233608,0.029447258,-0.0047222166,-0.011478619,0.0068774843,0.008378907,-0.012786309,0.030028453,-0.0085242065,-0.005085464,-0.016079752,0.015304824,0.058894515,-0.0028938712,0.0061994228,0.04649567,0.027122473,-0.00607834,0.0026153815,0.013948701,-0.021310516,0.0027243556,-0.021213649,-0.0018404536,0.045914475,0.0031239279,-0.013270639,-0.02576635,-0.021794844,-0.0026638145,-0.0069259177,-0.02576635,-0.004601134,-0.022569774,0.02673501,0.012350412,0.02576635,-0.016854681,-0.010267794,0.014626763,0.025960082,-0.06354408,0.04048998,0.016757814,0.024797691,-0.035259217,0.037971463,-0.018985732,0.005981474,0.0057393094,-0.005400278,0.019082598,0.01733901,0.022376042,0.00018994813,-0.043783423,0.027897403,-0.008185175,-0.015595422,-0.02964099,0.037971463,0.050757773,0.020438721,-0.021116784,-0.06160676,0.013948701,-0.0032692268,0.01084899,0.016467215,0.002990737,-0.013851835,0.037196536,0.020826185,-0.0072649485,-0.034096826,-0.001368232,0.029447258,0.019373195,-0.013658103,0.006054124,0.030609649,0.0050370307,-0.016564082,-0.0010957964,-0.021891711,0.02140738,-0.005085464,-0.011478619,0.015982887,0.02024499,0.0045284843,0.006005691,-0.017242145,0.009831897,-0.039521318,0.029253526,0.00016724516,-0.008863237,0.043977153,-0.04048998,0.01084899,-0.043977153,0.010800556,0.001374286,0.009638165,-0.033709362,-0.0055455775,0.014820495,-0.019179463,0.0026638145,0.0055697937,0.013851835,0.037777733,-0.0051581133,0.0033660927,0.029447258,-0.0013803402,-0.01995439,0.023344701,0.049014185,0.017629609,-0.013851835,-0.04862672,-0.019373195,0.0058361753,0.007991443,-0.00022702964,-0.036227874,0.067418724,-0.01830767,0.034096826,0.00615099,-0.009735031,0.021019917,0.014433031,-0.0047706496,-0.0333219,0.0010049845,-0.0048190826,0.018404536,0.0059088245,0.012786309,-0.02315097,0.028284866,-0.002542732,0.0039472887,-0.0013379613,-0.004843299,-0.022085443,0.01830767,0.03739027,0.012059814,0.06238169,0.013464371,0.0018525618,0.03584041,0.024119629,-0.04281476,0.02072932,0.022957237,-0.001029201,-0.0098803295,-0.025378887,-0.0137549685,-0.026347546,0.007749278,0.0058846083,0.04552701,0.013561237,-0.0019857525,0.015014227,-0.0022763505,-0.043008495,0.01637035,0.02673501,-0.0042378865,0.0031481443,-0.0050370307,0.005085464,-0.011672351,-0.01540169,0.0004752487,-0.008427341,-0.022763506,0.007894577,0.010122495,0.030997112,-0.017920205,0.0030512784,0.011527051,-0.046108205,-0.018404536,0.021988576,-0.0075555462,-0.014239299,-0.013464371,0.061994225,-0.0069259177,0.003874639,-0.019373195,-0.032353237,-0.024119629,0.0002633544,-0.032159504,-0.010122495,0.0030028454,0.00016043428,0.013173773,-0.022763506,-0.014723629,0.0070712166,0.013076907,-0.024797691,0.012786309,0.028284866,0.02072932,-0.024991423,-0.029059794,-0.02169798,0.0025185153,-0.0022279175,-0.034290556,-0.0036324742,0.047270596,0.002349,0.020632453,-0.009686598,-0.010945856,-0.022666639,-0.01230198,0.0041652373,-0.008039876,-0.006054124,-0.02382903,0.013173773,0.028866062,0.028478598,0.001029201,-0.020051258,-0.0043347524,-0.034871753,-0.015304824,0.04436462,0.015207958,0.0039472887,0.025572618,0.023054102,0.021213649,-0.018017072,0.0020826187,0.00044800516,-0.019179463,-0.020438721,-0.016757814,0.00096260564,-0.020148123,0.019373195,0.0023368918,-0.012059814,-0.004019938,-0.02286037,0.038940124,-0.010461526,0.008669505,-0.019857526,0.026541278,0.01084899,0.015789155,0.0068290513,-0.0013924484,0.0021431597,0.0071680825,0.06819365,0.0052065463,-0.046689402,0.02286037,-0.018695135,0.012592577,0.019179463,-0.0014348273,0.00022551611,0.08872924,0.021891711,0.04920792,-0.041846104,0.033709362,0.0072649485,0.023732165,-0.009250701,-0.010413093,-0.01215668,-0.024022764,-0.039521318,0.0016225051,-0.035452947,0.002155268,-0.047270596,-0.0009928762,-0.012592577,0.013464371,-0.012495711,-0.008669505,-0.00017405605,-0.008378907,0.014529897,0.051920164,-0.02673501,0.021988576,0.02673501,-0.04165237,0.024022764,0.021310516,0.010752124,0.010170928,0.023247834,-0.014433031,-0.002009969,0.014529897,0.018210804,0.028478598,0.0018283454,0.0032207938,0.011962948,0.0063931546,0.012253546,0.009541299,0.007700845,0.010316227,0.056569733,0.040102515,-0.019373195,0.010752124,0.030415917,-0.014626763,0.041071177,0.022763506,-0.055019874,-0.031965774,-0.04262103,0.00794301,-0.01830767,0.024797691,-0.022957237,0.02964099,-0.00062962883,-0.015982887,0.03467802,-0.037584,-0.0042621032,-0.014045567,-0.0071680825,0.03971505,0.015595422,-0.0012592577,0.020826185,0.012495711,0.0068290513,-0.030997112,-0.012592577,-0.026347546,-0.021891711,0.00071741367,0.04572074,0.019663794,-0.019082598,0.010170928,-0.04339596,0.0137549685,-0.017726474,-0.018501403,-0.0026032731,-0.036227874,-0.019179463,-0.005351845,-0.009831897,0.002009969,0.017048413,-0.016176619,-0.014045567,-0.010122495,0.0049885977,-0.0151110925,-0.029447258,-0.015789155,-0.01084899,0.011720783,0.004843299,-0.000490384,0.01070369,-0.0058846083,0.048045527,-0.060056906,0.075555466,-0.030222185,0.008814804,-0.00093838916,-0.03157831,0.0039957217,0.023441566,0.0098803295,0.056957196,-0.026541278,-0.010945856,-0.026153814,0.0071680825,0.0075071133,-0.009638165,-0.00077492784,-0.016757814,0.01782334,-0.039133854,0.028478598,-0.0070712166,-0.0052549792,0.0028696547,-0.049982846,-0.034290556,0.0123988455,0.022279175,-0.014917361,-0.00015210986,0.021988576,0.0105099585,0.030028453,0.01540169,0.036034144,0.022569774,0.018598268,-0.040102515,0.02218231,0.010752124,0.064706475,0.037971463,-0.02576635,-0.013367505,0.027509937,0.003087603,0.023247834,0.017629609,-0.010170928,-0.0018646701,-0.0027122474,0.0030512784,0.018210804,0.048045527,-0.001368232,-0.012689443,0.0044316184,0.0002784897,0.030222185,0.01782334,-0.0071680825,0.0011321211,0.01782334,-0.0028575463,0.014336165,-0.023344701,-0.003087603,-0.0042378865,0.03564668,0.0018041289,0.05347002,-0.025572618,-0.024216495,-0.023247834,0.015595422,0.036227874,-0.015789155,0.028866062,0.013464371,0.025185155,-0.004698,-0.007991443,0.021891711,-0.031384576,0.0056666597,0.01733901,-0.010074061,0.024216495,-0.0028817628,-0.037196536,0.0017435877,-0.031965774,-0.013561237,-0.010316227,-0.018501403]'),
('2039212982331846657', 'Java后端核心概念

一、Java基础

1. HashMap原理
HashMap基于哈希表实现，以键值对形式存储。通过put(key, value)存入，get(key)获取。当链表长度超过8且数组长度超过64时，链表转换为红黑树，提高查找效率。

扩容机制：
- 初始容量16，负载因子0.75
- 当元素个数 > 容量 × 负载因子时触发扩容
- 扩容为原容量的2倍，重新计算每个元素的位置

线程安全：
HashMap不是线程安全的，多线程环境下使用ConcurrentHashMap。

2. ConcurrentHashMap原理
ConcurrentHashMap是线程安全的HashMap实现。

JDK7实现：
- 采用分段锁（Segment），每个Segment独立加锁
- 默认16个Segment，支持16个线程并发写入

JDK8实现：
- 采用CAS + synchronized实现
- 锁粒度更细，只锁链表头节点
- 读操作不加锁，volatile保证可见性

3. JVM内存模型
内存结构：
- 程序计数器：当前线程执行的字节码行号
- 虚拟机栈：方法调用、局部变量、操作数栈
- 本地方法栈：本地方法调用
- 堆：对象实例、数组（线程共享）
- 方法区：类信息、常量、静态变量（线程共享）

堆内存划分：
- 新生代：Eden、Survivor0、Survivor1
- 老年代：存放长期存活的对象

4. 垃圾回收（GC）
判断对象是否存活：
- 可达性分析（GC Roots）

常见垃圾回收算法：
- 标记-清除：标记存活对象，清除未标记，产生内存碎片
- 复制算法：内存分为两块，存活对象复制到另一块，内存利用率低
- 标记-整理：标记存活对象，移动到一起，无碎片但移动开销大

分代收集：
- 新生代：复制算法（对象存活率低）
- 老年代：标记-清除或标记-整理（对象存活率高）

二、Spring框架

5. Spring IoC容器
IoC（控制反转）将对象的创建和管理交给Spring容器，而不是由程序员直接new。

依赖注入方式：
- 构造器注入：@Autowired public UserService(UserDao dao)
- Setter注入：@Autowired public void setUserDao(UserDao dao)
- 字段注入：@Autowired private UserDao userDao

Bean生命周期：
实例化 → 属性赋值 → 初始化 → 使用 → 销毁

6. Spring AOP
AOP（面向切面编程）将横切关注点（日志、事务、权限）从业务逻辑中分离。

核心术语：
- 切面（Aspect）：横切关注点的模块化
- 连接点（JoinPoint）：方法执行等可织入的点
- 通知（Advice）：切面执行的动作（前置、后置、环绕）
- 切入点（Pointcut）：匹配连接点的表达式

7. Spring Boot自动装配
Spring Boot通过@EnableAutoConfiguration注解开启自动装配，核心是META-INF/spring.factories文件中的配置类。

工作流程：
- 启动时扫描所有jar包下的spring.factories文件
- 加载配置类
- 根据@Conditional条件注解判断是否生效

三、数据库

8. MySQL索引
索引类型：
- B+树索引：InnoDB默认，适合范围查询
- 哈希索引：等值查询快，不支持范围
- 全文索引：文本搜索
- 空间索引：地理数据

InnoDB索引结构：
- 主键索引（聚簇索引）：叶子节点存储完整行数据
- 二级索引（辅助索引）：叶子节点存储主键值

索引优化原则：
- 区分度高的列优先
- 最左前缀匹配原则
- 避免在索引列上使用函数或计算

9. 事务隔离级别
事务特性（ACID）：
- 原子性（Atomicity）
- 一致性（Consistency）
- 隔离性（Isolation）
- 持久性（Durability）

隔离级别：
- READ UNCOMMITTED：存在脏读、不可重复读、幻读
- READ COMMITTED：存在不可重复读、幻读
- REPEATABLE READ：存在幻读（InnoDB已解决）
- SERIALIZABLE：全部解决，性能最低

四、缓存与中间件

10. Redis数据类型
- String：字符串，用于缓存、计数器
- Hash：哈希，用于对象存储
- List：列表，用于消息队列、最新列表
- Set：集合，用于去重、标签
- Sorted Set：有序集合，用于排行榜、延迟队列

11. 缓存穿透、击穿、雪崩
- 缓存穿透：查询不存在的数据，解决方案：布隆过滤器、缓存空值
- 缓存击穿：热点key过期，解决方案：互斥锁、永不过期
- 缓存雪崩：大量key同时过期，解决方案：过期时间加随机值、多级缓存

五、并发编程

12. 线程池
核心参数：
- corePoolSize：核心线程数
- maximumPoolSize：最大线程数
- keepAliveTime：非核心线程空闲存活时间
- workQueue：任务队列
- handler：拒绝策略

执行流程：
核心线程 → 任务队列 → 非核心线程 → 拒绝策略

13. synchronized和Lock
对比：
- synchronized是JVM层面实现，Lock是Java代码层面
- synchronized自动释放锁，Lock需要手动释放
- Lock支持可中断、公平锁、读写锁

六、设计模式

14. 单例模式（双重检查锁）
private static volatile Singleton instance;
private Singleton() {}
public static Singleton getInstance() {
    if (instance == null) {
        synchronized (Singleton.class) {
            if (instance == null) {
                instance = new Singleton();
            }
        }
    }
    return instance;
}

15. 代理模式
- JDK动态代理：实现接口，目标类有接口时使用
- CGLIB动态代理：继承目标类，目标类无接口时使用', '{"doc_id": "2039212967563702272", "chunk_index": 0, "collection_name": "javabackend"}', '[0.05255756,-0.02473297,0.01313939,-0.039224945,0.029177174,0.008501958,-0.012269871,0.07729053,0.05564918,0.008115506,-0.04366915,-0.008985024,-0.0010023615,0.011931726,0.098545425,0.056035634,-0.0054344903,-0.0067629213,-0.009902849,-0.021448122,0.04888626,0.021351509,0.004999731,-0.030336533,0.00069742627,0.04154366,-0.054876275,-0.02077183,0.01652085,0.025119422,-0.03207557,0.0403843,-0.04618109,0.04888626,0.028983949,0.04115721,-0.022027802,0.013719069,0.021254895,-0.010579141,0.019032793,0.033621382,0.040191077,0.015941171,0.02995008,0.0036229936,-0.0035022271,-0.0047823517,-0.03632655,-0.01144866,0.061832424,-0.01864634,-0.031882342,0.05564918,0.08656539,-0.04212334,-0.029177174,0.002415329,-0.04985239,0.012173259,-0.033428155,0.0003290886,0.011352046,0.0063764686,0.0024757122,0.030916212,-0.010772368,0.0048548114,0.008550265,-0.036906227,-0.017970048,-0.031109437,0.007873973,0.014781814,0.037485905,-0.013236003,-0.027438138,0.0017148836,0.049079485,-0.01768021,-0.02289732,0.04463528,0.032268796,-0.018839566,-0.021448122,-0.016327625,0.00084536517,-0.020965056,0.020578604,0.004250979,-0.0016424238,-0.0040819063,0.02415329,0.0044683586,0.015747946,0.000990285,-0.008840105,0.0074392133,0.0021858728,-0.005482797,0.036133323,0.008018892,0.06105952,0.033621382,0.022704093,0.034780737,-0.029177174,0.012752937,0.002149643,-0.005748483,0.0097579295,0.023090545,0.0039852927,0.01893618,-0.016424237,-0.009033331,0.019226018,-0.013815682,0.0041302126,-0.004250979,0.0018598033,0.030336533,-0.0019564165,-0.0007638478,0.006811228,-0.011207127,0.008840105,-0.004927271,0.009613009,0.040191077,-0.0146852005,-0.023670224,-0.016424237,-0.057967898,-0.057581443,0.0023790991,0.028017817,-0.00572433,-0.012752937,0.021254895,0.0010989747,0.020385377,0.014781814,0.0045166654,0.014781814,-0.019226018,-0.022414254,0.0039369864,-0.023090545,0.038258813,0.046567544,-0.028790722,-0.0021254895,0.0031399278,-0.03729268,0.005676023,0.010627448,0.0007427137,-0.030722985,0.0041785194,-0.019419245,0.03999785,0.01144866,-0.004685738,0.0061107823,-0.0034297672,-0.003405614,-0.032462023,0.019709084,-0.00748752,0.008115506,0.022510866,-0.005676023,-0.011062207,0.01130374,0.0075358264,0.0064247753,-0.028211042,0.02106167,0.0022704094,0.0022583327,0.012173259,-0.050238844,0.0018356501,0.004154366,-0.010047769,-0.03555364,0.0010265148,0.027631365,0.017873434,0.0007970586,-0.0117868055,-0.0018839566,-0.0013525842,0.034007832,0.06337824,-0.009419783,0.004057753,-0.018742952,0.032462023,0.028597496,0.098545425,-0.02077183,0.0017148836,0.0064247753,-0.03516719,0.0032848476,0.0051204977,-0.02995008,-0.010047769,-0.01526488,0.023863452,0.0004196634,0.013622456,-0.0045166654,0.010385915,-0.004250979,-0.024249904,-0.002451559,-0.004589125,0.014491974,-0.010627448,-0.0066663083,-0.025505874,0.02048199,0.008840105,-0.047726903,0.0001554868,0.030916212,0.00019247153,-0.005990016,-0.008067199,0.01313939,-0.0024032523,-0.009951156,0.069561474,-0.028211042,-0.0064247753,0.010868981,0.013719069,0.009129943,0.03052976,0.024636356,0.024926195,0.04366915,-0.017197143,-0.0008030969,-0.028597496,0.11129836,-0.025892327,0.0010748215,-0.009516397,-0.0039369864,-0.014105521,-0.036133323,0.00572433,0.0025119423,0.0042026727,-0.027438138,0.015168266,-0.02106167,0.03787236,0.0035988402,0.0031399278,-0.009274864,0.0077773593,-0.033814605,0.016714077,-0.020578604,-0.0032848476,-0.0011714345,0.00792228,-0.022027802,-0.025892327,-0.028597496,0.05255756,-0.0047098915,-0.037679132,-0.022221027,0.014105521,-0.019129407,-0.015651332,0.011738499,0.033428155,0.0097579295,-0.054489825,-0.0055311034,0.04096398,-0.0038886797,0.006014169,0.024539743,0.0036713001,0.00020379339,0.018742952,-0.004154366,-0.0056277164,0.00065213884,0.015458106,0.04115721,0.015747946,-0.0009661316,0.009854542,-0.0021858728,0.016231012,-0.001497504,0.0012438945,-0.009274864,0.015458106,-0.037099455,-0.013525843,-0.009129943,-0.017583596,-0.021158282,-0.011207127,0.030336533,0.0068595344,0.023863452,0.043475922,-0.019612473,0.0037196067,-0.0077773593,0.03149589,-0.04115721,0.013332617,0.036906227,0.015458106,-0.016134398,0.00763244,-0.026085554,0.016617464,0.030336533,0.048113354,0.0063281623,-0.023090545,-0.044828508,0.0031640811,0.034394287,-0.017293757,0.0061349357,0.023090545,0.016810691,-0.04212334,0.026085554,0.0003819239,-0.025892327,-0.0062315487,0.004299286,-0.008936717,-0.056422085,0.017197143,-0.02289732,-0.006811228,-0.039031718,-0.011496966,0.008936717,0.031109437,-0.027244912,-0.0077773593,-0.031302664,0.051398203,0.030143306,0.0014491974,0.025699101,0.014781814,0.013429229,-0.010675754,0.016231012,-0.00187188,-0.01526488,-0.0011472813,-0.022124413,0.006159089,-0.031882342,0.013332617,-0.009661316,-0.022704093,-0.026472006,-0.006907841,0.06917503,-0.004347592,0.044442054,-0.0726531,-0.0070044543,0.0068595344,-0.038065586,-0.005965863,-0.00068534963,-0.0076807463,-0.041930113,-0.008501958,0.00050118077,0.04212334,-0.008840105,-0.020675216,-0.026858458,0.026858458,0.013912295,0.0023670224,7.736601e-05,0.012028338,-0.0013344693,0.030722985,-0.013525843,-0.010917287,-0.0012982393,-0.008308732,-0.021737961,-0.018549727,0.04250979,-0.03729268,0.05255756,0.0010325531,0.039224945,-0.010240995,0.02415329,0.03052976,0.043862376,0.043862376,-0.019129407,-0.04366915,0.014105521,0.024249904,-0.048113354,-0.0070044543,-0.032462023,0.009033331,0.02840427,0.0036229936,-0.0008091352,0.005676023,0.008646878,-0.0070044543,-0.0036471467,0.0090816375,0.02627878,-0.033621382,-0.0183565,0.007245987,0.014202135,0.022704093,-0.021544736,0.040770754,0.025119422,-0.06917503,0.015554719,0.018066661,0.006907841,-0.0012016261,0.0033814607,-0.02231764,-0.00058873644,-0.0018235734,-0.03941817,0.015554719,-0.014781814,-0.010579141,0.020288764,-0.02473297,-0.011738499,-0.027438138,0.056035634,-0.015941171,0.0017269603,-0.019032793,0.034587514,-0.0054586437,0.02627878,0.0028863181,-0.0011835112,-0.030916212,-0.05410337,-0.025892327,-0.011593579,0.013042777,0.03420106,0.03574687,0.01115882,0.0007125221,0.03265525,-0.010192689,0.0066180015,0.013815682,0.00381622,-0.0010385915,-0.010482528,0.024926195,0.011013901,0.014781814,0.016231012,-0.012946163,-0.036519773,-0.00034871313,0.010240995,-0.038452037,0.015747946,-0.019709084,0.004637432,-0.00946809,0.0033090007,-0.024346517,-0.008985024,0.0051204977,-0.014781814,-0.01777682,-0.050238844,-0.10666093,0.025699101,-0.01584456,0.0031882343,0.0035263803,-0.03787236,-0.037485905,0.00932317,0.011207127,-0.029177174,-0.014781814,-0.03787236,0.0066663083,0.009709623,0.02106167,-0.008550265,-0.0117868055,0.04366915,0.014105521,-0.021641348,0.0061349357,0.027051685,-0.0009419783,0.048113354,-0.0066663083,0.005748483,0.009274864,-0.0330417,-0.032268796,-0.004927271,0.021351509,0.010724061,0.014878427,0.017873434,-0.005748483,0.0062315487,-0.0019926464,-0.0064247753,-0.024056677,-0.024539743,-0.001310316,0.015651332,0.013815682,-0.05526273,0.009613009,-0.015747946,0.005241264,-0.008598572,-0.023380386,-0.0055311034,-0.025119422,-0.0010023615,-0.032848474,0.025505874,0.0056277164,-0.011980032,-0.014395361,-0.021641348,0.0009600933,-0.026085554,-0.045408186,0.012076645,-0.036519773,0.013815682,-0.03265525,-0.015941171,-0.047920126,0.008840105,0.03536042,-0.0038886797,0.019419245,-0.016327625,-0.041930113,0.057194993,0.021544736,0.017293757,0.007873973,-0.027631365,-0.03941817,0.02627878,0.0018839566,-0.03149589,0.016617464,-0.0057967897,0.0003124832,0.016714077,0.032268796,-0.021544736,0.036713,0.037679132,-0.014298748,0.029563628,-0.012946163,-0.009806236,0.07729053,0.023476997,-0.02531265,-0.023960063,-0.006569695,0.010965594,-0.0010446298,-0.03052976,-0.05680854,-0.024636356,0.0036713001,0.004685738,-0.010192689,0.010192689,-0.01497504,0.019998925,0.003031238,0.0073426003,-0.037679132,-0.0055552567,-0.012559711,0.006569695,-0.02995008,0.027438138,0.021158282,0.021448122,0.034587514,-0.006811228,-0.020385377,0.0006581772,-0.0062798555,-0.022993932,-0.008018892,-0.014491974,-0.026472006,-0.01497504,-0.039804623,0.0021979494,-0.008936717,0.009854542,0.014781814,0.031109437,0.02473297,0.016907303,0.02782459,-0.025699101,-0.024636356,0.039611395,0.013622456,-0.00932317,-0.031109437,0.026665233,0.052171107,0.03207557,-0.021641348,0.04154366,0.008067199,0.0071010673,-0.026472006,-0.037679132,-0.0052654175,-0.021351509,0.057581443,0.009033331,-0.0183565,0.0012318178,-0.036906227,0.0041302126,-0.004057753,0.017293757,-0.008163813,-0.018742952,0.052944012,0.029563628,-0.011013901,-0.002656862,-0.008067199,0.034587514,-0.02289732,-0.029563628,-0.009516397,-0.034394287,-0.010965594,-0.015554719,-0.014298748,0.0029346247,0.011352046,0.023187159,-0.0049514244,0.023670224,-0.0015941171,0.0030553911,0.030722985,0.015554719,0.009033331,0.0079705855,-0.010337608,-0.03207557,-0.03574687,-0.019612473,-0.015941171,0.022414254,-0.03574687,-0.038065586,-0.0153614925,-0.023090545,-0.026665233,0.004734045,-0.008308732,-0.026472006,-0.034394287,0.0064247753,0.03729268,-0.026665233,0.012269871,-0.00792228,0.036133323,0.054489825,-0.009226557,0.0067146146,-0.0090816375,0.056035634,0.0060383226,-0.022800706,0.013429229,-0.022510866,-0.020868443,0.016231012,-0.0038403731,0.013429229,0.016810691,-0.009129943,-0.03207557,-0.017390369,-0.0045166654,-0.017583596,0.010192689,-0.08308732,0.034780737,-0.0045649717,-0.045601413,-0.03207557,0.014298748,-0.05101175,0.0047098915,-0.023766838,0.022221027,0.04579464,0.03574687,-0.011593579,-0.03052976,0.012849551,-0.00044079754,-0.00013057873,0.030916212,0.019612473,0.0071976804,-0.011690193,0.010192689,0.011738499,-0.034007832,0.006159089,-0.034007832,0.0403843,0.022221027,0.00071554125,0.0066180015,0.01893618,-0.00748752,0.030143306,0.05101175,-0.010144382,0.005313724,0.013236003,0.023670224,-0.015168266,-0.013042777,0.043282695,0.0024032523,0.01893618,0.05990016,-0.0029708548,0.016231012,0.0077773593,-0.045987863,-0.02531265,0.002318716,-0.02995008,0.028790722,-0.021544736,0.0079705855,0.024056677,0.057194993,-0.017293757,0.010240995,0.0070044543,0.004999731,0.0026447852,-0.029177174,0.013622456,-0.00089367176,-0.034007832,0.034780737,0.01497504,0.008936717,0.00023096584,-0.019129407,0.00011774729,-0.019709084,-0.015747946,-0.058354348,0.0063281623,0.07844989,0.0004438167,0.037099455,0.04579464,0.026472006,0.010579141,-0.012463097,-0.01526488,-0.019032793,0.0146852005,0.037485905,-0.004637432,0.010482528,-0.008743491,0.005313724,-0.034587514,-0.0061349357,0.054489825,-0.024926195,0.023476997,-0.037485905,-0.014395361,0.013236003,-0.0017269603,-0.007245987,0.03516719,-0.016907303,-0.044248827,-0.00084536517,0.04212334,-0.013042777,0.015941171,0.0063281623,-0.004444205,-0.015071653,-0.020868443,-0.013815682,0.023960063,0.044248827,-0.04115721,0.040577527,-0.0048065046,-0.04830658,-0.003574687,0.023766838,0.0011291663,-0.0018235734,0.011255433,-0.027244912,-0.015071653,-0.019129407,0.0022100261,0.002246256,0.018549727,0.01768021,-0.009709623,0.017583596,-0.014202135,0.0021979494,0.026472006,-0.031109437,-0.018839566,-0.0028017818,0.021641348,-0.00557941,-0.02531265,0.027244912,0.028211042,-0.0014190058,-0.049079485,0.012656325,-0.0024274057,0.027631365,0.0065213884,-0.010144382,0.04521496,0.01652085,-0.0073426003,-0.04096398,0.026858458,-0.037679132,-0.01777682,0.0153614925,0.043862376,0.0029708548,0.017293757,0.027438138,0.02077183,-0.039224945,-0.009274864,-0.015747946,-0.006811228,0.01893618,-0.00019775507,-0.03149589,0.017970048,-0.05990016,0.07922279,0.030336533,0.010337608,0.027631365,0.008018892,-0.00065213884,-0.012124952,-0.025699101,-0.0047581983,-0.0140089085,0.015071653,0.0042751324,0.016714077,0.0024757122,-0.0063281623,0.0047581983,0.021544736,-0.01130374,0.0153614925,0.010482528,-0.034973964,-0.025892327,0.067242764,0.014781814,-0.012463097,0.024539743,-0.030336533,0.004009446,0.010096075,0.01497504,0.020675216,-0.06878857,-0.025892327,-0.026858458,-0.021448122,-0.024346517,-0.028017817,0.009902849,-0.028211042,0.003031238,-0.039031718,-0.009806236,0.048693035,0.018742952,-0.040191077,0.03265525,0.057967898,-0.005168804,0.014781814,0.014588587,0.0055069504,0.0070044543,-0.096999615,0.014781814,0.0054586437,-0.026085554,0.021448122,-0.0065213884,0.026858458,0.044442054,-0.017583596,0.010047769,-0.020288764,-0.012463097,0.01893618,-0.031109437,0.0004981616,0.0051204977,0.051398203,0.04734045,-0.020675216,0.02260748,0.029563628,0.020868443,0.0016061938,-0.034394287,-0.004395899,0.0029104715,0.009033331,-0.015747946,-0.010240995,0.11902741,-0.024636356,-0.022800706,0.033814605,-0.038258813,0.042316563,-0.029177174,-0.01710053,0.005144651,0.034973964,0.008018892,-0.03420106,0.007729053,-0.01313939,0.054876275,0.0025481721,0.0035988402,-0.014105521,-0.004637432,-0.034780737,0.00089367176,0.035940096,0.040577527,0.0024274057,0.027631365,-0.0060866293,0.012124952,-0.008308732,-0.026858458,0.0041785194,-0.0016545004,0.0018960333,0.012318178,-0.00078498194,0.009854542,-0.024926195,0.008695184,0.007390907,-0.015651332,0.023187159,-0.009806236,-0.019998925,-0.0067146146,-0.011641886,-0.02840427,0.0038403731,-0.012269871,-0.033428155,-0.014588587,-0.021931188,-0.0063764686,0.01497504,-0.012221565,0.014105521,0.027438138,0.03536042,0.014105521,-0.012173259,0.003031238,-0.027438138,-0.004903118,-0.013719069,0.008550265,-0.015168266,-0.024636356,0.005676023,0.01652085,0.053330466,-0.0055311034,0.0058934027,-0.019515859,0.0056277164,0.005990016,0.029756853,0.0033331541,0.011255433,0.021834575,0.013622456,0.023283772,-0.0064730817,0.01497504,0.011545273,0.013429229,0.026085554,-0.0030553911,0.017583596,0.0034780737,-0.010917287,-0.015554719,-0.025505874,0.0084053455,-0.03883849,-0.021254895,-0.011062207,0.034394287,0.036519773,0.028211042,-0.023863452,-0.024926195,-0.014878427,-0.026472006,0.028017817,-0.028983949,-0.020095538,0.0097579295,-0.028017817,-0.030916212,0.033621382,-0.019032793,-0.01768021,-0.004903118,0.0003139928,-0.024249904,0.044248827,0.0068595344,0.020868443,-0.01768021,0.017970048,-0.016714077,0.012752937,-0.032462023,0.00396114,0.028983949,0.0023549458,-0.0028742414,-0.020675216,-0.023187159,0.02289732,0.04618109,0.029177174,0.014202135,0.01313939,0.029177174,-0.0065213884,0.0025240188,-0.031302664,0.02260748,0.01584456,-0.032268796,-0.012028338,-0.034587514,0.0506253,0.050238844,0.026665233,0.019322632,-0.007390907,0.00012831435,-0.026665233,0.039224945,0.0043717455,0.031302664,0.012463097,0.005676023,0.0062798555,0.0062315487,-0.069561474,-0.013429229,-0.039804623,-0.0060383226,0.012946163,-0.01777682,0.016424237,-0.052944012,0.023187159,-0.024056677,0.010144382,0.004734045,-0.012752937,0.022993932,-0.04985239,-0.010192689,0.06028661,0.02444313,-0.006062476,-0.023670224,0.019805698,0.00086348015,0.014781814,0.00065213884,-0.015941171,0.033814605,-0.021158282,-0.00072157953,-0.036519773,0.016424237,0.008550265,0.0044200523,-0.03207557,0.010096075,0.056035634,-0.037679132,0.06260533,-0.007825666,0.0071976804,0.038645264,0.011883419,-0.019612473,0.008018892,0.0052654175,-0.02019215,0.0056035635,0.008163813,-0.0019443398,-0.025505874,0.038065586,-0.008018892,0.03168912,0.005144651,-0.02260748,-0.0033331541,0.0029829314,0.05564918,0.012946163,-0.017003916,-0.016810691,0.0016182704,0.04463528,0.03729268,-0.066469856,0.026085554,-0.013236003,-0.021254895,0.0403843,-0.00071856036,0.004903118,-0.021834575,-0.010047769,-0.02048199,0.0010325531,0.0035988402,-0.005965863,-0.0035988402,0.033234928,0.028211042,-0.0024394824,0.0075358264,0.004106059,0.026858458,0.010917287,-0.02048199,0.04212334,0.0017148836,0.009033331,0.013429229,0.0018598033,-0.0042751324,0.0033090007,-0.01768021,-0.007245987,0.027438138,-0.008743491,0.0062798555,-0.03168912,0.011062207,-0.012849551,-0.015071653,-0.0034539206,0.023960063,-0.008308732,0.04618109,-0.011013901,0.0048789647,-0.029756853,-0.012221565,0.03632655,0.028597496,-0.016327625,0.007245987,-0.0021134128,-0.02782459,-0.027244912,0.009951156,-0.024346517,-0.01313939,0.020578604,0.020868443,0.038645264,-0.009613009,-0.0049514244,0.0146852005,-0.0330417,-0.007825666,-0.008115506,-0.003574687,0.0506253,0.010772368,0.0055552567,-0.020578604,-0.012221565,-0.011255433,0.030336533,0.024636356,-0.042896245,-0.0029104715,-0.009999462,-0.0023307926,0.008985024,0.010868981,0.0022341793,-0.020965056,-0.020868443,-0.0050480375,-0.013525843,0.038258813,-0.0140089085,0.0066180015,0.018549727,0.017583596,0.031302664,-0.00932317,0.036133323,0.0020288764,0.011496966,-0.009613009,0.00374376,-0.01710053,-0.023283772,-0.011835112,-7.0572896e-05,-0.011593579,-0.013332617,0.011207127,0.059127256,0.04135043,0.00032606942,-0.013236003,0.022414254,0.0140089085,0.02106167,0.034587514,-0.019129407,-0.01652085,0.008646878,0.022221027,-0.02840427,-0.019805698,0.017197143,-0.018549727,0.0031157744,-0.028211042,0.026085554,-0.016810691,0.057194993,0.048113354,0.024346517,-0.0035505337,0.0111105135,0.028790722,0.019805698,-0.016617464,-0.01497504,-0.0104342215,0.021641348,0.010240995,-0.028597496,-0.06299178,0.0022341793,-0.029370401,-0.01313939,0.017390369,-0.049272712,-0.011207127,0.044055603,-0.021931188,-0.010917287,0.0076807463,0.044055603,0.0015216573,-0.016134398,0.0046132784,-0.03168912,-0.004685738,0.04463528,-0.024346517,0.047726903,0.04096398,0.008695184,-0.013429229,0.029177174,0.0028380116,0.0074392133,0.004057753,-0.010965594,-0.028790722,-0.018259887,0.0035022271,-0.025892327,-0.018163275,0.01584456,0.01864634,0.058740802,0.00946809,0.033428155,0.028790722,-0.02627878,0.017970048,0.01144866,-0.016907303,-0.04308947,-0.03999785,0.02048199,-0.010724061,0.015651332,-0.009371476,0.032848474,-0.026085554,-0.019419245,0.026085554,-0.0022945625,0.029370401,-0.01893618,-0.0069561475,0.031109437,0.027631365,-0.024346517,-0.0032848476,-0.0011472813,-0.0403843,-0.016810691,-0.07072084,-0.004444205,0.0017269603,-0.012318178,0.057194993,0.04946594,0.0016424238,0.0052895704,-0.021834575,0.014298748,-0.014878427,-0.021931188,0.002173796,-0.012124952,-0.02627878,0.0040335995,0.004999731,0.0065213884,0.027244912,-0.038452037,0.0007125221,0.016617464,0.010482528,0.018066661,0.0064247753,-0.030916212,-0.02531265,0.034394287,-0.03420106,0.017486982,-0.039224945,-0.004999731,0.040191077,-0.052171107,0.039804623,-0.054876275,-0.0010567064,-0.03883849,-0.00792228,0.017970048,0.03941817,-0.002825935,0.05101175,-0.010530835,-0.0077773593,-0.015747946,0.0010567064,0.019129407,-0.03536042,-0.024056677,0.00073365617,-0.0004921233,-0.02473297,0.017486982,-0.0027051684,-0.04502173,0.014491974,-0.019998925,-0.03729268,-0.016907303,0.0012197412,0.013912295,-0.0052654175,0.031882342,0.005965863,-0.0039369864,-0.0024998656,-0.02531265,0.011400353,-0.013525843,-0.030336533,0.00044079754,-0.0022704094,0.09893188,0.043862376,-0.013815682,-0.0403843,0.02444313,-0.00565187,-0.0077773593,-0.0057967897,-0.024539743,-0.010965594,0.012656325,-0.018839566,0.06685631,0.061832424,-0.00572433,-0.015941171,-0.0026085554,-0.013042777,0.030143306,-0.005168804,-0.019226018,-0.010772368,0.012559711,-0.068015665,0.016424237,-0.023476997,0.011255433,-0.010385915,0.012752937,-0.025699101,0.023670224,0.0021254895,-0.01584456,-0.015071653,0.012752937,0.020385377,0.008115506,0.0050963443,0.030916212,0.027438138,-0.015554719,-0.04946594,0.018259887,-0.0014250441,0.008308732,-0.012752937,0.005965863,0.0071010673,0.0029467014,-0.04734045,-0.008067199,0.013815682,-0.020868443,0.011593579,-0.027244912]'),
('2039213266344947713', 'Java后端核心知识补充

一、Java基础进阶

1. String、StringBuilder、StringBuffer区别
- String：不可变，线程安全，性能最低，适用于字符串不经常变化的场景
- StringBuilder：可变，线程不安全，性能最高，适用于单线程字符串拼接
- StringBuffer：可变，线程安全，性能中等，适用于多线程字符串拼接

原理：String每次修改都会创建新对象，StringBuilder和StringBuffer在原有对象上修改。

2. ArrayList和LinkedList区别
- ArrayList底层是数组，随机访问O(1)，插入删除O(n)，内存连续
- LinkedList底层是双向链表，随机访问O(n)，插入删除O(1)，内存分散
- 适用场景：多查询少增删用ArrayList，多增删少查询用LinkedList

3. 异常体系
Throwable
├── Error（系统错误，不可处理）
│   ├── OutOfMemoryError
│   └── StackOverflowError
└── Exception
    ├── RuntimeException（非受检异常）
    │   ├── NullPointerException
    │   └── IndexOutOfBoundsException
    └── 受检异常（必须处理）
        ├── IOException
        └── SQLException

二、JVM进阶

4. 类加载机制
类加载过程：加载 → 验证 → 准备 → 解析 → 初始化 → 使用 → 卸载

类加载器：
- Bootstrap：加载rt.jar核心类库
- Extension：加载ext目录下的jar
- Application：加载classpath下的类

双亲委派机制：类加载请求先委派给父类加载器，父类无法加载才由子类加载，保证核心类库安全。

5. 垃圾回收器
- Serial：新生代，单线程，STW
- Parallel Scavenge：新生代，多线程，吞吐量优先
- CMS：老年代，并发收集，低延迟
- G1：整堆，分区回收，可预测停顿

三、多线程进阶

6. volatile关键字
作用：保证可见性、禁止指令重排序、不保证原子性
适用场景：状态标志位、双重检查锁的单例模式

7. ThreadLocal原理
原理：每个线程都有自己的ThreadLocalMap，存储线程局部变量
内存泄漏：key是弱引用，value是强引用，线程池场景需要手动remove()
使用场景：用户身份信息传递、数据库连接管理、事务管理

8. 锁升级过程（synchronized）
升级过程：无锁 → 偏向锁 → 轻量级锁 → 重量级锁
- 偏向锁：锁只被一个线程获取
- 轻量级锁：多线程交替执行，CAS自旋
- 重量级锁：多线程竞争激烈，阻塞等待

四、Spring进阶

9. Spring事务传播机制
- REQUIRED：支持当前事务，无则新建（默认）
- REQUIRES_NEW：新建事务，挂起当前事务
- SUPPORTS：支持当前事务，无则非事务执行
- NOT_SUPPORTED：非事务执行，挂起当前事务
- MANDATORY：必须存在事务，否则抛异常
- NEVER：必须非事务执行，否则抛异常
- NESTED：嵌套事务，独立提交/回滚

10. Spring循环依赖解决
三级缓存：
- 一级缓存：singletonObjects（完整对象）
- 二级缓存：earlySingletonObjects（早期对象）
- 三级缓存：singletonFactories（对象工厂）

解决原理：通过提前暴露ObjectFactory，在实例化后、属性赋值前将对象放入三级缓存
注意：构造器注入无法解决循环依赖

五、MySQL进阶

11. 联合索引最左前缀
示例：INDEX (a, b, c)
有效查询：WHERE a=1、WHERE a=1 AND b=2、WHERE a=1 AND b=2 AND c=3
无效查询：WHERE b=2（跳过了a）、WHERE c=3（跳过了a和b）

12. explain关键字段
- type：访问类型 const > eq_ref > ref > range > index > ALL
- key：实际使用的索引
- rows：预估扫描行数
- Extra：Using index（覆盖索引）、Using where、Using filesort（需优化）

13. MVCC原理
MVCC（多版本并发控制）：通过保存数据的历史版本，实现读写不阻塞
实现机制：
- 隐藏字段：DB_TRX_ID（事务ID）、DB_ROLL_PTR（回滚指针）
- ReadView：判断数据的可见性
- Undo Log：存储历史版本

六、Redis进阶

14. Redis持久化
- RDB：快照，恢复快、文件小，可能丢失数据
- AOF：追加命令，数据完整、文件大、恢复慢
- 混合持久化（Redis 4.0+）：结合RDB和AOF，兼顾恢复速度和数据完整性

15. Redis分布式锁
加锁：SET key value NX EX seconds
解锁：Lua脚本保证原子性
问题与解决：
- 锁过期业务未完成 → 看门狗自动续期
- 主从切换锁丢失 → 使用RedLock

七、消息队列

16. 消息可靠性保障
- 生产阶段：事务、确认机制
- 存储阶段：持久化、多副本
- 消费阶段：手动确认、幂等处理

17. 消息积压处理
原因：消费者处理能力不足、生产者突发流量
解决方案：临时增加消费者、优化消费逻辑、消息转移至临时队列

八、系统设计

18. 限流算法
- 计数器：固定窗口计数，简单，有临界问题
- 滑动窗口：细化窗口，更平滑
- 漏桶：匀速流出，平滑突发流量
- 令牌桶：匀速放入令牌，允许一定突发

19. 分布式ID生成
常见方案：
- UUID：无序，存储空间大
- 数据库自增：单点瓶颈
- Redis自增：依赖Redis
- 雪花算法：有序，趋势递增，依赖时钟

雪花算法结构：1位符号 + 41位时间戳 + 10位工作机器ID + 12位序列号

20. CAP理论
- C（一致性）：所有节点数据一致
- A（可用性）：请求总能得到响应
- P（分区容错性）：系统能容忍网络分区
- AP系统：保证可用性和分区容错性（如Eureka）
- CP系统：保证一致性和分区容错性（如ZooKeeper）

知识点汇总表

分类            核心知识点
Java基础        String、ArrayList、异常体系
JVM             类加载机制、垃圾回收器
多线程          volatile、ThreadLocal、锁升级
Spring          事务传播、循环依赖
MySQL           联合索引、explain、MVCC
Redis           持久化、分布式锁
消息队列        可靠性保障、消息积压
系统设计        限流算法、分布式ID、CAP', '{"doc_id": "2039213253741064192", "chunk_index": 0, "collection_name": "javabackend"}', '[0.032349452,-0.023092832,0.0278673,-0.043262523,0.03293408,-0.0027648064,-0.0086719915,0.07561197,0.06352965,0.034103338,-0.05729361,0.028257051,0.009256621,0.027477548,0.068206675,0.06547841,-0.017246546,0.0055783316,-0.011010506,-0.03312896,0.02728267,0.034493092,0.0278673,-0.059632123,-0.029231433,0.017733736,-0.032349452,-0.015687536,0.028646804,0.031180196,-0.040339377,0.03917012,-0.053396083,0.054955095,0.017149108,0.046575416,-0.003361615,-0.00823352,0.01549266,-0.042872768,0.007064263,0.021728698,0.005359096,0.009061744,0.020559441,0.0024115932,-0.02221589,0.0045065125,-0.006284758,-0.0319597,0.03566235,-0.034298215,-0.023287708,0.061191134,0.068206675,-0.010133564,-0.009451496,0.013251583,-0.0022897955,-0.020462003,-0.04521128,0.0026064694,-0.00046587596,-0.011790011,0.015005469,0.05066782,0.021436384,-0.032739203,8.944514e-05,-0.02884168,-0.0026551886,-0.014225964,-0.023872336,0.0072591393,0.031180196,-0.019877374,-0.02572366,-0.0056026913,0.06586816,-0.020949194,0.0020218408,0.033908464,0.013154145,-0.012033607,0.006138601,-0.01237464,-0.0073565776,-0.008477116,-0.008184801,-0.024554403,-0.012228482,0.015297784,0.030010939,0.022313327,0.012666955,0.0065283533,-0.010133564,0.009889968,-0.013738774,-0.020169688,0.020169688,0.03312896,0.02572366,0.030010939,0.011400259,-0.023872336,-0.024067214,-0.0043603554,0.017051669,0.0069181058,-0.001912223,0.024456965,0.003361615,0.029036557,-0.008379677,-0.00207056,0.004847546,0.017733736,0.009256621,-0.0001598594,-0.015102907,0.013738774,0.008964306,0.0031180196,0.023482585,0.013543897,0.011010506,0.005529613,0.0043359958,0.05768336,0.009451496,-0.03858549,0.0016320883,-0.06080138,-0.02689292,0.01753886,0.0278673,0.007307858,-0.009889968,-0.008915587,0.0237749,0.013154145,0.009743811,-0.045990787,0.0032885363,0.004482153,-0.025139032,0.00048414562,0.002886604,0.0319597,0.010766911,0.0004597861,0.020559441,0.0007155611,-0.0475498,0.00828224,0.025918538,-0.0042141983,0.00023293798,-0.02114407,-0.012569516,0.03293408,0.029816061,-0.034493092,0.015200345,-0.0114489775,0.0011083585,-0.026698042,0.037611112,-0.0025455707,0.012228482,0.018513242,0.0278673,0.0065770727,-0.020559441,-0.017343983,-0.009451496,-0.030790443,-0.001443302,0.013154145,0.009305339,0.02630829,-0.028257051,0.019292746,-0.009061744,0.006430915,-0.013641335,-0.018708117,-0.00979253,0.02474928,0.00205838,-0.0016320883,-0.01286183,-0.0360521,0.003507772,0.054955095,-0.002362874,-0.010133564,-0.007064263,0.03098532,0.05456534,0.07405297,0.022508204,-0.001912223,0.017343983,0.0013641336,-0.008087363,0.028646804,-0.0278673,-0.0237749,0.00063030276,-0.0046283104,0.006284758,0.0027891658,0.000721651,0.01656448,-0.03040069,-0.026503166,0.013543897,-0.011156663,0.007795049,-0.01344646,0.0049206247,-0.031569947,0.021436384,0.007795049,-0.040144503,-0.0278673,0.04170351,-0.010766911,0.022508204,0.0020949193,0.010718192,-0.005627051,-0.01958506,0.07366321,-0.025528785,-0.009207902,0.0014981109,-0.0040924004,-0.005212939,0.019487621,0.0050911414,-0.02689292,-0.0027160873,-0.023190271,0.02884168,-0.021046631,0.07717098,-0.01286183,0.021241508,0.00979253,-0.020559441,-0.021923576,-0.009646373,0.0039949627,-0.0009439317,0.036441855,-0.024846718,0.014031088,-0.014128526,0.0024846718,0.007941206,0.0049206247,-0.010620754,0.02689292,-0.04852418,0.026113413,-0.017246546,0.0073565776,0.00828224,0.008866868,0.00024207281,-0.009889968,-0.01597985,0.036441855,0.0037513673,-0.031569947,-0.010620754,0.025918538,0.006382196,0.019000432,0.028062176,0.02416465,0.015395221,-0.03351871,0.05378584,0.031375073,0.012666955,0.0237749,0.0052372986,0.020949194,-0.0013458639,-0.01237464,0.004530872,0.00034407832,0.0049693435,-0.0138362115,0.01597985,0.0029962219,0.006089882,-0.008915587,-0.025139032,0.0076001724,0.0033372552,0.025918538,-0.04131376,0.016954232,-0.056903858,0.015882412,-0.0006363927,-0.011595136,-0.04521128,-0.021728698,0.045016408,0.02065688,0.06937593,0.05144732,0.0008343138,0.010864349,-0.001753886,0.011936168,-0.030205814,0.016856793,0.024846718,0.00041106704,-0.023385147,0.010718192,-0.05768336,-0.014323402,0.054955095,0.0475498,0.024456965,-0.006382196,-0.050278064,-0.016174726,0.06352965,-0.0066745104,0.018610679,0.018513242,0.030205814,-0.02942631,0.001339774,0.0035321314,-0.019292746,-0.0025577503,-0.0037513673,-0.00052981975,-0.053396083,0.013738774,0.013641335,-0.016272165,-0.0038488053,-0.016856793,-0.008428397,0.01032844,-0.037221357,-0.00360521,-0.017831175,0.018902993,-0.002898784,-0.00064248254,-0.0017417063,0.0073565776,0.010084844,-0.0067719487,0.01183873,0.01597985,-0.027672423,-0.0035808505,-0.026698042,0.01393365,-0.038975243,0.031569947,0.025139032,-0.023969775,-0.0360521,-0.0034346934,0.042872768,-0.00092566205,0.02260564,-0.07678123,-0.0045065125,0.038000863,-0.021631261,-0.004482153,-0.00672323,0.001912223,-0.0319597,-0.021533823,0.0032641767,0.034687966,-0.01183873,-0.029231433,-0.015200345,0.029036557,0.0040436815,-0.01286183,-0.004603951,-0.0030205813,-0.0011692573,0.055344846,0.00672323,-0.015297784,-0.0017417063,0.0086719915,-0.036441855,-0.029816061,0.021728698,-0.041508634,0.0639194,-0.0022288968,0.026113413,-0.018513242,0.015590098,0.039364997,0.02942631,0.041508634,-0.005018063,0.0018147848,0.015102907,0.023482585,-0.03878037,0.020364566,-0.02270308,0.0319597,0.03566235,0.0026430087,0.01656448,-0.0048719053,0.0046526697,-0.017733736,-0.015882412,0.008477116,-0.015005469,-0.050278064,0.023287708,0.012666955,0.016272165,0.011936168,0.0032154575,0.03819574,0.023385147,-0.06703742,0.016272165,0.018123489,-0.00010352799,0.005919365,0.0026186493,-0.030010939,0.015200345,0.03566235,-0.048719056,-0.019877374,-0.021923576,-0.02630829,0.021728698,0.0050911414,-0.0015163806,-0.015005469,0.060021877,-0.032154575,-0.0015102907,-0.03040069,0.008818149,0.0047988268,0.0033372552,-0.016369602,0.00026034247,-0.033908464,-0.024067214,-0.044236902,-0.022995394,0.007795049,0.0319597,0.022118451,0.003970603,-0.007843768,0.015687536,0.029816061,-0.010766911,0.005505253,-0.009256621,-0.0008647632,0.0030571206,0.030790443,0.01393365,0.008087363,0.015200345,0.0034834126,-0.02221589,-0.019682499,-0.01286183,-0.04735492,0.03293408,-0.031764824,0.021338945,0.02728267,0.034687966,-0.04131376,-0.007795049,0.024944156,-0.020169688,-0.044236902,-0.012423359,-0.11848474,0.029231433,-0.032349452,-0.008720711,0.007892487,0.024651842,-0.02221589,-0.017636297,0.03040069,-0.029036557,-0.04482153,-0.020851756,0.025528785,0.023092832,0.02426209,-0.016174726,-0.029816061,0.0119848875,0.010961788,-0.040534254,0.019195307,0.014518279,-0.003824446,0.02728267,-0.012423359,0.010036126,0.0036295697,0.004019322,-0.06197064,-0.012569516,0.009110464,-0.002679548,0.00085258344,-0.0023385147,-0.018805556,0.00823352,0.007892487,-0.018123489,-0.024846718,-0.0041898387,0.0041898387,0.004701389,0.023482585,-0.03507772,0.039364997,-0.003873165,0.020949194,-0.0008404037,-0.032739203,-0.021923576,0.0064796344,0.0030084017,-0.05378584,0.0023019754,0.0065770727,0.011010506,0.00411676,-0.028062176,0.005042422,-0.039364997,-0.036831606,0.017051669,-0.02689292,-0.008038644,-0.014518279,-0.019974813,-0.016369602,0.02884168,0.020462003,-0.014323402,0.016272165,-0.04891393,-0.029816061,0.040144503,0.025528785,0.0044577937,-0.009743811,0.0029353232,-0.018708117,-0.0022532563,-0.015005469,-0.032349452,0.023482585,-0.014615716,-0.0015102907,-0.0025455707,0.038975243,-0.01286183,-0.008525834,0.02533391,-0.028451929,0.008964306,-0.00205838,-0.00360521,0.05378584,0.00018421892,-0.017441422,-0.021631261,0.007161701,0.019779935,0.00774633,-0.020949194,-0.053006332,-0.005529613,0.009695092,-0.014810593,0.02572366,0.0018147848,-0.015297784,0.009841249,-0.0027526265,0.019974813,-0.018902993,-0.0033372552,-0.0007460105,0.008574554,-0.022508204,0.00082822394,0.008087363,0.04540616,0.019877374,-0.00103528,-0.010766911,-0.00567577,-0.011546416,-0.026503166,0.010133564,0.00047501078,-0.03098532,-0.024944156,0.0033128958,-0.01656448,0.010231001,0.0063334773,-0.02474928,0.03040069,0.029816061,0.026113413,0.036831606,-0.011790011,-0.0038488053,0.046380542,0.005066782,0.0024603123,-0.016661918,0.046575416,0.013349021,0.010864349,-0.00721042,0.031375073,-0.0072591393,0.0062116794,0.013641335,-0.05768336,-0.017928611,0.007112982,0.04735492,-0.0018756837,-0.0031180196,0.00038366255,-0.05768336,0.00030297163,0.021728698,0.0035321314,-0.00721042,-0.028646804,0.02630829,-0.004262917,-0.009256621,0.010572035,0.009548935,0.034493092,-0.021338945,0.01802605,-0.010231001,-0.037416235,-0.02689292,-0.016856793,-0.023385147,0.00774633,-0.040534254,0.010133564,-0.011692573,0.0032154575,-0.008574554,-0.0014798413,0.0119848875,0.0057488484,0.012131045,0.008720711,-0.004603951,-0.03254433,-0.019390184,0.0105233155,-0.0028500648,0.007648892,-0.020462003,-0.05378584,-0.04189839,-0.032349452,-0.014615716,-0.004944984,-0.0013458639,-0.024456965,-0.019292746,0.01656448,0.02221589,-0.03975475,0.014713155,-0.02367746,0.005797568,0.05768336,0.021436384,-0.0012179763,-0.007112982,0.049693435,0.008477116,-0.0557346,0.0013763133,-0.030790443,-0.043262523,0.021338945,-0.009987406,0.019682499,-0.0016442682,0.025918538,-0.03507772,0.0024359527,-0.01188745,-0.017441422,0.0014798413,-0.076001726,0.015590098,-0.0018391444,-0.02572366,-0.037805986,0.001138808,-0.03975475,0.015297784,-0.006966825,0.0138362115,0.009451496,-0.0049693435,0.020364566,-0.0021436384,0.0035321314,0.004725748,0.029621186,0.022508204,0.022021012,0.010913068,-0.022313327,-0.0043359958,0.016272165,-0.014615716,-0.008428397,-0.031764824,0.05768336,0.025528785,-0.02533391,-0.0047744676,-0.0069181058,-0.0012971448,0.043652274,0.040534254,-0.016759355,-0.01393365,0.0237749,0.02065688,-0.028062176,0.0019487622,0.018220928,0.026503166,0.0005785388,0.06781693,0.0053347363,-0.01656448,-0.00823352,-0.037026484,-0.030205814,0.0066257915,-0.02884168,0.032349452,-0.011936168,0.05768336,0.02689292,0.047160044,-0.0036782888,-0.011790011,-0.013349021,0.000724696,-0.00828224,-0.019779935,0.022410765,0.0074052964,-0.013543897,0.011936168,0.0052860174,0.015395221,0.009256621,-0.016661918,0.014128526,-0.01393365,0.023385147,-0.04735492,-0.016856793,0.06352965,-0.030010939,0.003044941,0.024554403,-0.010620754,-0.0038975244,-0.028062176,-0.00411676,-0.02270308,0.008525834,0.036246978,0.011010506,0.038390614,-0.0013275943,0.01958506,-0.006966825,0.021241508,0.06547841,0.011400259,0.030790443,-0.031764824,-0.02942631,-0.01183873,-0.01393365,-0.0319597,0.042872768,-0.021728698,-0.04131376,-0.019195307,0.018220928,0.0016199086,0.038975243,0.009841249,-0.00979253,-0.015297784,-0.012764392,0.011107945,0.03819574,0.025918538,-0.01958506,0.012179764,-0.008184801,-0.039949626,0.016077287,0.019877374,-0.003044941,0.003921884,0.0052372986,-0.029621186,-0.048134428,-0.0075514535,0.007064263,0.009548935,0.01442084,0.013349021,0.008915587,0.035272595,0.0075514535,-0.016272165,-0.01958506,-0.04540616,-0.046185665,-0.0020218408,-0.004944984,-0.00037909515,-0.029816061,-0.0060411626,0.024359528,-0.008818149,-0.04189839,0.041118883,-0.01646704,0.030595567,0.0039462433,0.0010961788,0.019487621,-0.021533823,-0.019487621,-0.009938687,0.015687536,-0.036246978,0.006138601,0.009013025,0.023969775,0.010377158,0.056124352,0.022021012,0.018610679,0.00088303286,-0.014810593,-0.017051669,0.010377158,0.020851756,-0.0065283533,0.005529613,0.015590098,-0.010425878,0.10913068,0.03254433,0.034298215,0.015590098,0.005066782,0.0095976535,-0.01656448,-0.04579591,-0.03312896,-0.01958506,0.031764824,-0.0066745104,-0.019974813,-0.017928611,0.014713155,-0.0043359958,0.014323402,-0.015590098,-0.0051398603,0.020462003,-0.047744673,-0.01958506,0.07561197,0.0030693004,-0.011546416,0.02474928,-0.010864349,-0.021241508,0.0031180196,0.018318364,0.01188745,-0.04735492,-0.0050911414,-0.032349452,-0.010474597,-0.019000432,-0.02884168,0.02114407,-0.01753886,0.01646704,-0.054955095,0.018805556,0.031764824,0.016272165,-0.03917012,0.038390614,0.047160044,-0.019292746,0.0043603554,0.018123489,0.0021679979,0.013349021,-0.075222224,0.02728267,0.012959269,-0.039949626,0.04384715,0.00876943,0.01032844,0.030790443,-0.029621186,-0.006114241,0.005773208,-0.030790443,0.011059226,-0.0012484258,-0.015200345,0.035467472,0.056903858,0.02630829,-0.05261658,0.0074540153,0.0049693435,0.01183873,-0.0029353232,-0.020267127,0.006089882,0.014615716,0.005627051,-0.019682499,-0.019390184,0.14810593,0.008379677,-0.020072252,0.00016671051,-0.02474928,0.04482153,0.004993703,0.0074052964,0.01393365,0.038000863,0.008330959,-0.027477548,0.021728698,-0.017246546,0.023872336,0.018708117,-0.019292746,0.013738774,-0.04170351,-0.04267789,0.020169688,0.0475498,0.021436384,0.012666955,0.02572366,-0.0020462002,0.008428397,-0.022021012,-0.01393365,-0.032349452,0.018123489,-0.008184801,-0.010133564,-0.0004019322,0.007941206,-0.023190271,0.020754317,0.0075027347,-0.004701389,0.008477116,-0.028451929,-0.031569947,0.005919365,-0.034493092,-0.056124352,-0.013349021,-0.055344846,-0.012959269,-0.027477548,-0.031569947,-0.018220928,-0.008574554,0.00034864573,0.0048719053,0.012325921,0.008379677,0.018805556,-0.009207902,-0.030790443,-0.007989925,-0.005212939,-0.009548935,0.014908031,0.005529613,-0.01646704,-0.012228482,0.012959269,0.009695092,0.021533823,0.003873165,-0.035272595,0.019390184,-0.014225964,0.0066745104,0.0014006728,0.03858549,0.016272165,0.015102907,-0.009695092,0.011059226,0.032349452,0.010231001,0.031375073,0.0060411626,-0.012472078,0.019000432,-0.03566235,0.00036539292,-0.038975243,-0.012764392,0.0035321314,-0.018123489,-0.02114407,-0.04072913,0.014713155,0.05378584,0.016077287,-0.01442084,-0.005773208,-0.009256621,0.0065770727,0.035467472,-0.015590098,0.014518279,-0.005919365,-0.037221357,-0.017343983,0.031764824,-0.012569516,-0.004287277,0.02426209,0.029816061,-0.026698042,0.036246978,-0.022508204,0.023385147,-0.04072913,0.007795049,-0.0029596826,0.018902993,-0.021923576,0.03098532,0.019390184,0.031180196,-0.0037513673,-0.045990787,-0.009646373,0.03040069,0.01393365,0.014031088,0.013641335,0.00774633,0.044626653,0.012959269,0.001443302,-0.033323836,0.03254433,0.034103338,-0.041508634,-0.0054321745,-0.03858549,0.012569516,0.028062176,0.031180196,0.02533391,-0.00059680844,0.014908031,-0.01909787,0.06625792,0.012082325,0.007161701,0.0021070992,0.019487621,-9.3727085e-06,0.019487621,-0.028451929,-0.0024846718,-0.033323836,0.0019000431,0.022313327,-0.027477548,0.011059226,-0.027087795,0.0360521,-0.01188745,0.022021012,0.007648892,-0.034298215,0.03819574,-0.0012606055,-0.0072591393,0.06236039,0.012959269,-0.020559441,0.0033128958,0.0024968516,-0.004896265,0.015395221,-0.0048231864,-0.010084844,0.038390614,-0.0033128958,-0.0074540153,-0.033323836,0.01958506,-0.02260564,0.009013025,-0.011595136,0.011156663,0.06625792,-0.043067645,0.041508634,-0.018708117,-0.0053834557,0.058073115,0.018902993,0.0062116794,0.016954232,-0.016954232,-0.009159182,-0.00011646899,0.02114407,0.01032844,-0.03293408,-0.03293408,-0.016954232,0.011156663,-0.019000432,-0.03312896,-0.0013032347,0.009110464,0.033908464,0.018318364,-0.009402778,-0.03351871,0.019292746,0.033323836,0.041118883,-0.041118883,0.023190271,-0.006138601,0.010377158,0.04131376,-0.009402778,-0.00979253,-0.03858549,-0.02416465,-0.025139032,0.033323836,-0.019974813,0.0027769862,-0.023969775,-0.014031088,-0.017928611,-0.029816061,0.003191098,0.029231433,0.017928611,0.0019853015,-0.008477116,0.026698042,-0.030205814,0.0024481325,0.015687536,0.00076428015,0.011107945,0.024456965,-0.020462003,-0.030205814,-0.006236039,-0.024846718,-0.001132718,-0.0032154575,0.022021012,-0.00087085314,-0.020559441,0.008818149,0.024456965,-0.0015346502,0.032739203,-0.035857223,0.021338945,-0.011400259,-0.0074052964,0.020364566,0.036441855,0.0069181058,0.016759355,-0.011156663,-0.011059226,-0.008038644,0.02942631,-0.0278673,0.008428397,-0.0014250324,0.04540616,0.0020462002,0.0065283533,0.006966825,0.04696517,-0.02572366,0.01344646,-0.023287708,-0.013349021,0.053006332,0.00082822394,0.01549266,-0.03819574,-0.011741293,-0.021046631,0.033323836,0.00033798846,-0.036831606,-0.01656448,0.0017417063,0.00414112,0.0237749,0.034687966,0.015005469,-0.009159182,-0.03351871,0.002825705,-0.0009865608,0.021826137,-0.009500216,0.019487621,0.01958506,0.0138362115,0.035467472,-0.014615716,0.04170351,-0.0046526697,0.010669473,0.0027039077,-0.008136082,0.0017051669,-0.019195307,0.010279721,0.005529613,-0.01958506,-0.008866868,-0.00774633,0.04891393,0.03293408,0.011741293,0.01753886,0.039364997,0.008623273,0.016954232,0.027087795,-0.020267127,0.0007277409,0.023872336,0.017441422,-0.013543897,-0.01646704,0.009256621,-0.012569516,0.0138362115,-0.005456534,0.012959269,-0.0319597,0.010425878,0.0278673,0.018610679,-0.025528785,0.0029353232,0.019682499,0.039364997,0.018805556,0.013349021,-0.02260564,0.023287708,0.011936168,-0.019487621,-0.049108807,-0.0066745104,-0.018318364,-0.0138362115,-0.008184801,-0.0064796344,-0.007989925,0.010377158,-0.03858549,-0.0017051669,0.042483017,0.05924237,-0.014615716,0.0319597,0.0013336841,-0.017441422,-0.0075514535,0.025139032,-0.023969775,0.015784973,0.0074540153,0.012472078,-0.02533391,0.01958506,0.015882412,0.014713155,0.028062176,0.0052372986,-0.012131045,0.0043603554,0.009451496,-0.026113413,-0.020267127,0.017149108,0.018415803,0.035857223,0.02270308,0.0319597,0.015687536,-0.033713587,0.035272595,-0.027087795,-0.029621186,-0.035272595,-0.053006332,0.034882843,-0.0008464936,-0.021923576,0.016369602,0.023482585,-0.0058462867,-0.018220928,0.039949626,-0.056124352,0.055344846,-0.011156663,-0.0040924004,0.014908031,0.04189839,-0.001802605,0.0016808074,0.007795049,-0.01286183,0.008818149,-0.106012665,-0.029036557,-0.00019487622,-0.013154145,0.056514103,0.019000432,0.00672323,3.330404e-05,-0.00258211,0.021631261,-0.014518279,0.013543897,0.01597985,0.009402778,-0.031375073,0.0053834557,-0.00089521264,0.003507772,0.037416235,-0.027477548,-0.036831606,0.02572366,0.011205383,0.01188745,-0.009159182,-0.03254433,-0.02884168,0.05066782,-0.02728267,0.03040069,-0.042483017,-0.01802605,0.04521128,-0.049108807,0.0721042,-0.045990787,-0.0086719915,-0.038390614,0.015687536,-0.0009865608,0.03254433,-0.007112982,0.045990787,-0.0037757268,-0.01188745,0.0010961788,0.015395221,0.009841249,-0.026113413,-0.0039462433,-0.02884168,0.01344646,-0.04579591,0.011790011,0.022800518,-0.027477548,0.009207902,-0.027477548,-0.033713587,-0.016174726,0.012764392,-0.0033128958,-0.027672423,0.019974813,-0.014908031,-0.032154575,0.0003867075,0.023092832,0.0051155007,0.0072591393,-0.05066782,0.0045065125,-0.012325921,0.050278064,0.0024603123,-0.004750108,-0.030790443,0.00070947123,0.04579591,0.0040436815,0.017831175,-0.02942631,-0.010133564,0.0039949627,-0.0068206675,0.07015544,0.10523316,-0.010182283,-0.028646804,-0.008477116,-0.022118451,0.020462003,-0.01344646,0.0019487622,0.002728267,0.0001728004,-0.050278064,0.008525834,-0.013056707,0.004287277,0.0043359958,-0.017051669,-0.011156663,0.006114241,0.011059226,0.03566235,-0.030010939,0.009889968,-0.0008099543,0.015784973,0.02572366,0.027672423,0.011254102,-0.005821927,-0.036441855,0.026698042,-0.00258211,0.033323836,-0.012179764,0.013641335,0.03878037,-0.004603951,-0.06080138,-0.0037026482,0.027477548,-0.007795049,0.010718192,-0.022508204]'),
('2039214383007084545', 'Web前端核心知识补充

一、JavaScript进阶

1. this指向问题
- 普通函数调用：window / undefined（严格模式）
- 对象方法调用：调用该方法的对象
- 构造函数调用：新创建的实例
- call/apply/bind：指定的对象
- 箭头函数：定义时的外层作用域

箭头函数特点：
- 没有自己的this，继承外层作用域
- 不能作为构造函数
- 没有arguments对象

2. 深拷贝与浅拷贝
浅拷贝：只复制一层，引用类型共享
深拷贝：递归复制所有层级

实现方法：
- 浅拷贝：Object.assign()、扩展运算符 {...obj}
- 深拷贝：JSON.parse(JSON.stringify())（无法处理函数、undefined、循环引用）
- 深拷贝：structuredClone()（现代浏览器）、递归实现、lodash _.cloneDeep()

3. 防抖与节流
防抖：延迟执行，连续触发只执行最后一次
适用场景：搜索框输入、窗口resize

节流：固定时间间隔执行一次
适用场景：滚动加载、按钮点击

防抖实现：
function debounce(fn, delay) {
    let timer;
    return function(...args) {
        clearTimeout(timer);
        timer = setTimeout(() => fn.apply(this, args), delay);
    };
}

节流实现：
function throttle(fn, delay) {
    let lastTime = 0;
    return function(...args) {
        const now = Date.now();
        if (now - lastTime >= delay) {
            lastTime = now;
            fn.apply(this, args);
        }
    };
}

4. 数组常用方法
- map：映射生成新数组，不改变原数组
- filter：过滤元素，不改变原数组
- reduce：累加计算，不改变原数组
- forEach：遍历执行，不改变原数组
- find：查找第一个符合条件的元素
- some：是否有元素满足条件
- every：是否所有元素满足条件
- push/pop：末尾添加/删除，改变原数组
- shift/unshift：开头删除/添加，改变原数组
- splice：删除/替换元素，改变原数组
- sort：排序，改变原数组

二、ES6+核心特性

5. let / const 与 var 区别
- var：函数作用域、变量提升、允许重复声明、允许重新赋值
- let：块级作用域、暂时性死区、不允许重复声明、允许重新赋值
- const：块级作用域、暂时性死区、不允许重复声明、不允许重新赋值（引用类型可修改属性）

6. 解构赋值
数组解构：const [a, b, c] = [1, 2, 3]
对象解构：const { name, age } = { name: ''张三'', age: 18 }
函数参数解构：function fn({ name, age }) { ... }

7. 扩展运算符
- 数组展开：[...arr1, ...arr2]
- 对象展开：{...obj1, ...obj2}
- 函数参数：Math.max(...arr)
- 剩余参数：function(...args) {}

8. 模块化
- ES6：export default / export，导入用 import
- CommonJS：module.exports，导入用 require

三、Vue框架进阶

9. Vue组件通信方式
- props / emit：父子组件通信
- provide / inject：跨层级传递
- Vuex / Pinia：全局状态管理
- $refs：访问子组件实例
- $parent / $children：直接访问（不推荐）
- event bus：任意组件（已不推荐）

10. computed 和 watch 区别
- computed：有缓存，依赖变化才重新计算，不支持异步，适用于计算派生数据
- watch：无缓存，支持异步，适用于执行副作用（请求、DOM操作）

11. Vue Router核心
路由模式：
- hash：监听hashchange，无需后端配置
- history：利用HTML5 History API，需要后端支持

路由守卫：
- 全局守卫：beforeEach、afterEach
- 路由独享守卫：beforeEnter
- 组件内守卫：beforeRouteEnter、beforeRouteUpdate、beforeRouteLeave

12. Vuex / Pinia
- Vuex：单一状态树，actions处理异步，代码量较多
- Pinia：多store，类型提示强，代码简洁，Vue3推荐

四、React核心

13. React核心概念
- JSX：JavaScript语法扩展，描述UI
- 组件：函数组件 + Hooks / 类组件
- props：父组件传递数据
- state：组件内部状态
- 生命周期：componentDidMount、componentDidUpdate、componentWillUnmount

14. Hooks常用
- useState：管理状态
- useEffect：处理副作用（请求、DOM操作）
- useContext：消费Context
- useRef：获取DOM或保存变量
- useMemo：缓存计算结果
- useCallback：缓存函数

五、浏览器与网络

15. Cookie、localStorage、sessionStorage区别
- Cookie：4KB，可设置过期时间，自动携带到服务器，用于认证、会话
- localStorage：5-10MB，永久存储，不携带到服务器，用于长期存储
- sessionStorage：5-10MB，会话结束清除，不携带到服务器，用于临时存储

16. HTTP缓存
- 强缓存：Cache-Control、Expires，过期前不请求服务器
- 协商缓存：ETag、Last-Modified，向服务器验证资源是否过期

17. WebSocket
特点：全双工通信、持久连接、服务端可主动推送
适用场景：实时聊天、在线游戏、实时数据展示

六、工程化与构建工具

18. Webpack核心概念
- entry：入口文件
- output：输出配置
- loader：处理非JS文件（css、图片）
- plugin：扩展功能（压缩、热更新）
- mode：development / production

19. Vite特点
- 开发环境：原生ES模块，冷启动快
- 生产环境：Rollup打包
- 热更新：按需编译

七、常见面试题补充

20. 什么是跨域？如何解决？
跨域是浏览器同源策略导致的限制，协议、域名、端口任一不同即跨域。
解决方案：
- CORS：后端设置Access-Control-Allow-Origin
- 代理：开发环境配置proxy
- JSONP：仅支持GET请求
- postMessage：跨窗口通信

21. 什么是虚拟DOM？优缺点？
虚拟DOM是用JavaScript对象描述真实DOM结构。
优点：减少直接操作DOM、跨平台
缺点：首次渲染比直接操作DOM慢、占用内存

22. Vue和React的区别？
- 模板语法：Vue模板更接近HTML，React使用JSX
- 数据流：Vue双向绑定，React单向数据流
- 响应式：Vue自动追踪依赖，React需要setState

知识点汇总表

分类            核心知识点
JavaScript      this、深拷贝、防抖节流、数组方法
ES6+            let/const、解构、扩展运算符、模块化
Vue             生命周期、响应式、组件通信、computed/watch、Router、状态管理
React           组件、Hooks、生命周期
浏览器          存储、HTTP缓存、WebSocket、跨域
性能优化        首屏优化、内存管理
工程化          Webpack、Vite', '{"doc_id": "2039214362530492416", "chunk_index": 0, "collection_name": "web"}', '[0.021308724,-0.04339585,-0.05293126,-0.012843614,0.066942476,-0.050985258,0.0063245073,0.0836781,0.016054519,0.04514725,-0.024616929,0.015373418,0.04339585,0.06071527,0.02646563,0.044368852,-0.04339585,-0.0075407587,0.0015263956,-0.0029919785,0.00088178227,0.019557323,0.0037217294,-0.03405504,-0.019654622,0.03580644,-0.029384634,-0.037947044,-0.00909756,0.010021912,-0.018876221,-0.030357635,-0.06966688,0.056823265,0.00227439,0.010848963,0.006056932,0.011870613,0.046509452,0.023643928,-0.013330115,0.074726485,-0.0036730792,0.037947044,-0.030746836,-0.0072488585,-0.02607643,0.00039224108,0.0054244814,-0.00430553,0.031330638,-0.039114647,0.024130428,0.028022433,0.05332046,-0.03327664,-0.00900026,-0.009681361,0.010897612,-0.0149842175,-0.03483344,0.0036730792,-0.0014108516,0.0019581649,0.016735619,0.007832659,0.00015203143,-0.010557062,0.012259814,-0.048844658,-8.6657914e-05,0.0017878895,-0.049428456,0.04553645,-0.0016662644,-0.038141645,-0.020627623,-0.014886918,0.036195643,-0.007054258,0.012551715,0.057212465,0.014205816,0.000319266,-0.009730011,-0.049039256,-0.022087125,0.002724403,-0.025687229,-0.012843614,0.015568018,0.040476847,-0.013719316,0.024325028,-0.010459762,-0.007443459,-0.02607643,-0.029579233,-0.016054519,-0.0062758573,0.015373418,0.018584322,0.015762618,0.022184426,-0.00870836,-0.026854832,-0.004475805,-0.007929959,-0.01770862,0.007929959,0.0039893044,0.051374458,0.0010216512,0.027244031,0.012649015,0.039698444,-0.04183905,0.030552235,0.013427416,-0.0038676795,-0.018973522,0.005400156,0.015859919,0.013427416,0.028995434,0.0065677576,0.011335463,0.057601668,-0.014303116,0.055655666,0.002602778,-0.021406025,0.011627363,-0.08328889,-0.015178817,-0.0116760135,-0.012649015,0.038725443,-0.015276117,0.013330115,0.054488063,0.010070561,0.018681621,-0.056044865,0.012940915,-0.022768226,0.0075407587,-0.016443718,-0.013232815,0.021308724,0.004378505,-0.027244031,0.0049623055,0.015373418,-0.010070561,0.026854832,0.003101441,0.02607643,0.010411112,-0.025492629,-0.05059606,0.01683292,-0.0045244554,0.0063731573,0.041255247,0.00827051,-0.042617448,0.028995434,0.00017939709,0.031136036,-0.008221859,0.03366584,0.019557323,0.02646563,-0.0020311398,0.013622016,0.0044028303,-0.003575779,-0.021406025,0.014108516,-0.0072488585,0.014692317,-0.0027730532,0.05176366,0.0015446392,0.008124559,0.0012040889,-0.04106065,0.019362722,0.005108256,-0.020822223,-0.028022433,-0.0050839307,-0.03366584,0.0149842175,-0.0010946263,0.001301389,0.016930219,0.046120252,0.011432763,0.040866047,0.0860133,0.040087648,-0.033860438,0.01663832,0.007005608,-0.036974043,-0.009243511,-0.015470718,-0.029190034,-0.0005868413,0.019849222,0.02490883,0.0042325547,0.001678427,0.0062758573,-0.05176366,-0.004427155,0.028995434,-0.0076380586,-0.0099732615,-0.046704054,-0.0018000521,0.009389461,0.015470718,0.08056449,-0.04981766,-0.014011216,-0.015859919,-0.021600625,0.047093254,-0.010557062,0.00851376,0.0030892785,-0.009292161,0.00831916,-0.012940915,0.0063245073,-0.021600625,0.005059606,-0.020335723,-0.009243511,-0.017611321,-0.07589409,-0.010751663,-0.00851376,0.006202882,-0.029579233,0.0891269,-0.030357635,0.016249118,0.04183905,-0.0099732615,0.0072002085,0.022379026,0.014789617,-0.0049866308,-0.01770862,-0.010654362,0.06733168,-0.014108516,0.027438631,0.00870836,0.002675753,-0.014497717,0.010119212,-0.048844658,-0.0019946522,-0.006032607,0.018973522,-0.0013865266,-0.0050352807,-0.006908308,-0.030163035,-0.032109037,-0.015665319,-0.014789617,-0.040671445,0.024714228,0.005983957,-0.00088178227,0.024325028,0.020043824,-0.009243511,0.020141123,-0.016249118,0.062661275,0.05293126,0.014303116,-0.0099732615,-0.019362722,-0.0037217294,-0.00459743,-0.0039649797,0.01838972,0.005059606,0.0015689643,-0.015859919,0.0037460544,0.027049432,0.025492629,-0.03230364,-0.00227439,0.040866047,-0.046314854,0.001325714,-0.007443459,0.0066650575,-0.037363242,-0.015957218,-0.00063245074,-0.01770862,-0.029579233,-0.0036974042,0.0027852156,0.04417425,0.040282246,0.03600104,-0.012649015,0.01654102,0.0014716642,0.012649015,-0.010265162,0.035222642,0.036584843,0.020724924,-0.011724664,0.0094381105,-0.039893046,-0.016930219,0.01663832,0.00817321,-0.02510343,0.004889331,-0.057601668,-0.020530324,-0.00029646128,-0.056434065,0.040476847,0.010751663,0.024325028,-0.015568018,-0.00430553,-0.00885431,-0.024227727,-0.04106065,0.0073948083,-0.019946523,-0.030357635,0.054488063,-0.036584843,-0.0105084125,-0.005156906,0.013232815,0.0045244554,-0.0048650056,-0.04981766,-0.00875701,-0.037752442,0.04553645,0.0007267102,-0.0018973522,0.010654362,-0.028411632,0.028411632,-0.015859919,-0.018292421,-0.015859919,-0.020238424,-0.02529803,-0.019849222,0.011530063,-0.06927768,-0.012259814,-0.015470718,-0.005400156,-0.023741227,0.011238163,-0.0049136556,0.037363242,0.009146211,-0.01683292,-0.0020433024,-0.002505478,-0.016735619,-0.027827833,-0.028995434,-0.019849222,-0.0048650056,-0.028022433,0.030941436,0.036195643,-0.0065191076,-0.0004591349,-0.015081517,0.027244031,0.039893046,-0.015762618,-0.007005608,-0.006908308,0.00841646,0.021503326,0.031525236,-0.022962827,-0.009340811,-0.005132581,-0.00870836,-0.02490883,0.023838528,-0.022768226,0.039698444,-0.010605712,-0.016249118,-2.888597e-05,0.0007662384,0.06110447,0.054488063,0.013232815,0.03600104,-0.031525236,0.019557323,0.019751923,-0.021406025,0.03308204,-0.03269284,0.028995434,0.021697925,-0.00222574,0.030552235,0.021503326,0.014497717,-0.026854832,-0.057601668,0.014886918,0.0094381105,-0.038725443,0.04320125,0.030552235,0.038336243,-0.021892525,0.014205816,0.030357635,0.011821964,-0.06927768,-0.021406025,0.024519628,-0.023352027,0.006908308,0.014400417,-0.014400417,0.019751923,0.02529803,-0.04456345,-0.0032352288,-0.006859658,-0.010216512,-0.000744954,0.0075407587,0.0016905895,-0.006129907,0.04417425,-0.04378505,0.014108516,-0.018778922,0.035222642,0.032498237,-0.006956958,-0.046704054,-0.018973522,-0.03366584,-0.057212465,-0.027049432,-0.055655666,0.011530063,0.021308724,0.0018365396,0.004427155,0.001301389,0.009730011,-0.014497717,0.022573626,-0.021697925,-0.045731053,0.018292421,-0.0022014151,0.003429829,0.024033127,0.037947044,0.019946523,0.006713708,-0.024033127,-0.00909756,0.020724924,-0.040476847,0.006008282,-0.04183905,0.016054519,-0.007054258,0.01790322,0.00034967228,-0.018097822,0.012843614,-0.038530845,-0.020335723,-0.03444424,-0.05020686,-0.005205556,-0.05215286,0.02666023,-0.011530063,0.014108516,-0.024325028,-0.04475805,0.029968435,-0.028411632,0.018973522,-0.019168122,0.0075894087,0.040282246,0.04242285,-0.0073461584,0.007443459,0.026854832,0.006956958,-0.02588183,0.030163035,0.01663832,0.0088056605,0.01615182,-0.005010956,-0.012940915,0.014400417,-0.02510343,-0.00851376,-0.012649015,-0.00919486,0.0046947305,0.016735619,-0.03561184,-0.013622016,0.007784009,0.018778922,-0.011238163,0.013622016,0.02646563,-0.042228248,0.00047433804,-0.019946523,-0.022087125,0.046314854,-0.025687229,-0.0041839047,0.045925654,-0.03308204,-0.010703012,0.009778662,-0.031525236,-0.047677055,0.01741672,0.0076380586,0.0039893044,-0.00029190033,-0.021795224,-0.014789617,-0.014011216,0.0065677576,-0.018487021,-0.012843614,-0.014011216,0.012065214,-0.054877263,-0.004475805,0.008465109,0.015470718,-0.030746836,0.044952653,-0.015081517,-0.012308464,0.028411632,0.001350039,-0.006908308,-0.045341853,-0.019654622,0.002675753,0.0004682568,-0.005862332,-0.019168122,-0.015762618,0.0056920564,-0.015665319,0.01838972,-0.011384113,-0.0009182698,0.019265423,0.005983957,1.9003928e-05,0.0066164075,-0.005010956,0.02529803,0.032887436,-0.009292161,-0.020433024,-0.042228248,0.011043563,0.012016564,0.022573626,-0.018876221,-0.02627103,0.0053758314,0.037947044,-0.010800312,0.019946523,0.0005625163,-0.006956958,0.026854832,0.021600625,-0.0048650056,-0.01731942,-0.054877263,0.018292421,0.013622016,-0.020822223,-0.013524716,-0.013038215,0.039698444,-0.012940915,0.003575779,0.03639024,0.0050352807,-0.015762618,-0.010119212,0.01634642,0.011238163,0.039893046,-0.012308464,0.03405504,-0.0105084125,0.022768226,0.039893046,-0.057601668,0.029190034,-0.011530063,0.003478479,0.00885431,-0.005010956,-0.023060126,0.0041839047,0.010216512,-0.00827051,-0.0019946522,0.04300665,0.009340811,0.037168644,-0.00909756,0.03230364,0.016054519,-0.03230364,-0.009730011,-0.023449328,-0.024811529,0.014205816,0.025687229,0.0040136296,0.00030406285,-0.024325028,-0.020433024,0.0016176144,0.00450013,-0.030163035,-0.0010459762,-0.018097822,-0.023157427,-0.013330115,0.0019216773,0.0019946522,-0.021892525,0.019654622,-0.03502804,-0.0003314285,-0.014108516,-0.045341853,2.8695931e-05,-0.022281725,0.0038190293,0.019654622,-0.028606232,0.0028460282,0.00027365657,-0.013719316,-0.019265423,0.01751402,-0.0007540759,-0.022379026,-0.035222642,0.00078448217,0.018097822,-0.0017392396,-0.018876221,0.010216512,0.0045244554,0.01838972,-0.020238424,-0.07122368,-0.04203365,-0.007151558,0.0037217294,-0.0149842175,-0.010119212,-0.031719837,-0.02510343,0.044368852,-0.011773313,-0.007686709,0.003502804,0.01731942,-0.013330115,0.0836781,-0.0065677576,-0.0088056605,-0.035222642,0.043979652,0.014886918,-0.028022433,0.010605712,-0.048455454,-0.007881309,0.036974043,0.01800052,0.02588183,-0.009875962,0.003478479,0.023352027,-0.0037217294,0.0016905895,0.004281205,0.02646563,-0.044952653,0.01712482,0.059158467,-0.00861106,0.0111408625,0.011238163,-0.013913916,-0.022865526,-0.01683292,0.03541724,-0.0076380586,0.06305047,-0.01741672,0.01663832,-0.0039406545,-0.010751663,0.027633231,0.013524716,0.029968435,-0.00861106,0.008124559,0.021016825,-0.012940915,0.014886918,-0.030552235,-0.018778922,0.054098863,0.023935828,-0.006081257,0.0039649797,-0.04281205,-0.014205816,0.030163035,0.038336243,0.015276117,0.015665319,0.029579233,0.024811529,0.04514725,0.020822223,0.00034967228,0.022184426,0.007832659,0.06460728,0.010119212,0.0065191076,-0.0049623055,-0.00807591,-0.0056434064,-0.00017331583,-0.03269284,0.037947044,0.00207979,0.013232815,-0.012259814,0.035222642,0.031525236,-0.009389461,0.004889331,0.020141123,-0.029190034,-0.03230364,0.037168644,0.009486761,-0.012308464,0.04183905,0.0055217813,-0.011335463,0.016735619,0.006202882,0.03600104,-0.01634642,-0.016930219,-0.10741933,-0.00807591,0.029384634,-0.022768226,-0.02529803,0.036974043,0.022865526,-0.008221859,-0.020043824,0.0020311398,-0.013330115,0.00459743,0.015178817,0.00020524242,0.04281205,0.014108516,0.031914435,-0.029384634,0.0031136037,0.028411632,-0.00070846645,0.0023595276,0.016735619,-0.039309245,-0.003527129,0.010070561,-0.04378505,0.024616929,-0.009924611,-0.005351506,-0.0004348099,0.055655666,0.03541724,0.042617448,0.020919524,0.012843614,0.01780592,-0.007054258,0.0030649535,0.019946523,-0.012940915,-0.018973522,-0.023352027,-0.031719837,-0.023254726,0.028606232,0.010265162,0.014205816,0.0015324767,-0.0075894087,-0.011967914,-0.05293126,0.0028703534,0.018876221,0.028606232,-0.004086605,0.015081517,-0.018681621,0.046704054,-0.048650056,-0.02607643,0.00841646,-0.031719837,-0.022768226,-0.0009061073,-0.0055217813,-0.03483344,-0.00454878,-0.003575779,0.009048911,0.028217033,-0.023643928,0.011627363,0.007102908,0.00919486,-0.031914435,0.01780592,-0.007443459,-0.021795224,-0.021016825,-0.021114124,0.047677055,0.008027259,-0.02529803,0.014303116,0.02490883,-0.015470718,0.058380067,0.02607643,0.013913916,0.01780592,-0.01838972,-0.037168644,-0.027438631,-0.00875701,-0.03677944,-0.0014351767,0.05059606,-0.00450013,-0.008124559,0.046898656,0.007686709,-0.023449328,0.02666023,0.0032109036,-0.021503326,0.00875701,-0.037557844,-0.031914435,0.06616408,0.0018851897,-0.018097822,0.023741227,-0.001350039,0.006762358,0.027049432,0.016443718,0.005278531,0.057601668,0.00450013,-0.02490883,-0.031525236,-0.0020189774,0.011919264,0.048650056,-0.030163035,-0.012162514,0.006421807,0.024616929,0.0021406026,0.0064704577,-0.040282246,-0.0047677057,0.004037955,-0.033860438,-0.014789617,0.0063731573,-0.001678427,0.024519628,-0.056044865,0.0074921087,0.03230364,-0.038530845,-0.028995434,0.03677944,0.02588183,0.011773313,-0.023935828,0.02607643,0.010800312,0.015568018,-0.041255247,-0.013913916,0.009584061,-0.006008282,0.014011216,0.046314854,0.028411632,0.049428456,0.014011216,-0.0149842175,0.00856241,-0.023643928,-0.021308724,0.015276117,-0.010751663,-0.016443718,0.0105084125,0.0075407587,-0.010119212,-0.021016825,0.029579233,0.026854832,-0.0057650316,0.0073948083,-0.023935828,0.010021912,-0.007151558,-0.011432763,0.000875701,0.09652171,-0.013330115,-0.0073461584,0.0063731573,-0.00096083863,0.062661275,0.005400156,0.0062272074,-0.016735619,-0.0048650056,0.046898656,0.022573626,0.032887436,-0.013232815,0.027244031,-0.025492629,-0.023838528,-0.028606232,-0.015859919,-0.016443718,0.021016825,0.03580644,0.041255247,-0.00060204446,-0.0028946784,0.019557323,-0.024714228,-0.024616929,0.03677944,-0.041644447,0.05059606,-0.01654102,-0.009778662,-0.0036730792,0.01634642,0.010362462,0.021016825,0.012551715,-0.013622016,0.029968435,-0.003454154,-0.00827051,0.037168644,-0.011870613,-0.021989826,0.028800834,-0.04417425,-0.020822223,0.0010277324,-0.021503326,0.023546627,0.00856241,-0.0105084125,0.02529803,-0.0075894087,-0.0025419653,0.029190034,-0.0072002085,-0.0037217294,-0.032498237,-0.01683292,0.006762358,0.025492629,-0.03269284,0.0127463145,-0.0012101701,0.0065191076,-0.021406025,0.039698444,0.0006263695,0.0127463145,-0.00058380066,0.0046460805,0.030357635,0.015081517,0.022573626,0.054488063,0.023643928,-0.014886918,-0.006421807,0.022476327,-0.0075894087,0.0040622796,-0.024325028,-0.0017635645,0.03269284,-0.0021649275,-0.012843614,-0.01615182,-0.014011216,0.02666023,-0.01663832,0.006859658,-0.010994913,0.020043824,0.030941436,0.036974043,-0.0015446392,-0.027633231,-0.0030892785,0.015276117,0.03502804,-0.046509452,0.019849222,0.024422329,0.00062332884,-0.02490883,0.055655666,0.01683292,0.0013196327,0.023643928,0.007151558,0.030163035,0.015665319,-0.00450013,0.01712482,-0.032109037,0.003551454,-0.014205816,0.038141645,-0.02529803,0.040866047,0.024811529,0.033860438,-0.018778922,-0.06071527,-0.0004165661,-0.005156906,-0.022670927,0.010994913,0.00031470504,-0.028217033,0.032887436,0.013135515,0.008221859,-0.00861106,0.014595017,0.02607643,0.0066164075,0.0025176404,0.02510343,0.0016662644,0.006081257,-0.010167861,-0.029384634,-0.03230364,0.013135515,-0.015373418,0.001727077,0.018097822,0.03541724,0.028217033,0.018876221,-0.012454415,0.01615182,-0.04981766,-0.0014108516,-0.012405764,-0.018584322,0.03269284,-0.028800834,-0.021989826,-0.0062272074,0.01838972,0.0055704312,0.009924611,-0.018876221,-0.013719316,0.02607643,-0.042617448,-0.0149842175,0.013816616,0.021308724,0.040476847,0.0033082038,0.0023352026,0.02588183,-0.0037460544,0.002104115,0.032109037,0.048650056,0.0011919264,-0.018292421,-0.037557844,-0.0052542062,-0.0076380586,0.0018122146,0.027633231,0.005862332,0.036974043,-0.020627623,0.03269284,-0.005010956,-0.009535411,0.057212465,-0.003381179,-0.0050839307,-0.04300665,0.011724664,-0.012113864,0.0054974565,0.021503326,0.037557844,-0.039893046,0.01654102,0.012649015,0.020335723,-0.0083678095,-0.024422329,-0.015957218,0.00861106,0.031719837,0.029773835,0.06538568,0.0058380067,0.03502804,0.038336243,0.021211425,-0.032887436,-0.005910982,-0.0022014151,0.011384113,0.015276117,-0.007686709,-0.006811008,-0.012405764,-0.013232815,-0.013622016,0.028022433,0.00096083863,0.011967914,-0.00870836,-0.005327181,-0.04456345,0.0008088072,0.018681621,0.012843614,0.0064704577,-0.018681621,-0.0149842175,-0.019849222,-0.009632711,0.04553645,0.00865971,-0.031136036,0.011189513,0.0042325547,0.0076380586,-0.03230364,-0.031525236,0.023838528,-0.036584843,0.013135515,0.0015568018,-0.037363242,-0.023449328,0.030552235,0.045341853,-0.020141123,0.0058136815,-0.044952653,0.0019703272,0.0015811268,0.0116760135,0.012113864,0.011967914,0.011238163,0.0041109296,0.0001649541,-0.014692317,-0.02666023,-0.010362462,0.006908308,-0.02666023,-0.01663832,0.04281205,0.030552235,-0.023546627,-0.019751923,-0.010800312,0.0063245073,0.042617448,-0.00841646,-0.0019095147,0.020822223,-0.0033325288,0.015276117,-0.004378505,-0.027438631,-0.009146211,-0.020822223,-0.00895161,0.0050839307,-0.0016419394,-0.010459762,0.039114647,0.039503846,0.044368852,-0.0049136556,-0.0018730272,-0.04281205,-0.0018973522,-0.014205816,0.013622016,-0.007443459,0.005789357,0.030357635,0.0041109296,0.0149842175,-0.012016564,0.023060126,0.009243511,-0.031719837,-0.0076380586,-0.019849222,-0.02627103,-0.02510343,0.019168122,0.019070823,0.009486761,-0.019654622,-0.028022433,0.015665319,0.002724403,-0.0006689383,0.012016564,0.030163035,0.021503326,0.011627363,-0.00420823,-0.015470718,0.010654362,-0.013524716,0.061882872,0.0028581908,-0.03463884,0.016443718,-0.040866047,0.0072975084,0.038336243,-0.013330115,-0.015665319,0.06460728,0.0022379025,0.056434065,-0.03327664,0.047677055,-0.001489908,0.030357635,0.015081517,0.0099732615,-0.015859919,0.03269284,-0.04281205,-0.013330115,-0.02646563,-0.001751402,-0.023449328,-0.00919486,-0.026854832,0.06071527,0.006008282,0.000851376,-0.0066164075,-0.013232815,0.040476847,0.055266462,-0.022768226,0.029579233,0.057601668,-0.021892525,0.010216512,-0.00053211,-0.0046947305,-0.019557323,-0.0046460805,0.01683292,0.0056434064,0.00861106,0.019946523,-0.0022014151,0.0032109036,0.0063731573,0.01683292,0.013427416,-0.024325028,0.015859919,-0.020141123,0.013719316,0.05254206,0.061882872,-0.02529803,0.018973522,0.009243511,-0.01731942,0.021989826,0.01683292,-0.07005608,-0.038530845,-0.047871657,0.024422329,-0.020238424,-0.011627363,-0.027049432,0.038141645,-0.0039163297,-0.013622016,0.033471238,-0.03561184,0.009730011,-0.027049432,-0.004329855,0.04300665,0.0019216773,0.028411632,-0.0018122146,0.013038215,0.0018000521,-0.02646563,-0.049039256,-0.02666023,-0.007735359,-0.019654622,0.026854832,0.00817321,-0.019362722,0.0074921087,-0.005862332,0.010994913,-0.021211425,-0.009486761,-0.0083678095,-0.0037460544,-0.01800052,0.00900026,-0.0019460022,0.002529803,0.006956958,0.020627623,-0.006762358,0.0038190293,0.013816616,-0.029579233,-0.012065214,-0.028411632,-0.016249118,0.023935828,0.007929959,0.01819512,0.03444424,-0.030163035,0.03502804,-0.05176366,0.099246114,-0.012405764,0.005156906,-0.010167861,-0.038530845,0.00807591,0.047482453,0.010557062,0.056434065,-0.012551715,0.0072975084,0.006859658,-0.016249118,0.003381179,0.00415958,-0.020919524,-0.05059606,0.014108516,-0.029384634,0.0062758573,-0.0025176404,-0.01712482,-0.025687229,-0.023935828,-0.037947044,-0.014011216,0.0050839307,0.006421807,0.011286813,0.021892525,-0.013427416,0.0045731054,0.03444424,0.031525236,0.014789617,0.050985258,-0.04378505,-0.0003952817,0.014692317,0.03502804,0.005229881,0.005302856,-0.043979652,0.003356854,0.040282246,0.031719837,0.021503326,-0.011870613,0.009340811,-0.01702752,-0.015276117,0.054877263,0.03600104,0.012454415,-0.010216512,0.013524716,-0.015568018,0.027244031,0.0026392655,-0.016930219,0.0018730272,0.041644447,0.0075894087,-0.009340811,-0.011530063,-0.002578453,-0.03463884,0.01615182,0.018681621,0.023449328,-0.0149842175,0.010800312,0.011773313,0.014497717,0.00909756,-0.030746836,0.037557844,0.0009730011,0.06071527,-0.005351506,-0.0062758573,-0.011773313,-0.005205556,-0.009389461,-0.011578714,0.00856241,0.04106065,-0.0010946263,-0.05254206,0.014108516,-0.014011216,0.0020919524,0.00900026,-0.015665319]'),
('2039216656022056961', 'Python算法开发核心概念

一、Python基础进阶

1. Python可变与不可变类型
不可变类型：int、float、bool、complex、str、tuple
可变类型：list、dict、set
原理：不可变类型在内存中创建后不可修改，修改会创建新对象；可变类型在原内存上修改。

2. 深拷贝与浅拷贝
浅拷贝：只复制顶层，内部引用共享，适用对象结构简单
深拷贝：递归复制所有层级，适用对象结构复杂
import copy
list1 = [1, [2, 3]]
list2 = copy.copy(list1)      # 浅拷贝
list3 = copy.deepcopy(list1)  # 深拷贝

3. 列表推导式与生成器
列表推导式：一次性生成所有元素，占用内存，适用数据量小
生成器表达式：惰性计算，节省内存，适用数据量大
列表推导式：[x**2 for x in range(10)]
生成器表达式：(x**2 for x in range(10))

4. 装饰器
定义：在不修改原函数代码的情况下增加额外功能
应用场景：日志记录、性能计时、权限校验、缓存
def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        print(f"耗时: {time.time() - start}")
        return result
    return wrapper

5. 上下文管理器
with open(''file.txt'', ''r'') as f:
    content = f.read()
自定义上下文管理器：
class MyContext:
    def __enter__(self):
        print("进入")
        return self
    def __exit__(self, exc_type, exc_val, exc_tb):
        print("退出")

二、数据结构与算法

6. 常见数据结构复杂度
列表：访问O(1)、查找O(n)、插入O(n)、删除O(n)
字典：访问O(1)、查找O(1)、插入O(1)、删除O(1)
集合：访问O(1)、查找O(1)、插入O(1)、删除O(1)
堆：访问O(1)、查找O(n)、插入O(log n)、删除O(log n)
队列：访问O(1)、查找O(n)、插入O(1)、删除O(1)

7. 排序算法对比
冒泡排序：最优O(n)、平均O(n²)、最差O(n²)、空间O(1)、稳定
快速排序：最优O(n log n)、平均O(n log n)、最差O(n²)、空间O(log n)、不稳定
归并排序：最优O(n log n)、平均O(n log n)、最差O(n log n)、空间O(n)、稳定
堆排序：最优O(n log n)、平均O(n log n)、最差O(n log n)、空间O(1)、不稳定
计数排序：最优O(n+k)、平均O(n+k)、最差O(n+k)、空间O(k)、稳定

8. 二分查找
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1
时间复杂度：O(log n)

9. 动态规划核心思想
核心：将大问题分解为重叠子问题，保存子问题结果避免重复计算
解题步骤：
- 定义状态（dp[i]表示什么）
- 找到状态转移方程
- 初始化边界条件
- 确定遍历顺序
经典问题：斐波那契数列、背包问题、最长递增子序列、编辑距离

三、NumPy核心

10. NumPy数组创建
import numpy as np
arr = np.array([1, 2, 3])           # 从列表创建
zeros = np.zeros((3, 4))            # 全0
ones = np.ones((3, 4))              # 全1
eye = np.eye(3)                     # 单位矩阵
arange = np.arange(0, 10, 2)        # 等差数列
linspace = np.linspace(0, 1, 5)     # 等间隔

11. 数组索引与切片
一维切片：arr[1:5]、arr[::2]
二维切片：arr[0, :]第一行、arr[:, 0]第一列、arr[1:3, 2:4]子矩阵
布尔索引：arr[arr > 5]

12. 广播机制
当两个数组形状不同时，NumPy自动扩展较小数组以匹配较大数组
arr + 10  # 每个元素加10
arr1 = np.array([[1,2,3], [4,5,6]])
arr2 = np.array([10,20,30])
result = arr1 + arr2  # arr2广播到每一行

13. 常用NumPy函数
np.sum：求和
np.mean：平均值
np.std：标准差
np.dot：点积
np.matmul：矩阵乘法
np.reshape：重塑形状
np.transpose：转置
np.concatenate：拼接

四、Pandas核心

14. Series和DataFrame
Series：一维带标签数组，pd.Series([1,2,3], index=[''a'',''b'',''c''])
DataFrame：二维表格，pd.DataFrame({''col1'': [1,2], ''col2'': [3,4]})

15. 数据选择与过滤
列选择：df[''col1'']、df[[''col1'', ''col2'']]
行选择：df.loc[''row1'']按标签、df.iloc[0]按位置
条件过滤：df[df[''col1''] > 10]、df[(df[''col1''] > 5) & (df[''col2''] < 20)]

16. 数据清洗常用操作
查看缺失值：df.isnull().sum()
删除缺失值：df.dropna()
填充缺失值：df.fillna(0)
删除重复：df.drop_duplicates()
数据类型转换：df[''col''].astype(''int'')

17. 分组与聚合
df.groupby(''category'')[''value''].mean()
df.groupby([''cat1'', ''cat2'']).agg({''col1'': ''sum'', ''col2'': ''mean''})
透视表：pd.pivot_table(df, values=''value'', index=''row'', columns=''col'', aggfunc=''mean'')

五、机器学习基础

18. 监督学习 vs 非监督学习
监督学习：有标签数据，算法包括线性回归、逻辑回归、决策树、SVM、随机森林
非监督学习：无标签数据，算法包括K-Means、PCA、聚类

19. 回归与分类
回归：预测连续值，算法包括线性回归、决策树回归
分类：预测离散类别，算法包括逻辑回归、KNN、SVM、随机森林

20. 模型评估指标
分类指标：
- 准确率 = (TP+TN)/(TP+TN+FP+FN)
- 精确率 = TP/(TP+FP)
- 召回率 = TP/(TP+FN)
- F1分数 = 2 * (精确率 * 召回率) / (精确率 + 召回率)
- AUC/ROC：模型分类能力
回归指标：
- MAE：平均绝对误差
- MSE：均方误差
- RMSE：均方根误差
- R²：决定系数

21. 过拟合与欠拟合
过拟合：训练集好，测试集差，解决方案包括增加数据、正则化、Dropout、早停、简化模型
欠拟合：训练集差，测试集差，解决方案包括增加特征、复杂模型、减少正则化

22. 正则化
L1正则化：权重绝对值之和，产生稀疏解，特征选择
L2正则化：权重平方和，防止权重过大，平滑

六、PyTorch核心

23. Tensor基础
import torch
x = torch.tensor([1, 2, 3])
x = torch.zeros(3, 4)
x = torch.randn(3, 4)  # 标准正态分布
x = torch.ones(3, 4)
设备迁移：device = torch.device(''cuda'' if torch.cuda.is_available() else ''cpu'')
x = x.to(device)

24. 自动求导
x = torch.tensor([2.0], requires_grad=True)
y = x ** 2 + 3 * x + 1
y.backward()
print(x.grad)  # 2*x + 3 = 7

25. 神经网络构建
import torch.nn as nn
class MyNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.fc1 = nn.Linear(784, 128)
        self.fc2 = nn.Linear(128, 10)
        self.relu = nn.ReLU()
    def forward(self, x):
        x = self.relu(self.fc1(x))
        x = self.fc2(x)
        return x

26. 训练流程
model = MyNet()
criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
for epoch in range(num_epochs):
    for batch in dataloader:
        x, y = batch
        optimizer.zero_grad()
        output = model(x)
        loss = criterion(output, y)
        loss.backward()
        optimizer.step()

七、Scikit-learn核心

27. 标准流程
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)
model = RandomForestClassifier()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
score = model.score(X_test, y_test)

28. 交叉验证
from sklearn.model_selection import cross_val_score
scores = cross_val_score(model, X, y, cv=5)
print(f"平均得分: {scores.mean():.4f}")

29. 网格搜索调参
from sklearn.model_selection import GridSearchCV
param_grid = {
    ''n_estimators'': [50, 100, 200],
    ''max_depth'': [None, 10, 20]
}
grid_search = GridSearchCV(RandomForestClassifier(), param_grid, cv=5)
grid_search.fit(X_train, y_train)
print(grid_search.best_params_)

八、常见面试题

30. Python中列表和元组的区别？
列表可变，元组不可变；列表用方括号，元组用圆括号；列表占用内存更大，元组更轻量。

31. 什么是装饰器？有什么作用？
装饰器是一种设计模式，可以在不修改原函数代码的情况下增加额外功能。常用于日志记录、性能测试、权限校验、缓存等。

32. NumPy数组和Python列表有什么区别？
NumPy数组元素类型相同，列表可以不同；NumPy支持向量化运算，速度更快；NumPy内存连续，占用更小；NumPy提供丰富的数学函数。

33. Pandas中DataFrame和Series的区别？
Series是一维带标签数组，DataFrame是二维表格结构；DataFrame由多个Series组成；Series相当于一行或一列。

34. 什么是过拟合？如何防止过拟合？
过拟合是模型在训练集上表现好但测试集上表现差的现象。防止方法：增加数据量、正则化、Dropout、早停、数据增强、简化模型。

35. 什么是梯度消失和梯度爆炸？如何解决？
梯度消失：深层网络反向传播时梯度趋近于0；梯度爆炸：梯度变得非常大。解决方法：BatchNorm、残差连接、梯度裁剪、使用ReLU激活函数、合理初始化权重。

36. 如何处理数据不平衡问题？
数据层面：过采样（SMOTE）、欠采样；算法层面：调整类别权重、使用Focal Loss；评估指标：使用AUC、F1分数代替准确率。

37. 如何评估分类模型的好坏？
准确率、精确率、召回率、F1分数、ROC曲线、AUC值、混淆矩阵。不同场景关注不同指标。

知识点汇总表

分类            核心知识点
Python基础      可变/不可变、深拷贝/浅拷贝、装饰器、生成器、上下文管理器
数据结构        列表、字典、集合、堆、队列复杂度
算法            排序、二分查找、动态规划
NumPy           数组创建、索引切片、广播、常用函数
Pandas          Series/DataFrame、数据选择、数据清洗、分组聚合
机器学习        监督/非监督、回归/分类、评估指标、过拟合、正则化
PyTorch         Tensor、自动求导、神经网络构建、训练流程
Scikit-learn    数据划分、标准化、交叉验证、网格搜索', '{"doc_id": "2039216636333993984", "chunk_index": 0, "collection_name": "python"}', '[0.04609957,0.011767012,-0.06314479,-0.029248048,0.0538474,-0.019563263,0.0027117394,0.013365001,0.07437914,-0.01075011,-0.0075541316,0.019660112,0.0449374,0.033896744,0.049005006,0.06469436,0.00852261,-0.016464133,0.015398807,-0.032153483,0.002396984,0.08561349,-0.006779349,-0.037383266,-0.053072616,0.043775223,-0.04668066,-0.0759287,0.042806745,-0.024115112,-0.026342612,0.030603917,-0.042419355,0.013074459,-0.040095005,0.01433348,0.0061498377,0.027117396,0.031572394,-0.007796251,0.031185005,-0.001828003,-0.0028327992,0.043775223,0.0058108703,-0.005617175,-0.013365001,0.006004566,-0.010362719,0.003728642,0.029635439,-0.009539512,-0.012396524,0.03990131,0.07360436,-0.013558698,-0.018788481,0.011621741,0.0044792127,-0.034865223,0.03718957,-0.022759242,0.03718957,-0.013752393,-0.0058108703,-0.00987848,0.01752946,-0.0022759242,0.001828003,-0.051523052,-0.0069246204,0.03893283,-0.0013256049,-0.015301959,0.016076742,-0.010507991,-0.020241199,0.019563263,0.048230223,-0.005447691,-0.007263588,0.03777066,-0.0063435333,-0.007602555,-0.047649138,-0.022275003,-0.022081308,-0.003510734,0.025761526,0.029248048,0.022662394,0.0224687,0.0024817258,0.034671526,0.006101414,0.014430328,0.0052297832,0.03796435,-0.0015979894,-0.0026512097,0.012493371,-0.015398807,0.058496095,0.039126527,0.012057556,-0.015398807,-0.0358337,0.02062859,0.003607582,0.010072175,0.0078930985,0.04435631,0.041063484,-0.016367285,-0.024986742,0.023049785,0.004067609,0.02421196,0.0061256257,-0.0086194575,-0.00123481,-0.00023606661,0.03893283,0.05462218,0.06314479,-0.023146633,-0.0097332075,-0.021693915,0.009442665,0.024793047,-0.03505892,0.01752946,-0.024793047,-0.050360877,-0.034671526,-0.002421196,-0.024502503,0.011428045,-0.08290175,-0.0061256257,0.020725438,-0.04609957,0.02285609,-0.011185925,0.015011415,-0.0007293853,-0.0044307886,0.021015981,0.014042936,0.006585653,-0.009297392,-0.03002283,0.026342612,0.015398807,-0.061982617,-0.013365001,-0.0022153943,-0.010314295,-0.008425762,-0.008716306,-0.0028570113,0.012590219,-0.0005387161,-0.03234718,0.043194138,0.004116033,0.015108263,-0.008910001,0.041063484,-0.013268154,-0.017238915,0.02198446,0.009442665,-0.019175872,0.0224687,0.03350935,0.023049785,-0.018304242,0.009587936,0.0024333019,-0.010846958,0.026342612,-0.040095005,0.049198702,-0.0057382346,-0.0069730445,0.02014435,-0.014817719,-0.0014587706,0.03680218,0.03505892,0.02150022,-0.017820003,-0.029441742,0.023534024,0.014914568,-0.008038371,-0.012880763,0.015301959,0.03002283,0.031959787,0.072054796,0.040869787,-0.039707612,-0.005471903,-0.036027398,-0.017432611,-0.02595522,-0.031572394,-0.041450877,0.03447783,0.020725438,0.018788481,0.0030628128,-0.0071183164,0.031572394,0.013752393,-0.019369569,-0.015398807,-0.015108263,-0.009975327,-0.038158048,-0.02237185,0.013268154,0.0022638182,0.026730003,-0.011379621,0.029248048,0.0061256257,-0.037576962,0.002336454,-0.01791685,-0.013655545,-0.0016343073,0.03544631,0.015495654,-0.02111283,-0.027698481,-0.027117396,0.011040654,-0.027698481,0.013074459,0.011331197,-0.03893283,0.029829135,0.009830056,-0.03273457,-0.02198446,0.09646045,-0.02866696,0.0269237,-0.015786197,-0.031185005,-0.020338045,-0.0033896745,0.03331566,-0.0074088597,0.0075541316,-0.0050118756,0.0015616714,-0.044162616,0.012590219,0.016076742,0.022565547,0.01210598,-0.013558698,-0.039320223,0.01888533,-0.016851524,-0.0062951096,-0.0052782074,-0.026148917,-0.026342612,0.010895382,-0.022565547,0.028279569,-0.013655545,-0.036608484,0.00088978955,-0.011621741,-0.022952938,0.007941523,-0.0056655984,0.011815436,0.028860657,-0.0021427583,0.011040654,0.04842392,-0.046874356,-0.028279569,0.02062859,0.003038601,-0.01704522,-0.003050707,0.021403372,0.0019248509,0.029248048,-0.031185005,0.02866696,0.026148917,-0.017238915,0.018691633,-0.0009745314,0.008038371,-0.012880763,-0.006101414,-0.010895382,-0.01840109,-0.042031962,-0.03680218,0.021790763,0.00593193,-0.023534024,-0.016367285,0.03893283,-0.010895382,0.0627574,0.04435631,-0.011621741,0.010604839,0.017335763,-0.016754676,-0.03041022,0.028085873,0.022178154,0.008474186,0.0003858781,0.0005023982,-0.010653262,0.0019127448,0.02198446,0.0008595246,-0.0069730445,0.012202828,-0.028085873,-0.015786197,0.027892178,-0.01975696,0.039320223,0.013171306,0.011040654,-0.04706805,0.01186386,0.015786197,-0.020725438,-0.027504787,-0.010604839,0.0004237093,-0.015301959,0.048230223,-0.02334033,0.018982176,-0.0025422557,-0.010169023,-0.016464133,-0.010217447,-0.028473265,0.023146633,-0.015786197,0.003607582,-0.008038371,-0.0058108703,-0.059270877,0.005617175,0.0075057074,0.0269237,-0.01888533,-0.02372772,-0.009587936,-0.03041022,-0.0011379621,0.05694653,-0.03447783,0.02595522,0.09336132,0.01297761,-0.002457514,0.010507991,0.011960709,0.04609957,0.017820003,-0.030797614,-0.0050845114,-0.0013619227,-0.0064403815,-0.011670165,-0.018497936,-0.045131095,0.0057140226,-0.0269237,-0.015883045,-0.010072175,0.025374133,-0.0065372293,-0.020241199,-0.0045760605,0.016754676,-0.011815436,0.022178154,0.0013195518,0.0039223377,-0.017723154,0.0022880302,-0.0016100954,-0.010798534,0.013655545,-0.041450877,-0.015398807,-0.0027601635,-0.08290175,0.036414787,0.007941523,-0.005375055,-0.029054351,-0.006779349,0.021403372,0.0008050477,-0.0023485601,-0.021209678,-0.043194138,-0.008474186,-0.0068277726,-0.009781632,0.015979894,-0.028473265,0.004358153,0.016464133,0.001156121,0.021693915,0.0090068495,-0.008135218,0.030991308,-0.023921417,0.039320223,0.004793968,-0.023824569,0.015979894,0.031572394,0.017335763,0.028473265,-0.0025301499,0.00963636,-0.0057140226,-0.047842834,-0.023049785,0.01297761,-0.0050845114,0.014042936,0.026730003,0.009684784,0.023534024,0.0066825007,-0.061982617,0.024115112,-0.0030749189,0.0034138863,0.011282774,0.00075359724,-0.010265871,-0.031185005,0.04300044,-0.055009574,-0.0034623102,0.0039465493,0.048036527,0.013946089,0.019369569,0.01520511,-0.034284133,-0.061595228,-0.028279569,-0.0050602998,-0.02334033,0.008232066,0.06779349,0.0024938318,-0.011912284,-0.013365001,0.01568935,-0.014430328,0.01297761,0.025761526,-0.027117396,-0.0313787,0.023243481,0.00013770552,0.024115112,-0.049005006,0.007021468,0.021403372,-0.03854544,-0.007989947,0.042031962,-0.0032928265,0.032540873,-0.046293266,0.00057200756,0.01346185,0.013849241,-0.01099223,-0.016754676,0.0037044298,-0.04164457,-0.015398807,-0.016367285,-0.02866696,0.04396892,-0.031572394,0.038739137,0.0016948372,0.02237185,-0.014042936,-0.017238915,0.022759242,-0.0019611688,0.0016948372,-0.049005006,0.013171306,0.010265871,0.03990131,0.018497936,-0.009248968,0.0010592733,0.020241199,-0.032928266,0.044162616,0.0068761967,0.03331566,0.046874356,0.011718589,0.027892178,-0.008910001,-0.0246962,-0.034284133,-0.011282774,-0.016367285,0.017626306,0.019079024,-0.016754676,0.0035591582,-0.0064403815,-0.0008534716,0.0027117394,-0.023921417,0.02111283,-0.008861577,-0.0045034247,0.038351744,-0.038158048,0.06314479,0.01520511,0.0024333019,0.03544631,-0.027117396,-0.005423479,0,-0.052297834,-0.03951392,0.01927272,0.0031233428,0.00358337,-0.0041402453,-0.030991308,-0.011621741,0.002324348,0.013171306,-0.016464133,-0.03273457,0.032540873,-0.010943806,-0.043194138,-0.0044550006,-0.02556783,-0.013849241,-0.039707612,0.014236633,-0.05733392,-0.027892178,0.040482398,-0.028473265,-0.01752946,-0.043775223,-0.03447783,-0.032153483,0.001815897,0.0031475548,-0.016464133,-0.0020580166,-0.0101205995,0.0056655984,0.0025543617,0.007747827,-0.0033412504,0.014527176,-0.023630872,-0.00052055717,0.008086795,-0.01186386,-0.00358337,0.0402887,0.0122996755,-0.03234718,-0.009539512,0.013946089,-0.03176609,-0.021693915,-0.030216526,0.0078930985,-0.027698481,-0.04706805,0.002941753,0.017626306,-0.024793047,0.013171306,0.0358337,-0.029248048,0.01975696,0.004382365,-0.028279569,-0.02150022,0.017142067,-0.017335763,-0.022662394,0.023243481,-0.002396984,-0.021015981,-0.003607582,-0.0019611688,0.012154404,-0.032928266,0.006634077,0.026730003,0.009297392,0.020338045,-0.007263588,0.0007081998,-0.00039344435,0.0028691173,0.014720871,0.018304242,-0.0050602998,0.008086795,0.026536308,0.022178154,0.011670165,0.007844675,0.024018263,0.008910001,-0.023049785,-0.003014389,0.002953859,0.011524892,0.048036527,0.0028933291,0.015979894,0.017142067,-0.00051147764,-0.0313787,-0.03273457,-0.01520511,0.0063435333,0.01568935,-0.00876473,0.005326631,0.00876473,-0.029248048,0.005205571,-0.025374133,-0.033121962,0.021306524,0.010314295,0.0358337,-0.016464133,0.002445408,0.014817719,0.01617359,0.020531742,0.014236633,0.04164457,-0.0043097287,-0.003014389,0.01075011,0.02062859,-0.03796435,-0.002396984,-0.037383266,0.024986742,0.029829135,0.0045034247,0.011621741,0.0020216987,-0.02198446,0.01433348,-0.045518484,-0.01617359,0.036027398,-0.0021185465,-0.038351744,0.0015071945,0.0010108494,-0.017432611,-0.005641387,-0.078640446,-0.0011076971,0.0058592944,0.0048666038,-0.015398807,-0.015011415,0.0037044298,-0.008038371,0.037383266,-0.0034380984,0.004793968,0.0045760605,-0.011476469,-0.01099223,0.13636176,0.027117396,-0.023243481,-0.011428045,0.027117396,0.02421196,-0.06779349,-0.00017704995,-0.007021468,-0.01346185,0.03350935,-0.007602555,0.021887612,0.056171745,-0.032540873,0.013849241,0.012396524,0.00020882815,0.016560981,0.0246962,-0.03350935,0.020434894,0.0269237,-0.023921417,0.006028778,-0.0016464132,-0.013558698,-0.0052539953,-0.01346185,0.011185925,0.058496095,0.005471903,-0.021403372,0.026730003,0.006488805,-0.007844675,-0.0028933291,0.0033412504,0.011670165,-0.032928266,0.013268154,-0.027698481,0.011379621,-0.025374133,0.011040654,-0.016076742,0.0026996336,0.006634077,-0.004237093,0.018982176,-0.0038012776,-0.039707612,0.016270436,0.018304242,0.028473265,0.0224687,0.014236633,0.008571033,0.014624024,0.01099223,0.023921417,0.007989947,0.023146633,0.022565547,0.024018263,0.004842392,-0.01099223,0.009248968,-0.011960709,-0.016948372,-0.030797614,0.09917219,-0.026730003,-0.0015979894,-4.0668525e-05,0.026536308,0.03680218,0.013365001,0.04435631,0.020047503,-0.026148917,-0.014527176,0.031185005,0.007457284,-0.025374133,-0.0039949734,-0.011040654,0.004890816,0.004116033,0.0029901771,0.017432611,-0.006634077,-0.03718957,-0.08910001,-0.042419355,-0.007312012,0.002445408,0.017335763,0.045905877,-0.0313787,0.0025180439,0.008571033,0.03505892,-0.034671526,0.0078930985,0.008716306,0.0104595665,-0.004890816,0.00096242543,-0.007312012,-0.03350935,0.038351744,0.029635439,-0.052297834,-0.008135218,-0.0269237,-0.015979894,0.0016343073,-0.0358337,-0.01433348,-0.007796251,0.009055273,-0.014527176,0.018497936,0.039320223,-0.001210598,0.03273457,0.011718589,0.026148917,0.016560981,-0.01975696,-0.0064403815,-0.02237185,0.027117396,-0.0011319091,-0.017820003,-0.016076742,-0.041450877,0.03041022,-0.013365001,0.010023751,-0.019079024,0.014430328,-0.004769756,-0.004769756,0.04300044,-0.0061498377,-0.030216526,-0.03409044,0.00987848,-0.02372772,0.04745544,-0.021306524,-0.033121962,0.02731109,-0.01075011,-0.008910001,0.005641387,-0.011912284,0.04609957,-0.065081745,-0.004793968,0.018304242,0.013849241,0.056559138,0.035252612,0.032153483,0.007215164,0.010169023,-0.001828003,0.049586095,-0.023824569,-0.0068761967,-0.026536308,0.016754676,-0.014430328,-0.00052055717,-0.009394241,0.0039223377,-0.027504787,0.03893283,0.015398807,-0.024986742,-0.037576962,0.009442665,-0.00092005444,-0.047842834,0.018594785,-0.022952938,-4.199262e-05,-0.0224687,-0.0024938318,0.038739137,0.015786197,0.019079024,-0.01123435,0.015108263,0.026730003,-0.0038981256,-0.03002283,-0.003087025,-0.022952938,0.055396963,0.01888533,-0.02421196,-0.0014587706,0.009248968,0.023146633,0.0269237,-0.029635439,0.008232066,-0.00493924,0.008667882,-0.027504787,-0.015883045,0.01791685,0.01123435,0.022759242,-0.0031475548,-0.01752946,-0.05733392,0.0040191854,0.0313787,0.010362719,-0.0035349461,-0.0538474,-0.015786197,-0.020338045,-0.06818088,-0.015979894,-0.018497936,0.020822285,-0.021790763,-0.033703048,-0.004842392,-0.016948372,-0.028860657,0.044162616,0.02062859,0.018497936,-0.027504787,0.021306524,-0.0071183164,-0.0032444026,-0.003728642,0.013655545,-0.008910001,-0.022759242,-0.030216526,0.010653262,0.026342612,0.031572394,-0.0538474,-0.009152121,-0.00067793485,-0.044162616,0.00012711278,-0.019369569,0.001198492,0.02198446,0.023243481,0.031959787,0.006730925,0.02285609,0.02062859,0.024986742,0.012009132,0.00852261,-0.011670165,0.03273457,-0.0066825007,-0.00876473,-0.028085873,0.15960523,0.006101414,0.004769756,0.016948372,-0.0046002725,0.05423479,-0.008571033,-0.01791685,-0.02556783,-0.012009132,0.035640005,-0.0037528537,0.034865223,-0.04300044,0.014624024,0.011718589,0.03447783,-0.015786197,0.015301959,0.0029175412,0.037383266,-0.01888533,-0.019853806,-0.015011415,0.0716674,-0.009442665,-0.0313787,-0.0040191854,0.0075057074,-0.029054351,-0.006198262,0.017238915,-0.02595522,-0.032540873,-0.0078930985,0.013655545,0.0020701226,0.027892178,-0.017723154,0.027504787,0.0019611688,0.021015981,0.034865223,-0.011282774,-0.014914568,0.010217447,-0.023437178,-0.0034623102,0.0044065765,0.013655545,-0.035640005,-0.0065372293,-0.0051813596,0.0017795791,0.017335763,0.026536308,-0.01665783,-0.006077202,0.018691633,-0.0051329355,-0.024115112,-0.022178154,0.008958425,-0.015883045,0.005907718,-0.0018522149,0.016464133,0.0051813596,0.031185005,-0.02285609,0.013946089,0.029635439,-0.01617359,0.0246962,0.013558698,0.0028570113,-0.02237185,-0.0037528537,0.002457514,-0.03234718,0.021693915,0.011912284,0.020047503,-0.03990131,-0.042419355,-0.006585653,0.0068277726,-0.026148917,-0.033703048,-0.023049785,-0.022565547,0.017432611,0.025180439,-0.0063435333,-0.007263588,0.022081308,0.02198446,0.013655545,0.0008232066,-0.0027601635,-0.014720871,0.018497936,-0.038739137,-0.016367285,0.01210598,-0.003607582,-0.01791685,0.08832523,0.007844675,0.030216526,0.024018263,-0.018691633,-0.0005568751,0.03041022,0.03777066,0.020338045,-0.065081745,-0.01520511,-0.018788481,0.012590219,-0.021790763,0.001791685,0.014720871,0.0026148916,0.012687067,0.006585653,-0.021306524,0.0071183164,0.030991308,0.03505892,0.0063435333,0.004116033,-0.02372772,-0.015979894,-0.034284133,-0.02062859,0.048230223,0.009491088,0.011621741,-0.034865223,-0.049005006,0.0021790764,0.013752393,0.024405656,0.0073604356,-0.0044792127,-0.00605299,-0.009684784,-0.02595522,0.02421196,0.00092005444,-0.0090068495,0.043194138,0.031959787,0.0003631794,-0.032928266,0.011621741,-0.01752946,-0.009297392,-0.00040857683,0.0024938318,-0.02150022,-0.018304242,0.03331566,-0.034284133,0.019563263,0.01568935,0.010411142,-0.02062859,-0.016367285,-0.05191044,0.040095005,-0.0036802178,-0.0021306525,-0.03622109,0.0009684784,0.017820003,0.0065372293,-0.04435631,0.026342612,0.026148917,0.026342612,-0.008716306,-0.0045034247,-0.009103697,-0.0033896745,0.016270436,0.0123481,0.01433348,0.030603917,-0.050748266,0.02111283,-0.0141397845,-0.024018263,0.05113566,0.013365001,-0.021693915,-0.05113566,0.01975696,-0.0082804905,0.012057556,-0.003099131,-0.0063919574,-0.01975696,0.0010834852,0.013752393,-0.02062859,0.021790763,-0.02556783,0.01927272,-0.003002283,0.030991308,0.049973484,0.018982176,0.0039465493,0.00987848,0.0313787,0.039320223,-0.047842834,0.028473265,0.016560981,0.0031233428,0.0017432611,-0.016560981,-0.0051813596,-0.04222566,-0.03777066,0.010314295,0.022759242,-0.016464133,0.020531742,0.00876473,0.02237185,0.027504787,0.010072175,0.0062466855,2.9130015e-05,-0.006004566,0.048230223,-0.01520511,-0.015398807,0.0064403815,0.03041022,0.035252612,0.0027722693,-0.01617359,-0.0026875276,-0.015979894,-0.021403372,0.003038601,-0.005350843,-0.018110545,-0.00020882815,-0.014236633,-0.00049634516,-0.0627574,-0.0061256257,-0.0008050477,-0.0022153943,0.058883484,-0.02866696,-0.005423479,0.0123481,0.010362719,-0.004212881,0.015495654,0.016948372,-0.0027964814,0.018013699,-0.028085873,-0.008958425,0.031959787,-0.03951392,-0.01346185,0.0028570113,0.01975696,0.03893283,-0.017820003,-0.020919133,0.01927272,-0.025761526,0.0034865222,-0.022081308,0.0012529689,0.042613048,0.0012590219,0.027117396,0.003510734,-0.00963636,-0.02372772,-0.004672908,0.04067609,-0.00044186827,-0.040095005,0.003002283,0.008861577,-0.0015435125,0.043194138,0.03409044,0.008813153,-0.029248048,0.025374133,-0.002336454,0.010217447,0.009539512,0.03409044,0.012783915,0.00593193,0.032153483,-0.013171306,0.014720871,0.034284133,-0.02334033,-0.03331566,-0.005907718,-0.015979894,0.01791685,0.012687067,0.018110545,-0.018691633,-0.012687067,0.012880763,0.017238915,0.011524892,0.01975696,0.011185925,0.011040654,0.022178154,0.0064403815,0.024502503,-0.018788481,0.008861577,-0.0061498377,0.012783915,-0.019950654,-0.024986742,0.008425762,-0.01752946,0.0057140226,-0.005471903,-0.0016585193,0.0042855167,0.05733392,0.002396984,0.027117396,-0.048811313,0.033703048,0.006488805,0.03854544,-0.004091821,0.002396984,-0.029635439,0.0014950886,-0.010895382,0.0224687,-0.052297834,-0.0013256049,-0.040482398,-0.03409044,-0.024793047,-0.06469436,-0.035252612,0.010846958,-0.024986742,0.025180439,0.009975327,0.053460006,-0.02014435,0.008474186,0.017432611,0.028279569,0.0097332075,-0.046486963,-0.0059803543,0.008716306,0.0028933291,-0.00013543565,0.0012166509,0.026730003,0.0020822287,0.034671526,0.02111283,0.0076509793,-0.010604839,-0.01975696,0.0078930985,-0.0086194575,-0.00963636,0.03002283,0.022662394,0.0040191854,-0.027117396,-0.003631794,0.01099223,-0.025180439,0.011428045,0.013849241,-0.026148917,-0.031959787,-0.026536308,0.035252612,-0.009781632,-0.009345816,-0.0052297832,0.04396892,-0.0069730445,-0.0055445386,0.03777066,-0.009345816,0.0014527176,-0.020047503,0.0034138863,-0.0045034247,0.01791685,-0.011379621,0.010169023,0.0041402453,0.027698481,0.048230223,-0.00987848,0.00040555032,0.020919133,0.010895382,0.04164457,0.030797614,0.007312012,-0.00123481,-0.017723154,0.034671526,-0.024986742,-0.011282774,0.015495654,-0.061207835,0.020822285,0.02556783,0.019853806,-0.013558698,0.028473265,-0.0032686146,0.009055273,-0.023921417,0.019079024,0.06546914,0.019563263,0.00031475548,-0.04125718,-0.022081308,-0.030216526,0.017432611,0.034671526,-0.05191044,0.055009574,-0.013365001,-0.008135218,-0.016464133,0.026342612,-0.045905877,-0.004333941,0.011428045,0.023049785,-0.027117396,-0.027117396,-0.0062951096,-0.004769756,0.00037074563,-0.0053024194,0.019950654,-0.012590219,-0.029248048,-0.043775223,0.029635439,-0.056559138,-0.03331566,-0.0013316578,-0.032153483,0.03680218,-0.037576962,-0.004842392,-0.00963636,-0.0035349461,0.0041644573,-0.0018885329,-0.0025664677,-0.0141397845,0.010169023,0.017142067,0.042613048,-0.0056898105,0.011137501,-0.017335763,0.025374133,-0.0074088597,0.024502503,0.034671526,-0.023146633,-0.001803791,0.02198446,0.0033412504,0.0538474,-0.014720871,0.0010774322,0.0009926903,0.011428045,0.014527176,0.018207394,0.044162616,-0.03176609,0.013365001,-0.002372772,-0.0035591582,0.007021468,-0.03777066,-0.019079024,-0.010362719,0.031959787,-0.0028570113,0.023534024,-0.012251251,-0.02062859,-0.006101414,-0.023921417,-0.036995873,0.018110545,0.03893283,-0.0021790764,-0.03622109,0.030216526,0.007747827,-0.029829135,-0.036608484,-0.017432611,0.039320223,-0.043775223,-0.020919133,0.012396524,0.03854544,-0.033703048,-0.0012590219,-0.0016222013,0.019079024,-0.010217447,-0.04668066,0.010653262,-0.016948372,0.0068277726,0.0068277726,-0.021209678]'),
('2039216777090641921', 'Python算法开发进阶知识点

一、算法复杂度进阶

1. 时间复杂度分析技巧
O(1)：常数时间，如数组索引、哈希表查找
O(log n)：分治，如二分查找、平衡树操作
O(n)：线性扫描，如遍历数组、链表
O(n log n)：分治排序，如快速排序、归并排序
O(n²)：双层循环，如冒泡排序、简单动态规划
O(2ⁿ)：指数级，如递归穷举、子集问题
O(n!)：阶乘，如全排列问题

2. 空间复杂度分析
O(1)：原地操作，如冒泡排序、双指针
O(n)：额外数组，如归并排序、哈希表缓存
O(n²)：二维矩阵，如动态规划表格

二、递归与分治

3. 递归三要素
- 终止条件：什么时候停止递归
- 递推公式：问题如何分解
- 返回值：每层递归返回什么

示例 - 斐波那契数列：
def fib(n):
    if n <= 1:
        return n
    return fib(n-1) + fib(n-2)

4. 分治算法框架
def divide_conquer(problem):
    if problem is trivial:
        return solve(problem)
    sub_problems = split(problem)
    sub_results = [divide_conquer(p) for p in sub_problems]
    return merge(sub_results)

三、动态规划进阶

5. 动态规划解题模板
def dp_solution(nums):
    n = len(nums)
    dp = [0] * n
    dp[0] = nums[0]
    for i in range(1, n):
        dp[i] = max(dp[i-1] + nums[i], nums[i])
    return max(dp)

6. 常见动态规划类型
线性DP：一维状态，如最长递增子序列、最大子数组和
区间DP：二维区间状态，如矩阵链乘、回文子串
背包DP：容量限制，如0-1背包、完全背包
状态压缩DP：位运算优化，如旅行商问题、集合覆盖
树形DP：树结构，如树的最大独立集、树的直径

7. 背包问题详解
0-1背包：dp[i][w] = max(dp[i-1][w], dp[i-1][w-wt[i]] + val[i])
完全背包：dp[w] = max(dp[w], dp[w-wt[i]] + val[i])
多重背包：二进制拆分优化

四、图论算法

8. 图的表示方式
邻接矩阵：稠密图，空间O(V²)
邻接表：稀疏图，空间O(V+E)
graph = {0: [1, 2], 1: [0, 3], 2: [0, 3], 3: [1, 2]}

9. 深度优先搜索（DFS）
def dfs(graph, start, visited=None):
    if visited is None:
        visited = set()
    visited.add(start)
    for neighbor in graph[start]:
        if neighbor not in visited:
            dfs(graph, neighbor, visited)
    return visited

应用：拓扑排序、连通分量、图的遍历

10. 广度优先搜索（BFS）
from collections import deque
def bfs(graph, start):
    visited = set([start])
    queue = deque([start])
    while queue:
        node = queue.popleft()
        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    return visited

应用：最短路径、层级遍历、拓扑排序

11. 最短路径算法
Dijkstra：非负权图，复杂度O((V+E) log V)
Bellman-Ford：负权图，复杂度O(VE)
Floyd-Warshall：全源最短，复杂度O(V³)

Dijkstra算法实现：
import heapq
def dijkstra(graph, start):
    distances = {node: float(''inf'') for node in graph}
    distances[start] = 0
    pq = [(0, start)]
    while pq:
        dist, node = heapq.heappop(pq)
        if dist > distances[node]:
            continue
        for neighbor, weight in graph[node]:
            new_dist = dist + weight
            if new_dist < distances[neighbor]:
                distances[neighbor] = new_dist
                heapq.heappush(pq, (new_dist, neighbor))
    return distances

五、字符串算法

12. KMP字符串匹配
核心：利用部分匹配表，避免重复比较
def kmp(text, pattern):
    lps = [0] * len(pattern)
    for i in range(1, len(pattern)):
        j = lps[i-1]
        while j > 0 and pattern[i] != pattern[j]:
            j = lps[j-1]
        if pattern[i] == pattern[j]:
            j += 1
        lps[i] = j
    j = 0
    for i, ch in enumerate(text):
        while j > 0 and ch != pattern[j]:
            j = lps[j-1]
        if ch == pattern[j]:
            j += 1
        if j == len(pattern):
            return i - j + 1
    return -1

13. 常见字符串算法
KMP：字符串匹配，复杂度O(m+n)
Manacher：最长回文子串，复杂度O(n)
Trie树：前缀匹配，复杂度O(L)
AC自动机：多模式匹配，复杂度O(n)

六、树结构算法

14. 二叉树的遍历
前序遍历（根左右）：
def preorder(root):
    if not root: return
    print(root.val)
    preorder(root.left)
    preorder(root.right)

中序遍历（左根右）：
def inorder(root):
    if not root: return
    inorder(root.left)
    print(root.val)
    inorder(root.right)

后序遍历（左右根）：
def postorder(root):
    if not root: return
    postorder(root.left)
    postorder(root.right)
    print(root.val)

层序遍历（BFS）：
from collections import deque
def levelorder(root):
    if not root: return
    queue = deque([root])
    while queue:
        node = queue.popleft()
        print(node.val)
        if node.left: queue.append(node.left)
        if node.right: queue.append(node.right)

15. 二叉搜索树（BST）
操作：查找O(log n)、插入O(log n)、删除O(log n)
特点：左子树小于根，右子树大于根

16. 平衡二叉树
AVL树：严格平衡，高度差≤1，适用于查询频繁
红黑树：近似平衡，适用于插入删除频繁
B树：多路搜索树，适用于数据库索引

七、贪心算法

17. 贪心算法框架
def greedy(problems):
    problems.sort(key=lambda x: x.rule)
    result = []
    for p in problems:
        if can_choose(p):
            result.append(p)
            update_state(p)
    return result

经典问题：活动选择、区间调度、哈夫曼编码、最小生成树

八、位运算技巧

18. 常用位运算
判断奇偶：n & 1
乘除2：n << 1，n >> 1
交换两数：a ^= b; b ^= a; a ^= b
求绝对值：(n ^ (n >> 31)) - (n >> 31)
最低位1：n & -n

19. 状态压缩
枚举子集：
for mask in range(1 << n):
    for i in range(n):
        if mask >> i & 1:
            pass

子集枚举：
sub = mask
while sub:
    sub = (sub - 1) & mask

九、数学算法

20. 数论基础
最大公约数：
def gcd(a, b):
    return a if b == 0 else gcd(b, a % b)

最小公倍数：
def lcm(a, b):
    return a * b // gcd(a, b)

快速幂：
def fast_pow(a, n, mod):
    res = 1
    while n:
        if n & 1:
            res = res * a % mod
        a = a * a % mod
        n >>= 1
    return res

21. 素数判断
def is_prime(n):
    if n < 2: return False
    if n == 2: return True
    if n % 2 == 0: return False
    i = 3
    while i * i <= n:
        if n % i == 0:
            return False
        i += 2
    return True

十、高级数据结构

22. 并查集
class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]
    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return
        if self.rank[rx] < self.rank[ry]:
            self.parent[rx] = ry
        elif self.rank[rx] > self.rank[ry]:
            self.parent[ry] = rx
        else:
            self.parent[ry] = rx
            self.rank[rx] += 1

23. 线段树
应用：区间查询、区间更新
class SegmentTree:
    def __init__(self, data):
        self.n = len(data)
        self.tree = [0] * (4 * self.n)
        self.build(data, 1, 0, self.n - 1)
    def build(self, data, node, left, right):
        if left == right:
            self.tree[node] = data[left]
            return
        mid = (left + right) // 2
        self.build(data, node*2, left, mid)
        self.build(data, node*2+1, mid+1, right)
        self.tree[node] = self.tree[node*2] + self.tree[node*2+1]
    def query(self, node, left, right, ql, qr):
        if ql > right or qr < left:
            return 0
        if ql <= left and right <= qr:
            return self.tree[node]
        mid = (left + right) // 2
        return self.query(node*2, left, mid, ql, qr) + \
               self.query(node*2+1, mid+1, right, ql, qr)

24. 树状数组（Fenwick Tree）
class FenwickTree:
    def __init__(self, n):
        self.n = n
        self.bit = [0] * (n + 1)
    def update(self, idx, delta):
        while idx <= self.n:
            self.bit[idx] += delta
            idx += idx & -idx
    def query(self, idx):
        res = 0
        while idx > 0:
            res += self.bit[idx]
            idx -= idx & -idx
        return res
    def range_query(self, left, right):
        return self.query(right) - self.query(left - 1)

十一、LeetCode经典题型

25. 题型分类
数组：两数之和、最大子序和，解题思路：双指针、前缀和
链表：反转链表、环形链表，解题思路：双指针、递归
二叉树：二叉树遍历、最近公共祖先，解题思路：DFS、BFS
动态规划：爬楼梯、打家劫舍，解题思路：状态定义、转移方程
回溯：全排列、子集，解题思路：递归、剪枝
贪心：跳跃游戏、分发饼干，解题思路：局部最优
滑动窗口：无重复字符的最长子串，解题思路：双指针、哈希表
二分查找：搜索旋转排序数组，解题思路：边界条件

十二、代码优化技巧

26. 常见优化方法
缓存结果：避免重复计算，如动态规划、记忆化搜索
剪枝：提前终止无效搜索，如回溯算法
双指针：减少循环嵌套，如两数之和、接雨水
预处理：提前计算，如前缀和、差分数组
位运算：加速计算，如状态压缩
空间换时间：用哈希表加速查找，如两数之和

27. Python性能优化
使用局部变量：减少全局变量查找
列表推导式：比循环快
使用集合：快速去重和查找
使用内置函数：map、filter、sum等
避免递归：递归有栈溢出风险
使用缓存装饰器：@lru_cache

知识点汇总表

分类                核心知识点
复杂度分析          时间/空间复杂度、分析技巧
递归与分治          递归三要素、分治框架
动态规划            解题模板、背包问题、常见类型
图论                DFS/BFS、最短路径、拓扑排序
字符串              KMP、Manacher、Trie树
树结构              二叉树遍历、BST、平衡树
贪心算法            算法框架、经典问题
位运算              常用技巧、状态压缩
数学算法            数论、快速幂、素数判断
高级数据结构        并查集、线段树、树状数组
题型分类            LeetCode经典题型
优化技巧            缓存、剪枝、双指针', '{"doc_id": "2039216759277432832", "chunk_index": 0, "collection_name": "python"}', '[0.031957746,-0.0093452195,-0.033894576,-0.022854628,0.05926709,-0.022079896,-0.004575768,0.011039948,0.03234511,-0.00411577,-0.016947288,0.022176737,-0.015978873,0.034281943,0.043191373,0.07902279,-0.004938924,-0.019755697,0.004648399,-0.045709256,0.023919888,0.066239685,-0.00036618247,-0.051519755,-0.038349293,-0.0062462864,-0.053843956,-0.06236602,0.05926709,0.019562013,-0.0013134149,0.00997469,-0.042029276,0.023823045,-0.025566194,0.040286124,-0.016172554,0.028471444,0.041060857,-0.006076813,0.058492355,0.012589415,-0.0007565754,-0.008037857,-0.008957853,-0.007698911,0.0063431277,0.016656764,-0.02885881,-0.009732585,0.025953561,-0.023726204,-0.0024936725,0.07321229,0.082121715,-0.01588203,-0.03525036,0.00085341703,-0.002820513,-0.04997029,0.0054231323,0.017528338,0.040867176,-0.016366238,-0.009732585,-0.02537251,-0.010023111,-0.016172554,-0.0058589196,-0.001646308,-0.014526247,0.045321893,-0.00018460439,-0.015300981,-0.01234731,-0.02537251,-0.007698911,-0.06352812,0.012202048,0.016366238,0.026921978,-0.0043094535,0.025953561,-0.00823154,-0.018593596,-0.0011076264,-0.037380878,-0.0038252452,0.015010456,0.030214595,0.01588203,0.025759878,0.007117861,0.03989876,-0.018496756,0.032151427,-0.0004176296,0.023823045,0.012879939,0.027503029,0.029827228,0.009926269,0.049582925,0.060816556,0.013170464,0.021305162,0.008618907,-0.003462089,-0.01578519,-0.0042610327,-0.0029173547,0.007941015,0.0028689338,-0.005931551,-0.066239685,0.011814681,-0.0033652473,0.04997029,0.01888412,-0.0019731487,-0.019852538,-0.008618907,0.030989327,0.02827776,0.03466931,-0.0048905034,-0.0050841863,0.017915705,-0.016366238,0.040286124,-0.03583141,-0.008376802,-0.06391549,-0.07166282,-0.005181028,0.008667327,-0.04183559,0.030989327,-0.022854628,-0.007892595,0.0059073404,-0.054231323,0.00706944,-0.009587323,0.011378894,0.00023756467,-0.0027478817,-0.008764169,0.0073115444,0.0040431386,-0.048420824,0.020143062,0.0008897326,0.0049631344,-0.0048662927,-0.021111479,-0.010701002,0.0105557395,0.029827228,0.007941015,-0.03486299,-0.061203923,0.005979972,-0.049582925,0.031376693,0.024500936,-0.018399913,-0.0038010348,0.022757787,0.005059976,0.0076020695,0.014332564,0.026147244,-0.012589415,-0.015300981,0.011427314,0.020433588,-0.007408386,0.030795643,-0.017528338,-0.010168373,0.012783097,-0.0055441842,0.016559921,-0.0076020695,0.0016342028,-0.021402003,-0.02517883,-0.011814681,0.012395731,-0.030601962,0.020627271,-0.020530429,-0.01646308,0.009103115,-0.01704413,0.0001687163,0.0067304946,0.00944206,0.036606144,0.027309345,0.08095962,0.05578079,0.0063915486,-0.0036557722,0.027696712,0.022176737,-0.011717839,-0.014526247,-0.04047981,0.016075714,0.029827228,0.004236822,-0.0040673492,-0.018109389,0.030020911,0.029633544,-0.036606144,0.013364147,0.009296798,0.03447563,-0.05810499,-0.0036315618,-0.00944206,-0.0052052387,-0.024985146,-0.0062947073,-0.013751514,0.014623089,-0.03118301,0.0105557395,0.0054473425,-0.00096841645,-0.00019973589,-0.0077473316,-0.0048662927,-0.0062947073,-0.04047981,0.0026631453,-0.0064399694,-0.03157038,-0.03583141,0.00046302413,-0.05113239,-0.009296798,-0.021402003,-0.023145154,0.03157038,0.07863542,0.0026147244,0.027503029,-0.02469462,-0.029052494,-0.024985146,-0.0018884122,0.04164191,-0.010023111,0.024307253,-0.045709256,-0.021595687,-0.014429405,-0.030214595,0.0031231432,-0.01413888,-0.015688347,0.021402003,-0.011330473,-0.012879939,-0.013557831,0.007505228,-0.0046726097,-0.031376693,-0.01888412,0.00706944,-0.022176737,-0.00469682,-0.032732476,-0.00092604826,0.00075052277,-0.0140420385,0.0035589305,0.03989876,-0.002989986,-0.01413888,0.0053989217,-0.009635744,0.007408386,0.02469462,-0.037380878,-0.03641246,-0.015494663,0.004188401,-0.016559921,0.010458898,0.0017915705,-0.028084077,0.015010456,-0.017915705,0.00469682,-0.00026328824,0.031957746,0.0063915486,0.025953561,0.026147244,-0.01588203,-0.0044305054,-0.022564104,-0.020143062,-0.017237814,-0.012250468,0.027890395,0.018109389,0.007989436,-0.0026873557,0.03176406,-0.01704413,0.03931771,0.08986905,-0.0008292066,0.0010107846,0.00091394305,0.009926269,-0.014332564,0.021983054,0.022660946,0.0009986795,-0.0048420825,0.0021305163,-0.008522065,-0.03157038,0.014526247,-0.027696712,0.01936833,0.010846265,-0.020724112,-0.040092442,0.04454716,-0.042804006,0.05771762,0.0147199305,-0.0019005174,-0.025953561,-0.0043336637,0.012492573,0.016172554,-0.020239905,-0.00017855178,-0.026534611,-0.01646308,0.016656764,0.027890395,0.010652581,0.013557831,-0.013654673,-0.013654673,-0.027503029,-0.018399913,0.021014638,0.018012546,-0.0053747115,-0.012686255,-0.001143942,-0.03486299,0.0038978762,0.045515575,0.00881259,-0.03234511,0.005762078,-0.008861011,-0.029246178,0.01762518,0.033894576,0.015494663,0.014816772,0.123957306,-0.017237814,-0.0140420385,-0.0064883903,0.00411577,0.025566194,0.003002091,-0.024404095,-0.0058104987,0.02237042,-0.011717839,-0.030408278,-0.018012546,-0.02537251,-0.049001873,-0.017722022,-0.0052052387,0.010023111,0.025566194,-0.00025874877,-0.0023241995,0.01946517,0.037961926,0.012250468,-9.154562e-05,0.015397822,-0.015300981,0.021111479,0.0077957525,-0.02537251,0.00052355014,0.013073622,-0.048420824,-0.029633544,-0.007408386,-0.08560801,0.019174647,0.0015978871,0.0054473425,-0.020724112,-0.013073622,0.019852538,0.009248378,0.0010107846,0.0067304946,-0.047258724,0.010119952,0.05345659,0.0033410368,-0.013557831,-0.03873666,0.010604161,-0.0010047321,0.013364147,0.028084077,0.0057862885,-0.026921978,-0.01946517,-0.039511394,0.009199956,0.0029778806,-0.047065042,0.026534611,0.03757456,-0.0013376252,0.0020336746,0.00469682,0.0052052387,0.02537251,-0.046096623,-0.016269397,0.00472103,-0.014235722,0.012589415,0.012783097,0.0023726204,0.023629362,0.004357874,-0.061591286,-0.00234841,-0.0045515574,0.005059976,0.02295147,0.0017310445,0.015688347,-0.036799826,0.038349293,-0.03583141,0.0052052387,-0.025566194,0.01946517,-0.0058104987,-0.018690439,0.007117861,-0.05113239,-0.039705075,-0.0048420825,-0.04629031,-0.031376693,0.016753605,0.05461869,0.016947288,-0.01413888,0.001204468,-0.021305162,-0.037187193,-0.017915705,0.021305162,0.0020457797,-0.04648399,0.013557831,0.05074502,0.030795643,-0.033313528,0.02295147,0.0003540773,-0.0013376252,0.022176737,0.030408278,-0.03118301,0.009877848,-0.008279961,-0.0015494664,0.012395731,-0.025953561,0.019562013,-0.00085946964,-0.0049147136,-0.00997469,-0.03118301,0.012153626,-0.052681856,0.013654673,0.008037857,0.025759878,-0.011572577,0.0117662605,-0.015978873,-0.016947288,0.023532521,-0.004188401,0.006076813,-0.008279961,0.014235722,0.01413888,0.012589415,0.033313528,0.021595687,-0.028665127,0.0036557722,-0.03157038,0.044159792,-0.005519974,0.028084077,0.056942888,0.03292616,0.006536811,0.03989876,0.0031231432,-0.026534611,-0.031376693,-0.023823045,0.00026934085,0.01888412,-0.025759878,-0.0076504904,-0.011282052,0.0067304946,-0.0112336315,0.006875757,0.00411577,-0.017237814,0.0013557831,0.03408826,-0.022564104,0.02827776,0.004938924,-0.009635744,0.018012546,-0.053069223,0.04764609,0.017528338,-0.020336745,0.00048723453,0.028665127,0.0020942006,0.0014707826,0.0067304946,-0.024210412,-0.022564104,0.00939364,0.007941015,-0.041448224,-0.029439861,0.042804006,0.0025541985,-0.05578079,0.0077957525,-0.05771762,-0.0063915486,0.0062462864,-0.014816772,-0.016947288,-0.0018642017,-0.009926269,0.0112336315,-0.016656764,-0.03893034,-0.034281943,0.0037768243,0.02227358,-0.024985146,-0.04629031,0.007117861,0.010701002,-0.023048311,0.0011499946,0.0068273363,0.015688347,-0.03234511,-0.029827228,0.036799826,-0.0019368329,-0.007117861,0.0028447234,0.025953561,-0.011427314,-0.011475735,-0.012298889,0.02517883,-0.02517883,0.016075714,-0.0037768243,0.010362056,-0.036799826,-0.0008049962,0.03234511,-0.0015615716,-0.02885881,0.009054694,0.0129767805,-0.02227358,0.012492573,-0.014913614,-0.036606144,-0.00939364,0.011620997,-0.023048311,-0.026728295,-0.03447563,-0.0017189393,-0.0062462864,0.0009381535,0.016172554,0.022757787,-0.0022152527,0.0050841863,0.01946517,-0.034281943,0.018690439,-0.008473644,-0.013945198,-0.035637725,0.031957746,0.014526247,0.026921978,0.030795643,0.0034136681,0.024985146,0.007456807,0.020917796,0.029052494,0.0019126226,-0.01762518,0.011959944,-0.028665127,-0.0039705075,0.04590294,0.045128208,-0.0105557395,0.018496756,0.03757456,-0.0013376252,0.019562013,-0.01646308,-0.03583141,-0.0043820846,0.018109389,-0.014429405,0.001997359,0.008957853,0.010797843,-0.0014768351,-0.00065670745,0.0015615716,-0.020917796,-0.010749423,0.042416643,-0.045321893,-0.017915705,-0.020724112,0.008715748,0.02885881,0.035637725,0.04454716,-0.02537251,-0.011427314,-0.0036073513,-0.0038736658,-0.030020911,-0.0117662605,-0.06042919,-0.004357874,0.014429405,-0.0026147244,0.03176406,-0.0044789263,-0.02295147,-0.0035105096,-0.061978653,0.002820513,0.05810499,0.018690439,-0.024210412,0.015494663,-0.032732476,0.008618907,-0.023145154,-0.07050072,-0.045709256,-0.018399913,-0.020336745,-0.0030384066,-0.010410477,-0.014623089,-0.020143062,-0.010749423,0.012056785,0.021595687,0.016075714,0.007941015,0.020046221,0.117759444,0.03118301,-0.0014526247,-0.022079896,-0.0040673492,0.068563886,-0.05461869,-0.0058589196,0.023241995,-0.036025092,-0.0023847255,-0.01704413,0.002057885,0.06352812,-0.009684165,0.013460989,0.01578519,-0.004236822,0.023048311,0.012056785,-0.061203923,0.004987345,0.012395731,-0.024500936,-0.0054231323,0.0008776274,-0.016753605,0.046096623,-0.011427314,0.045709256,0.042029276,0.04764609,-0.0028326183,0.045321893,0.005132607,-0.017915705,-0.01820623,0.0059557613,-0.018303072,0.005931551,0.004406295,-0.0015736768,0.027503029,-0.019852538,0.03893034,-0.0020820955,-0.022757787,0.0110883685,-0.022079896,0.006633653,-0.016753605,-0.022176737,0.03931771,0.0038494554,-0.006004182,0.008473644,0.011524156,0.0076504904,0.00024513042,0.03157038,0.06391549,0.008183119,0.023241995,0.023919888,0.03641246,-0.030989327,-0.00023907782,-0.015300981,-0.024307253,0.035444044,-0.03447563,0.12085838,-0.006924178,-0.00176736,0.0010168373,0.013170464,0.037380878,-0.010458898,0.05113239,-0.0076020695,-0.0053989217,-0.0025663036,0.004575768,-0.026340928,-0.04590294,0.042416643,0.0027357766,0.042416643,0.011282052,-0.021402003,-0.0073599652,-0.0043336637,0.0048420825,-0.06314076,-0.011959944,0.005979972,-0.021498846,0.013364147,0.03699351,-0.019174647,-0.0058831302,-0.012686255,0.045709256,-0.008667327,0.010507319,0.011039948,0.0018520965,-0.0050115553,0.016656764,-0.004212612,-0.021014638,0.01946517,0.023435678,-0.03931771,0.013945198,0.0013436779,-0.045321893,-0.009248378,-0.039511394,-0.029439861,0.028084077,-0.018496756,-0.028471444,-0.024500936,0.016269397,-0.00037980083,0.04164191,0.004769451,0.014526247,0.0066820737,0.0073115444,-0.027696712,-0.03466931,0.006585232,-0.012395731,-0.0013255201,-0.010313636,-0.060816556,0.023726204,-0.029052494,-0.009296798,-0.018980963,0.01578519,0.016850447,-0.020724112,0.04357874,0.0072631235,-0.012105206,0.011814681,0.019174647,-0.013460989,0.018980963,0.0073599652,-0.015978873,-0.00085341703,-0.03466931,-0.02537251,-0.011572577,0.0019126226,0.007456807,-0.0053020804,-0.015300981,0.0068273363,5.258199e-05,0.012492573,0.029439861,0.016947288,0.00025118302,-0.026921978,0.030020911,0.007456807,-0.037187193,-0.005592605,-0.007166282,-0.0038010348,-0.018012546,0.0054957634,0.001646308,-0.0020820955,-0.0059073404,0.08870695,0.02885881,-0.03641246,-0.018303072,-0.009587323,0.0022394632,-0.02169253,0.004212612,-0.026728295,-0.002178937,-0.0037284035,0.0062947073,0.027309345,0.016075714,0.0140420385,0.010071531,0.012686255,0.016656764,-0.02178937,-0.03583141,-0.018690439,-0.019755697,0.03873666,-0.029439861,-0.00881259,-0.012879939,0.005979972,0.021498846,0.01994938,-0.009006273,-0.027309345,0.0020094642,0.006972599,-0.018496756,-0.036218777,0.033700895,-0.022757787,0.015107297,-0.031376693,-0.041254543,-0.04299769,0.00025572247,0.008328382,0.0039462973,0.01588203,-0.026147244,-0.004938924,0.01113679,-0.037380878,-0.035056677,-0.022854628,0.029052494,0.005181028,-0.01118521,0.032538794,-0.005519974,-0.008957853,0.04474084,-0.00019141356,0.009538902,-0.025566194,0.016753605,-0.015107297,-0.005519974,0.011572577,0.012250468,0.024016729,0.0026994608,-0.023435678,-0.005641026,0.055393424,0.022176737,-0.004648399,0.0070210192,-0.0053747115,-0.016269397,0.020143062,0.007698911,-0.007117861,0.023048311,0.030795643,-0.0015131508,0.010458898,-0.013170464,0.016269397,-0.0005326291,0.0023968308,0.014332564,-0.004212612,0.054231323,0.024500936,-0.022079896,-0.03699351,0.14487511,-0.015397822,0.00012483494,-0.021208322,-0.009296798,0.033119842,-0.01234731,-0.008279961,-0.030020911,-0.0063915486,0.016947288,0.028084077,0.055006057,-0.040092442,0.013848356,-0.008570486,0.020917796,-0.0030384066,-0.0030747224,0.018690439,0.04357874,0.0043094535,-0.005181028,0.00090789044,0.030795643,0.0044305054,0.015300981,0.0035105096,-0.0077473316,-0.0067304946,-0.033119842,-0.010023111,-0.020239905,0.020917796,0.0063915486,0.010410477,0.012250468,-0.01588203,0.016850447,0.0039462973,0.0010349951,-0.0006082866,0.016269397,0.0019368329,-0.05655552,0.0058831302,-0.02537251,0.01113679,0.018593596,-0.020627271,-0.011717839,-0.0020215693,0.005592605,-0.03157038,-0.01820623,-0.015010456,0.0112336315,-0.0048905034,-0.02411357,-0.015978873,-0.020820955,0.0022757787,0.01413888,0.0027115662,0.029052494,-0.005592605,0.0061978656,-0.007505228,0.040286124,-0.04454716,-0.017528338,0.038155608,0.00068999676,0.04880819,0.010846265,0.0048420825,-0.016947288,0.015688347,-0.012686255,-0.017140971,-0.0024815672,0.0007686806,0.0081346985,-0.020046221,-0.011524156,0.0013073622,0.022757787,-0.027696712,-0.022176737,0.002118411,-0.007844173,0.014913614,0.024210412,-0.029052494,-0.017528338,0.014235722,0.018012546,0.0011378893,0.015978873,-0.0110883685,-0.020530429,0.020724112,-0.026147244,-0.013751514,0.010168373,-0.0105557395,0.0035589305,0.03408826,0.022176737,0.04745241,0.012008364,-0.029052494,0.012153626,-0.017528338,0.055393424,0.01413888,-0.06507759,0.023435678,0.021208322,-0.007456807,-0.012492573,0.018303072,0.019755697,-0.0038252452,0.015591505,-0.03525036,-0.027503029,-0.008037857,0.0066820737,0.064302854,0.029439861,-0.017818863,0.021014638,0.036025092,-0.0056168158,-0.03641246,0.01762518,0.010749423,0.004648399,-0.018690439,-0.047065042,-0.011378894,-0.010168373,0.0007807858,0.007505228,-0.0073599652,-0.013364147,-0.00069302303,-0.02537251,-0.009006273,0.0050357655,0.0032199847,0.05461869,0.037380878,0.03466931,-0.04745241,-0.030795643,-0.01413888,-0.0059073404,-0.031957746,-0.024985146,0.000411577,0.008909431,0.025566194,-0.005979972,0.01994938,0.0028447234,-0.020917796,-0.011814681,-0.060816556,-0.035056677,0.029052494,0.0052536596,-0.0067304946,-0.026147244,0.0058347094,-0.0016220976,-0.013073622,0.020046221,0.0017552548,0.02827776,0.041060857,-0.0037768243,0.028084077,0.025566194,-0.012153626,0.029246178,0.030795643,-0.007505228,0.04067349,-0.06236602,0.014623089,0.012056785,-0.013945198,0.06507759,0.0031473537,-0.04454716,-0.027890395,0.008667327,-0.010894685,0.023048311,0.016559921,-0.0075536487,-0.019852538,-0.036799826,0.001264994,-0.040092442,0.02517883,-0.0027357766,0.043772426,-0.011911523,0.0058104987,0.05113239,0.020433588,-0.027890395,0.012250468,-0.0005326291,0.008425224,-0.018303072,0.01994938,0.002057885,-0.009006273,0.011475735,0.00072025973,0.000381314,-0.04299769,-0.049195558,0.014235722,0.042222958,-0.013945198,-0.003462089,0.0014889403,-0.0060283924,-0.027890395,-0.011039948,-0.0014586773,0.025566194,-0.010410477,0.016559921,-0.026534611,0.013460989,-0.01936833,-0.018109389,0.030020911,0.0022757787,-0.0067789154,-0.032732476,-0.026728295,-0.007408386,-0.0072631235,0.009684165,-0.025566194,-0.023435678,0.039124027,-0.0018884122,-0.044353474,-0.027309345,-0.018399913,-0.0036073513,0.02885881,-0.03176406,-0.0067789154,-0.014429405,0.011863102,0.025566194,0.017818863,0.020724112,0.005350501,0.007166282,-0.037380878,-0.0076504904,0.0062947073,-0.00944206,0.005132607,-0.020530429,0.031376693,0.012056785,0.00075960165,0.011620997,0.035056677,-0.037961926,0.05074502,-0.04299769,0.008328382,0.052681856,-0.0019852538,0.005156818,0.032151427,0.03447563,0.007892595,-0.011475735,0.00944206,-0.0026026194,-0.020239905,-0.004745241,-0.017237814,0.0009442061,0.036218777,0.0033410368,-0.015397822,-0.025566194,0.007844173,-0.0013255201,0.011282052,-0.008376802,0.019174647,0.0034862994,-0.012686255,0.03776824,-0.028665127,0.011378894,0.0036073513,-0.008183119,-0.0062462864,-0.009006273,-0.010362056,0.04822714,-0.007892595,0.0019731487,0.008570486,-0.045321893,0.05113239,-0.012589415,0.014526247,0.019271487,0.042222958,-0.014235722,0.013945198,-0.006924178,-0.0140420385,-0.0021668319,0.0010713107,-0.015010456,-0.0021426214,-0.015591505,-0.04183559,0.0044305054,-0.02517883,0.0008413118,-0.007892595,0.012105206,-0.004212612,-0.012492573,-0.018109389,0.031957746,-0.06469022,0.011475735,-0.012153626,0.053069223,-0.0067789154,0.02885881,0.0052052387,0.01413888,0.029052494,-0.010168373,-0.027115662,-0.032732476,-0.051907122,-0.017722022,0.007505228,-0.0021305163,-0.008376802,0.010604161,-0.036799826,0.029827228,0.01704413,0.06391549,-0.032151427,0.038349293,-0.026728295,0.020917796,-0.0019610433,-0.03466931,0.0038494554,-0.04648399,-0.03157038,-0.0072147027,-0.00944206,0.0062462864,0.016559921,0.0021426214,0.007117861,0.013170464,-0.018496756,0.0009381535,0.011378894,-0.0034378786,-0.051907122,0.007698911,0.030989327,-0.009006273,-0.045128208,-0.045515575,0.0026631453,-0.025759878,0.0010228899,0.013557831,-0.002989986,-0.051907122,-0.07592385,0.0037768243,-0.026147244,-0.014429405,-0.016656764,0.031376693,-0.016269397,-0.037961926,0.05113239,-0.030601962,-3.7261336e-05,-0.03408826,-0.008522065,-0.008279961,-0.00036769564,-0.012250468,-0.012395731,0.007408386,-0.020336745,0.04590294,-0.04454716,-0.029633544,0.013170464,0.0019610433,0.015397822,0.00051144493,0.028084077,-0.010991527,-0.016947288,0.029439861,-0.032732476,0.008425224,0.03699351,-0.025566194,-0.0040673492,0.047258724,0.010846265,-0.010458898,0.023338838,0.025953561,-0.005762078,0.016269397,0.02537251,0.03583141,-0.0059073404,-0.0072147027,-0.028084077,-0.0014707826,0.008667327,0.06314076,0.030408278,-0.026921978,0.011620997,-0.027890395,-0.014623089,0.0077957525,0.030601962,-0.03893034,0.004188401,0.009490482,0.012395731,-0.0045031365,-0.0035589305,0.00054473424,0.0009381535,0.03447563,0.015978873,0.020627271,-0.033119842,-0.009829427,-0.07127545,0.013557831,-0.046871357,-0.010652581,-0.008764169,0.0030989328,0.00997469,-0.043966107,-0.010701002,0.007456807,-0.039705075,0.012589415,0.012589415,0.009103115,0.032732476,-0.01820623,0.0129767805,0.04745241,-0.010071531,0.037187193,-0.006875757,-0.0048420825,-0.015204139,0.030989327,-0.0010047321,-0.03408826,-0.009054694,0.021595687,0.007892595,0.014816772,-0.06585232,-0.013848356,-0.0053262906,0.016656764,-0.023532521,-0.01646308,0.04590294,-0.016075714,0.003583141,0.0017068341,-0.027503029,0.0044305054,0.0067789154,-0.004624189,-0.03408826,0.016947288,-0.028471444,0.020239905,-0.0039705075,0.003292616,-0.015010456,-0.04880819,-0.022467263,0.024016729,0.022467263,0.008473644,-0.043191373,0.028084077,-0.018303072,-0.030020911,-0.0063431277,-0.0147199305,0.025953561,-0.018303072,-0.021595687,0.0026631453,0.023532521,-0.076311216,-0.014816772,-0.0031231432,0.018109389,-0.016559921,-0.01704413,0.0012831518,-0.012492573,-0.014526247,0.023241995,-0.020433588]');
INSERT INTO "public"."t_position" ("id", "name", "description", "required_skills", "interview_focus", "create_time", "update_time", "deleted") VALUES
('pos_java_001', 'Java后端开发', '负责服务器端业务逻辑开发，处理API请求、数据库操作、系统性能优化等', '["Java", "Spring Boot", "MySQL", "Redis", "MyBatis", "微服务", "Linux"]', 'Java基础、Spring框架、数据库设计、并发编程、JVM优化', '2026-03-29 18:54:26.798526', '2026-03-29 18:54:26.798526', 0),
('pos_python_001', 'Python算法', '负责算法设计、模型训练、数据处理，解决实际业务中的算法问题', '["Python", "NumPy", "Pandas", "Scikit-learn", "PyTorch", "数据结构", "机器学习"]', 'Python基础、数据结构、机器学习算法、模型评估、特征工程', '2026-03-26 19:50:19.231271', '2026-03-26 19:50:19.231271', 0),
('pos_web_001', 'Web前端开发', '负责用户界面开发，实现交互效果，优化用户体验，与后端联调接口', '["HTML5", "CSS3", "JavaScript", "Vue.js", "React", "Webpack", "HTTP协议"]', 'JavaScript基础、Vue/React框架、浏览器原理、性能优化、跨域处理', '2026-03-29 18:55:13.669578', '2026-03-29 18:55:13.669578', 0);
INSERT INTO "public"."t_question" ("id", "position_id", "question_type", "difficulty", "question_text", "reference_answer", "keywords", "create_time", "update_time", "deleted") VALUES
('q_java_001', 'pos_java_001', 'technical', 3, 'HashMap的实现原理是什么？', 'HashMap基于哈希表实现，以键值对形式存储。通过put()存入键值对，先计算key的hashCode()确定存储位置，如果位置为空直接存入，否则遍历链表/红黑树。当链表长度超过8且数组长度超过64时转为红黑树。', '{HashMap,哈希表,红黑树,扩容}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_002', 'pos_java_001', 'technical', 4, 'ConcurrentHashMap如何保证线程安全？', 'ConcurrentHashMap采用CAS+synchronized实现线程安全。JDK7采用Segment分段锁，JDK8采用synchronized锁住链表头节点，锁粒度更细，并发度更高。', '{ConcurrentHashMap,线程安全,CAS,synchronized}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_003', 'pos_java_001', 'technical', 4, 'JVM内存模型是怎样的？', 'JVM内存分为线程私有的程序计数器、虚拟机栈、本地方法栈，和线程共享的堆、方法区。堆又分为新生代（Eden、Survivor0、Survivor1）和老年代。', '{JVM,内存模型,堆,栈,方法区}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_004', 'pos_java_001', 'technical', 3, 'Spring Boot的自动装配原理是什么？', 'Spring Boot通过@EnableAutoConfiguration注解开启自动装配，核心是META-INF/spring.factories文件中的配置类。Spring Boot启动时会扫描所有jar包下的spring.factories文件，加载其中的配置类，根据条件注解判断是否生效。', '{"Spring Boot",自动装配,EnableAutoConfiguration}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_005', 'pos_java_001', 'technical', 3, 'MySQL的索引类型有哪些？InnoDB使用什么索引？', 'MySQL索引类型包括：B+树索引、哈希索引、全文索引、空间索引。InnoDB默认使用B+树索引，主键索引叶子节点存储完整行数据，二级索引叶子节点存储主键值。', '{MySQL,索引,B+树,InnoDB}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_006', 'pos_java_001', 'technical', 3, 'Redis支持哪些数据类型？', 'Redis支持String、Hash、List、Set、Sorted Set五种基本数据类型，还支持Bitmap、HyperLogLog、Geo、Stream等扩展类型。', '{Redis,数据类型,String,Hash,List}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_007', 'pos_java_001', 'scenario', 4, '设计一个秒杀系统，需要考虑哪些问题？', '高并发：限流、队列削峰、缓存预热；库存防超卖：乐观锁、Redis原子操作；防刷：验证码、限流；数据库优化：读写分离、分库分表；服务降级。', '{秒杀,高并发,限流,缓存,防超卖}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_008', 'pos_java_001', 'scenario', 4, '如何排查线上CPU飙升的问题？', 'top查看进程、top -H查看线程、jstack导出线程栈、分析线程状态、找到问题代码、查看GC日志、检查死循环。', '{CPU飙升,排查,jstack,GC}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_009', 'pos_java_001', 'behavior', 2, '当和同事意见不一致时，你会怎么处理？', '先倾听对方观点，理解对方思路；用数据或事实说服；如果无法达成一致，请示上级或技术负责人；最终无论结果如何，积极配合团队决策。', '{沟通,团队协作,冲突解决}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_010', 'pos_java_001', 'project', 3, '介绍你做过的最有挑战的项目，你在其中解决了什么问题？', '项目背景、团队规模、个人职责（负责哪些模块）、技术栈、具体实现、遇到的难点（如性能问题、并发问题）、解决方案、最终成果。', '{项目经验,角色,挑战,解决方案}', '2026-03-29 18:59:57.103648', '2026-03-29 18:59:57.103648', 0),
('q_java_011', 'pos_java_001', 'technical', 2, 'final、finally、finalize的区别是什么？', 'final修饰类、方法、变量；finally用于异常处理，保证代码块执行；finalize是Object的方法，垃圾回收前调用，已废弃。', '{final,finally,finalize,区别}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_012', 'pos_java_001', 'technical', 1, '==和equals()的区别是什么？', '==比较基本类型值或对象引用；equals()是Object的方法，默认比较引用，String等类重写为比较值。', '{==,equals,引用比较,值比较}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_013', 'pos_java_001', 'technical', 2, '什么是序列化？如何实现？', '序列化是将对象转换为字节流，便于存储或传输。实现Serializable接口，使用ObjectOutputStream序列化，ObjectInputStream反序列化。', '{序列化,Serializable,ObjectOutputStream}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_014', 'pos_java_001', 'technical', 3, '什么是反射？有什么应用场景？', '反射允许程序在运行时获取类的信息并操作对象。应用：框架（Spring）、动态代理、注解解析、IDE智能提示。', '{反射,动态代理,框架}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_015', 'pos_java_001', 'technical', 2, '什么是泛型？类型擦除是什么？', '泛型实现参数化类型，编译时进行类型检查。类型擦除是编译后移除泛型信息，替换为原始类型，插入强制转换。', '{泛型,类型擦除,参数化类型}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_016', 'pos_java_001', 'technical', 2, 'abstract和interface的区别是什么？', '抽象类可以有方法实现，单继承；接口多实现，Java8后有默认方法。抽象类描述本质，接口定义规范。', '{abstract,interface,抽象类,接口}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_017', 'pos_java_001', 'technical', 1, 'checked和unchecked异常的区别是什么？', 'checked异常必须捕获或声明抛出，如IOException；unchecked异常可以不处理，如NullPointerException，是RuntimeException的子类。', '{checked异常,unchecked异常,RuntimeException}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_018', 'pos_java_001', 'technical', 2, '什么是内部类？有几种类型？', '内部类是定义在类内部的类。类型：成员内部类、静态内部类、局部内部类、匿名内部类。', '{内部类,成员内部类,静态内部类,匿名内部类}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_019', 'pos_java_001', 'technical', 1, '什么是transient关键字？', 'transient修饰的字段不参与序列化，用于标记不需要持久化的敏感信息或临时数据。', '{transient,序列化,不序列化}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_020', 'pos_java_001', 'technical', 2, 'String为什么是不可变的？', 'String内部字符数组用final修饰，且不提供修改方法；不可变保证线程安全、哈希值稳定、字符串常量池复用。', '{String,不可变,字符串常量池}', '2026-04-01 22:34:47.892689', '2026-04-01 22:34:47.892689', 0),
('q_java_021', 'pos_java_001', 'technical', 2, 'TreeMap和LinkedHashMap的区别是什么？', 'TreeMap按key自然顺序或Comparator排序；LinkedHashMap保持插入顺序或访问顺序。两者都是有序的，但排序方式不同。', '{TreeMap,LinkedHashMap,排序,插入顺序}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_022', 'pos_java_001', 'technical', 2, 'HashSet如何保证元素不重复？', 'HashSet基于HashMap实现，元素作为key，value是固定常量。通过hashCode和equals判断重复，先比较hashCode再比较equals。', '{HashSet,HashMap,hashCode,equals}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_023', 'pos_java_001', 'technical', 2, 'PriorityQueue底层实现是什么？', 'PriorityQueue基于二叉堆（数组实现），默认最小堆，队首是最小元素。插入和删除时间复杂度O(log n)。', '{PriorityQueue,二叉堆,最小堆}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_024', 'pos_java_001', 'technical', 3, 'WeakHashMap的作用是什么？', 'WeakHashMap的key是弱引用，GC时会自动回收，适合实现缓存。当key被回收时，对应的entry也会被移除。', '{WeakHashMap,弱引用,缓存}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_025', 'pos_java_001', 'technical', 1, 'Collections和Arrays工具类有哪些常用方法？', 'sort排序、binarySearch二分查找、reverse反转、shuffle随机打乱、asList数组转列表、fill填充。', '{Collections,Arrays,sort,asList}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_026', 'pos_java_001', 'technical', 2, '什么是快速失败机制？', '快速失败是在遍历集合时，如果集合被修改，抛出ConcurrentModificationException。通过modCount版本号实现。', '{快速失败,ConcurrentModificationException,modCount}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_027', 'pos_java_001', 'technical', 2, 'BlockingQueue有哪些实现类？', 'ArrayBlockingQueue数组有界；LinkedBlockingQueue链表有界；PriorityBlockingQueue优先级无界；SynchronousQueue直接传递。', '{BlockingQueue,ArrayBlockingQueue,LinkedBlockingQueue}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_028', 'pos_java_001', 'technical', 3, 'CopyOnWriteArrayList的原理是什么？', '写时复制：修改时复制新数组，修改后替换原数组引用；读操作无锁，适合读多写少场景，数据一致性弱。', '{CopyOnWriteArrayList,写时复制,并发安全}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_029', 'pos_java_001', 'technical', 3, 'ConcurrentSkipListMap的特点是什么？', '基于跳表实现，有序并发安全，提供O(log n)的查找插入删除，空间换时间，比ConcurrentHashMap更适合有序场景。', '{ConcurrentSkipListMap,跳表,有序并发}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_030', 'pos_java_001', 'technical', 2, 'EnumSet和EnumMap的特点是什么？', '针对枚举类型优化的高性能集合，内部使用位向量实现，内存紧凑，操作速度快。只允许存储同一枚举类型的元素。', '{EnumSet,EnumMap,枚举,位向量}', '2026-04-01 22:36:24.53912', '2026-04-01 22:36:24.53912', 0),
('q_java_031', 'pos_java_001', 'framework', 2, 'Spring Bean的作用域有哪些？', 'singleton单例（默认）、prototype原型、request请求级、session会话级、application应用级。', '{Spring,Bean作用域,singleton,prototype}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_032', 'pos_java_001', 'framework', 1, 'Spring Boot的核心注解有哪些？', '@SpringBootApplication组合了@EnableAutoConfiguration、@ComponentScan、@Configuration。', '{SpringBoot,注解,自动配置}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_033', 'pos_java_001', 'framework', 3, '如何实现分布式事务？', '2PC两阶段提交、TCC补偿事务、SAGA长事务、最终一致性（本地消息表、事务消息）。根据业务场景选择不同方案。', '{分布式事务,2PC,TCC,SAGA}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_034', 'pos_java_001', 'framework', 2, '什么是服务熔断和降级？', '熔断是调用失败达到阈值时断开调用，防止雪崩；降级是提供兜底方案，返回默认值或执行备用逻辑。Hystrix、Sentinel实现。', '{服务熔断,服务降级,Hystrix,Sentinel}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_035', 'pos_java_001', 'framework', 2, '如何实现接口幂等性？', '唯一ID去重、乐观锁版本号、分布式锁、状态机控制、Token机制。防止重复请求造成数据错误。', '{幂等性,唯一ID,乐观锁,分布式锁}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_036', 'pos_java_001', 'framework', 3, '什么是零拷贝技术？', '零拷贝减少数据在用户态和内核态之间的拷贝次数。Java使用FileChannel的transferTo/transferFrom，或直接内存映射。', '{零拷贝,FileChannel,内存映射}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_037', 'pos_java_001', 'framework', 2, '如何排查死锁问题？', 'jstack查看线程堆栈，找出BLOCKED状态的线程，分析锁持有关系；使用jconsole或VisualVM可视化监控；代码中记录锁获取顺序。', '{死锁,排查,jstack,线程}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_038', 'pos_java_001', 'framework', 2, '什么是SPI机制？', 'Service Provider Interface，用于框架扩展。通过META-INF/services/文件配置接口实现类，ServiceLoader动态加载。', '{SPI,ServiceLoader,扩展机制}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_039', 'pos_java_001', 'framework', 3, '如何实现一个简单的RPC框架？', '使用动态代理生成服务代理；序列化协议（JSON/Protobuf）；网络通信（Netty/HTTP）；服务注册与发现；负载均衡。', '{RPC,动态代理,序列化,Netty}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_java_040', 'pos_java_001', 'framework', 2, '什么是JWT？有哪些组成部分？', 'JSON Web Token，包含Header（头部）、Payload（载荷）、Signature（签名）。用于身份认证，无状态，可扩展。', '{JWT,身份认证,Token}', '2026-04-01 22:36:36.317183', '2026-04-01 22:36:36.317183', 0),
('q_python_001', 'pos_python_001', 'technical', 2, 'Python中的列表和元组有什么区别？', '列表可变，元组不可变；列表用方括号，元组用圆括号；列表支持增删改，元组不支持；列表占用内存更大，元组更轻量。', '{Python,列表,元组,可变}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_002', 'pos_python_001', 'technical', 3, '什么是装饰器？有什么作用？', '装饰器是一种设计模式，可以在不修改原函数代码的情况下增加额外功能。常用于日志记录、性能测试、权限校验、缓存等。', '{装饰器,设计模式,AOP}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_003', 'pos_python_001', 'technical', 3, 'NumPy数组和Python列表有什么区别？', 'NumPy数组元素类型相同，列表可以不同；NumPy支持向量化运算，速度更快；NumPy内存连续，占用更小；NumPy提供丰富的数学函数。', '{NumPy,数组,性能,向量化}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_004', 'pos_python_001', 'technical', 4, 'Pandas中DataFrame和Series的区别？', 'Series是一维带标签数组，DataFrame是二维表格结构；DataFrame由多个Series组成；Series相当于一行或一列，DataFrame相当于整个表格。', '{Pandas,DataFrame,Series,数据结构}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_005', 'pos_python_001', 'technical', 3, '什么是过拟合？如何防止过拟合？', '过拟合是模型在训练集上表现好但测试集上表现差的现象。防止方法：增加数据量、正则化（L1/L2）、Dropout、早停、数据增强、简化模型。', '{过拟合,正则化,Dropout,机器学习}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_006', 'pos_python_001', 'technical', 4, '什么是梯度消失和梯度爆炸？如何解决？', '梯度消失：深层网络反向传播时梯度趋近于0；梯度爆炸：梯度变得非常大。解决方法：BatchNorm、残差连接、梯度裁剪、使用ReLU激活函数、合理初始化权重。', '{梯度消失,梯度爆炸,神经网络,反向传播}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_007', 'pos_python_001', 'scenario', 4, '如何处理数据不平衡问题？', '数据层面：过采样（SMOTE）、欠采样；算法层面：调整类别权重、使用Focal Loss；评估指标：使用AUC、F1分数代替准确率。', '{数据不平衡,采样,SMOTE,"Focal Loss"}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_008', 'pos_python_001', 'scenario', 3, '如何评估分类模型的好坏？', '准确率、精确率、召回率、F1分数、ROC曲线、AUC值、混淆矩阵。不同场景关注不同指标。', '{模型评估,准确率,召回率,AUC}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_009', 'pos_python_001', 'behavior', 2, '描述一个你参与的算法项目，你负责什么？', '项目背景、业务目标、数据来源、算法选型、特征工程、模型训练、效果评估、遇到的挑战、解决方案。', '{项目经验,算法,模型训练}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_010', 'pos_python_001', 'project', 3, '你在数据预处理中做过哪些工作？', '数据清洗：处理缺失值、异常值；数据转换：标准化、归一化、编码；特征工程：特征提取、特征选择、特征降维；数据划分：训练集、验证集、测试集。', '{数据预处理,特征工程,清洗,标准化}', '2026-03-29 19:00:18.8225', '2026-03-29 19:00:18.8225', 0),
('q_python_011', 'pos_python_001', 'technical', 1, 'Python中is和==的区别是什么？', 'is比较的是对象身份（内存地址），==比较的是值是否相等。对于小整数和字符串常量，is可能为True因为Python做了缓存。', '{is,==,对象身份,值比较}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_012', 'pos_python_001', 'technical', 2, '什么是闭包？如何创建闭包？', '闭包是指内部函数引用了外部函数的变量，并且外部函数返回了内部函数。闭包可以保存外部函数的状态，常用于装饰器。', '{闭包,内部函数,状态保存}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_013', 'pos_python_001', 'technical', 2, '__new__和__init__的区别是什么？', '__new__是创建实例的类方法，返回实例对象；__init__是初始化实例的实例方法，不返回任何值。__new__先于__init__执行。', '{__new__,__init__,实例创建,实例初始化}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_014', 'pos_python_001', 'technical', 3, '什么是GIL锁？有什么影响？', 'GIL是全局解释器锁，保证同一时刻只有一个线程执行Python字节码。它限制了Python多线程的并行能力，但多进程可以绕过GIL。', '{GIL,全局解释器锁,多线程,多进程}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_015', 'pos_python_001', 'technical', 3, 'Python中的垃圾回收机制是怎样的？', 'Python以引用计数为主，标记清除和分代回收为辅。当引用计数为0时立即回收；循环引用由标记清除处理；分代回收将对象分为三代，新生代回收更频繁。', '{垃圾回收,引用计数,标记清除,分代回收}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_016', 'pos_python_001', 'technical', 2, '@staticmethod和@classmethod的区别是什么？', '静态方法不需要类或实例作为参数，类方法第一个参数是cls，可以访问类属性。类方法可以被子类重写，静态方法不能。', '{staticmethod,classmethod,静态方法,类方法}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_017', 'pos_python_001', 'technical', 3, '什么是元类？有什么作用？', '元类是类的类，用于控制类的创建过程。type是Python的内置元类，可以通过继承type创建自定义元类。常用于ORM框架、单例模式等。', '{元类,type,类创建,ORM}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_018', 'pos_python_001', 'technical', 2, 'yield和return的区别是什么？', 'return返回一个值并结束函数；yield返回一个生成器，可以多次返回值，函数状态会被保留。yield from可以委托给另一个生成器。', '{yield,return,生成器,惰性求值}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_019', 'pos_python_001', 'technical', 2, '什么是上下文管理器？如何实现？', '上下文管理器用于资源管理，如文件、锁。可以通过实现__enter__和__exit__方法，或使用contextlib模块的contextmanager装饰器。', '{上下文管理器,with语句,资源管理}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_020', 'pos_python_001', 'technical', 1, 'sys.path和PYTHONPATH的区别是什么？', 'sys.path是Python模块搜索路径的列表；PYTHONPATH是环境变量，用于设置额外的模块搜索路径，会被添加到sys.path中。', '{sys.path,PYTHONPATH,模块搜索路径}', '2026-04-01 22:34:20.971389', '2026-04-01 22:34:20.971389', 0),
('q_python_021', 'pos_python_001', 'algorithm', 3, '如何实现LRU缓存淘汰算法？', 'LRU使用OrderedDict或哈希表+双向链表实现。OrderedDict的move_to_end和popitem方法可以轻松实现；双向链表+哈希表可以O(1)完成get和put操作。', '{LRU,缓存淘汰,OrderedDict,双向链表}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_022', 'pos_python_001', 'algorithm', 2, '如何判断链表是否有环？', '使用快慢指针法：快指针每次走两步，慢指针每次走一步，如果有环，两个指针一定会相遇。也可以用哈希表记录访问过的节点。', '{链表,环,快慢指针}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_023', 'pos_python_001', 'algorithm', 2, '如何找到数组中出现次数超过一半的元素？', '使用摩尔投票法：维护一个候选元素和计数，遍历数组，计数为0时更换候选，相等时加1，不等时减1。最后验证候选元素是否满足条件。', '{摩尔投票法,众数,数组}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_024', 'pos_python_001', 'algorithm', 2, '如何实现一个最小栈？', '使用辅助栈存储当前最小值：每次push时，辅助栈压入当前最小值和入栈值的较小值；pop时两个栈同时弹出；getMin直接返回辅助栈顶。', '{最小栈,辅助栈,O(1)取值}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_025', 'pos_python_001', 'algorithm', 3, '如何判断一棵树是否是平衡二叉树？', '递归计算左右子树的高度，如果高度差大于1返回False；同时返回子树高度，自底向上判断。时间复杂度O(n)。', '{平衡二叉树,递归,高度差}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_026', 'pos_python_001', 'algorithm', 2, '如何实现一个优先队列？', 'Python内置的heapq模块可以实现最小堆，时间复杂度O(log n)。如果需要最大堆，可以将元素取负入堆。', '{优先队列,堆,heapq}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_027', 'pos_python_001', 'algorithm', 3, '如何找到数组中第K大的元素？', '使用快速选择算法，平均O(n)时间复杂度；也可以使用最小堆，维护大小为K的堆，堆顶就是第K大的元素。', '{第K大,快速选择,堆排序}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_028', 'pos_python_001', 'algorithm', 2, '如何实现一个线程安全的单例模式？', '使用模块级变量，Python模块是天然的单例；或使用装饰器加锁实现双重检查锁；或使用__new__方法控制实例创建。', '{单例模式,线程安全,双重检查锁}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_029', 'pos_python_001', 'algorithm', 2, '如何判断两个字符串是否为同构？', '使用两个哈希表记录双向映射：一个记录s到t的映射，一个记录t到s的映射。遍历字符串，如果映射不一致则返回False。', '{同构字符串,哈希表,映射}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_030', 'pos_python_001', 'algorithm', 2, '如何实现一个循环队列？', '使用数组和头尾指针，通过取模运算实现循环。需要区分队空和队满，常用方法是牺牲一个空间，或维护一个计数器。', '{循环队列,数组,头尾指针}', '2026-04-01 22:34:30.331213', '2026-04-01 22:34:30.331213', 0),
('q_python_031', 'pos_python_001', 'advanced', 3, '如何优化Python代码的性能？', '使用局部变量减少全局查找；用列表推导式代替循环；使用join拼接字符串；用生成器处理大数据；使用多进程绕过GIL；使用Cython或PyPy加速。', '{性能优化,局部变量,列表推导式,多进程}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_032', 'pos_python_001', 'advanced', 3, '如何实现一个分布式锁？', '使用Redis的SET NX EX命令实现原子加锁，设置过期时间防止死锁；或使用ZooKeeper的临时顺序节点；或使用etcd的租约机制。需要处理锁续期和释放。', '{分布式锁,Redis,ZooKeeper,原子操作}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_033', 'pos_python_001', 'advanced', 3, '如何设计一个限流器？', '令牌桶算法：按固定速率生成令牌，请求消耗令牌；漏桶算法：请求进入桶中匀速流出；计数器算法：固定窗口计数。常用Redis实现分布式限流。', '{限流器,令牌桶,漏桶,计数器}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_034', 'pos_python_001', 'advanced', 3, '什么是协程？和线程有什么区别？', '协程是用户态轻量级线程，由程序控制切换，无需系统调用；线程由操作系统调度，有上下文切换开销。协程适合IO密集型任务，线程适合CPU密集型。', '{协程,线程,用户态,上下文切换}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_035', 'pos_python_001', 'advanced', 3, '如何使用asyncio实现异步编程？', '使用async def定义协程，await等待异步操作；事件循环调度任务；使用asyncio.gather并发执行多个协程；使用asyncio.run启动事件循环。', '{asyncio,异步编程,协程,事件循环}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_036', 'pos_python_001', 'advanced', 2, '什么是Cython？有什么作用？', 'Cython是Python的超集，可以将Python代码编译成C扩展，显著提升性能。通过静态类型声明，可以接近C语言的执行速度。', '{Cython,编译,性能优化,C扩展}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_037', 'pos_python_001', 'advanced', 3, '如何调试Python内存泄漏？', '使用tracemalloc跟踪内存分配；使用objgraph查看对象引用关系；使用pympler分析内存使用；使用guppy进行堆内存分析。重点关注循环引用和全局缓存。', '{内存泄漏,调试,tracemalloc,objgraph}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_038', 'pos_python_001', 'advanced', 3, '如何实现一个简单的Web框架？', '基于WSGI协议，实现路由注册和请求分发；解析请求方法和路径，调用对应的处理函数；支持中间件机制；使用依赖注入处理请求上下文。', '{Web框架,WSGI,路由,中间件}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_039', 'pos_python_001', 'advanced', 1, '什么是PEP8？有哪些核心规范？', 'PEP8是Python代码风格指南。核心规范：使用4个空格缩进；行长度不超过79字符；函数名用小写+下划线；类名用驼峰；导入每行一个；空行分隔函数和类。', '{PEP8,代码规范,风格指南}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_python_040', 'pos_python_001', 'advanced', 2, '如何打包和发布一个Python包？', '使用setuptools编写setup.py；配置pyproject.toml；构建wheel包；使用twine上传到PyPI；添加README和LICENSE；配置CI/CD自动发布。', '{打包,发布,PyPI,setuptools}', '2026-04-01 22:34:38.849546', '2026-04-01 22:34:38.849546', 0),
('q_web_001', 'pos_web_001', 'technical', 2, '什么是闭包？有什么作用？', '闭包是指有权访问另一个函数作用域中变量的函数。作用：封装私有变量、实现模块化、保存变量状态。', '{闭包,作用域,模块化}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_002', 'pos_web_001', 'technical', 2, '什么是事件循环？宏任务和微任务有什么区别？', '事件循环是JavaScript处理异步任务的执行模型。宏任务：setTimeout、setInterval、I/O；微任务：Promise.then。每个宏任务执行后会先清空微任务队列。', '{事件循环,宏任务,微任务,Promise}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_003', 'pos_web_001', 'technical', 2, 'Vue的生命周期有哪些？', 'beforeCreate、created、beforeMount、mounted、beforeUpdate、updated、beforeDestroy、destroyed。', '{Vue,生命周期,钩子函数}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_004', 'pos_web_001', 'technical', 3, '什么是虚拟DOM？优缺点是什么？', '虚拟DOM是用JS对象描述真实DOM结构，通过Diff算法找出最小变更。优点：减少直接操作DOM、跨平台；缺点：首次渲染慢、占用内存。', '{虚拟DOM,Diff算法,性能}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_005', 'pos_web_001', 'technical', 3, '什么是跨域？如何解决？', '跨域是浏览器同源策略导致的限制。解决方案：CORS（后端设置响应头）、代理（proxy）、JSONP（仅GET）、postMessage。', '{跨域,CORS,代理,同源策略}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_006', 'pos_web_001', 'scenario', 3, '如何优化首屏加载速度？', '网络层：CDN加速、Gzip压缩；资源层：图片懒加载、路由懒加载、代码分割；缓存层：强缓存、协商缓存；渲染层：骨架屏、减少重排重绘。', '{首屏优化,性能,懒加载,缓存}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_007', 'pos_web_001', 'technical', 3, '浏览器从输入URL到页面渲染经历了什么？', 'DNS解析 -> TCP连接 -> 发送HTTP请求 -> 服务器处理 -> 返回响应 -> 解析HTML生成DOM树 -> 解析CSS生成CSSOM树 -> 合并为渲染树 -> 布局 -> 绘制 -> 合成显示。', '{浏览器原理,渲染,DNS,HTTP}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_008', 'pos_web_001', 'scenario', 3, '什么是重排和重绘？如何优化？', '重排：布局发生变化，代价高；重绘：外观发生变化，代价中等。优化：用transform代替top/left、批量修改样式、使用visibility代替display:none。', '{重排,重绘,性能优化}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_009', 'pos_web_001', 'behavior', 2, '描述一个你遇到的复杂交互需求，如何实现的？', '需求描述、技术选型（Vue/React）、组件设计、状态管理、遇到的坑、最终效果。', '{项目经验,交互,组件}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_010', 'pos_web_001', 'project', 3, '介绍你的一个前端项目，遇到的最大技术难点是什么？', '项目背景、技术栈、负责模块、遇到的难点（如性能问题、兼容性问题）、解决方案、最终成果。', '{项目经验,技术难点,解决方案}', '2026-03-29 19:00:06.386758', '2026-03-29 19:00:06.386758', 0),
('q_web_011', 'pos_web_001', 'technical', 1, 'var、let、const的区别是什么？', 'var函数作用域，变量提升；let/const块级作用域，暂时性死区。const声明常量，引用类型可修改属性。', '{var,let,const,作用域}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_012', 'pos_web_001', 'technical', 2, '什么是作用域链？', '作用域链是变量查找的路径，从当前作用域向外层逐层查找，直到全局作用域。闭包会保存外部作用域链。', '{作用域链,变量查找,闭包}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_013', 'pos_web_001', 'technical', 2, '什么是高阶函数？举例说明。', '高阶函数是接受函数作为参数或返回函数的函数。例如：map、filter、reduce、debounce、throttle。', '{高阶函数,map,filter,reduce}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_014', 'pos_web_001', 'technical', 3, '什么是函数柯里化？', '柯里化是将多参数函数转换为单参数函数链。实现：返回新函数逐步收集参数，参数足够时执行原函数。', '{柯里化,函数式编程,参数收集}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_015', 'pos_web_001', 'technical', 2, '什么是尾调用优化？', '尾调用是函数最后一步调用另一个函数，可以复用栈帧，避免栈溢出。严格模式下启用，递归常用优化。', '{尾调用,栈帧优化,递归}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_016', 'pos_web_001', 'technical', 1, 'typeof和instanceof的区别是什么？', 'typeof返回类型字符串；instanceof判断对象原型链上是否存在构造函数的prototype。', '{typeof,instanceof,类型判断}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_017', 'pos_web_001', 'technical', 2, '什么是Symbol？有什么作用？', 'Symbol创建唯一值，作为对象属性键，防止属性名冲突。内置Symbol如Symbol.iterator用于定制迭代行为。', '{Symbol,唯一值,迭代器}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_018', 'pos_web_001', 'technical', 3, '什么是Proxy？有什么作用？', 'Proxy代理对象，可以拦截和定义基本操作（get、set、deleteProperty）。用于数据劫持、验证、日志记录。', '{Proxy,代理,拦截,数据劫持}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_019', 'pos_web_001', 'technical', 2, '什么是Reflect？', 'Reflect提供操作对象的方法，与Proxy配套使用。将Object上的内部方法统一到Reflect，使操作更规范。', '{Reflect,对象操作,Proxy}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_020', 'pos_web_001', 'technical', 2, '什么是模块化？有哪些规范？', '模块化将代码分割为独立模块。规范：CommonJS（Node）、AMD（浏览器）、ES6 Module（原生）、UMD（通用）。', '{模块化,CommonJS,"ES6 Module",AMD}', '2026-04-01 22:37:31.651782', '2026-04-01 22:37:31.651782', 0),
('q_web_021', 'pos_web_001', 'framework', 1, 'Vue的v-if和v-show的区别是什么？', 'v-if条件为假时销毁元素，v-show切换display属性。v-if切换开销大，v-show初始渲染开销大。', '{v-if,v-show,Vue,条件渲染}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_022', 'pos_web_001', 'framework', 2, 'Vue的key的作用是什么？', 'key标识节点唯一性，帮助Vue的Diff算法正确复用元素，提高渲染性能。避免就地复用导致的状态错乱。', '{key,Vue,Diff算法,列表渲染}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_023', 'pos_web_001', 'framework', 2, 'React中useMemo和useCallback的区别？', 'useMemo缓存计算结果，返回缓存值；useCallback缓存函数引用。都用于性能优化，避免不必要的重新渲染。', '{useMemo,useCallback,React,Hooks}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_024', 'pos_web_001', 'framework', 2, 'React的key有什么作用？', 'key标识节点唯一性，帮助React的Diff算法识别变化，决定是复用、更新还是销毁重建。', '{key,React,Diff算法,列表渲染}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_025', 'pos_web_001', 'framework', 2, '什么是高阶组件（HOC）？', '高阶组件是接受组件返回新组件的函数，用于逻辑复用，如权限控制、日志记录、数据获取。', '{高阶组件,HOC,React,逻辑复用}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_026', 'pos_web_001', 'framework', 1, 'Vue的slot是什么？有哪些类型？', '插槽用于内容分发，让父组件可以向子组件传递模板。类型：默认插槽、具名插槽、作用域插槽。', '{slot,插槽,Vue,内容分发}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_027', 'pos_web_001', 'framework', 2, 'Vue的mixins有什么优缺点？', '优点：复用逻辑；缺点：命名冲突、来源不清晰、过度耦合。Vue3推荐使用Composition API替代。', '{mixins,Vue,逻辑复用,"Composition API"}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_028', 'pos_web_001', 'framework', 3, 'React的Fiber是什么？', 'Fiber是React16的增量渲染机制，将更新任务拆分为可中断的小任务，实现优先级调度，避免阻塞主线程。', '{Fiber,React,增量渲染,任务调度}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_029', 'pos_web_001', 'framework', 3, 'Vue的nextTick原理是什么？', 'nextTick将回调延迟到下次DOM更新后执行。使用Promise、MutationObserver、setImmediate、setTimeout降级方案。', '{nextTick,Vue,异步更新,DOM更新}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_030', 'pos_web_001', 'framework', 2, 'React的useEffect和useLayoutEffect的区别？', 'useEffect异步执行，不阻塞渲染；useLayoutEffect同步执行，在DOM更新后、浏览器绘制前，用于测量DOM。', '{useEffect,useLayoutEffect,React,Hooks}', '2026-04-01 22:37:40.331129', '2026-04-01 22:37:40.331129', 0),
('q_web_031', 'pos_web_001', 'performance', 3, '浏览器如何渲染页面？', '解析HTML生成DOM树，解析CSS生成CSSOM树，合并为渲染树，布局计算位置，绘制像素，合成图层显示。', '{浏览器渲染,DOM树,CSSOM树,渲染树}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_032', 'pos_web_001', 'performance', 2, '什么是重排和重绘？如何避免？', '重排影响布局（位置、大小），重绘只影响外观（颜色、背景）。避免：用transform代替top/left、批量修改样式、使用visibility代替display。', '{重排,重绘,性能优化,布局}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_033', 'pos_web_001', 'performance', 2, '什么是回流（Reflow）？', '回流是浏览器重新计算元素位置和几何尺寸的过程。当添加/删除DOM、改变尺寸、改变窗口大小时触发，代价高。', '{回流,布局计算,性能}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_034', 'pos_web_001', 'performance', 1, '什么是CDN？有什么作用？', '内容分发网络，将静态资源缓存到全球节点，用户就近访问，加速资源加载，减轻源服务器压力。', '{CDN,内容分发,静态资源加速}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_035', 'pos_web_001', 'performance', 2, '什么是浏览器缓存？有哪些类型？', '强缓存：Cache-Control、Expires，过期前不请求服务器；协商缓存：ETag、Last-Modified，向服务器验证资源是否过期。', '{浏览器缓存,强缓存,协商缓存,ETag}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_036', 'pos_web_001', 'performance', 1, '什么是DNS预解析？', 'DNS预解析提前解析域名，减少DNS查询延迟。使用<link rel="dns-prefetch" href="//example.com">。', '{DNS预解析,性能优化,域名解析}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_037', 'pos_web_001', 'performance', 2, '什么是preload和prefetch？', 'preload预加载当前页面必需资源，优先级高；prefetch预加载后续页面可能用到的资源，优先级低。', '{preload,prefetch,资源预加载,性能优化}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_038', 'pos_web_001', 'performance', 3, '如何检测内存泄漏？', 'Chrome DevTools Memory面板，录制堆快照，对比前后内存变化；Performance面板查看内存趋势；使用WeakMap/WeakSet避免强引用。', '{内存泄漏,调试,"Chrome DevTools",堆快照}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_039', 'pos_web_001', 'security', 2, '什么是XSS攻击？如何防范？', '跨站脚本攻击，注入恶意脚本。防范：输入过滤、输出转义、使用CSP、HttpOnly Cookie。', '{XSS,跨站脚本,安全,防范}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0),
('q_web_040', 'pos_web_001', 'security', 2, '什么是CSRF攻击？如何防范？', '跨站请求伪造，冒充用户发送请求。防范：Token验证、SameSite Cookie、验证Referer、二次确认。', '{CSRF,跨站请求伪造,安全,防范}', '2026-04-01 22:37:51.895865', '2026-04-01 22:37:51.895865', 0);


