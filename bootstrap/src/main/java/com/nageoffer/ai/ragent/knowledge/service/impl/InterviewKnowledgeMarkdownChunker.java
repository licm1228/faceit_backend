/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.nageoffer.ai.ragent.knowledge.service.impl;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.nageoffer.ai.ragent.core.chunk.VectorChunk;
import com.nageoffer.ai.ragent.knowledge.dao.entity.KnowledgeDocumentDO;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class InterviewKnowledgeMarkdownChunker {

    private static final String RAG_SOURCE_ROOT = "/home/furina/Code/Face It/rag/";
    private static final String SECTION_FAQ = "高频问题";
    private static final String SECTION_ANSWER = "参考答案";
    private static final String SECTION_FOLLOW_UP = "延伸追问";
    private static final Set<String> HEADER_ONLY_SECTIONS = Set.of("适用知识库", "建议文件名", "主题标签", "检索关键词");
    private static final Pattern QUESTION_NO_PATTERN = Pattern.compile("问题\\s*(\\d+)");
    private static final Pattern H1_PATTERN = Pattern.compile("(?m)^#\\s+(.+)$");
    private static final Pattern H2_PATTERN = Pattern.compile("(?m)^##\\s+(.+)$");
    private static final Pattern H3_PATTERN = Pattern.compile("(?m)^###\\s+(.+)$");

    public boolean supports(KnowledgeDocumentDO documentDO, String text) {
        if (documentDO == null || StrUtil.isBlank(text)) {
            return false;
        }
        String sourceLocation = StrUtil.blankToDefault(documentDO.getSourceLocation(), "");
        String docName = StrUtil.blankToDefault(documentDO.getDocName(), "");
        return sourceLocation.startsWith(RAG_SOURCE_ROOT)
                && docName.toLowerCase(Locale.ROOT).endsWith(".md")
                && text.contains("## " + SECTION_FAQ);
    }

    public List<VectorChunk> chunk(KnowledgeDocumentDO documentDO, String kbName, String markdown) {
        String normalized = normalize(markdown);
        ParsedDocument parsed = parseDocument(normalized);
        List<VectorChunk> chunks = new ArrayList<>();

        for (Section section : parsed.sections()) {
            if (HEADER_ONLY_SECTIONS.contains(section.title())) {
                continue;
            }
            if (SECTION_FAQ.equals(section.title())) {
                chunks.addAll(buildQuestionChunks(parsed, kbName, section));
                continue;
            }
            if (SECTION_ANSWER.equals(section.title())) {
                chunks.addAll(buildAnswerChunks(parsed, kbName, section));
                continue;
            }
            if (SECTION_FOLLOW_UP.equals(section.title())) {
                addSectionChunk(chunks, parsed, kbName, section, "followup", null, null, null);
                continue;
            }
            addSectionChunk(chunks, parsed, kbName, section, "section", null, null, null);
        }

        if (chunks.isEmpty()) {
            chunks.add(buildChunk(
                    0,
                    parsed.title(),
                    kbName,
                    "section",
                    null,
                    null,
                    null,
                    "主题：" + parsed.title() + "\n\n" + normalized.strip(),
                    parsed.tags()
            ));
            return chunks;
        }

        for (int i = 0; i < chunks.size(); i++) {
            chunks.get(i).setIndex(i);
        }
        return chunks;
    }

    private List<VectorChunk> buildQuestionChunks(ParsedDocument parsed, String kbName, Section section) {
        List<VectorChunk> chunks = new ArrayList<>();
        for (Section questionSection : splitLevel3Sections(section.body())) {
            Integer questionNo = parseQuestionNo(questionSection.title());
            Map<String, String> details = extractQuestionDetails(questionSection.body());
            String prompt = firstNonBlankParagraph(removeDetailLines(questionSection.body()));
            StringBuilder content = new StringBuilder();
            content.append("主题：").append(parsed.title()).append("\n");
            content.append("问题");
            if (questionNo != null) {
                content.append(questionNo);
            }
            content.append("：").append(StrUtil.blankToDefault(prompt, questionSection.title())).append("\n");
            if (StrUtil.isNotBlank(details.get("difficulty"))) {
                content.append("难度：").append(details.get("difficulty")).append("\n");
            }
            if (StrUtil.isNotBlank(details.get("questionType"))) {
                content.append("类型：").append(details.get("questionType")).append("\n");
            }
            if (StrUtil.isNotBlank(questionSection.body())) {
                String explanation = removeDetailLines(questionSection.body()).strip();
                if (StrUtil.isNotBlank(explanation) && !explanation.equals(prompt)) {
                    content.append("\n").append(explanation);
                }
            }
            chunks.add(buildChunk(
                    chunks.size(),
                    parsed.title(),
                    kbName,
                    "question",
                    questionNo,
                    details.get("difficulty"),
                    details.get("questionType"),
                    content.toString().strip(),
                    parsed.tags()
            ));
        }
        return chunks;
    }

    private List<VectorChunk> buildAnswerChunks(ParsedDocument parsed, String kbName, Section section) {
        List<VectorChunk> chunks = new ArrayList<>();
        for (Section answerSection : splitLevel3Sections(section.body())) {
            Integer questionNo = parseQuestionNo(answerSection.title());
            String body = answerSection.body().strip();
            if (StrUtil.isBlank(body)) {
                continue;
            }
            StringBuilder content = new StringBuilder();
            content.append("主题：").append(parsed.title()).append("\n");
            if (questionNo != null) {
                content.append("问题").append(questionNo).append("参考答案：\n");
            } else {
                content.append(answerSection.title()).append("：\n");
            }
            content.append(body);
            chunks.add(buildChunk(
                    chunks.size(),
                    parsed.title(),
                    kbName,
                    "answer",
                    questionNo,
                    null,
                    null,
                    content.toString().strip(),
                    parsed.tags()
            ));
        }
        return chunks;
    }

    private void addSectionChunk(
            List<VectorChunk> chunks,
            ParsedDocument parsed,
            String kbName,
            Section section,
            String sectionType,
            Integer questionNo,
            String difficulty,
            String questionType
    ) {
        String body = section.body().strip();
        if (StrUtil.isBlank(body)) {
            return;
        }
        StringBuilder content = new StringBuilder();
        content.append("主题：").append(parsed.title()).append("\n");
        content.append(section.title()).append("：\n");
        content.append(body);
        chunks.add(buildChunk(
                chunks.size(),
                parsed.title(),
                kbName,
                sectionType,
                questionNo,
                difficulty,
                questionType,
                content.toString().strip(),
                parsed.tags()
        ));
    }

    private VectorChunk buildChunk(
            int index,
            String docTitle,
            String kbName,
            String sectionType,
            Integer questionNo,
            String difficulty,
            String questionType,
            String content,
            List<String> tags
    ) {
        Map<String, Object> metadata = new LinkedHashMap<>();
        metadata.put("docTitle", docTitle);
        metadata.put("kbName", kbName);
        metadata.put("sectionType", sectionType);
        if (questionNo != null) {
            metadata.put("questionNo", questionNo);
        }
        if (StrUtil.isNotBlank(difficulty)) {
            metadata.put("difficulty", difficulty);
        }
        if (StrUtil.isNotBlank(questionType)) {
            metadata.put("questionType", questionType);
        }
        if (tags != null && !tags.isEmpty()) {
            metadata.put("tags", tags);
        }
        return VectorChunk.builder()
                .chunkId(IdUtil.getSnowflakeNextIdStr())
                .index(index)
                .content(content)
                .metadata(metadata)
                .build();
    }

    private ParsedDocument parseDocument(String markdown) {
        Matcher titleMatcher = H1_PATTERN.matcher(markdown);
        String title = titleMatcher.find() ? titleMatcher.group(1).trim() : "未命名主题";
        List<Section> sections = splitLevel2Sections(markdown);
        List<String> tags = extractTags(sections);
        return new ParsedDocument(title, tags, sections);
    }

    private List<Section> splitLevel2Sections(String markdown) {
        List<Section> sections = new ArrayList<>();
        Matcher matcher = H2_PATTERN.matcher(markdown);
        List<HeadingPos> headings = new ArrayList<>();
        while (matcher.find()) {
            headings.add(new HeadingPos(matcher.start(), matcher.end(), matcher.group(1).trim()));
        }
        for (int i = 0; i < headings.size(); i++) {
            HeadingPos current = headings.get(i);
            int sectionEnd = i + 1 < headings.size() ? headings.get(i + 1).start() : markdown.length();
            String body = markdown.substring(current.contentStart(), sectionEnd).strip();
            sections.add(new Section(current.title(), body));
        }
        return sections;
    }

    private List<Section> splitLevel3Sections(String markdown) {
        List<Section> sections = new ArrayList<>();
        Matcher matcher = H3_PATTERN.matcher(markdown);
        List<HeadingPos> headings = new ArrayList<>();
        while (matcher.find()) {
            headings.add(new HeadingPos(matcher.start(), matcher.end(), matcher.group(1).trim()));
        }
        if (headings.isEmpty()) {
            return sections;
        }
        for (int i = 0; i < headings.size(); i++) {
            HeadingPos current = headings.get(i);
            int sectionEnd = i + 1 < headings.size() ? headings.get(i + 1).start() : markdown.length();
            String body = markdown.substring(current.contentStart(), sectionEnd).strip();
            sections.add(new Section(current.title(), body));
        }
        return sections;
    }

    private List<String> extractTags(List<Section> sections) {
        for (Section section : sections) {
            if ("主题标签".equals(section.title())) {
                return splitTags(section.body());
            }
        }
        return List.of();
    }

    private List<String> splitTags(String value) {
        if (StrUtil.isBlank(value)) {
            return List.of();
        }
        Set<String> tags = new LinkedHashSet<>();
        for (String item : value.split("[、,，\\n]")) {
            String normalized = item.trim();
            if (StrUtil.isNotBlank(normalized)) {
                tags.add(normalized);
            }
        }
        return List.copyOf(tags);
    }

    private Map<String, String> extractQuestionDetails(String body) {
        Map<String, String> details = new LinkedHashMap<>();
        details.put("difficulty", extractDetail(body, "难度"));
        details.put("questionType", extractDetail(body, "类型"));
        return details;
    }

    private String extractDetail(String body, String label) {
        String pattern = "(?ms)^####\\s*" + Pattern.quote(label) + "\\s*$\\s*(.+?)(?=^####\\s+|\\z)";
        Matcher matcher = Pattern.compile(pattern).matcher(body);
        if (matcher.find()) {
            return matcher.group(1).strip();
        }
        return "";
    }

    private String removeDetailLines(String body) {
        return body
                .replaceAll("(?ms)^####\\s*难度\\s*$\\s*.+?(?=^####\\s+|\\z)", "")
                .replaceAll("(?ms)^####\\s*类型\\s*$\\s*.+?(?=^####\\s+|\\z)", "")
                .replaceAll("(?m)^###\\s+问题\\s*\\d+\\s*$", "")
                .replaceAll("(?m)^###\\s+.*$", "")
                .strip();
    }

    private String firstNonBlankParagraph(String body) {
        if (StrUtil.isBlank(body)) {
            return "";
        }
        for (String block : body.split("\\n\\s*\\n")) {
            String normalized = block.strip();
            if (StrUtil.isNotBlank(normalized)) {
                return normalized.replace('\n', ' ').replaceAll("\\s+", " ").trim();
            }
        }
        return body.replace('\n', ' ').replaceAll("\\s+", " ").trim();
    }

    private Integer parseQuestionNo(String title) {
        if (StrUtil.isBlank(title)) {
            return null;
        }
        Matcher matcher = QUESTION_NO_PATTERN.matcher(title);
        if (matcher.find()) {
            return Integer.parseInt(matcher.group(1));
        }
        return null;
    }

    private String normalize(String markdown) {
        return StrUtil.blankToDefault(markdown, "")
                .replace("\r\n", "\n")
                .replace('\r', '\n')
                .trim();
    }

    private record ParsedDocument(String title, List<String> tags, List<Section> sections) {
    }

    private record Section(String title, String body) {
    }

    private record HeadingPos(int start, int contentStart, String title) {
    }
}
