# HJSON Compatibility Review

## Scope
Reviewed all `*.hjson` files under:

- `mod.hjson`
- `content/items/*.hjson`
- `content/liquids/*.hjson`
- `content/planets/*.hjson`
- `content/status/*.hjson`
- `content/units/*.hjson`
- `content/weathers/*.hjson`

## Findings

### 1) No obvious syntax blockers for Mindustry-style HJSON
Current files consistently use key/value maps and arrays in a way that aligns with standard Mindustry mod content conventions.

### 2) Potential portability concerns for non-HJSON tooling
Several patterns are valid HJSON, but can break in strict JSON pipelines (or in editors/lint tools that only partially support HJSON):

- Unquoted string values (for example, `type: legs`, `shootSound: railgun`).
- Hash comments (for example, section comments in weapon lists).
- Bare hex-like tokens used for colors (for example, `colors: [b892ff, d9e1ff, ffffff]`).

These are legal in HJSON, but not legal in strict JSON without transformation.

## Suggested Improvements

1. **Quote non-numeric scalar strings consistently**
   - Safer for mixed tooling and easier machine conversion.
   - Example target style: `type: "legs"`, `shootSound: "railgun"`, `color: "b892ff"`.

2. **Prefer `//` comments (or reduce inline commentary in content files)**
   - Some third-party HJSON parsers are more predictable with JSON-like comment styles.
   - If high portability is required, move large commentary blocks to markdown docs.

3. **Add an automated parse check in CI**
   - Parse every `*.hjson` file with the same parser/runtime your game build uses.
   - Fail fast on malformed content before release.

4. **Document a single style guide for content authors**
   - Define quoting rules, comments policy, and color token format.
   - This prevents drift as the content library grows.

## Optional Next Step
If you want, I can follow up with a mechanical cleanup pass that normalizes string quoting across the whole `content/` tree while preserving behavior.
