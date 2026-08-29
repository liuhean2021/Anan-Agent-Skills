# DESIGN.md MVP 起步模板（200 行版）

> 摘自《AI 时代的统一设计系统》指南「MVP 模板」章节。从零起步时直接复制本文件内容为项目 DESIGN.md 并填空；占位符处理、合并层规则见 `guide.md` 模块 5 与 Step 3。

```markdown
---
name: [项目] Design System
description: Agent 契约
audience: agent
version: 0.1.0
framework: vue@3
componentLibrary: element-plus@2.4.4
package: "@[org]/ui"
updated: 2026-08-25
status: Draft
---

# [项目] 设计系统 SSOT

## 顶层原则

| 层级 | 是什么 | Agent 含义 |
|------|--------|------------|
| L0 设计 SSOT | 本文件 | 选型、令牌、布局（核心，不依赖任何库） |
| L1 组件库（可选） | @[org]/ui | 有则优先使用，生成质量更佳 |
| L2 框架原语 | Element Plus 2.4.4 | 无组件库时的基础控件来源 |
| 禁止层 | 第三库/硬编码 | 任何角色禁止 |

**组件选型决策规则**：
1. 查附录 A 有封装组件 → 优先使用；禁止同款原语替代
2. 无组件库 → 框架原语 + 附录 B 令牌约束视觉
3. 全无 → 最小 DOM + 附录 B 令牌；禁止第三库

## 页面模板

### A. 标准列表页
筛选表单 → 操作栏 → 数据表格

### B. 弹窗表单
Dialog + Input/Select/Switch

### C. 详情页
标题 + Tag/Avatar/Steps

### D. 结果反馈
Result / Toast / Alert

## 附录 A 组件注册表

| 导出名 | 基于 | 状态 |
|--------|------|------|
| YourButton | el-button | ✅ |
| YourDialog | el-dialog | ✅ |
| YourTable | el-table | ✅ |
| YourInput | el-input | ✅ |
| YourTag | el-tag | ✅ |
| YourModalForm | 自定义 | ❌ 未实现 → Dialog+字段 |

## 附录 B 令牌（合并层起步形态，待拆层）

### B.1 颜色
| CSS 变量 | 值 |
|---|---|
| `--colors-brand-primary` | #主品牌色 |
| `--colors-brand-hover` | #悬停色 |
| `--colors-brand-active` | #激活色 |
| `--colors-text-primary` | #标题色 |
| `--colors-text-regular` | rgba(正文色) |
| `--colors-bg-page` | #页面底色 |
| `--colors-bg-white` | #白色 |
| `--colors-success` | #成功色 |
| `--colors-warning` | #警告色 |
| `--colors-danger` | #危险色 |

### B.2 间距
| CSS 变量 | 值 |
|---|---|
| `--spacing-xs` | 4px |
| `--spacing-sm` | 8px |
| `--spacing-base` | 12px |
| `--spacing-lg` | 16px |
| `--spacing-xl` | 24px |
| `--spacing-2xl` | 32px |

### B.3 圆角
| CSS 变量 | 值 |
|---|---|
| `--radius-small` | 2px |
| `--radius-base` | 4px |
| `--radius-large` | 8px |
| `--radius-full` | 9999px |

### B.4 字号
| CSS 变量 | 值 |
|---|---|
| `--size-xs` | 12px |
| `--size-sm` | 13px |
| `--size-base` | 14px |
| `--size-lg` | 16px |
| `--size-xl` | 18px |

## 组件-令牌映射（核心 3–5 个组件）

### YourButton
| 令牌 | 默认态 | Hover | Active | Disabled |
|------|--------|-------|--------|----------|
| colors.brand-primary | 背景+边框 | — | — | — |
| colors.brand-hover | — | 背景+边框 | — | — |
| colors.brand-active | — | — | 背景+边框 | — |
| colors.text-on-dark | 文字 | — | — | — |

### YourDialog
| 令牌 | 默认态 |
|------|--------|
| colors.border-light | header 分割线 |
| colors.text-primary | 标题文字 |
| colors.text-regular | 内容文字 |
| radius.radius-base | 弹窗圆角 4px |
| typography.size-lg + typography.weight-medium | 标题 16px/500 |

## 已知偏差

| 项 | 设计稿 | 当前 | 状态 |
|----|--------|------|------|
| Input 圆角 | 4px | 2px | 待对齐 |

## Open questions

- [ ] Input 圆角对齐排期
- [ ] YourModalForm 导出排期
```

