# RFC 017: The command-line tool and the diary data

Status: Accepted · Updated: 2026-11-20 · Code: `Sources/site_tool` (`Program`, `*Command`,
`RootURLArguments*`), `Sources/App/main.swift`, `Sources/DiaryData` (`Diary`, `Entry`, `Diary+URL`)

## Summary

`site_tool` prints the website's data and a few generated files from a terminal, for checking the
generator's output and to choose new ids. It is not a separate binary: the macOS app
executable runs it when it is given arguments. The app's loading ([RFC 005](005-music-loading.md), [RFC 006](006-precomputed-music-data.md)) is cached and
conditional; the tool's `Bracket`, `Music` and diary reads go straight to a URL.

## Invocation

`main.swift` calls `Program.asyncMain()` on macOS when `CommandLine.arguments.count > 1` and
`arguments[1]` does not contain `NSTreatUnknownArgumentsAsOpen`. Otherwise it starts
`SiteAppApp`. Every other platform always starts the app. The `site_tool` sources are filtered to
macOS in the Xcode project and are built into the `SiteApp` target with swift-argument-parser.
CI builds and tests the `SiteApp` scheme; it never runs the tool.

```
<SiteApp executable> [subcommand] <root-url> [options]
```

The root URL is one argument, parsed with `URL(string:)`; a string it rejects throws
`RootURLError.notURLString`. The tool appends a file name to it with `appending(path:)`.

## Commands

`Program` is `site_tool`; `dumpVault` is the default subcommand.

| Command | Reads | Prints |
|---|---|---|
| `dumpVault <url> [--search-string s]` | `shows.json` | Counts of artists, shows, venues; every show (`.full`, newest first); every venue (`.oneLine`); each artist with shows and its shows; optionally the venues and artists matching `s` |
| `dumpLookup <url>` | `shows.json` | The `Lookup` as JSON |
| `dumpBracket <url>` | `music.json` | The `Bracket` as JSON |
| `nextID <url>` | `music.json` | `Next Show: n`, `Next Venue: n`, `Next Artist: n` |
| `dumpDiary <url>` | `diary.json` | `<title> has <n> entries.` |
| `associatedDomains <appID> <bundleID>` | nothing | The `applinks` JSON, appID `<appID>.<bundleID>` |

The JSON dumps use sorted keys, pretty printing and ISO 8601 dates, and are printed once.
`associatedDomains` has a fixed component list: `/bands/*`, `/dates/*`, `/venues/*`,
`/stats.html`, `/settings.html`, `/search.html`.

## How the tool loads

| Command | Path | `Last-Modified` | Bracket cache |
|---|---|---|---|
| `dumpBracket` | `Bracket(url:)` | not read | not read or written |
| `nextID` | `Bracket(url:artistsWithShowsOnly: false)` | not read | not read or written |
| `dumpVault`, `dumpLookup` | `Vault.load` / `Lookup(url:)` with `policy: .download` | not read | the saved `Bracket` only if the download fails, and the download is saved |
| `dumpDiary` | `Diary.load` | not read | none |

`Bracket(url:)` downloads with `.reloadIgnoringLocalCacheData`, decodes, and derives the snapshot
([RFC 006](006-precomputed-music-data.md)); the date it returns is not used. `dumpVault` and `dumpLookup` use [RFC 005](005-music-loading.md)'s
`download` policy, so they always download, save the `Bracket` to the app's Caches file, and print
from it. No `HEAD` is sent.

## The diary

`Diary` (`timestamp`, `colophon`, `header`, `title`, `statics`, `friends`, `entries`) and `Entry`
(`timestamp`, optional `title`, `id`, `comment`) decode `diary.json` at the archive root with the
shared `fromJSON` (ISO 8601 dates), next to `shows.json` and `music.json`. Only `dumpDiary` reads it
today; the app, widgets and intents do not yet. The app is meant to use the diary in the future,
which is why `DiaryData` is compiled into every platform and not limited to the tool.
`Diary.load` does a plain `URLSession.shared` request with no cache policy and no status check.

## Next IDs

The archive's ids are the `ID` strings of `ArchivePath` (its `description`); shows, venues and
artists each have their own map. `nextID` loads the music with
`artistsWithShowsOnly: false`, so artists without shows still hold their ids. For each of the
three maps it strips every non-digit from each key, and parses the result as an `Int` (keys
with no digits are dropped). It builds `0..<count`, removes the existing numbers, and prints the
smallest one left. If nothing is left, it prints the number of keys.

## Rules

1. The tool MUST run only on macOS, and only when `main.swift` finds arguments; with none (or
   with `NSTreatUnknownArgumentsAsOpen` first) the app starts.
2. A command that fails MUST throw, and swift-argument-parser prints the error and exits
   non-zero. The commands catch no errors.
3. `dumpVault` and `dumpLookup` MUST NOT be read as cache-free: they save the `Bracket`
   ([RFC 005](005-music-loading.md) rule 3) and, if the network fails, read the one the app saved.
4. `nextID` MUST load all artists, not only those with shows.
5. The JSON dumps MUST use sorted keys and ISO 8601 dates, so output is stable for diffing.
   The text dumps have no stated stability.

## Rationale

- **Straight to the URL.** `Bracket(url:)` shows what the generator produced now, with no
  dependence on what an earlier run saved.
- **Gaps first.** A new id fills a gap before extending the sequence, so ids stay dense.
- **One executable.** The tool shares the app's model code without a second target.
- **The diary on every platform.** The app will use it, so it is built for the app's platforms
  now, and the tool is its only reader until then.

## Open questions

- `archiveIndices` evaluates `0...(count - 1)`: with an empty map that range is invalid, and
  `nextID` would trap rather than print `0`. Is an empty map possible? See [#1746](https://github.com/bolsinga/site/issues/1746).
- `dumpVault` and `dumpLookup` overwrite the app's saved `Bracket` on a Mac that has run the
  app, and may read it when offline. Is that intended? See [#1747](https://github.com/bolsinga/site/issues/1747).
- `dumpBracket` and `dumpLookup` print `cannot encode ...` and exit zero if the UTF-8 step fails. See [#1748](https://github.com/bolsinga/site/issues/1748).
- The `dumpLookup` abstract says "text output" but the output is JSON. See [#1748](https://github.com/bolsinga/site/issues/1748).
- The id format (prefix and number) is not read here; `nextID` assumes digits in each id.
- Where `shows.json` and `music.json` come from is outside this repo (the generator).
- How the tool is run (path to the built executable, sandbox: the target sets
  `ENABLE_APP_SANDBOX = YES`) is not documented anywhere in the repo. See [#1750](https://github.com/bolsinga/site/issues/1750).
