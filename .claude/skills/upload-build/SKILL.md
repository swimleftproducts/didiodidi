---
name: upload-build
description: Build the didiodidi Android release APK and upload it to DigitalOcean Spaces at the fixed download URL. Use when the user asks to "upload the build", "publish a new APK", "push the latest build to spaces", or similar.
---

# Upload build

Builds the Flutter Android release APK and publishes it to the fixed public
download URL, overwriting whatever was there before:

```
https://didiodidi.sfo3.cdn.digitaloceanspaces.com/builds/didiodidi-app-release.apk
```

This is the established convention for this project — one stable filename,
always overwritten, so any link to it (e.g. from the landing page) never
needs to change between releases.

## Steps

1. Build the release APK:
   ```
   cd app && flutter build apk --release
   ```
   Output lands at `app/build/app/outputs/flutter-apk/app-release.apk`. If
   the build fails, stop and report the error — do not upload a stale or
   partial APK.

2. Upload it with `s3cmd`, using the project-specific config
   (`~/.s3cfg-didiodidi` — do NOT use the default `~/.s3cfg`, which points at
   an unrelated Cloudflare R2 account):
   ```
   s3cmd -c ~/.s3cfg-didiodidi put \
     app/build/app/outputs/flutter-apk/app-release.apk \
     s3://didiodidi/builds/didiodidi-app-release.apk \
     --acl-public \
     --mime-type=application/vnd.android.package-archive
   ```

3. Report the public URL back to the user:
   `https://didiodidi.sfo3.cdn.digitaloceanspaces.com/builds/didiodidi-app-release.apk`

## Notes

- This overwrites the live download link in place — anyone who already has
  the URL bookmarked gets the new APK immediately. Mention this when
  reporting completion; don't ask for confirmation before running (that's
  the point of the skill), but do surface the APK's file size and build
  timestamp so the user can sanity-check what just went out.
- No code signing is configured yet (CLAUDE.md Section 13: APK is distributed
  unsigned, by email/download, no Play Store in v1). This produces the same
  kind of build.
- If `s3cmd` reports an auth error, check `~/.s3cfg-didiodidi` exists and is
  valid before assuming it's a Spaces-side issue.
