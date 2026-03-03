# Example app

**Run:**

```bash
cd example
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Cases (quick lookup)

| Case | What it shows |
|------|----------------|
| 1 Basic | `@Get` / `@Post`, `@Body`, `@StreamResponse` |
| 2 User | `@QueryKey`, `@Path`, `@Header`, `@Query()` |
| 3 Article | `@Post` / `@Put` / `@Delete`, `@Body`, `@Path('id')` |
| 4 Upload | **Custom client**: `@NetApi(client: 'upload')`, `UploadNetClient`, `ContentType.formData`, `@Part` |
| 5 Nested | `@DataPath('result')` |

All requests use `https://httpbin.org` (set in `main.dart`).

---

## Key files

- `main.dart` — config, `setClient('upload', UploadNetClient(dio))`
- `network/upload_net_client.dart` — custom `INetClient`
- `server/upload_api.dart` — `@NetApi(client: 'upload')`
- `server/demo_server.dart` — stream, basic API
- `server/user_api.dart`, `article_api.dart`, `nested_api.dart` — other cases

---

[Example project on GitHub](https://github.com/Dong-Hong-Li/net_retrofit_kit/tree/main/example)
