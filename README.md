<h1 align="center">
  <img src="docs/logo.svg" alt="Cheat on Content" width="720">
</h1>

<h2 align="center">Cheat on Content</h2>

<p align="center">
  <strong>English</strong>
  &nbsp;·&nbsp;
  <a href="docs/README_CN.md"><strong>简体中文</strong></a>
</p>

<p align="center">
  <a href="https://watcha.cn/products/cheat-on-content">
    <img src="docs/guancha-no1.svg" alt="Watcha Hot List · 观猹热榜 · #1" width="328">
  </a>
</p>

<p align="center">
<a href="CHANGELOG.md"><img src="https://img.shields.io/badge/version-v0.1.0-orange" alt="Version"></a>
&nbsp;
<a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
</p>

<p align="center">
For content creators — a skill that turns every post into a calibrated experiment.
</p>

<p align="center">
You're reading this. The skill predicted it.<br>
It turns every "I feel this will go viral" into a calibrated experiment.<br>
It took me from zero to 1M followers in a month. It said I'd write this. I did.<br>
Your doubt — predicted too.
</p>

---

## 🎬 What it actually does

Most creators live in the same gambling loop:

> Publish → Numbers come in → Learn nothing → Roll the dice again

A creator who's shipped 200 pieces is barely 10% sharper than someone who's shipped 1 — because they never **kept books** after each round.

**Cheat on Content** makes every judgment get logged, retrospected, absorbed into the next:

📊 Score → 🎯 Blind-predict → 🚀 Publish → 📈 T+3d retro → 🧬 Evolve your rubric

This isn't motivation. It's **compounding** — every piece you don't retro is silently eroding your ability to see yourself.

One month in = you have a hit-formula that's **only yours**.
Three months in = you're 10× sharper than your first-day self.

---

## 🌀 Origin

> I never believed in fate. Until this skill made me film a video — and predicted exactly how much traffic that video would pull.
>
> I tried to break it. I told my audience. I hoped collective observation would collapse the wave function and shift the trajectory.
>
> The data was accurate.
>
> I didn't escape fate. I just moved from first-order to second-order.
>
> If even my awakening — even my audience's observation — was already in its prediction, then right now, reading this:
> are you here out of curiosity, or just closing the algorithm's last move?
>
> — *the creator*

---

## ⚖️ How it differs from other "creator tools"

| Others | This |
|---|---|
| Give you "inspiration" | Make **your own intuition** measurable |
| AI writes for you | AI **judges** for you — the script stays yours |
| Ship 10 versions, A/B test | Ship one — **bet** in writing, settle the books with data |
| Static dashboard | An **evolving rubric** — your formula 3 months from now isn't the starting one |

In a sentence: other tools help you "ship more." This helps you "judge sharper."

---

## 🤔 Can't I just use ChatGPT / DeepSeek / Doubao?

Those are **general assistants** — they tell everyone the same thing. You ask "will this go viral?" and the answer is fitted to global average opinion, not your channel. Ask again tomorrow — same answer. **It doesn't remember you. It doesn't change because of you.**

This is **your own ops expert** — serving only your one channel:

- The scoring formula is reverse-engineered from **your** history, not the global training distribution
- Every piece you ship updates its understanding — by month three, judgment accuracy is 10× sharper than day one (**auto-evolving**)
- It knows your benchmark account, your cadence, the last three reasons you flopped — things ChatGPT forgets after the first reply

General LLMs help everyone. This helps **your** account.

---

## 🛡️ Why the loop actually evolves

📝 **Every piece is logged**: Score and prediction get written before publish, archived end-to-end. Three days later you settle accounts — you see exactly where you were sharp, where you were off. No more vague "I feel this one didn't land."

🔁 **It gets sharper**: Three same-direction misses in a row, the tool actively prompts you to upgrade your scoring formula. **You don't have to remember — it remembers for you.**

🛡️ **Upgrades have a brake**: Switching the formula requires re-scoring all historical samples — only released if it ranks more accurately than the old. Plus a cross-model independent audit — **so you can't fool yourself.**

🪒 **The rubric is a workbench, not a museum**: Observations refuted by data get deleted; observations absorbed into formal dimensions also get deleted. It only holds what's most useful right now.

---

## 📦 Install

### Codex native（推荐）

```bash
git clone https://github.com/zhu-siyuan/cheat-on-content.git
cd cheat-on-content
bash install-codex.sh
```

这会安装一个用户可见的 `content-operator`、内部 `cheat-*` 能力库，以及 Codex 原生 SessionStart / PreToolUse hooks。

### Claude Code legacy

原来的 Claude Code 工作流继续保留：

```bash
bash install.sh
```

> ⚠️ **Upgrading from v0.x?** Run `/cheat-migrate` in your content project after `git pull`. The 1.3 → 1.4 migration is **BREAKING for blind-channel integrity** — it splits `rubric_notes.md` so the blind sub-agent can't leak actuals. Without migrate, blind scoring will keep flagging `non_blind_warning`. See [CHANGELOG](CHANGELOG.md) and [migrations/1.3-to-1.4.md](migrations/1.3-to-1.4.md).

15 internal sub-skills remain as the capability library. In Codex native mode, `content-operator` is the only implicit user-facing entry.

**Supported agents**: Claude Code (legacy workflow) · **Codex native zero-learning mode**

> Claude legacy still supports the original `install.sh` options. Codex-native installation is intentionally separated into `install-codex.sh` so its current skill path and hooks do not inherit old Claude-era assumptions.

---

## 🚀 Codex native: no onboarding command

For Codex, install the native entry + lifecycle hooks:

```bash
git clone https://github.com/zhu-siyuan/cheat-on-content.git
cd cheat-on-content
bash install-codex.sh
```

Then open Codex inside any content project and **just say what you actually want to do**:

```text
我最近有个想法：为什么具身智能到现在还没有 GPT-3 moment？
我大概有三个观点……
```

No `init`, no `status`, no `/cheat-*` command list.

The Content Operator will:

1. silently bootstrap the project if needed;
2. infer what it can from your normal conversation and existing files;
3. ask one important missing question at a time;
4. draft / score / lock a blind prediction when you are actually ready to shoot;
5. remember that you published;
6. surface T+3d retros when they become actionable;
7. turn performance data into the next concrete recommendation;
8. recalibrate the rubric internally when the evidence is strong enough.

Codex may require a one-time review/trust of the installed lifecycle hooks. After that, SessionStart can restore project state automatically and the PreToolUse guard protects immutable prediction sections.

---

## ⚡ Daily use: speak normally

There is no special daily syntax.

```text
“我今天突然想到一个观点……”
→ AI 深挖你的 angle，必要时问你一个关键问题，然后写稿

“这版我改好了，准备拍”
→ AI 自动评分，并在看到实绩前锁定盲预测

“拍完了，临场改了不少”
→ AI 记录实际拍摄稿，必要时写 v2 预测

“发了：https://...”
→ AI 自动识别平台并登记，记住未来的复盘窗口

“后台数据在这里”
→ AI 自动定位对应作品、复盘、沉淀经验，并给下一条建议

“下一条我做什么？”
→ AI 结合 buffer、候选池、最近复盘和校准状态给建议
```

The old `cheat-*` sub-skills still exist, but they are **internal implementation details in Codex native mode**. You should not need to learn them.

Full internal protocol: see [SKILL.md](SKILL.md). User-facing orchestration: see [skills/content-operator/SKILL.md](skills/content-operator/SKILL.md).

---

## 📈 Star History

<a href="https://star-history.com/#XBuilderLAB/cheat-on-content&Date">
  <img src="docs/star-history.svg" alt="Star History Chart" width="720">
</a>

---

## 📜 License

MIT. Commercial use, modification, closed-source integration — all fine.

---

*Is this cheating? So was the calculator. So was Google.*
*The future doesn't reward effort — it rewards those who see the pattern first.*

*You reading this line — that's predicted too.*
