plugins {
    `kotlin-dsl`
}

repositories {
    google()
    mavenCentral()
}

dependencies {
    implementation("com.android.tools.build:gradle:8.5.2")
    implementation("org.javassist:javassist:3.28.0-GA")
    implementation("commons-io:commons-io:2.11.0")
}

gradlePlugin {
    plugins {
        create("patchFlutterAccessibilityPlugin") {
            id = "com.rockwellits.patchflutteraccessibility"
            implementationClass = "com.rockwellits.PatchFlutterAccessibilityPlugin"
        }
    }
}