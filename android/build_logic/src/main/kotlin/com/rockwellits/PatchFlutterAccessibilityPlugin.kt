package com.rockwellits

import javassist.ClassPool
import javassist.CtNewMethod
import org.gradle.api.Plugin
import org.gradle.api.Project
import java.io.File
import java.io.FileOutputStream
import java.util.jar.JarEntry
import java.util.jar.JarFile
import java.util.jar.JarOutputStream

class PatchFlutterAccessibilityPlugin : Plugin<Project> {
    override fun apply(project: Project) {
        project.afterEvaluate {
            val buildDir = project.buildDir
            val flutterJarDir = File(buildDir, "intermediates/flutter/flutter_embedding_release")
            if (!flutterJarDir.exists()) {
                project.logger.lifecycle("No Flutter embedding JAR found at $flutterJarDir")
                return@afterEvaluate
            }

            flutterJarDir.walk().filter { it.isFile && it.name.contains("flutter_embedding") }.forEach { jarFile ->
                project.logger.lifecycle("Patching Flutter embedding JAR: $jarFile")
                patchAccessibilityJar(jarFile, project)
            }
        }
    }

    private fun patchAccessibilityJar(jarFile: File, project: Project) {
        val sdkDir = System.getenv("ANDROID_SDK_ROOT")
            ?: throw IllegalStateException("ANDROID_SDK_ROOT environment variable not set")
        val compileSdk = 34
        val androidJarPath = "$sdkDir/platforms/$compileSdk/android.jar"

        val classPool = ClassPool.getDefault()
        classPool.insertClassPath(jarFile.absolutePath)
        classPool.insertClassPath(androidJarPath)
        classPool.importPackage("android.os.Build")
        classPool.importPackage("android.view.accessibility.AccessibilityNodeInfo")
        classPool.importPackage("android.util.Log")
        classPool.importPackage("java.lang.reflect.Field")

        val ctClass = classPool.get("io.flutter.embedding.engine.systemchannels.AccessibilityChannel")
        val ctMethod = ctClass.getDeclaredMethod("createAccessibilityNodeInfo")
        ctMethod.name = "createAccessibilityNodeInfo_original"

        ctClass.addMethod(
            CtNewMethod.make("""
                public android.view.accessibility.AccessibilityNodeInfo createAccessibilityNodeInfo(int virtualViewId) {
                    android.view.accessibility.AccessibilityNodeInfo result = createAccessibilityNodeInfo_original(virtualViewId);
                    try {
                        if (Build.MANUFACTURER.contains("RealWear")) {
                            Object semanticsNode = flutterSemanticsTree.get(Integer.valueOf(virtualViewId));
                            if (semanticsNode != null) {
                                java.lang.reflect.Field valueField = semanticsNode.getClass().getDeclaredField("value");
                                valueField.setAccessible(true);
                                CharSequence value = (CharSequence) valueField.get(semanticsNode);
                                if (value != null && value.length() > 0) {
                                    Log.d("AccessibilityChannel", "Semantics value injected: " + value);
                                    result.setContentDescription(value);
                                }
                            }
                        }
                    } catch(Exception e) {
                        Log.e("AccessibilityChannel", "Patch error", e);
                    }
                    return result;
                }
            """.trimIndent(), ctClass)
        )

        val byteCode = ctClass.toBytecode()
        val tempJar = File(jarFile.parentFile, "temp_${jarFile.name}")
        JarFile(jarFile).use { jar ->
            JarOutputStream(FileOutputStream(tempJar)).use { jarOut ->
                jar.entries().iterator().forEach { entry ->
                    if (entry.name != "io/flutter/embedding/engine/systemchannels/AccessibilityChannel.class") {
                        jarOut.putNextEntry(JarEntry(entry.name))
                        jar.getInputStream(entry).use { input -> input.copyTo(jarOut) }
                    }
                }
                jarOut.putNextEntry(JarEntry("io/flutter/embedding/engine/systemchannels/AccessibilityChannel.class"))
                jarOut.write(byteCode)
            }
        }
        jarFile.delete()
        tempJar.renameTo(jarFile)
        project.logger.lifecycle("Patched AccessibilityChannel in $jarFile")
    }
}
