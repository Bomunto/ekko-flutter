allprojects {
    repositories {
        google()
        mavenCentral()
        // The ekko Android library, until the GitLab Maven registry is wired up:
        // `./gradlew :ekko:publishToMavenLocal` in packages/android.
        maven("https://gitlab.com/api/v4/projects/86375044/packages/maven")
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
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
