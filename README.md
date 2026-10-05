# coffeeimpliescode.com — Zig autodoc

This repository is the source of [coffeeimpliescode.com](https://coffeeimpliescode.com).
It no longer contains the old blog. It builds **Zig autodoc** for a list of Zig
libraries and publishes the result to GitHub Pages.

## How publishing works

`.github/workflows/docs.yml` runs one matrix leg per entry in `projects.json`:

1. check the library repository out at its configured ref,
2. build its autodoc with Zig 0.16.0 —
   `zig build-obj <library root> -femit-docs=<dir>`,
3. strip the `std` module out of `sources.tar`,
4. upload the four-file bundle (`index.html`, `main.js`, `main.wasm`,
   `sources.tar`) as an artifact.

The `deploy` job downloads every artifact, writes a landing page with
`scripts/build-index.mjs`, and deploys with `actions/deploy-pages`. Each library gets
its own subdirectory, so one site serves all of them.

No build-system cooperation is needed: `zig build-obj` with `-femit-docs` ignores
`build.zig` entirely, which is why the pipeline does not call `zig build docs` at all.

A library whose build fails does not cancel the other legs (`fail-fast: false`) and
does not block the deploy (`if: always()`). Its row on the landing page is rendered
as missing, so a broken library is visible instead of silently absent.

Runs are triggered by a push to `main`, weekly on Mondays, and by manual dispatch.

## Adding a library

Append an entry to `projects.json`:

```json
{
  "name": "zmath",
  "repo": "CoffeeImpliesCode/zmath",
  "ref": "main",
  "root": "src/root.zig",
  "description": "IEEE-754 and scalar mathematics for f16/f32/f64."
}
```

| field | meaning |
|---|---|
| `name` | URL segment and artifact name; must be unique |
| `repo` | `owner/name` on GitHub |
| `ref` | branch, tag, or commit to document |
| `root` | library root source file, relative to the repository root |
| `fork_of` | optional; upstream repository, shown on the landing page |
| `description` | one line shown on the landing page |

`root` must be the source file of the module registered under the package's
`build.zig.zon` `.name` — read it off `b.addModule("<name>", .{ .root_source_file = ... })`
in that project's `build.zig`. Do **not** use an executable root: `build-obj` has no
package manager, so a root that imports a module by name (`@import("zmath")`) fails
with `no module named 'zmath' available within module 'main'`.

## Private repositories

Most of the listed libraries are private. The default `GITHUB_TOKEN` cannot read
another repository, so checkout uses a fine-grained token stored as the
`DOCS_TOKEN` repository secret:

```yaml
token: ${{ secrets.DOCS_TOKEN || github.token }}
```

The token is named `Zig autodoc`, expires **2027-01-03**, and grants *Contents:
read-only* on fourteen repositories. It never grants write access, so it cannot
push anything. When it expires the private libraries drop off the site and their
rows appear as missing — regenerate the token and update the secret to bring them
back. Rotate it by deleting the token at
<https://github.com/settings/personal-access-tokens> and repeating
`gh secret set DOCS_TOKEN --repo CoffeeImpliesCode/coffeeimpliescode.github.io`.

Adding a library that is not covered by the token means regenerating it with that
repository selected, or making the library public.

## Why `sources.tar` is stripped

Zig's autodoc tars the **whole standard library** into every `sources.tar`: about
17 MiB per library, fetched by every visitor before the page renders anything. The
search index and the declaration tree live in `main.wasm`, so the workflow keeps only
the library's own sources. The trade-off is that the `[src]` view of `std`
declarations is empty; everything else, including searching std, is unaffected.

## Not published, and why

Every repository below was tested against Zig 0.16.0 and left out because the build
failed. Re-test the fix, then add the entry.

| repository | reason |
|---|---|
| `kernel` | `src/gates.zig:274:42: error: no module named 'build_options' available within module 'kernel'` |
| `ziglint` | `src/main.zig:4:31: error: no module named 'build_options' available within module 'main'` |
| `zopengl` | `src/zopengl.zig:5:31: error: no module named 'build_options' available within module 'zopengl'` |
| `zcov` | `lib/std/c.zig:11013:12: error: dependency on libc must be explicitly specified` |
| `zemscripten` | `src/zemscripten.zig:6:20: error: root source file struct 'testing' has no member named 'refAllDeclsRecursive'` |
| `zeichnung` | `src/main.zig:87:23: error: root source file struct 'heap' has no member named 'GeneralPurposeAllocator'` |
| `zmath-testing` | its only library-shaped root is a leftover `zig init` stub, so autodoc would publish an empty API |
| `tinyfold` | no `build.zig` on the default branch |
| `foundation` | no Zig source at all — a Markdown research repository |
| `nogui`, `noapi`, `zla` | build fine locally but are not published under `CoffeeImpliesCode`, so CI cannot check them out |

`kernel`, `ziglint`, `zopengl` and `zcov` need their module graph, which means either
a `docs` step in their own `build.zig` (`b.addObject(...).getEmittedDocs()`) or a root
that avoids the generated module.

## Serving autodoc locally

Autodoc pages cannot be opened from the filesystem — `main.js` fetches and
instantiates `main.wasm`, which requires HTTP:

```sh
zig build-obj src/root.zig -femit-docs=docs
python3 -m http.server -d docs
```

## Old blog

The previous apollo-typst site is preserved on the `static` branch, unchanged, with
its last deployment from 2026-03-09. History before this rewrite is intact in
`git log main`.