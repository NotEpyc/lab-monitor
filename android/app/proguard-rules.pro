# Keep Javax Annotations
-keep class javax.annotation.** { *; }

# Keep Crypto Tink Classes
-keep class com.google.crypto.tink.** { *; }

# Keep Google HTTP Client Classes
-keep class com.google.api.client.** { *; }

# Keep Joda-Time Classes
-keep class org.joda.time.** { *; }

# Keep Java Naming and Directory Interface (JNDI) classes
-keep class javax.naming.** { *; }

# Keep Java GSS-API classes
-keep class org.ietf.jgss.** { *; }

# Suppress warnings for missing annotations
-dontwarn javax.annotation.**
-dontwarn com.google.api.client.**
-dontwarn org.joda.time.**
-dontwarn javax.naming.**
-dontwarn org.ietf.jgss.**

# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.api.client.http.GenericUrl
-dontwarn com.google.api.client.http.HttpHeaders
-dontwarn com.google.api.client.http.HttpRequest
-dontwarn com.google.api.client.http.HttpRequestFactory
-dontwarn com.google.api.client.http.HttpResponse
-dontwarn com.google.api.client.http.HttpTransport
-dontwarn com.google.api.client.http.javanet.NetHttpTransport$Builder
-dontwarn com.google.api.client.http.javanet.NetHttpTransport
-dontwarn javax.annotation.concurrent.ThreadSafe
-dontwarn org.joda.time.Instant