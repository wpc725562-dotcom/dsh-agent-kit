---
name: github-repo-verification
description: 核实 GitHub 仓库相关声明是否属实。当用户提供仓库链接、功能描述、安装命令、star 数、Docker 镜像、npm 包名,或引用其他 AI/视频/文章对某个开源项目的介绍时,按本流程逐项实测验证,并输出"声明 vs 实测"对照表,区分真实与编造。触发词:核实/验证仓库、这个仓库存在吗、repo 真假、安装命令对不对、Docker 镜像存在吗。
---

# GitHub 仓库声明核实

目的:AI 生成的介绍(常见于抖音/小红书文案、其他 LLM 回答)常出现"真实仓库链接 + 编造细节"(功能夸大、安装命令错误、Docker 镜像不存在、star 数过时)。本技能把核实流程固化为标准步骤,每次执行同一套验证。

## 一、存在性检查(必须做)

1. 首选 GitHub API:`GET https://api.github.com/repos/{owner}/{repo}` + `User-Agent` 头。
   - 200 = 存在(同时拿到 stars、language、license、description、default_branch、pushed_at)
   - 404 = 不存在(声明是假的)
2. API 触发限流(403)时降级到网页:`GET https://github.com/{owner}/{repo}`(200 = 存在,404 = 不存在),再用页面 HTML 里的 `aria-label="(\d[\d,]*) users? starred this repository"` 或 `"starCount":(\d+)` 提取 star 数。
3. 批量核实时逐个请求,不要并行打爆限流;20 个仓库以内按序即可。

## 二、功能与描述核实(必须做)

1. 拉取 README:`GET https://raw.githubusercontent.com/{owner}/{repo}/HEAD/README.md`(HEAD 自动指向默认分支;404 时试 master/main)。
2. 把声明里的每一条功能描述,与 README 实际内容比对:按关键词搜索 README 全文,零命中即视为"描述与仓库不符"。
3. 常见编造特征:声称"截图转笔记/知识图谱/自动归档"但 README 是"视觉路由/OCR"类;声称"多账号管理面板"但实际只是脚本。

## 三、安装命令 / 镜像 / 包名核实(声明里有才做)

| 声明类型 | 验证方法 |
|---|---|
| npm/npx 包 | `GET https://registry.npmjs.org/{pkg}/latest`(路径中 `/` 转义为 `%2f`);200 得版本号,404 为假包 |
| Docker Hub 镜像 | `GET https://hub.docker.com/v2/repositories/{namespace}/{name}`;404 = 镜像不存在 |
| GHCR 镜像 | `GET https://ghcr.io/v2/{owner}/{image}/tags/list`(可能 401/403,那是需要认证,不代表不存在) |
| 一键安装脚本 | 直接 GET 脚本 URL:纯文本 shell 才是真脚本;返回 HTML/JS 跳转 = 声称的 `curl \| bash` 不可用 |

## 四、star 数 / 协议 / 更新状态

- star 数:以 API/页面实测为准;声明值偏差 >20% 记为"过时/不准"。
- 协议:license 字段(MIT/Apache-2.0 等);无 license = 不能按开源协议自由使用,要单独提醒。
- 活跃度:最近 push 时间、open_issues 数量,判断是否维护中。

## 五、输出格式(每次固定)

1. **验证结果表**:

   | 声明 | 实测结论 | 证据 |
   |---|---|---|
   | 仓库存在 | ✅/❌ | 状态码 / API 字段 |
   | 功能描述 | ✅ 相符 / ⚠️ 部分 / ❌ 不符 | README 关键词命中情况 |
   | 安装命令 | ✅ / ❌ 实际应为… | 包名/README 原文 |
   | Docker/脚本 | ✅ / ❌ 不存在 | registry 状态码 |
   | star 数 | ✅ / ⚠️ 实际 N | 实测值 |

2. **总结**:哪些可信、哪些是编造/夸大、哪些细节对不上,一句话给用户结论。

## 注意

- 只陈述实测结果,不猜测;拿不到就明说"未能验证"(如需要认证的 GHCR、无法访问的抖音视频)。
- 网络请求用 PowerShell `Invoke-WebRequest -UseBasicParsing`,统一带 `User-Agent`。
- 本技能不修改任何文件,纯只读核实。
