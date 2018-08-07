/**
 * Setup/config for nodepool plugin configuration
 * Examples derived from: 
 * - https://stackoverflow.com/questions/29085710/programmatically-getting-jenkins-configuration-for-a-plugin
 * - https://support.cloudbees.com/hc/en-us/articles/217708168-create-credentials-from-groovy
 */
import java.util.logging.Level
import java.util.logging.Logger
import jenkins.model.*
import net.sf.json.JSONObject

/**
 * Setup the logger
 */
Logger logger = Logger.getLogger("nodepool-plugin.groovy")

/**
 * Print out plugin details.
 * @param plugin a plugin object reference
 */
void printPluginDetails(Object plugin) {
    //def plugin = hudson.model.Hudson.instance.pluginManager.getPlugin("nodepool-agents")
    //println(String.format("Plugin: %s, %s", plugin.getClass().getName(), plugin.getVersion()))
    //println ""
    //println(String.format("nodepool-agents getUpdateInfo() : %s", plugin.getUpdateInfo()))

    println ""
    println "nodepool-agents plugin methods"
    for (i in plugin.getClass().getMethods()) {
        println i.toString().replace("hudson.PluginWrapper.", "").replace("java.lang.", "").replace("java.util.", "").replace(" ", "\t")
    }

    println ""
    println "nodepool-agents plugin fields"
    for (i in plugin.getClass().getFields()) {
        println i.toString().replace("hudson.PluginWrapper.", "").replace("java.lang.", "").replace("java.util.", "").replace(" ", "\t")
    }

    println ""
    println(String.format("nodepool-agents plugin.getPlugin().getClass().getName(): %s", plugin.getPlugin().getClass().getName()))
    println ""
    println "nodepool-agents plugin.getPlugin() methods"
    for (i in plugin.getPlugin().getClass().getMethods()) {
        println i.toString().replace("hudson.PluginWrapper.", "").replace("java.lang.", "").replace("java.util.", "").replace(" ", "\t").replace("java.lang", "")
    }
}

/**
 * Generates and returns a nodepool plugin configuration as a JSONObject.
 *
 * @return a nodepool plugin configuration as a JSONObject.
 */
JSONObject generateConfig() {
    Map<String, String> config = new HashMap<String, String>()
    config.put("connectionString", "23.253.248.16:2181")
    config.put("credentialsId", "root")
    config.put("requestRoot", "requests")
    config.put("priority", "100")
    config.put("labelPrefix", "nodepool-dd-")
    config.put("zooKeeperRoot", "nodepool")
    config.put("nodeRoot", "nodes")
    config.put("jdkInstallationScript", "apt-get update && apt-get install openjdk-8-jre-headless -y")
    config.put("jdkHome", "/usr/lib/jvm/java-8-openjdk-amd64")
    JSONObject jsonObject = JSONObject.fromObject(config)
    println String.format("JSONObject: %s", jsonObject)

    return jsonObject
}

logger.log(Level.INFO, "Running nodepool-plugin.groovy...")

//def jenkinsInstance = Jenkins.getInstance()
// Figure this out: def desc = inst.getDescriptor("hudson.plugins.git.GitSCM")
plugin = hudson.model.Hudson.instance.pluginManager.getPlugin("nodepool-agents")
print(String.format("Plugin: %s", plugin))
// Also seen this way
def pluginWrapper = jenkins.model.Jenkins.instance.getPluginManager().getPlugin('nodepool-agents')
print(String.format("Plugin Wrapper: %s", pluginWrapper))
def nodepoolPlugin = pluginWrapper.getPlugin()
print(String.format("Plugin Wrapper Plugin class: %s", nodepoolPlugin))
//printPluginDetails(nodepoolPlugin)

//plugin.getPlugin().configure(generateConfig)
//plugin.getPlugin().save()

nodepoolPlugin.configure(null, generateConfig())
nodepoolPlugin.save()

//def nodepoolDescriptor = jenkinsInstance.getDescriptor("com.rackspace.jenkins_nodepool.NodePoolDescriptor")
//logger.log(Level.INFO, String.format("Configuring Nodepool: %s", nodepoolDescriptor))
/*
configuration = new com.rackspace.jenkins_nodepool.Nodepool(
        "23.253.248.16:2181",  // connectionString
        "root",                // credentialsId
        "requests",            // requestRoot
        "100",                 // priority
        "nodepool-dd-",        // labelPrevix
        "nodepool",            // zooKeeperRoot
        "nodes",               // nodeRoot
        "apt-get update && apt-get install openjdk-8-jre-headless -y",  // jdkInstallationScript
        "/usr/lib/jvm/java-8-openjdk-amd64"                             // jdkHome
)

nodepoolDescriptor.addConfiguration(configuration)
nodepoolDescriptor.save()
*/
