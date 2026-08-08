const state = {
  manifest: null,
  lessons: [],
  featured: new Map(),
  current: 44,
  filter: 'all',
  query: '',
  loading: false,
};

const $ = (selector, root = document) => root.querySelector(selector);
const $$ = (selector, root = document) => Array.from(root.querySelectorAll(selector));

function padLesson(number) {
  return String(number).padStart(3, '0');
}

function unitKey(part, unit, index) {
  return unit.id || `${part.id}-${index}`;
}

function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function flattenManifest(manifest) {
  return manifest.parts.flatMap((part) =>
    part.units.flatMap((unit, unitIndex) =>
      unit.lessons.map((lesson) => ({
        ...lesson,
        partId: part.id,
        partLabel: part.label,
        partTitle: part.title,
        kind: lesson.kind || part.kind,
        unitId: unitKey(part, unit, unitIndex),
        unitLabel: unit.label || `单元 ${unitIndex + 1}`,
        unitTitle: unit.title,
        file: `lessons/${padLesson(lesson.number)}/lesson.md`,
        visual: `lessons/${padLesson(lesson.number)}/visual.svg`,
      })),
    ),
  );
}

function getLesson(number) {
  return state.lessons.find((lesson) => lesson.number === Number(number));
}

function getEmbeddedBundle() {
  const bundle = window.COURSE_BUNDLE;
  if (!bundle?.manifest || !Array.isArray(bundle.featured) || !bundle.lessons) return null;
  return bundle;
}

async function loadCourseData() {
  const embedded = getEmbeddedBundle();
  if (window.location.protocol === 'file:' && embedded) return embedded;

  try {
    const [manifestResponse, featuredResponse] = await Promise.all([
      fetch('data/lessons.json'),
      fetch('data/featured-lessons.json'),
    ]);
    if (!manifestResponse.ok || !featuredResponse.ok) throw new Error('课程数据未找到');
    return {
      manifest: await manifestResponse.json(),
      featured: await featuredResponse.json(),
    };
  } catch (error) {
    if (embedded) return embedded;
    throw error;
  }
}

function getFilteredLessons() {
  const query = state.query.trim().toLowerCase();
  return state.lessons.filter((lesson) => {
    const filterMatches = state.filter === 'all' || lesson.kind === state.filter;
    if (!filterMatches) return false;
    if (!query) return true;
    const haystack = [
      lesson.number,
      lesson.title,
      lesson.partTitle,
      lesson.unitTitle,
      lesson.label,
      lesson.kind,
    ]
      .join(' ')
      .toLowerCase();
    return haystack.includes(query);
  });
}

function renderDirectory() {
  const directory = $('#curriculum-list');
  if (!directory) return;

  const visible = getFilteredLessons();
  const visibleNumbers = new Set(visible.map((lesson) => lesson.number));
  const byPart = new Map();

  visible.forEach((lesson) => {
    if (!byPart.has(lesson.partId)) byPart.set(lesson.partId, new Map());
    const byUnit = byPart.get(lesson.partId);
    if (!byUnit.has(lesson.unitId)) byUnit.set(lesson.unitId, []);
    byUnit.get(lesson.unitId).push(lesson);
  });

  if (!visible.length) {
    directory.innerHTML = `
      <div class="empty-state">
        <strong>没有找到匹配课程</strong>
        <span>试试搜索“突破”“K线”或清除筛选条件。</span>
      </div>`;
    updateDirectorySelection();
    return;
  }

  directory.innerHTML = state.manifest.parts
    .filter((part) => byPart.has(part.id))
    .map((part, partIndex) => {
      const units = byPart.get(part.id);
      const open = Boolean(state.query) || partIndex < 3;
      return `
        <details class="curriculum-part" ${open ? 'open' : ''}>
          <summary>
            <span class="part-number">${escapeHtml(part.label)}</span>
            <span>
              <strong>${escapeHtml(part.title)}</strong>
              <small>${units.size} 个单元 · ${Array.from(units.values()).flat().length} 课</small>
            </span>
            <span class="summary-chevron">⌄</span>
          </summary>
          <div class="part-units">
            ${part.units
              .map((unit, originalIndex) => ({ unit, originalIndex }))
              .filter(({ unit, originalIndex }) => units.has(unitKey(part, unit, originalIndex)))
              .map(({ unit, originalIndex }) => {
                const lessons = units.get(unitKey(part, unit, originalIndex));
                return `
                  <section class="curriculum-unit">
                    <div class="unit-heading">
                      <span>${escapeHtml(unit.label || `单元 ${originalIndex + 1}`)}</span>
                      <strong>${escapeHtml(unit.title)}</strong>
                    </div>
                    <div class="lesson-list">
                      ${lessons
                        .map((lesson) => {
                          const isFeatured = state.featured.has(lesson.number);
                          const active = lesson.number === state.current;
                          return `
                            <button class="lesson-item ${active ? 'is-active' : ''} ${isFeatured ? 'is-featured' : ''}" data-lesson="${lesson.number}" type="button">
                              <span class="lesson-index">${String(lesson.number).padStart(3, '0')}</span>
                              <span class="lesson-copy"><span class="lesson-name">${escapeHtml(lesson.title)}</span><span class="lesson-subtitle">${escapeHtml(lesson.unitTitle)}</span></span>
                              ${isFeatured ? '<span class="lesson-mark" title="代表性完整课程">●</span>' : ''}
                            </button>`;
                        })
                        .join('')}
                    </div>
                  </section>`;
              })
              .join('')}
          </div>
        </details>`;
    })
    .join('');

  $$('.lesson-item', directory).forEach((button) => {
    button.addEventListener('click', () => selectLesson(Number(button.dataset.lesson)));
  });
  updateDirectorySelection(visibleNumbers);
}

function updateDirectorySelection(visibleNumbers = null) {
  $$('.lesson-item').forEach((button) => {
    const number = Number(button.dataset.lesson);
    const isActive = number === state.current;
    const isVisible = !visibleNumbers || visibleNumbers.has(number);
    button.classList.toggle('is-active', isActive && isVisible);
    if (isActive && isVisible) button.setAttribute('aria-current', 'page');
    else button.removeAttribute('aria-current');
  });
}

function formatInline(text, lesson) {
  const tokens = [];
  const stash = (html) => {
    const key = `\u0000${tokens.length}\u0000`;
    tokens.push(html);
    return key;
  };

  let output = escapeHtml(text);
  output = output.replace(/!\[([^\]]*)\]\(([^)\s]+)(?:\s+["']([^"']+)["'])?\)/g, (_, alt, rawSrc, title) => {
    const src = resolveAsset(rawSrc, lesson);
    const titleAttr = title ? ` title="${escapeHtml(title)}"` : '';
    return stash(`<img class="md-image" src="${escapeHtml(src)}" alt="${escapeHtml(alt)}"${titleAttr} loading="lazy">`);
  });
  output = output.replace(/\[([^\]]+)\]\(([^)\s]+)(?:\s+["']([^"']+)["'])?\)/g, (_, label, href, title) => {
    const safeHref = resolveLink(href);
    const titleAttr = title ? ` title="${escapeHtml(title)}"` : '';
    return stash(`<a href="${escapeHtml(safeHref)}"${titleAttr}>${label}</a>`);
  });
  output = output.replace(/`([^`]+)`/g, (_, code) => stash(`<code>${code}</code>`));
  output = output.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
  output = output.replace(/__([^_]+)__/g, '<strong>$1</strong>');
  output = output.replace(/\*([^*]+)\*/g, '<em>$1</em>');
  output = output.replace(/_([^_]+)_/g, '<em>$1</em>');

  return output.replace(/\u0000(\d+)\u0000/g, (_, index) => tokens[Number(index)]);
}

function resolveAsset(src, lesson) {
  if (src === 'visual.svg' || src === './visual.svg') return lesson.visual;
  if (src.startsWith('../../assets/')) return src.slice(6);
  if (src.startsWith('../')) return `lessons/${padLesson(lesson.number)}/${src.slice(3)}`;
  return src;
}

function resolveLink(href) {
  if (href.startsWith('#')) return href;
  if (href.startsWith('../../')) return href.slice(6);
  if (/^https?:\/\//i.test(href)) return href;
  return href;
}

function markdownToHtml(markdown, lesson) {
  const lines = markdown.replaceAll('\r\n', '\n').split('\n');
  const output = [];
  let paragraph = [];
  let listType = null;

  const closeParagraph = () => {
    if (!paragraph.length) return;
    output.push(`<p>${paragraph.map((line) => formatInline(line, lesson)).join('<br>')}</p>`);
    paragraph = [];
  };
  const closeList = () => {
    if (listType) output.push(`</${listType}>`);
    listType = null;
  };

  lines.forEach((line) => {
    if (!line.trim()) {
      closeParagraph();
      closeList();
      return;
    }

    const heading = line.match(/^(#{1,4})\s+(.+)$/);
    if (heading) {
      closeParagraph();
      closeList();
      const level = Math.min(heading[1].length + 1, 5);
      output.push(`<h${level}>${formatInline(heading[2], lesson)}</h${level}>`);
      return;
    }

    if (/^---+$/.test(line.trim())) {
      closeParagraph();
      closeList();
      output.push('<hr>');
      return;
    }

    const imageOnly = line.match(/^!\[([^\]]*)\]\(([^)\s]+)(?:\s+["']([^"']+)["'])?\)$/);
    if (imageOnly) {
      closeParagraph();
      closeList();
      output.push(`<figure class="md-figure">${formatInline(line, lesson)}${imageOnly[3] ? `<figcaption>${escapeHtml(imageOnly[3])}</figcaption>` : ''}</figure>`);
      return;
    }

    const quote = line.match(/^>\s?(.*)$/);
    if (quote) {
      closeParagraph();
      closeList();
      output.push(`<blockquote>${formatInline(quote[1], lesson)}</blockquote>`);
      return;
    }

    const unordered = line.match(/^\s*[-*+]\s+(.+)$/);
    const ordered = line.match(/^\s*\d+[.)]\s+(.+)$/);
    if (unordered || ordered) {
      closeParagraph();
      const nextType = unordered ? 'ul' : 'ol';
      if (listType !== nextType) {
        closeList();
        listType = nextType;
        output.push(`<${listType}>`);
      }
      output.push(`<li>${formatInline((unordered || ordered)[1], lesson)}</li>`);
      return;
    }

    closeList();
    paragraph.push(line.trim());
  });

  closeParagraph();
  closeList();
  return output.join('');
}

function setReaderState(lesson, content) {
  const featured = state.featured.get(lesson.number);
  const reader = $('#reader');
  const title = $('#reader-title');
  const kicker = $('#reader-kicker');
  const meta = $('#reader-meta');
  const goal = $('#lesson-goal');
  const quote = $('#lesson-quote');
  const image = $('#lesson-image');
  const markdownLink = $('#lesson-markdown');
  const status = $('#lesson-status');
  const counter = $('#progress-text');
  const progress = $('#progress-bar');
  const prev = $('[data-prev]');
  const next = $('[data-next]');

  title.textContent = `第${lesson.number}课 · ${lesson.title}`;
  kicker.textContent = `${lesson.partLabel} / ${lesson.partTitle} · ${lesson.unitTitle}`;
  meta.innerHTML = `<span>${escapeHtml(lesson.kindLabel || lesson.kind)}</span><span>${state.featured.has(lesson.number) ? '完整示范课' : '课程骨架课'}</span>`;
  goal.textContent = featured?.goal || '先把事实、结构与假设分开，再决定自己还需要什么证据。';
  quote.textContent = featured?.quote || '每一课都从价格行为出发，回到可解释的判断。';
  if (image) {
    image.src = lesson.visual;
    image.alt = `${lesson.title}原创示意图`;
  }
  const heroImage = $('#hero-image');
  if (heroImage) {
    heroImage.src = lesson.visual;
    heroImage.alt = `${lesson.title}原创示意图`;
  }
  const heroVisualLabel = $('#hero-visual-label');
  if (heroVisualLabel) heroVisualLabel.textContent = padLesson(lesson.number);
  const currentCardTitle = $('#current-card-title');
  if (currentCardTitle) currentCardTitle.textContent = lesson.title;
  markdownLink.href = lesson.file;
  status.textContent = '已加载';
  counter.textContent = `${String(lesson.number).padStart(3, '0')} / 172`;
  if (progress) progress.style.width = `${(lesson.number / 172) * 100}%`;
  if (prev) prev.disabled = lesson.number <= 1;
  if (next) next.disabled = lesson.number >= 172;
  $('#lesson-content').innerHTML = content;
  reader.dataset.lesson = lesson.number;
  updateDirectorySelection();
}

async function loadLesson(number) {
  const lesson = getLesson(number);
  if (!lesson || state.loading) return;
  state.loading = true;
  const status = $('#lesson-status');
  status.textContent = '读取中…';
  try {
    const embedded = getEmbeddedBundle();
    let markdown = null;
    if (window.location.protocol === 'file:' && typeof embedded?.lessons?.[padLesson(lesson.number)] === 'string') {
      markdown = embedded.lessons[padLesson(lesson.number)];
    } else {
      try {
        const response = await fetch(lesson.file);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        markdown = await response.text();
      } catch (error) {
        if (typeof embedded?.lessons?.[padLesson(lesson.number)] !== 'string') throw error;
        markdown = embedded.lessons[padLesson(lesson.number)];
      }
    }
    setReaderState(lesson, markdownToHtml(markdown, lesson));
  } catch (error) {
    status.textContent = '读取失败';
    $('#lesson-content').innerHTML = `<div class="error-state"><strong>这节课暂时无法打开</strong><span>${escapeHtml(error.message)}。请确认 data/course-bundle.js 存在，或使用 README 中的本地服务器方式打开。</span></div>`;
  } finally {
    state.loading = false;
  }
}

function updateUrl(number) {
  const url = new URL(window.location.href);
  url.searchParams.set('lesson', number);
  window.history.replaceState({ lesson: number }, '', url);
}

function selectLesson(number, shouldScroll = true) {
  const lesson = getLesson(number);
  if (!lesson) return;
  state.current = lesson.number;
  updateUrl(lesson.number);
  loadLesson(lesson.number);
  if (shouldScroll) $('#reader')?.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function selectAdjacent(offset) {
  const nextNumber = Math.max(1, Math.min(172, state.current + offset));
  selectLesson(nextNumber);
}

function bindControls() {
  $$('[data-filter]').forEach((button) => {
    button.addEventListener('click', () => {
      state.filter = button.dataset.filter;
      $$('[data-filter]').forEach((item) => item.classList.toggle('active', item === button));
      renderDirectory();
    });
  });

  const search = $('#lesson-search');
  search?.addEventListener('input', () => {
    state.query = search.value;
    renderDirectory();
  });

  $('[data-random]')?.addEventListener('click', () => {
    const candidates = Array.from(state.featured.keys());
    const number = candidates[Math.floor(Math.random() * candidates.length)];
    selectLesson(number);
  });
  $('[data-prev]')?.addEventListener('click', () => selectAdjacent(-1));
  $('[data-next]')?.addEventListener('click', () => selectAdjacent(1));

  $$('[data-start]').forEach((link) => {
    link.addEventListener('click', (event) => {
      event.preventDefault();
      selectLesson(Number(link.dataset.start));
    });
  });

  window.addEventListener('popstate', () => {
    const number = Number(new URLSearchParams(window.location.search).get('lesson')) || 44;
    selectLesson(number, false);
  });
}

async function boot() {
  try {
    const courseData = await loadCourseData();
    state.manifest = courseData.manifest;
    const featured = courseData.featured;
    state.lessons = flattenManifest(state.manifest);
    state.featured = new Map(featured.map((lesson) => [lesson.number, lesson]));

    const requested = Number(new URLSearchParams(window.location.search).get('lesson'));
    state.current = getLesson(requested)?.number || 44;
    $('#stat-total').textContent = state.lessons.length;
    $('#stat-featured').textContent = state.featured.size;
    bindControls();
    renderDirectory();
    await loadLesson(state.current);
  } catch (error) {
    const status = $('#lesson-status');
    if (status) status.textContent = '初始化失败';
    const content = $('#lesson-content');
    if (content) content.innerHTML = `<div class="error-state"><strong>课程目录暂时无法读取</strong><span>${escapeHtml(error.message)}。请确认 data/course-bundle.js 存在，或使用 README 中的本地服务器方式打开。</span></div>`;
  }
}

document.addEventListener('DOMContentLoaded', boot);
