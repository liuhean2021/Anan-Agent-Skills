#!/usr/bin/env bash
# validate-design-md.sh —— DESIGN.md 附录 B ↔ tokens.css 令牌一致性校验
# 依据《AI 时代的统一设计系统》指南「防漂移闭环」章节。
#
# 用法：
#   bash validate-design-md.sh <DESIGN.md路径> <tokens.css路径> [附录B标题] [附录C标题]
#   例：bash validate-design-md.sh ./DESIGN.md ./src/styles/tokens.css
#   区段标题默认 "## 附录 B" / "## 附录 C"，与目标文档实际标题不一致时用第 3/4 参数覆盖。
#
# 退出码：0 = 一致；1 = 用法错误或存在差异（差异清单打印到 stdout）。

set -u

DESIGN_MD="${1:-}"
TOKENS_CSS="${2:-}"
SEC_B="${3:-## 附录 B}"
SEC_C="${4:-## 附录 C}"

if [ -z "$DESIGN_MD" ] || [ -z "$TOKENS_CSS" ]; then
  echo "用法: bash validate-design-md.sh <DESIGN.md路径> <tokens.css路径> [附录B标题] [附录C标题]" >&2
  exit 1
fi
if [ ! -f "$DESIGN_MD" ]; then
  echo "错误: 找不到 $DESIGN_MD" >&2
  exit 1
fi
if [ ! -f "$TOKENS_CSS" ]; then
  echo "错误: 找不到 $TOKENS_CSS" >&2
  exit 1
fi

TMP_MD="$(mktemp)"
TMP_CSS="$(mktemp)"
trap 'rm -f "$TMP_MD" "$TMP_CSS"' EXIT

# 1. 提取 DESIGN.md 附录 B 区段内的全部 --token 名（限定区段，避免误抓正文示例）；
#    先过滤 Markdown 表格分隔行（如 |------|------|，纯 -/:/|/空格），避免连续破折号误判为令牌
tok_re='--[A-Za-z0-9-]*[A-Za-z0-9][A-Za-z0-9-]*'
awk -v b="$SEC_B" -v c="$SEC_C" 'index($0,b)==1{f=1;next} index($0,c)==1{f=0} f' "$DESIGN_MD" \
  | grep -Ev '^[[:space:]]*\|?[-:| ]+\|?[[:space:]]*$' \
  | grep -oE -- "$tok_re" | sort -u > "$TMP_MD"

# 2. 提取 tokens.css 中实际定义的 --token 名（剥行尾冒号）；
#    🔵 计划中的令牌行以 "/* TODO(决策)" 注释标记，按防漂移规则豁免校验
grep -v 'TODO(决策)' "$TOKENS_CSS" \
  | grep -oE -- "$tok_re[[:space:]]*:" \
  | sed 's/[[:space:]]*:$//' | sort -u > "$TMP_CSS"

if [ ! -s "$TMP_MD" ]; then
  echo "警告: $DESIGN_MD 的「$SEC_B」区段未提取到任何令牌，请确认区段标题参数是否正确" >&2
  exit 1
fi

if diff -u "$TMP_MD" "$TMP_CSS"; then
  echo "✅ 通过：DESIGN.md 附录 B 与 $TOKENS_CSS 令牌一致（$(wc -l < "$TMP_MD" | tr -d ' ') 个）"
  exit 0
else
  echo "" >&2
  echo "❌ 不一致：以 - 开头的仅存在于 DESIGN.md，以 + 开头的仅存在于 tokens.css" >&2
  echo "   修复原则：令牌以 tokens.css 为准；若属新增令牌，须先补 DESIGN.md 附录 B 映射" >&2
  exit 1
fi
