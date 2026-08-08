# Market Thinking / Price Action

面向 10—16 岁青少年的 Market Thinking 课程仓库。

这不是一本“青少年炒股书”。课程以 Price Action Trading 为主体训练材料，用金融市场练习观察事实、识别结构、比较概率、管理风险、复盘判断，并把这些能力迁移到生活、历史、商业、体育与 AI 协作。

## 仓库结构

```text
.
├── index.html                 # 顶层课程入口，动态调取每一课
├── app.js                     # 目录、搜索、课程加载和进度状态
├── styles.css                 # 顶层阅读界面
├── data/
│   ├── lessons.json           # 172 课 manifest
│   └── featured-lessons.json  # 已完整填充的代表课内容
├── lessons/
│   ├── 001/
│   │   ├── lesson.md          # 每课唯一内容源
│   │   └── visual.svg         # 本课原创或已标注来源的图形
│   └── ...
├── assets/reference/          # 可公开复用、已记录许可的参考图
├── sources/image-credits.md   # 图片来源、许可与使用说明
└── tools/generate_lessons.ps1 # 从 manifest 生成/更新每课文件夹
```

每一课都是独立目录。顶层页面只读取 `data/lessons.json`，再按课号请求 `lessons/NNN/lesson.md` 和 `lessons/NNN/visual.svg`。这让课程可以逐课编辑、审阅和替换图片，也方便以后从 Markdown 生成 PDF、PPT 或教师手册。

## 本地运行

`fetch()` 需要 HTTP 环境。Windows PowerShell：

```powershell
python -m http.server 8000
```

然后打开 <http://127.0.0.1:8000/>。

## 课程内容约定

已完整填充的代表课包括：1、3、9、16、23、34、44、71、88、104、123、142、155、172。每课包含：

- 一句话目标和 Price Action 核心概念；
- 生活、历史、市场三个层面的案例；
- 一张主图或图形说明；
- 没有标准答案的思考题；
- AI 讨论提示和复盘字段；
- 参考资料与“什么证据会让我改变观点”。

其余课程已经建立独立文件夹，并使用相同结构化模板生成初稿，后续应逐课补充真实案例、图表和教师提示。

## 参考资料与边界

Al Brooks 的三本 Price Action 著作和视频课程是重要专业参考，但本仓库不会照搬原书章节、长段落或书页截图，也不把原始交易训练直接移植给青少年。参考入口：

- [Brooks Trading Course — Price Action Trading Books](https://www.brookstradingcourse.com/price-action-trading-books/)
- [Wiley — Example of how to Trade a Trading Range](https://onlinelibrary.wiley.com/doi/10.1002/9781119202608.ch21)
- [Wiley — Tight Trading Ranges](https://onlinelibrary.wiley.com/doi/10.1002/9781119202608.ch22)
- [CME Group — Chart Types: candlestick, line, bar](https://www.cmegroup.com/education/courses/technical-analysis/chart-types-candlestick-line-bar)

本地书籍只作为个人学习参考，不进入仓库；尤其不上传 EPUB、扫描页或未经许可的书中图片。

## 图片策略

Trading Range 等容易被误读的概念优先使用：

1. 有明确公开许可的参考图，并在 `sources/image-credits.md` 留下作者、页面、许可和下载地址；
2. 没有明确许可时，使用本仓库原创 SVG，依据权威教材/教育页面重新绘制；
3. 图片旁边只保留必要的解释，不把形态当成预测按钮。

当前仓库已放入 Wikimedia Commons 的 CC0 Trading Range 图和 CC BY-SA 3.0 Candlestick 图，并在来源文件中标注许可。它们是参考图，不替代课程自己的原创示意图。

## 教育边界

课程不鼓励未成年人进行实盘投机，不提供保证盈利的信号，不把单次输赢当作学习评价。重点是：

> 事实 → 上下文 → 结构 → 可能路径 → 风险边界 → 复盘更新
