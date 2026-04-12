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
