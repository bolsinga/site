# RFC 005: Loading the music

Status: Accepted · Updated: 2026-11-20 · Code: `Sources/Site/Music` (`SiteModel`, `VaultModel`),
`Shared/Sources/Shared/MusicData` (`Vault`, `Lookup`, `Bracket`, `Music`),
`Shared/Sources/Shared/Utilities` (`URL+LastModified`, `FileManager+CacheCodable`)

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
| `VaultProvider` | the `Vault` for App Intents, which can run with no scene: it is given each load, and loads one itself if asked first | the app |
| `VaultModel` | one loaded `Vault` and the session state around it: location, Maps, today | until the next load |
| `Vault` | the read-only query API the app, intents and widgets use; adds URLs and list orders | one load |
| `Lookup` | chooses where the `Bracket` comes from, and answers per-item questions from it | one load |
| `Bracket` | the precomputed snapshot; the only thing saved ([RFC 006](006-precomputed-music-data.md)) | the Caches directory |
| `Tracker`, `Music` | derive the snapshot from the decoded JSON ([RFC 006](006-precomputed-music-data.md)) | one download |

## Where the data comes from

`LoadAttempt` in `Lookup` is a small state machine. Each source is tried at most once per load.

1. **Ask the server.** A `HEAD` request reads `Last-Modified`. If it is newer than the date the
   app last loaded, or the server sent none, the file is downloaded and made into a `Bracket`,
   which is saved. Otherwise the saved `Bracket` is read.
2. **Network failure** (the `HEAD` or the download): read the saved `Bracket`. If that also
   fails, the load fails with the network's error.
3. **Cache failure** (missing, purged, or from an older cache version): download, without the
   `HEAD`. If that also fails, the load fails.

The date the app last loaded is the `Bracket`'s `timestamp`, which is the `Last-Modified` of
the download it was made from. `SiteModel` keeps it in memory and in `@AppStorage`:

| Reason | Date used | Effect |
|---|---|---|
| `initial` | the stored date | a launch costs a `HEAD` and a read |
| `refresh` | the date of the last load | a pull to refresh costs a `HEAD` |
| `errorRetry`, `preview` | none | always downloads |

## Rules

1. The file MUST NOT be downloaded when the server's `Last-Modified` is not newer than the stored
   date, unless the saved `Bracket` can't be read.
2. The server's `Last-Modified` is the archive's version. A server that doesn't send one makes
   every load a download.
3. The saved `Bracket` is a cache: it lives in the Caches directory, and the system may remove
   it. Nothing may depend on it being there. When it can't be read, the load falls back to the
   network, and when both fail the load fails and the error is shown. A download MUST be used even
   when saving it fails. The failure is logged and the older saved `Bracket` is removed, since the
   stored date is the download's and the next launch would otherwise read the older one as its
   copy. The next launch downloads again.
4. A saved `Bracket` whose `timestamp` is older than the stored date MUST NOT be used while the
   network works. It is a cache failure, so the file is downloaded without a `HEAD`. When the
   network has failed, it is used anyway.
5. When loads overlap, the one that started last wins, whatever order they finish in. A
   superseded load MUST NOT change the model.
6. A new load makes a new `Vault` and `VaultModel`, and cancels the old model's tasks. A `Vault`
   is never changed in place.
7. Work that follows a load (the widget snapshot, the Spotlight index, geocoding, location)
   starts from the new model, and is skipped for previews.
8. A load that isn't made by `SiteModel` can still happen: `VaultProvider` loads when an intent
   asks before the app has, with `Vault.load` and the stored last-modified date, so it follows
   rules 1 to 5, from the saved `Bracket` when it is current. `SiteModel` hands every vault it
   loads to the provider, and a vault it hands over replaces the provider's. A launch with a
   scene and an intent can make both loads. The tasks of rule 7 stay with `SiteModel`.
9. Code outside `Shared` MUST reach the data through `Vault`. `Bracket` is public only for the
   command line tool, which builds one directly and doesn't use the cache.

## Rationale

- **A `HEAD` first.** It costs a round trip and no body. The file costs far more, and changes
  rarely, so almost every launch is one cheap request and a local read.
- **Both fallbacks.** Offline works from the cache. A purged or old cache works from the network.
- **A model that is replaced.** Nothing has to be invalidated after a load, because a load makes
  a new `Vault` instead of changing the old one.
- **Last started wins.** A refresh can begin while a slower load is still going, and the network
  doesn't finish them in the order they began.
