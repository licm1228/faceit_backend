-- 初始化面试相关数据

-- 插入岗位数据
INSERT INTO t_position (id, name, description, create_time, update_time, deleted) VALUES
                                                                                      ('1', 'Java开发工程师', '负责后端系统开发', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                      ('2', '前端开发工程师', '负责前端页面开发', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                      ('3', '全栈开发工程师', '负责前后端系统开发', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                      ('4', '数据工程师', '负责数据处理和分析', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                      ('5', 'DevOps工程师', '负责系统运维和部署', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0);

-- 插入Java开发工程师题目（使用UPSERT）
INSERT INTO t_question (id, position_id, question_type, difficulty, question_text, reference_answer, keywords, create_time, update_time, deleted) VALUES
                                                                                                                                                      ('1', '1', '技术题', 3, '请解释Java中的多线程实现方式有哪些？', 'Java中的多线程实现方式主要有：\n1. 继承Thread类\n2. 实现Runnable接口\n3. 实现Callable接口\n4. 使用线程池', '{"多线程", "Thread", "Runnable", "Callable"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                                                                                      ('2', '1', '技术题', 4, '请解释Java中的垃圾回收机制', 'Java的垃圾回收机制是自动内存管理的核心，主要包括：\n1. 标记-清除算法\n2. 复制算法\n3. 标记-整理算法\n4. 分代收集算法', '{"垃圾回收", "GC", "内存管理"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                                                                                      ('3', '1', '技术题', 5, '请解释Spring框架中的IoC和AOP', 'IoC（控制反转）是Spring的核心，将对象的创建和依赖关系的管理交给Spring容器。\nAOP（面向切面编程）是Spring的重要特性，用于处理横切关注点，如事务、日志等。', '{"Spring", "IoC", "AOP"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0)
    ON CONFLICT (id) DO NOTHING;

-- 插入前端开发工程师题目（使用UPSERT）
INSERT INTO t_question (id, position_id, question_type, difficulty, question_text, reference_answer, keywords, create_time, update_time, deleted) VALUES
                                                                                                                                                      ('4', '2', '技术题', 3, '请解释React中的虚拟DOM', '虚拟DOM是React的核心概念，是对真实DOM的轻量级抽象。React通过比较虚拟DOM的差异，只更新需要变化的部分，提高了渲染性能。', '{"React", "虚拟DOM", "性能优化"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                                                                                      ('5', '2', '技术题', 4, '请解释前端路由的实现原理', '前端路由的实现原理主要有两种：\n1. Hash模式：使用URL的hash部分，通过hashchange事件监听变化\n2. History模式：使用HTML5的History API，通过pushState和replaceState方法', '{"前端路由", "Hash", "History API"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0)
    ON CONFLICT (id) DO NOTHING;

-- 插入全栈开发工程师题目（使用UPSERT）
INSERT INTO t_question (id, position_id, question_type, difficulty, question_text, reference_answer, keywords, create_time, update_time, deleted) VALUES
                                                                                                                                                      ('6', '3', '技术题', 4, '请解释RESTful API的设计原则', 'RESTful API的设计原则包括：\n1. 资源标识：使用URI标识资源\n2. 统一接口：使用HTTP方法（GET, POST, PUT, DELETE）\n3. 无状态：服务器不保存客户端状态\n4. 缓存：支持缓存机制\n5. 分层系统：支持分层架构', '{"RESTful", "API设计", "HTTP"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                                                                                      ('7', '3', '技术题', 5, '请解释微服务架构的优缺点', '微服务架构的优点：\n1. 服务解耦\n2. 独立部署\n3. 技术栈灵活\n4. 可扩展性好\n\n缺点：\n1. 分布式复杂性\n2. 服务间通信开销\n3. 数据一致性挑战\n4. 运维复杂度高', '{"微服务", "架构设计", "分布式系统"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0)
    ON CONFLICT (id) DO NOTHING;

-- 插入数据工程师题目（使用UPSERT）
INSERT INTO t_question (id, position_id, question_type, difficulty, question_text, reference_answer, keywords, create_time, update_time, deleted) VALUES
                                                                                                                                                      ('8', '4', '技术题', 3, '请解释SQL中的GROUP BY和HAVING子句', 'GROUP BY用于对结果集进行分组，HAVING用于对分组后的结果进行筛选。HAVING与WHERE的区别是，HAVING可以使用聚合函数，而WHERE不行。', '{"SQL", "GROUP BY", "HAVING"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                                                                                      ('9', '4', '技术题', 4, '请解释数据仓库和数据库的区别', '数据仓库和数据库的主要区别：\n1. 数据库面向事务，数据仓库面向分析\n2. 数据库存储当前数据，数据仓库存储历史数据\n3. 数据库设计遵循范式，数据仓库设计遵循星型或雪花模型\n4. 数据库查询频率高，数据仓库查询复杂度高', '{"数据仓库", "数据库", "数据分析"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0)
    ON CONFLICT (id) DO NOTHING;

-- 插入DevOps工程师题目（使用UPSERT）
INSERT INTO t_question (id, position_id, question_type, difficulty, question_text, reference_answer, keywords, create_time, update_time, deleted) VALUES
                                                                                                                                                      ('10', '5', '技术题', 3, '请解释CI/CD的概念', 'CI（持续集成）是指开发人员频繁将代码集成到共享仓库，每次集成都会自动构建和测试。\nCD（持续部署）是指将通过测试的代码自动部署到生产环境。', '{"CI/CD", "持续集成", "持续部署"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0),
                                                                                                                                                      ('11', '5', '技术题', 4, '请解释Docker和Kubernetes的关系', 'Docker是容器化平台，用于打包和运行应用。Kubernetes是容器编排平台，用于管理和编排Docker容器，提供自动部署、扩缩容、服务发现等功能。', '{"Docker", "Kubernetes", "容器编排"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0)
    ON CONFLICT (id) DO NOTHING;