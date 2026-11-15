// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

/// [choice]：给选项选择
/// [input]：手动输入答案
enum AnswerMode { choice, input }

/// [original]：原版，根据 Map 的 emoji 猜书名
/// [random]：加强版，将书名过一遍[CfbbLangTranslator]之后让用户猜
enum ClueMode { original, random }
