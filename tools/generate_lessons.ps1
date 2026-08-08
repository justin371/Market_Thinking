$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $root 'data\lessons.json'
$featuredPath = Join-Path $root 'data\featured-lessons.json'
$manifest = Get-Content -Raw $manifestPath | ConvertFrom-Json
$featuredList = Get-Content -Raw $featuredPath | ConvertFrom-Json
$featured = @{}
foreach ($item in $featuredList) { $featured[[int]$item.number] = $item }

function Escape-Svg([string]$value) {
  return [System.Security.SecurityElement]::Escape($value)
}

function Get-VisualType($lesson) {
  if ($featured.ContainsKey([int]$lesson.number)) { return $featured[[int]$lesson.number].visual }
  switch ([int]$lesson.number) {
    { $_ -le 15 } { return 'candle' }
    { $_ -le 30 } { return 'structure' }
    { $_ -le 39 } { return 'pullback' }
    { $_ -le 48 } { return 'breakout' }
    { $_ -le 55 } { return 'range' }
    { $_ -le 62 } { return 'levels' }
    { $_ -le 70 } { return 'reversal' }
    { $_ -le 76 } { return 'cycle' }
    { $_ -le 87 } { return 'multiframe' }
    { $_ -le 95 } { return 'paths' }
    { $_ -le 110 } { return 'decision' }
    { $_ -le 122 } { return 'psychology' }
    { $_ -le 128 } { return 'queue' }
    { $_ -le 141 } { return 'cycle' }
    { $_ -le 154 } { return 'ai' }
    { $_ -le 160 } { return 'unknown' }
    default { return 'capstone' }
  }
}

function New-Visual([int]$number, [string]$title, [string]$type) {
  $safeTitle = Escape-Svg $title
  $safeType = Escape-Svg $type
  $grid = '<g opacity=".14" stroke="#18324b" stroke-width="1"><path d="M30 52H770 M30 112H770 M30 172H770 M30 232H770 M30 292H770"/><path d="M90 28V316 M190 28V316 M290 28V316 M390 28V316 M490 28V316 M590 28V316 M690 28V316"/></g>'
  $body = switch ($type) {
    'candle' { '<path d="M90 254V72 M180 254V122 M270 254V52 M360 254V98 M450 254V140 M540 254V62 M630 254V105 M720 254V44" stroke="#5f7182" stroke-width="4" stroke-linecap="round"/><g><rect x="74" y="146" width="32" height="75" rx="5" fill="#e35d53"/><rect x="164" y="140" width="32" height="55" rx="5" fill="#149b8f"/><rect x="254" y="82" width="32" height="103" rx="5" fill="#149b8f"/><rect x="344" y="115" width="32" height="84" rx="5" fill="#e35d53"/><rect x="434" y="154" width="32" height="58" rx="5" fill="#e35d53"/><rect x="524" y="76" width="32" height="105" rx="5" fill="#149b8f"/><rect x="614" y="117" width="32" height="70" rx="5" fill="#e35d53"/><rect x="704" y="68" width="32" height="120" rx="5" fill="#149b8f"/></g><text x="36" y="38" fill="#2f6df6" font-size="17" font-weight="800">OPEN · HIGH · LOW · CLOSE</text>' }
    'structure' { '<path d="M44 270L140 204L215 234L310 137L385 178L486 88L565 132L742 42" fill="none" stroke="#2f6df6" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/><g fill="#fff" stroke="#2f6df6" stroke-width="4"><circle cx="140" cy="204" r="9"/><circle cx="215" cy="234" r="9"/><circle cx="310" cy="137" r="9"/><circle cx="385" cy="178" r="9"/><circle cx="486" cy="88" r="9"/><circle cx="565" cy="132" r="9"/></g><g fill="#172a3d" font-size="16" font-weight="900"><text x="123" y="182">HH</text><text x="196" y="260">HL</text><text x="292" y="116">HH</text><text x="365" y="205">HL</text><text x="468" y="67">HH</text><text x="547" y="158">HL</text></g>' }
    'pullback' { '<path d="M42 270L118 205L170 234L255 140L312 180L408 91L465 126L565 55L742 37" fill="none" stroke="#2f6df6" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/><path d="M118 205L170 234L255 140 M312 180L408 91" fill="none" stroke="#e35d53" stroke-width="6" stroke-linecap="round"/><circle cx="255" cy="140" r="10" fill="#fff" stroke="#f0b74f" stroke-width="5"/><circle cx="408" cy="91" r="10" fill="#fff" stroke="#f0b74f" stroke-width="5"/><text x="242" y="116" fill="#936319" font-size="15" font-weight="900">H1</text><text x="395" y="66" fill="#936319" font-size="15" font-weight="900">H2</text>' }
    'breakout' { '<rect x="82" y="93" width="392" height="142" rx="12" fill="#eaf0ff" stroke="#2f6df6" stroke-width="3" stroke-dasharray="9 8"/><path d="M98 178L150 146L202 191L256 130L308 180L368 119L426 173L500 77L570 107L642 75L740 121" fill="none" stroke="#2f6df6" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/><path d="M484 235L530 206L563 237L593 284" fill="none" stroke="#e35d53" stroke-width="7" stroke-linecap="round"/><text x="105" y="122" fill="#2f6df6" font-size="15" font-weight="900">旧区间</text><text x="507" y="57" fill="#108b7f" font-size="15" font-weight="900">突破</text><text x="608" y="307" fill="#cf4c42" font-size="15" font-weight="900">失败</text>' }
    'range' { '<rect x="70" y="86" width="580" height="176" rx="14" fill="#fff5d8" stroke="#d29a34" stroke-width="3" stroke-dasharray="8 7"/><path d="M47 238L101 165L150 205L199 126L244 189L292 152L341 219L389 132L438 190L485 118L532 206L581 145L633 194L684 112L748 162" fill="none" stroke="#d29a34" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/><path d="M70 174H650 M70 174L56 165 M70 174L56 183 M650 174L664 165 M650 174L664 183" fill="none" stroke="#e35d53" stroke-width="3"/><text x="94" y="116" fill="#936319" font-size="16" font-weight="900">上沿</text><text x="94" y="250" fill="#936319" font-size="16" font-weight="900">下沿</text><text x="296" y="182" fill="#cf4c42" font-size="15" font-weight="900">中部：信息最混乱</text>' }
    'levels' { '<path d="M50 244L144 179L218 214L306 132L392 168L487 92L560 126L742 64" fill="none" stroke="#2f6df6" stroke-width="7" stroke-linecap="round"/><path d="M48 210H726 M48 146H726 M48 90H726" stroke="#e35d53" stroke-width="3" stroke-dasharray="8 7" opacity=".8"/><text x="58" y="202" fill="#cf4c42" font-size="14" font-weight="900">支撑区</text><text x="58" y="138" fill="#cf4c42" font-size="14" font-weight="900">前高 / 压力区</text><text x="58" y="82" fill="#cf4c42" font-size="14" font-weight="900">关键位置</text>' }
    'reversal' { '<path d="M48 92L108 118L162 88L220 132L277 105L338 174L401 229L461 199L522 246L581 197L645 228L742 162" fill="none" stroke="#e35d53" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/><path d="M338 174L401 229L461 199" fill="none" stroke="#2f6df6" stroke-width="6"/><circle cx="401" cy="229" r="10" fill="#fff" stroke="#f0b74f" stroke-width="5"/><text x="420" y="250" fill="#936319" font-size="15" font-weight="900">需要跟进</text>' }
    'cycle' { '<circle cx="390" cy="170" r="112" fill="none" stroke="#d7dfe7" stroke-width="26"/><path d="M390 58A112 112 0 0 1 502 170" fill="none" stroke="#2f6df6" stroke-width="26" stroke-linecap="round"/><path d="M502 170A112 112 0 0 1 390 282" fill="none" stroke="#129b8f" stroke-width="26" stroke-linecap="round"/><path d="M390 282A112 112 0 0 1 278 170" fill="none" stroke="#d49a31" stroke-width="26" stroke-linecap="round"/><path d="M278 170A112 112 0 0 1 390 58" fill="none" stroke="#e35d53" stroke-width="26" stroke-linecap="round"/><text x="357" y="166" fill="#172a3d" font-size="18" font-weight="900">状态</text><text x="338" y="191" fill="#627285" font-size="13">持续变化</text>' }
    'multiframe' { '<path d="M54 254L120 201L183 219L248 145L306 180L369 114L429 155L504 92L573 116L648 67L742 102" fill="none" stroke="#2f6df6" stroke-width="6" stroke-linecap="round"/><rect x="62" y="48" width="196" height="55" rx="12" fill="#eaf0ff"/><rect x="284" y="48" width="196" height="55" rx="12" fill="#fff5d8"/><rect x="506" y="48" width="196" height="55" rx="12" fill="#e5f6f2"/><text x="87" y="82" fill="#2f6df6" font-size="14" font-weight="900">大周期：背景</text><text x="310" y="82" fill="#936319" font-size="14" font-weight="900">中周期：结构</text><text x="532" y="82" fill="#087b70" font-size="14" font-weight="900">小周期：细节</text>' }
    'paths' { '<circle cx="88" cy="170" r="20" fill="#172a3d"/><path d="M112 170H242M242 170L382 89M242 170L382 170M242 170L382 251" fill="none" stroke="#2f6df6" stroke-width="4" stroke-linecap="round"/><rect x="405" y="55" width="270" height="60" rx="14" fill="#e5f6f2"/><rect x="405" y="140" width="270" height="60" rx="14" fill="#eaf0ff"/><rect x="405" y="225" width="270" height="60" rx="14" fill="#fff0ec"/><text x="433" y="91" fill="#087b70" font-size="16" font-weight="900">上涨 · 跟进</text><text x="433" y="176" fill="#2f6df6" font-size="16" font-weight="900">震荡 · 等待</text><text x="433" y="261" fill="#cf4c42" font-size="16" font-weight="900">下跌 · 失效</text>' }
    'decision' { '<circle cx="88" cy="170" r="23" fill="#172a3d"/><path d="M113 170H230M230 170L356 91M230 170L356 249M356 91H483M356 249H483" fill="none" stroke="#2f6df6" stroke-width="4" stroke-linecap="round"/><rect x="493" y="59" width="205" height="65" rx="14" fill="#e5f6f2"/><rect x="493" y="216" width="205" height="65" rx="14" fill="#fff0ec"/><text x="517" y="87" fill="#087b70" font-size="15" font-weight="900">过程合理</text><text x="517" y="109" fill="#627285" font-size="12">结果仍有随机性</text><text x="517" y="244" fill="#cf4c42" font-size="15" font-weight="900">过程失控</text><text x="517" y="266" fill="#627285" font-size="12">结果好也不可复制</text>' }
    'psychology' { '<path d="M54 252C132 112 218 112 296 252S460 392 538 252S662 112 742 252" fill="none" stroke="#e35d53" stroke-width="7" stroke-linecap="round"/><path d="M54 270H742" stroke="#2f6df6" stroke-width="3" stroke-dasharray="8 8"/><circle cx="218" cy="151" r="14" fill="#fff" stroke="#f0b74f" stroke-width="5"/><circle cx="538" cy="151" r="14" fill="#fff" stroke="#f0b74f" stroke-width="5"/><text x="81" y="55" fill="#cf4c42" font-size="16" font-weight="900">情绪会放大运动</text><text x="553" y="301" fill="#627285" font-size="14">先暂停，再复盘</text>' }
    'queue' { '<path d="M80 252H520" stroke="#172a3d" stroke-width="3"/><g fill="#2f6df6"><circle cx="120" cy="161" r="18"/><circle cx="188" cy="161" r="18"/><circle cx="256" cy="161" r="18"/><circle cx="324" cy="161" r="18"/></g><g fill="#eaf0ff"><path d="M101 188h38l17 64H84z"/><path d="M169 188h38l17 64h-72z"/><path d="M237 188h38l17 64h-72z"/><path d="M305 188h38l17 64h-72z"/></g><rect x="578" y="79" width="130" height="130" rx="18" fill="#fff5d8"/><path d="M608 156h70M643 122v68" stroke="#936319" stroke-width="7" stroke-linecap="round"/><text x="80" y="95" fill="#2f6df6" font-size="16" font-weight="900">需求集中</text><text x="575" y="240" fill="#936319" font-size="13" font-weight="900">供需找平衡</text>' }
    'ai' { '<rect x="58" y="55" width="390" height="75" rx="18" fill="#eaf0ff"/><rect x="315" y="168" width="390" height="75" rx="18" fill="#172a3d"/><circle cx="90" cy="93" r="13" fill="#2f6df6"/><circle cx="346" cy="206" r="13" fill="#e35d53"/><text x="120" y="90" fill="#172a3d" font-size="15" font-weight="800">请列出三个可能路径</text><text x="120" y="113" fill="#627285" font-size="12">证据、反例、下一步</text><text x="375" y="203" fill="#fff" font-size="15" font-weight="800">哪个证据会推翻你？</text><text x="375" y="226" fill="#b8c8d8" font-size="12">答案需要核对来源和日期</text><path d="M205 150H548" stroke="#f0b74f" stroke-width="4" stroke-dasharray="8 9"/><text x="299" y="145" fill="#936319" font-size="13" font-weight="900">讨论 → 核验 → 更新</text>' }
    'market' { '<circle cx="124" cy="170" r="51" fill="#eaf0ff" stroke="#2f6df6" stroke-width="4"/><circle cx="654" cy="170" r="51" fill="#fff0ec" stroke="#e35d53" stroke-width="4"/><path d="M176 170H602M602 170L578 155M602 170L578 185" stroke="#f0b74f" stroke-width="5" stroke-linecap="round"/><path d="M320 245L384 195L438 216L520 96L742 82" fill="none" stroke="#149b8f" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/><text x="81" y="176" fill="#2f6df6" font-size="17" font-weight="900">需求</text><text x="607" y="176" fill="#cf4c42" font-size="17" font-weight="900">供给</text><text x="328" y="282" fill="#087b70" font-size="15" font-weight="900">成交 · 价格 · 新证据</text>' }
    'evidence' { '<rect x="72" y="74" width="280" height="194" rx="17" fill="#eaf0ff" stroke="#2f6df6" stroke-width="3"/><rect x="408" y="74" width="280" height="194" rx="17" fill="#fff5d8" stroke="#d49a31" stroke-width="3"/><path d="M112 129H306M112 168H278M112 207H238" stroke="#627285" stroke-width="8" stroke-linecap="round"/><path d="M450 129L486 165L548 101" fill="none" stroke="#149b8f" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/><circle cx="594" cy="211" r="25" fill="#fff" stroke="#e35d53" stroke-width="6"/><path d="M612 229L650 267" stroke="#e35d53" stroke-width="9" stroke-linecap="round"/><text x="105" y="51" fill="#2f6df6" font-size="15" font-weight="900">事实</text><text x="438" y="51" fill="#936319" font-size="15" font-weight="900">解释 · 需要核验</text>' }
    'states' { '<rect x="63" y="76" width="194" height="184" rx="18" fill="#eaf0ff"/><rect x="303" y="76" width="194" height="184" rx="18" fill="#fff5d8"/><rect x="543" y="76" width="194" height="184" rx="18" fill="#e5f6f2"/><path d="M100 210L135 172L170 190L218 126M338 174H458M578 212L614 139L662 179L709 105" fill="none" stroke="#2f6df6" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/><text x="122" y="112" fill="#2f6df6" font-size="15" font-weight="900">趋势</text><text x="358" y="112" fill="#936319" font-size="15" font-weight="900">区间</text><text x="597" y="112" fill="#087b70" font-size="15" font-weight="900">突破</text>' }
    'unknown' { '<path d="M52 253L128 207L177 228L245 140L308 177L378 124L431 194L503 80L568 115L646 68L748 104" fill="none" stroke="#2f6df6" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/><circle cx="245" cy="140" r="16" fill="#fff" stroke="#e35d53" stroke-width="5"/><text x="239" y="146" fill="#cf4c42" font-size="17" font-weight="900">?</text><circle cx="503" cy="80" r="16" fill="#fff" stroke="#f0b74f" stroke-width="5"/><text x="497" y="86" fill="#936319" font-size="17" font-weight="900">?</text><text x="54" y="307" fill="#627285" font-size="14">先描述 · 再判断 · 最后提出可证伪路径</text>' }
    'capstone' { '<path d="M78 250L170 198L258 224L352 143L448 174L548 99L726 67" fill="none" stroke="#2f6df6" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/><circle cx="170" cy="198" r="12" fill="#fff" stroke="#e35d53" stroke-width="5"/><circle cx="352" cy="143" r="12" fill="#fff" stroke="#f0b74f" stroke-width="5"/><circle cx="548" cy="99" r="12" fill="#fff" stroke="#149b8f" stroke-width="5"/><rect x="82" y="58" width="166" height="46" rx="12" fill="#fff0ec"/><rect x="317" y="58" width="166" height="46" rx="12" fill="#fff5d8"/><rect x="552" y="58" width="166" height="46" rx="12" fill="#e5f6f2"/><text x="116" y="87" fill="#cf4c42" font-size="14" font-weight="900">观察</text><text x="351" y="87" fill="#936319" font-size="14" font-weight="900">判断</text><text x="586" y="87" fill="#087b70" font-size="14" font-weight="900">更新</text><text x="262" y="294" fill="#627285" font-size="14" font-weight="900">把价格行为变成终身学习方法</text>' }
    default { '<circle cx="390" cy="170" r="90" fill="#eaf0ff" stroke="#2f6df6" stroke-width="4"/><path d="M332 170h116M390 112v116" stroke="#2f6df6" stroke-width="5"/><text x="350" y="166" fill="#172a3d" font-size="18" font-weight="900">观察</text><text x="355" y="191" fill="#627285" font-size="13">证据</text>' }
  }
  return @"
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 340" role="img" aria-labelledby="title desc">
  <title id="title">第${number}课：$safeTitle</title>
  <desc id="desc">原创课程示意图，视觉类型：$safeType。</desc>
  <rect width="800" height="340" rx="22" fill="#fbfcfd"/>
  $grid
  $body
  <text x="30" y="328" fill="#627285" font-size="12">Market Thinking · lesson $number · $safeType</text>
</svg>
"@
}

function New-CommonCases($number, $title, $kind) {
  if ($kind -eq 'price-action') {
    return @(
      "生活案例：把《价格运动》换成可观察的日常过程，例如排队、比赛比分、爬楼梯或一次试行方案。先写事实，再写你认为它可能意味着什么。",
      "历史案例：选择一段当时信息不完整的转折。不要用后来知道的结果替代当时的证据，比较不同参与者可能看到的路径。",
      "市场案例：回到图表，标出位置、结构、跟进和失败信号。相同形态放在不同上下文中，含义可以完全不同。"
    )
  }
  if ($kind -eq 'decision') {
    return @(
      "生活案例：把一个真实选择写成可能路径，注明等待、行动和不行动各自的成本。",
      "历史案例：把当时可获得的信息和事后结果分开，讨论哪些风险当时无法知道。",
      "市场案例：写出支持证据、反面证据、失效条件和最大可接受风险，不用一次结果证明自己。"
    )
  }
  if ($kind -eq 'ai') {
    return @(
      "生活案例：比较《听起来很确定》的回答和《承认缺少信息》的回答，哪个更值得继续核验。",
      "历史案例：让不同来源对同一事件给出解释，记录它们的证据、日期和遗漏。",
      "市场案例：让 AI 先描述图表，再提出多个情景，最后由人核对来源并保留自己的判断。"
    )
  }
  return @(
    "生活案例：找一个和《$title》相似的日常场景，写下供给、需求、等待、竞争或不确定性中的至少两个因素。",
    "历史案例：找一段相关历史事件，区分当时可见证据、后来的解释和仍然无法确定的部分。",
    "市场案例：在一张价格图上标记与本课相关的位置，再写出一个支持解释和一个反面解释。"
  )
}

function New-LessonMarkdown($lesson) {
  $number = [int]$lesson.number
  $title = [string]$lesson.title
  $type = Get-VisualType $lesson
  $featuredItem = $null
  if ($featured.ContainsKey($number)) { $featuredItem = $featured[$number] }
  $lines = [System.Collections.Generic.List[string]]::new()
  $lines.Add("# 第${number}课：$title")
  $lines.Add('')
  $lines.Add("> 课程位置：$($lesson.partLabel) / $($lesson.partTitle) / $($lesson.unit)")
  $lines.Add('')
  if ($featuredItem) {
    $lines.Add('## 本课目标')
    $lines.Add($featuredItem.goal)
    $lines.Add('')
    $lines.Add('## Price Action 核心')
    $lines.Add($featuredItem.priceAction)
    $lines.Add('')
    $lines.Add('> ' + $featuredItem.quote)
    $lines.Add('')
    $lines.Add('## 主图')
    $lines.Add('![本课原创示意图](visual.svg)')
    if ($number -eq 9) { $lines.Add('![许可参考图：K线结构](../../assets/reference/candlestick.svg)') }
    if ($number -eq 44) { $lines.Add('![许可参考图：Trading Range](../../assets/reference/eur-usd-trading-range.jpg)') }
    $lines.Add('')
    $lines.Add('## 三层案例')
    foreach ($case in $featuredItem.cases) {
      $lines.Add("### $($case.label)：$($case.title)")
      $lines.Add($case.body)
      $lines.Add('')
    }
    $lines.Add('## 开放思考题')
    $lines.Add($featuredItem.question)
    $lines.Add('')
    $lines.Add('## AI 一起讨论')
    $lines.Add($featuredItem.ai)
    $lines.Add('')
    $lines.Add('## 复盘卡')
    $lines.Add('- 我看见的事实：')
    $lines.Add('- 我的主要解释：')
    $lines.Add('- 支持证据：')
    $lines.Add('- 反面证据：')
    $lines.Add('- 什么会证明我错：')
    $lines.Add('- 我现在愿意等待的新信息：')
    $lines.Add('')
    $lines.Add('## 参考资料')
    foreach ($reference in $featuredItem.references) { $lines.Add("- $reference") }
    if ($number -eq 9) { $lines.Add('- 许可参考图：`../../assets/reference/candlestick.svg`，详见 `sources/image-credits.md`。') }
    if ($number -eq 44) { $lines.Add('- 许可参考图：`../../assets/reference/eur-usd-trading-range.jpg`，详见 `sources/image-credits.md`。') }
  } else {
    $lines.Add('## 本课目标')
    $lines.Add("围绕《$title》建立一套可观察、可解释、可更新的判断框架。本课是课程初稿，后续会继续补充案例、图表和教师提示。")
    $lines.Add('')
    $lines.Add('## 核心知识')
    $lines.Add("本课属于 $($lesson.kind) 主题。学习时先把概念放回上下文：价格在哪里？参与者可能看见什么？什么证据支持当前解释？什么证据会让解释失效？")
    $lines.Add('')
    $lines.Add('## 主图')
    $lines.Add('![本课原创示意图](visual.svg)')
    $lines.Add('')
    $lines.Add('## 三层案例')
    foreach ($case in New-CommonCases $number $title $lesson.kind) { $lines.Add($case); $lines.Add('') }
    $lines.Add('## 开放思考题')
    $lines.Add("如果没有唯一答案，你会用哪些证据支持你对《$title》的解释？请同时写出一个反例和一个可能改变观点的新信息。")
    $lines.Add('')
    $lines.Add('## AI 一起讨论')
    $lines.Add("请 AI 先复述《$title》的问题，再提出三个不同情景；要求它标注证据、假设和无法确认的部分。")
    $lines.Add('')
    $lines.Add('## 复盘卡')
    $lines.Add('- 我看见的事实：')
    $lines.Add('- 我的解释：')
    $lines.Add('- 支持证据：')
    $lines.Add('- 反面证据：')
    $lines.Add('- 失效条件：')
    $lines.Add('- 下一步观察：')
    $lines.Add('')
    $lines.Add('## 参考资料')
    $lines.Add('- Al Brooks Price Action 书籍与视频课程：仅作专业参考，不照搬原书。')
    $lines.Add('- `sources/image-credits.md`：公开图像许可和权威教学页面。')
  }
  return ($lines -join "`n")
}

$flatLessons = foreach ($part in $manifest.parts) {
  foreach ($unit in $part.units) {
    foreach ($lesson in $unit.lessons) {
      [pscustomobject]@{
        number = [int]$lesson.number
        title = [string]$lesson.title
        partLabel = [string]$part.label
        partTitle = [string]$part.title
        unit = [string]$unit.title
        kind = [string]$part.kind
      }
    }
  }
}

if ($flatLessons.Count -ne 172) { throw "Expected 172 lessons, found $($flatLessons.Count)" }

foreach ($lesson in $flatLessons | Sort-Object number) {
  $folder = Join-Path $root ('lessons\{0:D3}' -f $lesson.number)
  New-Item -ItemType Directory -Force -Path $folder | Out-Null
  Set-Content -Path (Join-Path $folder 'lesson.md') -Value (New-LessonMarkdown $lesson) -Encoding utf8
  Set-Content -Path (Join-Path $folder 'visual.svg') -Value (New-Visual $lesson.number $lesson.title (Get-VisualType $lesson)) -Encoding utf8
}

$embeddedLessons = [ordered]@{}
foreach ($lesson in $flatLessons | Sort-Object number) {
  $key = '{0:D3}' -f $lesson.number
  $embeddedLessons[$key] = Get-Content -Raw (Join-Path $root ('lessons\{0:D3}\lesson.md' -f $lesson.number))
}
$bundle = [ordered]@{
  manifest = $manifest
  featured = @($featuredList)
  lessons = $embeddedLessons
}
$bundleJson = $bundle | ConvertTo-Json -Depth 30 -Compress
$bundlePath = Join-Path $root 'data\course-bundle.js'
Set-Content -Path $bundlePath -Value "window.COURSE_BUNDLE = $bundleJson;" -Encoding utf8

Write-Output "Generated $($flatLessons.Count) lesson folders and file:// bundle under $root"
