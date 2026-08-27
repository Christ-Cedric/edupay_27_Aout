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
// Depuis l'API 36.1, les plateformes du SDK Android portent une version mineure :
// Google publie `platforms;android-37.0` et `android-37.1`, mais plus aucun
// `android-37`. Un module qui declare seulement `compileSdk = 37` (c'est le cas
// de flutter_secure_storage 11.x) se resout donc vers le hash `android-37`, qui
// n'existe pas — d'ou :
//     Failed to find target with hash string 'android-37'
// On force ici la paire (compileSdk, compileSdkMinor) sur tous les modules
// Android, plugins compris. compileSdk est retro-compatible : compiler contre
// 37.0 ne change ni minSdk ni targetSdk, donc aucun impact sur le runtime.
//
// Passe par la reflexion volontairement : l'extension `android` n'a pas le meme
// type selon qu'il s'agit d'une application ou d'une bibliotheque, et le build
// racine n'applique aucun plugin AGP qui donnerait acces au type statiquement.
val enforcedCompileSdk = 37
val enforcedCompileSdkMinor = 0

subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        val methods = androidExtension.javaClass.methods
        val setCompileSdk = methods.firstOrNull { it.name == "setCompileSdk" && it.parameterCount == 1 }
        val setCompileSdkMinor = methods.firstOrNull { it.name == "setCompileSdkMinor" && it.parameterCount == 1 }
        if (setCompileSdk == null || setCompileSdkMinor == null) {
            logger.warn(
                "compileSdk non force sur ${project.path} : AGP n'expose pas " +
                    "setCompileSdk/setCompileSdkMinor (version trop ancienne ?)",
            )
            return@afterEvaluate
        }
        setCompileSdk.invoke(androidExtension, enforcedCompileSdk)
        setCompileSdkMinor.invoke(androidExtension, enforcedCompileSdkMinor)
    }
}

// Doit rester APRES le bloc ci-dessus : `evaluationDependsOn` evalue `:app`
// immediatement, et on ne peut plus enregistrer d'`afterEvaluate` sur un projet
// deja evalue ("Cannot run Project.afterEvaluate(Action) when the project is
// already evaluated").
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
