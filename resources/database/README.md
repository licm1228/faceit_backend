# Database Initialization

PostgreSQL 初始化建议顺序：

```bash
psql "postgresql://postgres:furina@127.0.0.1:5432/ragent" -f resources/database/schema_pg.sql
psql "postgresql://postgres:furina@127.0.0.1:5432/ragent" -f resources/database/init_data_pg.sql
psql "postgresql://postgres:furina@127.0.0.1:5432/ragent" -f resources/database/upgrade_interview_schema.sql
psql "postgresql://postgres:furina@127.0.0.1:5432/ragent" -f resources/database/init_interview_data.sql
psql "postgresql://postgres:furina@127.0.0.1:5432/ragent" -f resources/database/init_faceit_default_config.sql
```

`init_faceit_default_config.sql` 可重复执行，用于初始化 FaceIt 最小可用后台配置：

- 默认面试意图树：包含岗位知识问答和模拟面试 MCP 两类叶子节点。
- 默认查询词映射：覆盖 Java 后端、Python 算法、Web 前端常见面试口语表达。
- 默认数据通道：`通用文档清洗通道`，包含解析、分块、索引节点。

初始化后可在后台验证：

- `意图管理 -> 意图树配置`
- `意图管理 -> 意图列表`
- `数据通道`
