# RFC 005: Loading the music

Status: Accepted · Updated: 2026-11-22 · Code: `SiteKit/Sources/SiteCore` (`SiteModel`, `VaultModel`),
`SiteKit/Sources/SiteCore/MusicData` (`Vault`, `Lookup`, `Bracket`, `Music`),
`SiteKit/Sources/SiteCore/Utilities` (`URL+LastModified`, `FileManager+CacheCodable`)

## Summary

The archive is one JSON file on the website. It is large and only changes when the website is
regenerated, so the app downloads it only when the server says it changed, and otherwise reads
what it saved from the last download. What is saved, and what is computed before it is saved, is
[RFC 006](006-precomputed-music-data.md). This RFC is when the app goes to the network, when it goes to the cache, and how a
finished load replaces the one before it.

## The path

```
SiteModel.load ─► Vault.load ─► Vault ─► Lookup ─► Bracket ─► Tracker ─► Music
 (when, replace)   (facade)     (query)  (source)  (snapshot)  (derive)   (JSON)
```

| Type | Is | Lives |
|---|---|---|
| `SiteModel` | decides when to load, and swaps in the new model | the app |
| `VaultLoader` | does the loading for `SiteModel` and for App Intents, which can run with no scene, and keeps the last loaded `Vault` and a value made from it | `SiteCore` |
| `VaultProvider` | `VaultLoader` keeping the entity catalog of the loaded `Vault` | the app |
| `VaultModel` | one loaded `Vault` and the session state around it: location, Maps, today | until the next load |
| `Vault` | the read-only query API the app, intents and widgets use; adds URLs and list orders | one load |
| `Lookup` | chooses where the `Bracket` comes from, and answers per-item questions from it | one load |
| `Bracket` | the precomputed snapshot; the only thing saved ([RFC 006](006-precomputed-music-data.md)) | the Caches directory |
| `Tracker`, `Music` | derive the snapshot from the decoded JSON ([RFC 006](006-precomputed-music-data.md)) | one download |

## Where the data comes from

`Lookup.bracket(url:policy:)` decides, from a `LoadPolicy`. Each source is tried at most once per
load.

**`savedIfCurrent`** starts from the saved `Bracket`:

1. **Read the saved `Bracket`.** If it can't be read (missing, purged, or from an older cache
   version), download without asking. If that fails, the load fails with the network's error.
2. **Ask the server.** A `HEAD` request reads `Last-Modified`. If it is newer than the saved
   `Bracket`'s `timestamp`, or the server sent none, the file is downloaded and made into a
   `Bracket`, which is saved. Otherwise the saved `Bracket` is used.
3. **Network failure** (the `HEAD` or the download): use the saved `Bracket`.

**`download`** downloads, saves it, and uses the saved `Bracket` only if that fails. If there is
none, the load fails.

**`uncached`** downloads, and neither reads nor writes the saved `Bracket`. If the download fails,
the load fails. It is for the command line tool ([RFC 017](017-site-tool.md)), which must leave
what the app saved alone.

The date of the archive is the `Bracket`'s `timestamp`, which is the `Last-Modified` of the
download it was made from. It is kept nowhere else.

| Reason | Policy | Effect |
|---|---|---|
| `initial`, `refresh` | `savedIfCurrent` | a launch or a pull to refresh costs a read and a `HEAD` |
| `errorRetry`, `preview` | `download` | always downloads |

## Rules

1. The file MUST NOT be downloaded when the server's `Last-Modified` is not newer than the saved
   `Bracket`'s `timestamp`, unless that can't be read.
2. The server's `Last-Modified` is the archive's version. A server that doesn't send one makes
   every load a download.
3. The saved `Bracket` is a cache: it lives in the Caches directory, and the system may remove
   it. Nothing may depend on it being there. When it can't be read, the load falls back to the
   network, and when both fail the load fails and the error is shown. A download MUST be used even
   when saving it fails. The failure is logged and the older saved `Bracket` is removed, since it
   is older than the download and the next launch would only read it to find that out. The next
   launch downloads again.
4. The date of the archive MUST be kept only in the `Bracket`. Nothing else stores it, so the date
   and the data can't disagree, and when the system removes the cache both go.
5. When loads overlap, the one that started last wins, whatever order they finish in. A
   superseded load MUST NOT change the model.
6. A new load makes a new `Vault` and `VaultModel`, and cancels the old model's tasks. A `Vault`
   is never changed in place.
7. Work that follows a load (the widget snapshot, the Spotlight index, geocoding, location)
   starts from the new model, and is skipped for previews.
8. Every load goes through `VaultLoader` (the app's `VaultProvider`), which calls `Vault.load`. An intent that asks before
   the app has starts a `savedIfCurrent` load. The `initial` load MUST join a load that is already
   running, so a launch with a scene and an intent reads the archive once. A `refresh` and an
   `errorRetry` MUST start their own, in the caller's task, so cancelling them cancels the load,
   and an `initial` load doesn't join one that has finished, so it checks the server itself. The
   provider keeps only the vault of the load that started last (rule 5). It stores no date, as
   the `Bracket` a download saves carries it (rule 4), so a download an intent made isn't
   downloaded again. The tasks of rule 7 stay with `SiteModel`.
9. Code outside `SiteKit/Sources/SiteCore/MusicData` MUST reach the data through `Vault`. `Bracket` is public only for the
   command line tool, which builds one directly and doesn't use the cache.

## Rationale

- **A `HEAD` after the read.** It costs a round trip and no body. The file costs far more, and
  changes rarely, so almost every launch is a local read and one cheap request. The read comes
  first because its date is what the request is about; when the archive has changed, that read
  is the price.
- **The date with the data.** A date kept elsewhere had to be reconciled with the saved `Bracket`:
  a copy older than the date, a failed save, a purged cache. One value in one file has none of
  that, and a load needs no date handed to it.
- **Both fallbacks.** Offline works from the cache. A purged or old cache works from the network.
- **A model that is replaced.** Nothing has to be invalidated after a load, because a load makes
  a new `Vault` instead of changing the old one.
- **Last started wins.** A refresh can begin while a slower load is still going, and the network
  doesn't finish them in the order they began.
