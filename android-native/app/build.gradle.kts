plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.androidnative"
    compileSdk = 34
    ndkVersion = "26.3.11579264"

    defaultConfig {
        applicationId = "com.example.androidnative"
        minSdk = 24
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        externalNativeBuild {
            cmake {
                cppFlags += "-std=c17"
            }
        }

        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
        }
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            val ciStoreFile = System.getenv("ANDROID_KEYSTORE_PATH")
            val ciStorePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD")
            val ciKeyAlias = System.getenv("ANDROID_KEY_ALIAS")
            val ciKeyPassword = System.getenv("ANDROID_KEY_PASSWORD")

            if (!ciStoreFile.isNullOrBlank() && !ciStorePassword.isNullOrBlank() &&
                !ciKeyAlias.isNullOrBlank() && !ciKeyPassword.isNullOrBlank()
            ) {
                signingConfig = signingConfigs.create("ciRelease") {
                    storeFile = file(ciStoreFile)
                    storePassword = ciStorePassword
                    keyAlias = ciKeyAlias
                    keyPassword = ciKeyPassword
                }
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

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
}
