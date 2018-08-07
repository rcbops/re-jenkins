/**
 * Script to setup/configure Maven
 * Derived from:
 * - https://wiki.jenkins.io/display/JENKINS/Add+a+Maven+Installation%2C+Tool+Installation%2C+Modify+System+Config
 * - https://wiki.jenkins.io/display/JENKINS/Jenkins+Script+Console
 * - https://github.com/cloudbees/jenkins-scripts
 * - https://github.com/jenkinsci/jenkins-scripts
 * - https://github.com/samrocketman/jenkins-script-console-scripts
 * - https://groups.google.com/forum/#!topic/jenkinsci-users/U9HLBVB5_CM
 */
import java.util.logging.Level
import java.util.logging.Logger
import jenkins.*
import jenkins.model.*
import hudson.*
import hudson.model.*

/**
 * Setup the logger
 */
Logger logger = Logger.getLogger("maven-setup.groovy")

logger.log(Level.INFO, "Running maven-setup.groovy...")
String mavenName = "maven-3"
String mavenVersion = "3.3.9"

def mavenPlugin = Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0]
// Check for installation matching the name
maven3Install = mavenPlugin.installations.find {
    install -> install.name.equals(mavenName)
}

// If no match was found, add an installation.
if (maven3Install == null) {
    logger.log(Level.INFO, String.format("No Maven install for %s found. Adding...", mavenName))

    newMavenInstall = new hudson.tasks.Maven.MavenInstallation('maven-3', null,
            [new hudson.tools.InstallSourceProperty([new hudson.tasks.Maven.MavenInstaller(mavenVersion)])]
    )

    mavenPlugin.installations += newMavenInstall
    mavenPlugin.save()

    logger.log(Level.INFO, String.format("Maven install added: %s:%s", mavenName, mavenVersion))
} else {
    logger.log(Level.INFO, String.format("%s install found - not adding another one.", mavenName))
}

/*
def listMavenInstallations = (mavenPlugin.installations as List)
listMavenInstallations.add(new hudson.tasks.Maven.MavenInstallation("MAVEN3", "/home/jenkins/apache-maven/apache-maven-3.2.3", []))
mavenPlugin.installations = listMavenInstallations
mavenPlugin.save()
*/
