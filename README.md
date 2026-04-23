<div align="center">

# 🌟 FaceIt · AI 模拟面试与能力提升平台

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Fira+Code&pause=1000&color=1E90FF&center=true&vCenter=true&width=535&lines=Welcome+to+FaceIt+AI+Mock+Interview;面向计算机相关专业学生的AI模拟面试平台;助力大学生斩获心仪Offer;提供精准的评估与成长分析)](https://git.io/typing-svg)

**FaceIt 核心 Web 后端与大模型交互工程**

_提供岗位化题库、模拟面试、即时评估、面试报告和成长分析_

[![Java](https://img.shields.io/badge/Java-17-ff7f2a.svg?style=flat-square&logo=openjdk&logoColor=white)]()
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.x-6db33f.svg?style=flat-square&logo=springboot&logoColor=white)]()
[![Milvus](https://img.shields.io/badge/Milvus-2.6.x-00b3ff.svg?style=flat-square&logo=milvus&logoColor=white)]()
[![React](https://img.shields.io/badge/React-18-61dafb.svg?style=flat-square&logo=react&logoColor=black)]()
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?style=flat-square)](LICENSE)

</div>

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=1E90FF&height=80&section=header" />

## 目录

<div align="center">

[![项目介绍](https://img.shields.io/badge/-项目介绍-1E90FF?style=for-the-badge)](#项目介绍)&nbsp;
[![特色功能](https://img.shields.io/badge/-特色功能-00BFFF?style=for-the-badge)](#特色功能)&nbsp;
[![技术栈](https://img.shields.io/badge/-技术栈-87CEFA?style=for-the-badge)](#技术栈)&nbsp;
[![项目结构](https://img.shields.io/badge/-项目结构-4682B4?style=for-the-badge)](#项目结构)

[![核心架构](https://img.shields.io/badge/-核心架构-1E90FF?style=for-the-badge)](#核心架构)&nbsp;
[![致谢原作者](https://img.shields.io/badge/-致谢原作者-00BFFF?style=for-the-badge)](#致谢原作者)&nbsp;
[![快速开始](https://img.shields.io/badge/-快速开始-87CEFA?style=for-the-badge)](#快速开始)

</div>

## 项目介绍

FaceIt 当前基于现有 Ragent 工程演进而成，主目标已经收敛为 **“AI 模拟面试与能力提升平台”**。

核心能力包括岗位题库管理、多轮对话流式展现、多维度智能评估报告、用户成长曲线，及管理后台多路知识检索功能。

> 本地默认后端入口为 `http://localhost:9090/api/faceit`。

## 特色功能

| 板块           | 说明                                                                   |
| -------------- | ---------------------------------------------------------------------- |
| **模拟面试引擎** | 基于意图定向和Agent能力调度对话组件，提供真切多轮拟真互动的专业评估面试  |
| **即时评估报告** | 自动提取知识、技能点及沟通状态，生成针对性点评与成长能力提升雷达图分析   |
| **可观测管理**   | 全链路追踪日志展示，完善的入库监控，从提问、重写到响应皆有据可查         |
| **高可用设计**   | 基于三态熔断器的模型降级容错及分布式高并发排队控制                       |

## 技术栈

| 类别           | 技术                                                                                                                      |
| -------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **核心框架**   | ![Java 17](https://img.shields.io/badge/Java-17-ff7f2a?style=flat-square&logo=openjdk&logoColor=white) ![Spring Boot 3](https://img.shields.io/badge/Spring_Boot-3.5-6db33f?style=flat-square&logo=springboot&logoColor=white) |
| **前端架构**   | ![React 18](https://img.shields.io/badge/React-18-61dafb?style=flat-square&logo=react&logoColor=black) ![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white) |
| **基础中间件** | ![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white) ![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat-square&logo=redis&logoColor=white) ![Milvus](https://img.shields.io/badge/Milvus-2.6-00b3ff?style=flat-square&logo=milvus&logoColor=white) |

## 项目结构

<details>
<summary><b>点击展开核心目录结构</b></summary>

```text
faceit_backend/
├── frontend/          # 现代化前端界面代码库及后台展示大屏 (Next.js / Vite React)
├── bootstrap/         # 后端业务调度入口及配置启动模块
├── framework/         # RAG 底层基础设施封装抽象 (AOP/分布式锁/全局跨线程追溯)
├── infra-ai/          # 大模型基础设施解耦访问、降级切换等模型交互边界
├── mcp-server/        # MCP 协议和业务工具挂载中心
├── resources/         # 外部组件拓扑网 (Docker) 与 Schema 配置字典
└── scripts/           # Python 知识库导入脚本和其他启动命令
```

</details>

## 核心架构

本项目遵循高可拓展性和高可用的工业级软件生产设计标准：

1. **分布式检索策略模式**：动态融合模型分发渠道、模型队列隔离排队机制和降级探测兜底体系；
2. **长程生命周期上下文**：支持并发会话动态滑动截取摘要，控制 Token 和上下文语境；
3. **ETL 处理流水线**：涵盖了针对本地和企业级复杂信息的检索解析管道能力。

## 致谢原作者

FaceIt 从极其优秀的开源项目 **[Ragent](https://github.com/nageoffer/ragent)** 孵化而来，我们深度借鉴了其高水平的工程化设计、防腐隔离标准与企业级后端规约指引！

向原作者 **nageoffer/ragent** 构建的高质量 Java RAG 开源标准表达最高敬意，任何对 RAG 深度研发选型感兴趣的同学，强烈推荐查阅、点赞支持原项目：

## 快速开始

```bash
# 1. 构建全链路 Java 代理后端
mvn clean install -DskipTests

# 2. 安装前端相关依赖并启用客户端
cd frontend && pnpm install && pnpm run dev
# 前端默认本地访问入口：http://localhost:3000
```

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=1E90FF&height=80&section=footer" />

<div align="center">

<sub>Powered by FaceIt</sub>

<a href="#-faceit--ai-模拟面试与能力提升平台">
  <img src="https://img.shields.io/badge/Back_to_Top-1E90FF?style=for-the-badge" alt="Back to Top" />
</a>

</div>
