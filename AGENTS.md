# Agent Guide — Personal Homepage Template

A **static personal/academic homepage template**: plain HTML + CSS + vanilla JS, no build step, no package manager, no framework. Originally intended for GitHub Pages but works on any static host.

## Architecture

- **Single-page entry** ([index.html](index.html)) — sections: hero/about, news, experience, selected research, publications, media coverage, service, visitors globe. All sections are placeholder skeletons; fill them in with your own content. The above-the-fold critical CSS is inlined in `<head>`; the rest lives in [style.css](style.css). The self-hosted `Inter` font is loaded from [fonts/](fonts/).
- **Resume page** ([resume.html](resume.html)) — minimal wrapper that is meant to embed a CV PDF via `<iframe>`. By default it shows a placeholder; drop your CV at `docs/cv.pdf` and re-enable the iframe.
- **Scripts** ([js/main.js](js/main.js), [js/globe.js](js/globe.js), [js/hidebib.js](js/hidebib.js)) — vanilla JS. `main.js` handles sticky nav, mobile menu, scroll fade-ins, lazy video play, and the "Show more" news toggle. `globe.js` renders a `cobe` WebGL visitor globe using country counts from [data/globe-data.json](data/globe-data.json). `hidebib.js` toggles BibTeX `<pre>` blocks inside publication cards.
- **Visitor globe pipeline** — [.github/workflows/update-globe.yml](.github/workflows/update-globe.yml) runs [data/update-globe.sh](data/update-globe.sh) daily, hitting the GoatCounter API and writing to `data/globe-data.json`. Requires `GOATCOUNTER_TOKEN` and `GOATCOUNTER_SITE` repo secrets. The shipped JSON is empty — the workflow fills it.

## Build / run

There is no build. Preview locally with any static server (e.g. `python -m http.server`) at the repo root and open `/`. Do **not** add bundlers, npm dependencies, or transpilers — the site is intended to be served as-is.

## Conventions

- **Vanilla JS only**, ES modules loaded directly from `cdn.jsdelivr.net` when needed (see top of [js/globe.js](js/globe.js)). No TypeScript.
- **Asset paths are relative** so the site works on both a root domain and on subpath previews.
- **Media (images / videos / PDFs)** referenced by the template should live under top-level folders like `images/`, `posters/`, `docs/`. These folders are intentionally absent in the template — create them when you add content.
- **SEO** — [index.html](index.html) contains a JSON-LD `Person` schema, Open Graph / Twitter tags, canonical URL, and meta description. All currently use `Your Name` / `https://example.com/` placeholders. Update them together with [sitemap.xml](sitemap.xml) and [robots.txt](robots.txt) when deploying.
- When adding a project sub-page, create a new top-level folder with its own `index.html`, then add a matching `<url>` entry to [sitemap.xml](sitemap.xml) and a card in the `#research` or `#publications` sections of [index.html](index.html).

## Pitfalls

- The globe workflow needs `GOATCOUNTER_TOKEN` and `GOATCOUNTER_SITE` secrets; running [data/update-globe.sh](data/update-globe.sh) locally without them will exit immediately. The shipped `data/globe-data.json` has zero visitors so the globe renders empty until the workflow runs.
- `.gitignore` is Python-oriented from earlier history; it is harmless but does not reflect a Python project.
- The favicon `<link>` was removed from the template — add an `icons/favicon.svg` (or similar) and re-add the `<link rel="icon">` tag in `<head>` when you have one.
