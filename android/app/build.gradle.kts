plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun secureSigningValue(name: String): String? =
    providers.gradleProperty(name)
        .orElse(providers.environmentVariable(name))
        .orNull

val releaseStoreFile = secureSigningValue("VEIL_RELEASE_STORE_FILE")
val releaseStorePassword = secureSigningValue("VEIL_RELEASE_STORE_PASSWORD")
val releaseKeyAlias = secureSigningValue("VEIL_RELEASE_KEY_ALIAS")
val releaseKeyPassword = secureSigningValue("VEIL_RELEASE_KEY_PASSWORD")
val releaseSigningAvailable =
    listOf(
        releaseStoreFile,
        releaseStorePassword,
        releaseKeyAlias,
        releaseKeyPassword,
    ).all { !it.isNullOrBlank() }

android {
    namespace = "com.veil.mobile"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.veil.mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningAvailable) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (releaseSigningAvailable) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

flutter {
    source = "../.."
}

gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any { it.name.contains("Release", ignoreCase = true) }
    if (releaseRequested && !releaseSigningAvailable) {
        throw GradleException(
            "RELEASE SIGNING MATERIAL -- HUMAN ACTION REQUIRED: configure external VEIL release signing credentials.",
        )
    }
}
