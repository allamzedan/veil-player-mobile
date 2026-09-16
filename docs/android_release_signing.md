# Android release signing

VEIL Mobile release builds require a project release key stored outside this repository. Debug builds do not require release credentials and continue to use Android's normal debug signing.

## Create the key (one-time human action)

Choose a protected path outside the repository, then run `keytool` interactively so passwords are never written to source or shell history:

```powershell
keytool -genkeypair -v -keystore "C:\secure\veil-mobile-release.jks" -alias veil-mobile -keyalg RSA -keysize 4096 -validity 10000
```

Back up the keystore and its credentials securely. Losing them can prevent compatible future updates.

## Configure Gradle outside the repository

Set these properties in the user-level `%USERPROFILE%\.gradle\gradle.properties` file, or inject environment variables with the same names from a secure CI secret store:

```properties
VEIL_RELEASE_STORE_FILE=C:/secure/veil-mobile-release.jks
VEIL_RELEASE_STORE_PASSWORD=<keystore password>
VEIL_RELEASE_KEY_ALIAS=veil-mobile
VEIL_RELEASE_KEY_PASSWORD=<key password>
```

Do not create a repository-local `key.properties`, and do not copy the keystore into the project.

## Build and verify

```powershell
flutter build apk --release
apksigner verify --verbose --print-certs build\app\outputs\flutter-apk\app-release.apk
```

Without all four external values, release tasks stop with `RELEASE SIGNING MATERIAL -- HUMAN ACTION REQUIRED` instead of producing a debug-signed release artifact.
