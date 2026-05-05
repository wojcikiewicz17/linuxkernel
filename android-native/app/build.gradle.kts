plugins {
    id("com.android.application")
}

val supportedAbis = listOf("armeabi-v7a", "arm64-v8a")
val requestedAbi = (project.findProperty("ciAbi") as String?)
    ?: (project.findProperty("abiFilter") as String?)

android {
    namespace = "com.example.androidnative"
    compileSdk = 34
    ndkVersion = "26.3.11579264"

    defaultConfig {
        applicationId = "com.example.androidnative"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0-beta"

        externalNativeBuild {
            cmake {
                cFlags += listOf("-std=c17", "-Wall", "-Wextra", "-Werror")
            }
        }

        ndk {
            val abi = requestedAbi?.trim().orEmpty()
            if (abi.isNotEmpty()) {
                require(abi in supportedAbis) {
                    "Unsupported ABI '$abi'. Supported ABI values: ${supportedAbis.joinToString()}"
                }
                abiFilters += abi
            } else {
                abiFilters += supportedAbis
            }
        }
    }

    signingConfigs {
        create("ciRelease") {
            val injectedStoreFile = project.findProperty("android.injected.signing.store.file") as String?
            val injectedStorePassword = project.findProperty("android.injected.signing.store.password") as String?
            val injectedKeyAlias = project.findProperty("android.injected.signing.key.alias") as String?
            val injectedKeyPassword = project.findProperty("android.injected.signing.key.password") as String?

            val envStoreFile = System.getenv("ANDROID_KEYSTORE_PATH")
            val envStorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            val envKeyAlias = System.getenv("ANDROID_KEY_ALIAS")
            val envKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")

            val selectedStoreFile = injectedStoreFile ?: envStoreFile
            val selectedStorePassword = injectedStorePassword ?: envStorePassword
            val selectedKeyAlias = injectedKeyAlias ?: envKeyAlias
            val selectedKeyPassword = injectedKeyPassword ?: envKeyPassword

            if (!selectedStoreFile.isNullOrBlank() && !selectedStorePassword.isNullOrBlank() &&
                !selectedKeyAlias.isNullOrBlank() && !selectedKeyPassword.isNullOrBlank()) {
                storeFile = file(selectedStoreFile)
                storePassword = selectedStorePassword
                keyAlias = selectedKeyAlias
                keyPassword = selectedKeyPassword
            }
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
        }
        release {
            isMinifyEnabled = false
            val ciRelease = signingConfigs.getByName("ciRelease")
            if (ciRelease.storeFile != null) {
                signingConfig = ciRelease
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

tasks.register("verifyReleaseSigningInputs") {
    group = "verification"
    description = "Fail official release when signing inputs are absent."
    doLast {
        val requireSigning = (project.findProperty("requireReleaseSigning") as String?)
            ?.equals("true", ignoreCase = true) == true
        if (!requireSigning) return@doLast

        val hasInjectedSigning = listOf(
            "android.injected.signing.store.file",
            "android.injected.signing.store.password",
            "android.injected.signing.key.alias",
            "android.injected.signing.key.password"
        ).all { !((project.findProperty(it) as String?).isNullOrBlank()) }

        val hasEnvSigning = listOf(
            "ANDROID_KEYSTORE_PATH",
            "ANDROID_KEYSTORE_PASSWORD",
            "ANDROID_KEY_ALIAS",
            "ANDROID_KEY_PASSWORD"
        ).all { !System.getenv(it).isNullOrBlank() }

        require(hasInjectedSigning || hasEnvSigning) {
            "Official release requires complete signing inputs; unsigned release is internal-only."
        }
    }
}

tasks.matching { it.name == "preReleaseBuild" }.configureEach {
    dependsOn("verifyReleaseSigningInputs")
}

tasks.register("betaSourceSelfTest") {
    group = "verification"
    description = "Validate the beta app/session/JNI contract without a device."
    doLast {
        val activity = file("src/main/java/com/example/androidnative/MainActivity.java").readText()
        val native = file("src/main/cpp/native-lib.c").readText()
        require("BETA_INIT_OK" in activity)
        require("BETA_TERMINAL_OK" in activity)
        require("BETA_CLEANUP_OK" in activity)
        require("/system/bin/sh" in activity)
        require("destroyForcibly" in activity)
        require("Java_com_example_androidnative_MainActivity_stringFromJNI" in native)
    }
}
