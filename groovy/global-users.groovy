/**
 * Script was adapted from SO: https://stackoverflow.com/questions/44398287/adding-global-password-to-jenkins-with-init-groovy#44423191
 * Requires the envinject plugin to be loaded
 */
import jenkins.model.*
import hudson.util.*
import hudson.slaves.NodeProperty
import hudson.slaves.NodePropertyDescriptor
import org.jenkinsci.plugins.envinject.*

def instance = Jenkins.getInstance()

DescribableList<NodeProperty<?>, NodePropertyDescriptor> globalNodeProperties = instance.getGlobalNodeProperties();

envInjectNodeProperty= new EnvInjectNodeProperty(false, "/var/lib/jenkins/secret.properties")
propDescriptor = envInjectNodeProperty.getDescriptor()

// create a password entry
def passEntry = new EnvInjectGlobalPasswordEntry("admin", "adminadmin")

// password entries list, add you global password here
List<EnvInjectGlobalPasswordEntry> envInjectGlobalPasswordEntriesList= [passEntry];
propDescriptor.envInjectGlobalPasswordEntries = envInjectGlobalPasswordEntriesList.toArray(
        new EnvInjectGlobalPasswordEntry[envInjectGlobalPasswordEntriesList.size()]
    );
propDescriptor.save();