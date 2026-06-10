# §13 验证铁律 + 阶段顺序纪律（Verification Gate & Phase Discipline）

> 适用：使用 `ai-coding-workflow` 技能时的横切纪律层；Superpowers 插件为必装配套，但本文件规则内联生效，不依赖插件是否加载成功。

---

## Section 13.1 适用范围

| 条件 | 是否适用本文件 |
|------|---------------|
| 本次任务按 **ai-coding-workflow** 推进 | **MUST** 遵守 |
| 未使用 ai-coding-workflow（闲聊、查资料、其他独立技能） | 不适用 |
| 使用哪个 Agent / IDE | **无关** |

Superpowers 插件 MUST 已安装（见 `ref-02-tool-stack.md § 10.5` 与 `§ 10.6.B`）。未安装时 MUST NOT 进入 Phase 6 及之后；可先走场景 E 完成安装。

---

## Section 13.2 阶段顺序铁律（Phase Sequence）

工作流 Phase 按 `ref-03-full-workflow.md` 文档书写顺序推进：`Phase 0 → 1 → 2 → … → 10`，或经场景路由进入 `Phase 5B`。

**规则**：

1. 收到开发任务后，MUST 先场景识别（`SKILL.md` § 场景识别），确定**起始 Phase**。
2. 当前 Phase 的**退出条件**未全部满足前，MUST NOT 进入下一 Phase。
3. MUST NOT 在无对应产出物的情况下跳阶段（例如无 `spec.md` 进入 Phase 6）。
4. **唯一允许的捷径**来自 workflow 已有定义：Phase 5B（bug fix）、场景 C1/C2、场景 G（UI 快车道）等；MUST NOT 自创新捷径。
5. 用户要求「直接写代码」时，IF 仍走 ai-coding-workflow，THEN Agent MUST 说明缺失的前序 Phase/产出物，并按最小必要 Phase 补齐或明确记录已满足的跳过依据。

---

## Section 13.3 验证铁律（Iron Law）

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
（无 fresh 验证证据，禁止任何完成类宣称）
```

**核心原则**：Evidence before claims, always.

若在本消息内**未**执行并读取验证命令的**完整输出**，则禁止做出成功/完成类结论。

### 13.3.1 禁止表述（含同义改写）

在未附 fresh 证据时，禁止包括但不限于：

- 完成、已通过、修好了、没问题、应该可以了
- 测试绿、lint 过、构建成功（若未在本消息内跑过对应命令）
- 可以提交、可以合并、可以发布
- 「Great!」「Done!」「Perfect!」等暗示成功的满意表述

### 13.3.2 Gate Function（5 步，不可跳过）

```
BEFORE 任何 success/completion 宣称：

1. IDENTIFY — 什么命令能证明这个结论？（见 § 13.4 或项目 AGENTS.md 验证命令）
2. RUN     — 在本消息内完整执行该命令（非上次结果、非猜测）
3. READ    — 读取完整输出，检查 exit code，统计失败数
4. VERIFY  — 输出是否支持结论？
             - 否 → 如实报告实际状态并附证据
             - 是 → 再做出结论，并附证据摘要或关键输出
5. ONLY THEN — 才可宣称 pass / 完成 / 修好了
```

跳过任一步 = 未验证，等同于违规。

### 13.3.3 常见失败模式

| 宣称 | 必须 | 不足 |
|------|------|------|
| 测试通过 | 测试命令输出，0 failures | 上次运行结果、「应该过」 |
| Lint 干净 | linter 输出，0 errors | 只改了代码未跑 lint |
| 构建成功 | build 命令 exit 0 | lint 过 ≠ 编译过 |
| Bug 已修 | 复现测试 + 修复后测试 | 只改代码未跑测试 |
| Phase N 完成 | 该 Phase 产出物已写入 + 退出条件满足 | 口头说「做完了」 |

---

## Section 13.4 各 Phase 纪律层（横切 Gate）

以下补充 `ref-03` 各 Phase **退出条件**，不替代原有定义。

| Phase | 纪律层（退出前额外要求） |
|-------|-------------------------|
| **0** | Superpowers 必装检查 PASS（`§ 10.6.B`） |
| **1** | `ceo-review.md` 已写入；禁止无文件宣称「方向定了」 |
| **2** | `spec.md` 已锁定；禁止无 spec 进入 Phase 3+ |
| **3** | `plan.md` 等产出物就绪；禁止无方案进入 Phase 4+ |
| **4** | `tasks.md` 就绪；禁止无任务列表进入 Phase 5/6 |
| **5** | 失败测试已提交（红灯）；禁止无测试基线进入 Phase 6 |
| **5B** | 步骤「确认测试通过」MUST 走 Gate Function（§ 13.3.2） |
| **6** | 退出前 MUST freshly run 项目验证命令（测试/lint/build 等，见 AGENTS.md）；禁止无输出宣称「实施完成」 |
| **7** | `review-findings.md` 已处理；禁止无审查记录宣称「审过了」 |
| **8** | 正式 QA 完成；Iron Law 仍适用于 Phase 8 内的每条验收结论 |
| **9** | 合并/PR 前 MUST 再跑全量验证；禁止无证据宣称「可发布」 |
| **10** | 复盘产出已写入；禁止无 `/retro` 或等价产物宣称「已复盘」 |

---

## Section 13.5 与 Superpowers 插件的关系

| 层面 | 说明 |
|------|------|
| **必装** | 使用 ai-coding-workflow 时 MUST 安装 Superpowers（与 Agent 无关） |
| **内联规则** | 本文件（§ 13）为 workflow 自有铁律，**不依赖**插件会话 Hook |
| **插件技能** | 已安装时 MAY 调用 `verification-before-completion`、`systematic-debugging`、`test-driven-development` 等加深执行；**不形成第二条 workflow** |
| **与 gstack** | gstack 未装可降级；Superpowers 未装 **不可降级**（阻断 Phase 6+） |

---

## Section 13.6 无 gstack 时的最低验证命令

gstack 不可用时，Phase 6/8/9 的 Gate Function 仍 MUST 执行。最低集合由项目 `AGENTS.md` 定义；若无定义，代理 SHOULD 按技术栈选用：

| 项目类型 | 建议命令（示例） |
|---------|-----------------|
| Node 前端 | `npm run lint`、`npm run build`、项目测试脚本（如有） |
| 有 E2E | 上述 + `npx playwright test`（或项目等价命令） |
| 无自动化测试 | lint + build + 对照 `spec.md`/checklist **手测清单**（手测结论仍须具体，禁止「手测过了」无条目） |

手测清单 MUST 逐条列出已验证项，不可省略为一句「功能正常」。
