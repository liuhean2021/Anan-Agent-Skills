# §2 工具体系总览 + §10 各工具详细说明 + §11 参考来源

> 适用：工具选型、安装升级、命令速查

---

## Section 2：工具体系总览（Tool Stack）

AI Coding Workflow 以 `Phase 0~10 / 5B` 为主线推进。以下工具与角色是**阶段内介入能力**，用于帮助代理完成同一条工作流，而不是多条彼此分离的流程。

### 2.1 工作流组成能力

| 层级 | 工具 | 职责 |
|------|------|------|
| **纪律层** | **Superpowers** | 使用 ai-coding-workflow 时**必装**；阶段顺序、完成必验证、TDD/调试纪律（横切全 Phase；见 `ref-09-verification-gate.md`） |
| 基础环境层 | 各 Agent 原生 hooks | 自动化质量卡口、事件触发命令或 prompt/agent/http/mcp_tool handler |
| 上下文层 | AGENTS.md + CLAUDE.md + memory/ | 项目记忆、AI 角色定义、架构决策 |
| 文档层 | Context7 MCP | 自动查验最新库文档；无 MCP 时降级为提示词、library ID 或官方文档 |
| 需求层 | spec-kit | 规格驱动开发，需求 → 规格 → 计划 → 任务 |
| 外部代理层 | oh-my-claudecode | 调用 Codex / Gemini / 外部 CLI worker 并行实现或复核 |
| 验证层 | gstack + 单元测试 | UI 验证 + 业务逻辑覆盖（未安装可降级） |
| 沉淀层 | ADR + Checkpoint commit | 架构决策记录，知识不流失 |

### 2.2 AI 代理与模型选择

```
主力：Claude Code CLI
  模型与推理档位遵循当前 CLI / 仓库默认配置，MUST NOT 在工作流文档中硬编码固定模型分工

辅助：Codex CLI、Gemini CLI、Cursor（次选）
规则：单一模型优先；超限时保持代理不变，临时替换模型补充
```

### 2.3 OMC 接入原则

- `oh-my-claudecode` SHOULD 作为 Claude Code 的外部代理编排层，而不是替代主代理；在其他宿主中，文档内同类命令表示“外部代理编排能力”，可用宿主等价入口替代
- 代码实现阶段，IF 任务可拆成彼此独立的子任务，THEN MAY 用 `/team` 或 `omc team ...` 并行调用 Codex / Gemini
- 代码审查阶段，IF 需要交叉验证架构、安全、可读性或 UX 风险，THEN SHOULD 追加 `/ccg`、`/ask <model>` 或 `omc ask <model> ...`
- OMC 外部 agent 输出 MUST 视为"辅助结论"，最终是否采纳 MUST 由当前 Claude Code 主代理结合测试、审查结果和人工判断统一裁决
- 外部 agent 只应接收完成任务所需的最小上下文；敏感信息边界仍受 Section 3：AI 治理（ref-04）约束

### 2.4 上游依据与映射原则

本技能应优先参考上游官方文档与官方仓库，按阶段映射到本地工作流；尽量少在技能中写死易随版本变化的固定细节。

| 上游来源 | 在本工作流中的用途 |
|------|------|
| `spec-kit` 官方文档 / 官方仓库 | 校准 Phase 0 / 2 / 3 / 4 / 5 / 6 的规格链路顺序、核心命令与产物定义 |
| `gstack` 官方站 / 官方仓库 | 校准 Phase 1 / 3 / 7 / 8 / 9 / 10 的评审、QA、发布、复盘类职责边界 |
| Superpowers 官方仓库 | 校准纪律层技能（验证铁律、TDD、系统调试）与 ai-coding-workflow 的组合方式；**不替代**本 workflow 的 Phase 定义 |
| 其他工具官方文档 / 官方仓库 | 校准外部代理编排、Context7 MCP、`gitleaks` 等阶段辅助能力的真实用法 |

**规则**：
- 当本技能与上游工具当前行为存在冲突或歧义时，SHOULD 先复核上游官方文档，再回写本技能
- 本技能负责定义“阶段与工具如何组合”，不负责替代上游文档去冻结所有版本细节
- 若任务依赖新版本库、陌生 SDK、或近期变化的工具行为，MUST 优先查官方文档，而不是只依赖技能内静态描述

---

## Section 10：各工具详细说明（Tool Reference）

### 10.1 spec-kit

```bash
# 安装（持久化，推荐）— 锁定最新 release tag（替换 vX.Y.Z 为实际版本号）
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z

# 或安装 main 分支最新（可能包含未发布变更，不推荐生产）
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 升级 — 同样锁定版本 tag
uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git@vX.Y.Z

# 一次性使用（无需安装）
uvx --from git+https://github.com/github/spec-kit.git@vX.Y.Z specify init . --integration <agent-key>

# 项目初始化（一次性）
specify init . --integration <agent-key>                          # 在当前目录初始化
specify init --here --integration <agent-key>                     # 等价写法
specify init . --integration <agent-key> --force                  # 强制合并，跳过确认
specify init . --integration codex --integration-options="--skills"  # Codex CLI 常用写法：同时安装 agent skills
specify init . --integration <agent-key> --branch-numbering timestamp  # 时间戳分支编号（分布式团队推荐，避免编号冲突）
specify check                                       # 验证工具是否就绪
specify version                                     # 显示版本与系统信息
specify version --features                          # 显示本地 CLI 功能标记
specify version --features --json                   # 以 JSON 格式输出功能标记（CI/脚本用）
specify self check                                  # 检查 CLI 是否为最新版
specify self upgrade                                # 自动升级 CLI 到最新版

# 核心命令（使用顺序）
/speckit.constitution            # 项目原则（一次性）
/speckit.specify "功能描述"      # PRD + 用户故事（生成初稿；重复执行会覆盖 spec.md，仅在推倒重来时使用）
/speckit.clarify                 # 澄清模糊点，追加写入 spec.md；可多次执行直到规格无歧义（plan 前 MUST 执行）
/speckit.checklist               # 需求质量 checklist（plan 前执行，检查需求完整性/清晰度/一致性，不是代码验收）
/speckit.plan "技术栈"           # 技术方案
/speckit.tasks                   # 任务拆解
/speckit.taskstoissues           # 将 tasks.md 转为 GitHub Issues（可选，在 tasks 后、implement 前执行）
/speckit.analyze                 # 跨文档一致性分析（tasks 后、implement 前运行）
/speckit.implement               # 执行实现

# Codex CLI 语法（skills integration 模式，与 /speckit.* 等价）
$speckit-constitution / $speckit-specify / $speckit-clarify / $speckit-checklist / $speckit-plan / $speckit-tasks / $speckit-taskstoissues / $speckit-analyze / $speckit-implement

# Extensions：扩展新能力（Jira/Linear/Azure DevOps/代码审查等）
specify extension list               # 列出已安装扩展
specify extension add <name>         # 安装扩展（写入 .claude/commands/；支持 --from URL、--dev 本地目录、--priority）
specify extension remove <name>      # 卸载扩展（--keep-config 保留配置、--force 跳过确认）
specify extension search [query]     # 搜索可用扩展（--tag、--author、--verified 过滤）
specify extension info <name>        # 查看扩展详情
specify extension catalog list       # 列出已配置的扩展目录
specify extension catalog add <url>  # 添加扩展目录（--name、--priority、--install-allowed）
specify extension catalog remove <name>  # 移除扩展目录

# Presets：自定义模板格式（规范化 spec/plan/tasks 输出风格）
specify preset list                  # 列出已安装预设
specify preset add <name>            # 安装预设（--from URL、--dev 本地目录、--priority）
specify preset remove <name>         # 卸载预设
specify preset search [query]        # 搜索可用预设（--tag、--author 过滤）
specify preset info <name>           # 查看预设详情
specify preset enable <name>         # 启用预设
specify preset disable <name>        # 禁用预设（保留安装，暂时停用）
specify preset set-priority <id> <n> # 设置预设优先级（数字越小优先级越高）
specify preset resolve <template>    # 查看某个模板在解析栈中的来源（调试用）
specify preset catalog list          # 列出已配置的预设目录
specify preset catalog add <url>     # 添加预设目录（--name、--priority、--install-allowed）
specify preset catalog remove <name> # 移除预设目录
```

> **Extensions vs Presets**：Extensions 增加新命令（集成外部工具），Presets 覆盖现有模板格式（定制输出风格）。两者可叠加，优先级：project overrides > presets > extensions > core。扩展和预设均支持通过目录（catalog）发现和安装，目录配置分别存储在 `.specify/extension-catalogs.yml` 和 `.specify/preset-catalogs.yml`。

### 10.2 gstack

```bash
# 初始安装（Claude Code；需先安装 Claude Code、Git、Bun）
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup

# 初始安装（Codex CLI / 宿主等价路径；需先安装 Git、Bun）
git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.codex/skills/gstack && cd ~/.codex/skills/gstack && ./setup

# 升级
/gstack-upgrade                  # 自动检测安装方式并升级到最新版本

# 产品方向
/office-hours                    # 方向模糊/问题定义不清时先做产品梳理
/plan-ceo-review                 # 产品方向评审（寻找最优版本）
/plan-eng-review                 # 架构深度评审（图表、边界、失败模式）

# 开发 & 审查
/review                          # 代码审查（生产级 bug）
/browse                          # 持久化浏览器会话，用于页面操作、截图与交互验证

# 浏览器 & 测试
/setup-browser-cookies           # 导入本机浏览器 cookies，测试登录后页面
/qa                              # feature branch 默认走 diff-aware；最常用

# 发布 & 复盘
/qa --quick                      # 30 秒冒烟测试（staging 验证用）
/qa --regression <baseline>      # 对比基线回归测试
/ship                            # 发布
/retro                           # 周复盘
```

> spec-kit 升级分两层：先升级 CLI，再在项目内执行 `specify init --here --force --integration <agent-key>` 刷新 commands/templates/scripts。Codex skills 模式使用 `--integration codex --integration-options="--skills"`。

### 10.3 其他工具

| 工具 | 用法 |
|------|------|
| Context7 | 优先使用 Context7 MCP 自动文档查验；无 MCP 时降级为提示词末尾加 `use context7`、指定库 ID（如 `use library /vercel/next.js`）或查官方文档 |
| Context7 MCP | 手动配置时使用 `https://mcp.context7.com/mcp`，API key 推荐通过 `CONTEXT7_API_KEY` header 提供 |
| Claude Code hooks | 用户级 `~/.claude/settings.json`、项目级 `.claude/settings.json`、本地 `.claude/settings.local.json`；handler 可为 `command`、`prompt`、`agent`、`http`、`mcp_tool` |
| AGENTS.md | 项目根目录，定义规范 + 禁止事项 + 验证命令 |

### 10.4 oh-my-claudecode（OMC）

```bash
# 升级
npm i -g oh-my-claude-sisyphus@latest  # npm 发布包名；项目品牌名为 oh-my-claudecode（两者指同一项目，npm 注册名不同）
omc update                             # 检查并安装更新
omc update --check                     # 仅检查更新，不安装
omc setup                              # 安装/刷新 hooks、agents、skills 等配置
/setup 或 /omc-setup                   # Claude Code 会话内 setup 入口

# 使用命令
omc ask codex "review this patch for security and correctness"
omc team 2:codex "review auth flow"
omc team 1:codex,1:gemini "compare approaches"
/ask codex "review this patch for security and correctness"
/ccg "Codex 看架构与安全，Gemini 看可读性与交互"
/team 3:executor "implement tasks T1,T2 with clear ownership"
/omc-teams 2:codex "analyze backend risks and propose fixes"
```

**规则：**
- 实现阶段优先用 `/team` 做 Claude Code 会话内团队编排；明确要启动 tmux CLI worker 时用 `omc team ...`
- `/omc-teams` 是兼容入口，当前应理解为路由到 CLI-first `omc team ...` runtime
- 审查阶段优先用 `ask` / `ccg` 做交叉复核
- 只有在任务可拆分、上下文边界清楚时才启用并行；否则单代理更稳
- OMC 适合作为 Claude Code 的增强层，不替代 `spec-kit` 或 `gstack`

### 10.4A 宿主 CLI 安装与 CC Switch

`Claude Code`、`Codex CLI`、`Gemini CLI` 的安装步骤，以及 `CC Switch` 的 provider / model 切换说明，统一见 `ref-08-host-installation-and-cc-switch.md`。

### 10.5 Superpowers（纪律插件，使用 ai-coding-workflow 时必装）

**绑定对象**：**ai-coding-workflow 技能** — 与使用哪个 Agent / IDE **无关**。  
**未安装时**：MUST NOT 进入 Phase 6 及之后（可先走场景 E 安装）。**不可降级**（区别于 gstack）。

**职责**：横切纪律层 — 阶段顺序、完成必验证（Iron Law）、TDD/调试深化；**不替代** Phase 0~10 定义（详见 `ref-09-verification-gate.md`）。

#### 安装（文档书写顺序：Claude Code → Cursor → 其他）

**Claude Code**

```bash
# 在 Claude Code 中安装官方插件（推荐）
/add-plugin superpowers
```

无需关心具体路径 —— 验证是否已装直接检查斜杠命令即可（见 `§ 10.6.B`）。

**Cursor**

```bash
/add-plugin superpowers
```

**其他 Agent**

按该 Agent 的插件市场安装 Superpowers（或等价官方包）。若暂无官方插件，MUST 在 Phase 0 向用户说明并暂停 Phase 6+，直至安装完成。

#### 与 workflow Phase 的映射（插件已装时 MAY 调用）

| Superpowers 技能 | 对应 workflow 位置 | 说明 |
|-----------------|-------------------|------|
| `verification-before-completion` | 全 Phase（§ 13.3） | 规则已内联于 `ref-09`；插件作 reinforcement |
| `test-driven-development` | Phase 5 / 5B | 强化红绿循环 |
| `systematic-debugging` | Phase 5B | 先根因再改代码 |
| `brainstorming` | Phase 1~2 | 与 `/office-hours` 等并存，不替代 spec 链路 |
| `requesting-code-review` | Phase 7 | gstack `/review` 优先；插件作补充 |
| `receiving-code-review` | Phase 7 修复轮次 | 不盲改 review 意见 |
| `finishing-a-development-branch` | Phase 9 前 | 合并/PR 决策树 |

> Superpowers **不同步**到 `~/.agents/skills/` 中心仓库；见 `sync-agents-npx-skills/references/agent-paths.md` 第三技能源。

### 10.6 工具检查清单

#### 10.6.A 能力工具（4 件套，按需检查，可降级）

进入**场景 E**、工具维护场景，或用户明确要求时，代理 SHOULD 检查以下 4 个能力工具。默认不在每次会话开始时自动升级。

| 工具 | 职责 | 未安装时 |
|------|------|---------|
| spec-kit | Phase 0~6 规格链路 | 手动 spec / 需安装 CLI |
| gstack | Phase 1/3/7~10 评审、QA、发布 | 人工审查、测试命令、CI |
| gitleaks | Secret 扫描 | 手动 / CI 替代 |
| oh-my-claudecode | 外部代理编排 | 单 Agent 执行 |

**gitleaks 安装 / 配置（摘录）**

```bash
brew install gitleaks       # 首次安装
brew upgrade gitleaks       # 升级

# pre-commit hook（项目根目录，示例）
gitleaks git --pre-commit --staged --no-banner
```

**gitleaks 规则**：密钥 MUST NOT 硬编码；`.env` MUST 在 `.gitignore`；CI MUST 二次扫描。

**建议版本检查脚本（可并行执行）：**

```bash
# gstack
~/.claude/skills/gstack/bin/gstack-update-check --force 2>/dev/null
~/.codex/skills/gstack/bin/gstack-update-check --force 2>/dev/null

# specify-cli
uv tool list 2>/dev/null | grep specify-cli
specify version 2>/dev/null
specify self check 2>/dev/null

# gitleaks
brew outdated gitleaks 2>/dev/null

# oh-my-claudecode
omc update --check 2>/dev/null
npm view oh-my-claude-sisyphus version 2>/dev/null
```

**升级命令（检测到更新时）：**

| 工具 | 升级命令 |
|------|---------|
| gstack | `/gstack-upgrade` |
| specify-cli | `uv tool install specify-cli --force --from git+https://github.com/github/spec-kit.git@vX.Y.Z` |
| gitleaks | `brew upgrade gitleaks` |
| oh-my-claudecode | `omc update` 或 `npm i -g oh-my-claude-sisyphus@latest` |

#### 10.6.B 纪律插件（Superpowers，使用 ai-coding-workflow 时 MUST，不可降级）

**检查时机**：Phase 0；每次确认按 ai-coding-workflow 推进新任务时。

**检查逻辑**：检测**当前 Agent 环境**下 Superpowers 的斜杠命令 `verification-before-completion` 是否可用（与 Agent 种类无关，只问「装没装」）。

```bash
# 验证 Superpowers 是否已装 —— 只看斜杠命令 verification-before-completion 能否被加载
# Claude Code: 运行 Skill 工具并检查报错
# Cursor / 其他 Agent: 按对应宿主方式尝试调用该斜杠命令
#
# 具体执行由代理在 Phase 0 完成，方式不限：
# - 在 Claude Code 中调用 Skill 工具以 verification-before-completion 为目标
# - 或检查宿主是否注册了该斜杠命令（如通过 /help 或技能列表）
#
# 要点：不关心文件放哪，只关心 `/verification-before-completion` 能不能用。
```

| 结果 | 动作 |
|------|------|
| PASS（斜杠命令存在） | 继续当前 Phase |
| FAIL（斜杠命令不可用） | 阻断 Phase 6+；提示安装 Superpowers（§ 10.5）；允许场景 E / Phase 0~5 中与安装相关的动作 |

> gstack 未装 → 降级。Superpowers 未装 → **阻断**，不得用「人工验证」代替纪律插件必装要求。

---

## Section 11：参考来源（References）

| 工具 / 主题 | 来源 |
|------|------|
| spec-kit 官方仓库 | https://github.com/github/spec-kit |
| spec-kit 官方 Quick Start | https://github.github.com/spec-kit/quickstart.html |
| gstack 官方站 | https://gstacks.org/ |
| gstack 官方仓库 | https://github.com/garrytan/gstack |
| Context7 | https://github.com/upstash/context7 |
| Context7 安装文档 | https://context7.com/docs/installation |
| hooks 配置 | https://code.claude.com/docs/en/hooks |
| oh-my-claudecode | https://github.com/Yeachan-Heo/oh-my-claudecode |
| gitleaks | https://github.com/gitleaks/gitleaks |
| Superpowers | https://github.com/obra/superpowers |
