allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Certains plugins (ex. flutter_secure_storage 8.x) épinglent un compileSdk 33
// en dur, trop ancien pour leurs dépendances androidx récentes qui exigent 34+.
// On relève ces sous-projets au même niveau que l'app (SDK 36, déjà installé
// sur la machine) sans toucher à l'app elle-même. Ce bloc doit être enregistré
// AVANT le `evaluationDependsOn(":app")` ci-dessous, sinon l'`afterEvaluate`
// arriverait trop tard sur un sous-projet déjà évalué.
subprojects {
    afterEvaluate {
        (extensions.findByName("android") as? com.android.build.gradle.BaseExtension)?.let { ext ->
            val current = ext.compileSdkVersion
                ?.substringAfter("android-")
                ?.toIntOrNull() ?: 0
            if (current in 1 until 36) {
                ext.compileSdkVersion(36)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
