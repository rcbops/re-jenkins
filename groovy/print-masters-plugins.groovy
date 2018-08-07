import hudson.PluginWrapper

def pcount = 0
def pstr = ''

List<PluginWrapper> plist = new ArrayList<PluginWrapper>()
plist.addAll(jenkins.model.Jenkins.instance.pluginManager.plugins)

plist.sort { it.shortName }.each {
    pcount = pcount + 1
    pname = (pcount + '. ' + it).replaceAll("Plugin:", '')
    pstr = pstr + ' ' + String.format("%s:%s:active=%b:archive=%s:pluginClass=%s\n", pname, it.getVersion(), it.active, it.archive, it.getPluginClass())
}

println pstr  // Console Output
