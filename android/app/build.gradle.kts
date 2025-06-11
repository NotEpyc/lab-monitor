plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lab_monitor"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.lab_monitor"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    packagingOptions {
        resources {
            excludes += "META-INF/DEPENDENCIES"
            excludes += "META-INF/LICENSE"
            excludes += "META-INF/LICENSE.txt"
            excludes += "META-INF/NOTICE"
            excludes += "META-INF/NOTICE.txt"
        }
    }

    lint {
        abortOnError = false
    }
}

flutter {
    source = "../.."
}

configurations {
    all {
        exclude(group = "commons-logging", module = "commons-logging")
        exclude(group = "org.apache.httpcomponents", module = "httpclient")
        exclude(group = "javax.naming", module = "javax.naming-api")
        exclude(group = "org.ietf.jgss", module = "ietf-jgss")
    }
}

dependencies {
    // Other dependencies...

    // Add Error Prone Annotations
    implementation("com.google.errorprone:error_prone_annotations:2.11.0")

    // Add Javax Annotation API
    implementation("javax.annotation:javax.annotation-api:1.3.2")

    // Add Joda-Time
    implementation("joda-time:joda-time:2.10.14")

    // Add OkHttp
    implementation("com.squareup.okhttp3:okhttp:4.11.0")
}
