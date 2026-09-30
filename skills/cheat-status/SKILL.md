---
name: cheat-status
description: cheat-on-content 的状态看板。显示当前模式 / rubric 版本 / 校准进度 / 待复盘 / pool 状态 / 是否该升级 SQLite / 是否该 bump rubric。**任何时候都可调，无副作用**。触发词："状态"/"看板"/"status"/"我现在该做什么"/"进度怎么样"。
allowed-tools: Bash(*), Read, Glob, Grep
---

# /cheat-status — 状态看板

读 state file + 扫描用户项目 → 汇总当前进度 → 输出"今天该做什么"清单。

## Codex-native operator mode

当 `content-operator` 内部读取本 skill 时，status 是**状态判断器**，不是要求用户学习的看板命令。

- `.cheat-state.json` 不存在 → 内部 silent bootstrap，然后继续用户原始目标；不要回复“先跑 init”。
- 保留下面所有派生指标和优先级判断，但把 `/cheat-*` 命令视为**内部路由提示**。
- 默认只把“当前最重要的 1–2 个结论”返回给 operator。
- 用户明确问“我现在进度怎么样 / 下一步做什么”时，用自然语言展示状态，并给一个下一步动作；不要附 copy-paste 命令。
- status 本身仍保持只读；如果需要执行 retro / bump / recommend，由 operator 在 status 返回后继续路由。

## Overview

```
[用户：状态]
  ↓
[Phase 1: 读 .cheat-state.json + 扫文件系统]
  ↓
[Phase 2: 计算派生指标]
  ↓
[Phase 3: 检测建议触发器（升级 / bump / 清算）]
  ↓
[Phase 4: 输出看板]
```

## Constants

- **SQLITE_UPGRADE_THRESHOLD = 30** — calibration_samples 达到 N 时建议升 SQLite
- **CLEANUP_LINE_THRESHOLD = 600** — rubric_notes.md 行数超 N 时建议清算
- **STALE_PREDICTION_DAYS = 30** — in_progress prediction 超 N 天未发布提示清理

## Inputs

| 来源 | 用途 |
|---|---|
| `.cheat-state.json` | 主要状态 |
| `predictions/*.md` | 校准样本数 / pending retros |
| `candidates.md` | 候选池规模 |
| `rubric_notes.md` | 行数 / 当前版本 |
| `.cheat-cache/usage.jsonl`（如有） | meta-logging 数据，用于"距上次 bump 多少次预测" |

## Workflow

### Phase 1: 读状态

```python
state = read_json('.cheat-state.json')
if not state:
    return "__NEEDS_SILENT_BOOTSTRAP__"  # operator 内部接管，不向用户展示

predictions = glob('predictions/*.md')
candidates_count = parse_candidates_md_entries()
rubric_lines = wc -l rubric_notes.md
```

### Phase 2: 派生指标

| 指标 | 算法 |
|---|---|
| **Buffer 数** | `len(state.shoots)` |
| **Buffer 颜色** | 按 [cadence-protocol.md](../../shared-references/cadence-protocol.md) 派生：`buffer_days = buffer_count × target_publish_cadence_days`，`<1 红 / 1-2 橙 / 3-5 绿 / >5 蓝`。如 `target_publish_cadence_days=null` → 颜色禁用 |
| **Confidence 等级** | 按 [state-management.md confidence 表](../../shared-references/state-management.md) 派生：从 `calibration_samples` 整数派生 emoji + 标签 |
| **最早一拍至今天数** | `now - state.shoots[0].shot_at`，用于警告"拍了 N 天没发" |
| 校准样本数 | predictions 中含完整复盘段（实绩数据非空）的文件数 |
| 待复盘 | state.pending_retros 中已过 RETRO_WINDOW_DAYS 的 |
| 池大小 | candidates.md 中 tier!=skip 的 entry 数 |
| 上次 bump 至今几次预测 | predictions 中 published_at > state.last_bump_at 的数量 |
| 同向偏差队列 | state.consecutive_directional_errors |
| in_progress 陈旧度 | now - state.in_progress_session.started_at（如有） |

### Phase 3: 检测建议触发器

按优先级（高→低）计算**内部 action signal**，不要把内部命令名当用户待办：

1. **Buffer = 红** → 用户语言："存货快没了，下一条优先做稳妥题，不推实验题。"
2. **Buffer = 蓝** → "已经有 N 条没发，先消化存货和复盘，不急着继续拍。"
3. **最早 shot > 14 天** → "有一条拍了 N 天还没发，时效可能在流失。"
4. **in_progress >= STALE_PREDICTION_DAYS** → operator 需要自然确认：已经发了、弃稿了、还是仍在制作。
5. **待复盘 ≥ 1** → 当前目标处理完后自然提醒，并准备自动路由 retro。
6. **pool 为空 + 无校准样本 + bootstrap >24h** → 可能卡在选题；下一次聊内容时优先从用户经历/观点切入。
7. **系统性偏差信号** → 内部评估 rubric bump：
   - 默认参考：连续 ≥3 次同向偏差；
   - 1 次 ≥10x 极端误差可更早；
   - 3 次但误差都 <25% 可更晚。
8. **confidence 跨档** → 可以简短通知，不要求用户确认。
9. **calibration_samples ≥5** → rubric 首次具备正式重校资格；由 operator 在证据成熟时自动评估。
10. **calibration_samples ≥10** → percentile bucket 可用；内部选择合适时机重校。
11. **calibration_samples ≥ SQLITE_UPGRADE_THRESHOLD 且 data_layer=markdown** → 工程维护建议，不抢占普通创作对话。
12. **rubric_notes > CLEANUP_LINE_THRESHOLD** → 下次内部 bump 时顺带清算。
13. **有足够样本但 pool 为空** → operator 可在用户问“下一条做什么”时自动构建/补充候选池。
14. **benchmark_status=pending** → 在自然涉及对标/选题时问一个具体账号，不要求用户记导入命令。
15. **rubric_form_mismatch=true** → 降低预测信心，并随着真实样本调整 rubric。
16. **last_bump_self_audited=true** → 下次 bump 有外部审核能力时优先走独立审核。

### Phase 4: 输出

**被 content-operator 内部调用时**：只返回结构化/紧凑的 1–2 个最高优先级 signal，不展开完整看板。

**用户明确问进度时**：用自然语言输出，例如：

```text
最近状态：
- 有 1 条已经到复盘时间，等你把后台数据/截图给我，我就能直接拆。
- 还有 2 条拍完没发，按现在节奏够几天，不急着继续囤。
- 最近三次都高估了“技术密度”的作用，我会在下一轮模型校准里处理。

现在最值得先做：把上一条的数据给我；复盘完我再结合结果给你下一条选题。
```

不要输出内部 skill 名、slash command、state JSON 或要求用户 copy-paste 命令。

## Key Rules

1. **无副作用**：status 自身只读；后续动作由 content-operator 路由给对应内部能力。
2. **不假装数据可用**：字段缺失就标 unknown，不猜。
3. **建议有优先级**：默认只 surfaced 最重要的 1–2 件事。
4. **用户语言优先**：告诉用户“现在发生了什么、需要他补什么”，不是“该运行什么”。
5. **普通用户不需要看健康度细节**：rubric 行数、hook 元数据、schema 等只在异常或 debug 请求时展示。

## Refusals

- status 自己不写数据；如果用户说“那就顺手复盘”，由 content-operator 在 status 返回后立即路由 retro，而不是让用户重新发一次命令。
- 用户明确说不想看工程健康度时，不强塞；只有它会影响当前结果时才解释。

## Integration

- 上游：所有内部 skill 完成时更新 .cheat-state.json。
- 下游：content-operator 根据 action signal 自动选择 retro / recommend / trends / bump 等内部能力。
- SessionStart 使用相同派生逻辑给新会话恢复最小必要上下文。
