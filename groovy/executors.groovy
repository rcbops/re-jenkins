/*
 * Set the number of executors available on the master
 */
import jenkins.model.*
import java.util.logging.Level
import java.util.logging.Logger

/**
 * Setup the logger
 */
Logger logger = Logger.getLogger("executors.groovy")

logger.log(Level.INFO, "Running executors.groovy...")
def instance = Jenkins.getInstance()

java.lang.Integer num_executors = 3
logger.log(Level.INFO, String.format("Setting executors to: %d", num_executors))
instance.setNumExecutors(num_executors)

java.lang.Integer slave_agent_port = 55000
logger.log(Level.INFO, String.format("Setting slave agent port to: %d", slave_agent_port))
instance.setSlaveAgentPort([slave_agent_port])
