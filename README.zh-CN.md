本主页项目基于 [Rawal Khirodkar](https://rawalkhirodkar.github.io/) 的个人主页模板改造而来。感谢 Rawal Khirodkar 开源分享原始项目与设计思路。

原始仓库：[rawalkhirodkar/rawalkhirodkar.github.io](https://github.com/rawalkhirodkar/rawalkhirodkar.github.io)

---
# 个人主页模板 · 使用与维护指南

这是一个**纯静态**的个人 / 学术主页模板：只有 HTML + CSS + 原生 JS，没有打包工具、没有 npm 依赖、不需要构建。直接用任意静态服务器托管即可（GitHub Pages、Netlify、Vercel、Nginx 都行）。

---

## 一、目录结构与各部分职责

```
unilinear/
├── index.html              主页（所有内容版块都在这里）
├── resume.html             CV 页面（iframe 嵌入 PDF）
├── style.css               站点样式（关键首屏样式已内联进 index.html）
├── sitemap.xml             SEO 站点地图
├── robots.txt              SEO 爬虫规则
├── AGENTS.md               给 AI 编码代理看的项目说明
├── README.zh-CN.md         （本文件）中文使用指南
│
├── fonts/                  自托管的 Inter 字体（拉丁 + 拉丁扩展）
│   ├── inter-latin.woff2
│   └── inter-latin-ext.woff2
│
├── js/                     原生 JS 脚本
│   ├── main.js             导航 / 滚动淡入 / 视频懒播 / "Show more" 切换
│   ├── globe.js            访客 3D 地球（基于 cobe，WebGL）
│   └── hidebib.js          论文卡片里 BibTeX 折叠/展开（备用工具）
│
├── data/                   访客数据
│   ├── globe-data.json     地球渲染所需的 {国家代码: 访问数} 数据
│   └── update-globe.sh     从 GoatCounter API 拉数据生成上面 JSON 的脚本
│
└── .github/workflows/
    └── update-globe.yml    每天定时跑 update-globe.sh 并自动 commit 数据
```

> **添加内容时**自己再建这些目录：`images/`（图片视频）、`posters/`（视频封面图）、`docs/`（CV / 论文 PDF）、`icons/`（favicon / 学校 logo）等。

---

## 二、`index.html` 的版块（按从上到下顺序）

每个版块都已经做成**占位骨架**，只需要把里面的文本/链接/图片换成自己的即可。

| 版块 ID | 名称 | 干什么的 |
|---|---|---|
| `#about` | Hero / About | 头像、姓名、头衔、社交链接、简介。**头像是占位灰块**，把 `<div class="hero-photo">` 换成 `<img src="images/me.jpg" class="hero-photo">` 即可 |
| `#news` | News | 时间线式新闻列表。超过若干条后通过 `class="news-extra"` 标记，点击 `Show more` 按钮展开（逻辑在 `js/main.js`）。模板里默认隐藏了 `Show more` 按钮（`hidden` 属性），新闻多了再去掉 |
| `#experience` | Experience | 学校 / 工作经历的时间线，左侧是 logo，右侧是角色 / 机构 / 时间 |
| `#research` | Selected Research | 配图 + 标签的精选项目格子（鼠标移上去会播放视频） |
| `#publications` | Publications | 论文卡片：缩略图 + 标题 + 作者 + 会议 + paper/code/project 链接 |
| `#media` | Media Coverage | 媒体报道 logo 云。模板里加了 `hidden`，没东西时不会显示 |
| `#service` | Service | 学术服务（审稿、组织 workshop 等） |
| `#visitors` | Visitors | WebGL 3D 地球，按访问国家点亮（数据来自 `data/globe-data.json`） |

> **导航栏**（顶部 `<nav>`）只有 4 个锚点：About / News / Experience / Publications。要加新版块进导航，改 `index.html` 顶部 `<ul class="nav-links">` 即可。

---

## 三、典型操作流程

### 1. 本地预览

```powershell
cd b:\homepage\unilinear
python -m http.server 8000
# 然后浏览器打开 http://localhost:8000
```

任何静态服务器都行（`npx serve`、VSCode `Live Server` 扩展 等）。**不要**改成 `npm start` / webpack / vite —— 模板就是要原汁原味地被服务。

### 2. 替换基本信息

在 [index.html](index.html) 里全局搜索并替换以下占位符：

| 占位符 | 替换成 |
|---|---|
| `Your Name` | 你的名字（4 处：`<title>`、JSON-LD、`<nav>`、`<h1>`） |
| `Your Title / Affiliation` | 你的头衔，如 `PhD Student, XX University` |
| `you@example.com` | 你的邮箱 |
| `https://example.com/` | 你的部署域名（同步改 [sitemap.xml](sitemap.xml)、[robots.txt](robots.txt)） |
| 简介里的三段 `<p>...</p>` | 你自己的 bio |

JSON-LD（`<script type="application/ld+json">`）里的字段（`worksFor`、`alumniOf`、`knowsAbout`、`sameAs`）一并补上 —— 这部分给 Google Knowledge Panel 用，影响搜索结果展示。

### 3. 添加头像 / 图片 / 视频

1. 新建 `images/` 目录
2. 把图片放进去：`images/me.jpg`、`images/some-paper.jpg` …
3. 在 HTML 里用**相对路径**引用：`<img src="images/me.jpg">`

> 视频建议 `<video loop muted playsinline preload="none">` 并提供 `poster` 海报图（放 `posters/`），首屏不会自动加载，滚动到附近时由 `js/main.js` 中的 `IntersectionObserver` 触发懒播。

### 4. 添加 CV

1. 新建 `docs/` 目录，放入 `docs/cv.pdf`
2. 修改 [resume.html](resume.html)，把 `<div class="placeholder">…</div>` 换成：
   ```html
   <iframe src="docs/cv.pdf" title="CV"></iframe>
   ```
3. 在 `index.html` 的 `.hero-links` 里加一个跳转到 `resume.html` 或直接到 PDF 的链接

### 5. 添加新闻 / 论文 / 项目

直接在对应版块里复制注释里的 example HTML 块（`<div class="pub-card fade-in">…</div>` 之类），照样修改文字、链接、图片即可。`fade-in` 这个 class 是滚动到时浮现的动画，必须保留。

### 6. 添加项目专题子页（如 `myproject/`）

1. 在仓库根新建 `myproject/index.html`（可以从老的学术项目页模板复制，自带 Bulma + carousel）
2. 在 `index.html` 的 `#research` 或 `#publications` 加入跳转卡片
3. 在 [sitemap.xml](sitemap.xml) 里加 `<url><loc>https://你的域名/myproject/</loc>…</url>`

---

## 四、访客地球 (Globe) 工作机制

主页底部那个旋转 3D 地球**不是实时**统计的，而是离线生成 JSON 的：

```
GoatCounter（隐私友好的访客分析服务，无 cookie）
        │  HTTP API
        ▼
data/update-globe.sh                ← 用 curl + jq 拉每个国家的访问数
        │  写文件
        ▼
data/globe-data.json                ← 简单的 {国家代码: count} 列表
        │  fetch() 加载
        ▼
js/globe.js                         ← cobe 库渲染 WebGL 地球
```

定时执行流程：

```
.github/workflows/update-globe.yml
   ├─ schedule: 每天 06:00 UTC
   ├─ 跑 bash data/update-globe.sh
   │     ├─ 读 secret: GOATCOUNTER_TOKEN
   │     └─ 读 secret: GOATCOUNTER_SITE
   └─ 如有变化 → git commit + git push（github-actions[bot] 身份）
```

### 想启用地球，需要做：

1. 注册 [GoatCounter](https://www.goatcounter.com/) 拿到 site 子域和 API token
2. 在 GitHub 仓库 → **Settings → Secrets and variables → Actions** 添加两个 secret：
   - `GOATCOUNTER_TOKEN`
   - `GOATCOUNTER_SITE`（比如 `myname`，对应 `https://myname.goatcounter.com/`）
3. 在 `index.html` `</body>` 之前加上 GoatCounter 的统计脚本：
   ```html
   <script data-goatcounter="https://你的site.goatcounter.com/count"
           async src="//gc.zgo.at/count.js"></script>
   ```
4. 等到第二天 UTC 06:00（或在 Actions 里手动 `Run workflow`）

### 不想要地球？

- 删掉 `index.html` 里 `<section id="visitors">…</section>` 整段
- 删掉底部 `<script type="module" src="js/globe.js">` 这一行
- 可以一起删掉 `data/`、`js/globe.js`、`.github/workflows/update-globe.yml`

---

## 五、SEO / 上线前清单

1. ✅ [index.html](index.html) 里所有 `Your Name`、`https://example.com/`、`you@example.com` 都换掉
2. ✅ JSON-LD 的 `name`、`url`、`image`、`jobTitle`、`worksFor`、`sameAs` 全部补完
3. ✅ Open Graph (`og:*`) 和 Twitter Card (`twitter:*`) meta 标签
4. ✅ [sitemap.xml](sitemap.xml) 中的域名 + 所有子页 URL
5. ✅ [robots.txt](robots.txt) 中的 sitemap URL
6. ✅ 加上 favicon：`icons/favicon.svg` 然后在 `<head>` 加 `<link rel="icon" type="image/svg+xml" href="icons/favicon.svg">`
7. ✅（可选）Google Search Console 验证：把它给的 `googleXXXX.html` 文件放到根目录

---

## 六、常见坑

| 现象 | 原因 / 解决 |
|---|---|
| 地球是空白 | `data/globe-data.json` 里 `locations: []`。要么先让 GitHub Actions 跑一遍，要么先手动塞几个国家进去测试 |
| 字体没生效 | 检查 `fonts/` 是否被部署，`<head>` 里 `@font-face` 的 `src: url(fonts/...)` 路径相对于 `index.html` 必须正确 |
| 点击导航没反应 | `js/main.js` 里 `nav.addEventListener('click', …)` 只对 `<a href="#xxx">` 生效。你新加的版块要有对应 `id` |
| GitHub Pages 部署后子页 404 | `index.html` 里所有路径都是相对的，没问题；但如果你写了绝对路径如 `/images/x.jpg`，在 `username.github.io/repo/` 这种子路径部署会挂 |
| `update-globe.sh` 本地跑直接退出 | 它做了 `: "${GOATCOUNTER_TOKEN:?...}"` 校验。本地测试的话先 `export GOATCOUNTER_TOKEN=xxx` |
| `.gitignore` 里有一堆 Python 配置 | 模板早期遗留，不影响使用，可保留可删 |

---

## 七、文件之间的依赖速查表

```
index.html ──┬── style.css
             ├── fonts/inter-latin.woff2, inter-latin-ext.woff2
             ├── js/main.js          （导航、淡入、视频懒播、新闻折叠）
             └── js/globe.js         （地球，用到 data/globe-data.json）
                       │
                       └── 通过 CDN 加载 cobe（jsdelivr ESM）

resume.html ──── docs/cv.pdf （需要自行添加）

.github/workflows/update-globe.yml ──── data/update-globe.sh ──── data/globe-data.json
```

`hidebib.js` 是个独立工具：在论文卡片里写 `<pre>` 标签放 BibTeX，再在卡片上加 `onclick="togglebib('paper-id')"`，就能折叠/展开。模板默认没启用，按需引入 `<script src="js/hidebib.js"></script>`。

---

## 八、下一步建议

- 先把 [index.html](index.html) 的姓名、bio、第一条 news、第一篇 publication 填好 → 本地起 server 看效果
- 加 favicon 和头像
- 决定要不要地球版块；要的话申请 GoatCounter 并加 secrets
- 部署到 GitHub Pages：仓库设置 Pages → Source 选 `main` 分支根目录即可

