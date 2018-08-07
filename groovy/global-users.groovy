/**
 * Script was adapted from SO: https://stackoverflow.com/questions/44398287/adding-global-password-to-jenkins-with-init-groovy#44423191
 * Requires the envinject plugin to be loaded
 * Examples of setting up users/credentials:
 * - [Examples of setting credentials for a plugin = https://plugins.jenkins.io/ec2, https://plugins.jenkins.io/slack)
 * - https://stackoverflow.com/questions/29085710/programmatically-getting-jenkins-configuration-for-a-plugin
 * - https://support.cloudbees.com/hc/en-us/articles/217708168-create-credentials-from-groovy
 * - https://github.com/hayderimran7/useful-jenkins-groovy-init-scripts/blob/master/init.groovy
 * - https://ifritltd.com/2018/03/18/advanced-jenkins-setup-creating-jenkins-configuration-as-code-and-applying-changes-without-downtime-with-java-groovy-docker-vault-consul-template-and-jenkins-job/
 * - [Creating Admin User] https://groups.google.com/forum/#!topic/jenkinsci-users/Pb4QZVc2-f0
 * - [Possible auth matrix example](https://gist.github.com/hayderimran7/50cb1244cc1e856873a4)
 */
import groovy.transform.Field
import java.util.logging.Level
import java.util.logging.Logger
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import com.cloudbees.plugins.credentials.*
import hudson.model.*
import hudson.util.*
import jenkins.model.*

// import hudson.security.HudsonPrivateSecurityRealm
// import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
//import org.jenkinsci.plugins.envinject.*

/**
 * Setup the logger
 */
@Field Logger logger = Logger.getLogger("global-users.groovy")

logger.log(Level.INFO, "Running global-users.groovy...")

/**
 * Creates a new user if the user does not exist.
 *
 * @param userID the user's ID
 * @param description a description for the user
 * @param username the user's user name
 * @param password the user's password
 */
void createIfNotExistUser(String userID, String description, String username, String password) {
    CredentialsStore credentialStore = SystemCredentialsProvider.getInstance().getStore()
    List<Credentials> listCredentials = credentialStore.getCredentials(Domain.global())
    user = listCredentials.find {
        cred -> cred.getDescriptor().getId().equals(userID)
    }
    if (user == null) {
        logger.log(Level.INFO, String.format("User %s not found. Adding...", userID))
        // Can't use UUID unless we check for existing user some other way
        //Credentials adminCreds = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,java.util.UUID.randomUUID().toString(), "Admin User", "admin", "adminadmin")
        Credentials creds = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, userID, description, username, password)
        credentialStore.addCredentials(Domain.global(), creds)
        logger.log(Level.INFO, String.format("User %s added.", userID))
    } else {
        logger.log(Level.INFO, String.format("User %s already exists. Not adding...", userID))
    }
}
// String id, String username, PrivateKeySource privateKeySource,
//                                  String passphrase,
//                                  String description
void createIfNotExistSSHKey(String id, String description, String username, String passphrase, String keyfile) {
    CredentialsStore credentialStore = SystemCredentialsProvider.getInstance().getStore()
    List<Credentials> listCredentials = credentialStore.getCredentials(Domain.global())
    user = listCredentials.find {
        cred -> cred.getDescriptor().getId().equals(id)
    }
    if (user == null) {
        logger.log(Level.INFO, String.format("Key %s not found. Adding...", id))
        BasicSSHUserPrivateKey ssh_key_credentials = new BasicSSHUserPrivateKey(
                CredentialsScope.GLOBAL,
                id,
                username,
                new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(keyfile),
                passphrase,
                description)
        credentialStore.addCredentials(Domain.global(), ssh_key_credentials)
        logger.log(Level.INFO, String.format("Key %s added.", id))
    } else {
        logger.log(Level.INFO, String.format("Key %s already exists. Not adding...", id))
    }
}

logger.log(Level.INFO, "Creating users...")
createIfNotExistUser("admin", "Admin User", "admin", "adminadmin")
createIfNotExistUser("ddeal", "David Deal User", "ddeal", "ddealddeal")

logger.log(Level.INFO, "Setting up root SSH key...")
String keyFile = "/var/jenkins_home/.ssh/openstack_dd_id_rsa"
if (new File(keyFile).canRead()) {
    createIfNotExistSSHKey("root", "Root SSH Key", "root", "", keyFile)
} else {
    logger.log(Level.WARNING, String.format("Unable to read input ssh keyFile: %s", keyFile))
}
