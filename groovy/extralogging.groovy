/**
 * Put any additional logging setup configuration in here
 */
import java.util.logging.Level
import java.util.logging.LogManager
import java.util.logging.Logger

/**
 * Setup the logger
 */
Logger logger = Logger.getLogger("extralogging.groovy")

logger.log(Level.INFO, "Running extralogging.groovy")

///////////////////////////////////////////////////////////////////////////////
// NodePool Plugin Logger Setup
///////////////////////////////////////////////////////////////////////////////

//log("==== extralogging.groovy - Setting up NodePool Logger")

//log("Removing existing Rackspace Log Handlers...")
//def globalLogger = LogManager.getLogManager().getLogger("")
//globalLogger.getHandlers().each { handler -> globalLogger.removeHandler(handler) }
//def consoleHandler = new ConsoleHandler()
//globalLogger.setLevel(Level.INFO)
//globalLogger.addHandler(consoleHandler)

//Logger rootLogger = LogManager.getLogManager().getLogger("")
//LogManager.getLogManager().getLoggerNames().toList().findAll {name -> name.startsWith("com.rackspace")}.sort().each {
//    loggerName ->
//        log(sprintf("  Removing Log Handler for: %s", loggerName))
//        def handlers = LogManager.getLogManager().getLogger(loggerName).getHandlers()
//        handlers.each { handler ->
//            LogManager.getLogManager().getLogger(loggerName).removeHandler(handler)
//            rootLogger.removeHandler(handler)
//        }
//}

//def nodePoolLogName = "com.rackspace.jenkins_nodepool"
//def nodePoolLogLevel = Level.ALL
//def nodePoolLogger = LogManager.getLogManager().getLogger(nodePoolLogName)
//if (nodePoolLogger == null) {
//    nodePoolLogger = new Logger(nodePoolLogName)
//
//    def registered = LogManager.getLogManager().addLogger(nodePoolLogger)
//    if (registered) {
//        log("Registered logger: " + nodePoolLogger.getName())
//    } else {
//        log_warn("Unable to register logger: " + nodePoolLogger.getName())
//    }
//} else {
//    log("Discovered existing logger: " + nodePoolLogger.getName())
//}
//
//// If we don't have a handler, create one and add it.
//if (nodePoolLogger.getHandlers().length == 0) {
//    def nodePoolLogHandler = new ConsoleHandler()
//    nodePoolLogHandler.setLevel(nodePoolLogLevel)
//    nodePoolLogger.addHandler(nodePoolLogHandler)
//    log("No previous handlers - added console handler to " + nodePoolLogger.getName())
//}
//
//// Make sure all the handlers have the appropriate level set
//LogManager.getLogManager().getLogger(nodePoolLogName).getHandlers().each {
//    handler ->
//        log("Setting log level to '" + nodePoolLogLevel + "' on handler for logger: " + nodePoolLogName)
//        handler.setLevel(nodePoolLogLevel)
//}

///////////////////////////////////////////////////////////////////////////////
// Zookeeper Logger Setup
///////////////////////////////////////////////////////////////////////////////

//log("==== extralogging.groovy - Setting up Zookeeper Logger")
//def zookeeperLogName = "org.apache.zookeeper"
//def zookeeperLogLevel = Level.WARNING
//def zookeeperLogger = LogManager.getLogManager().getLogger(zookeeperLogName)
//if (zookeeperLogger == null) {
//    zookeeperLogger = new Logger(zookeeperLogName)
//
//    def registered = LogManager.getLogManager().addLogger(zookeeperLogger)
//    if (registered) {
//        log("Registered logger: " + zookeeperLogger.getName())
//    } else {
//        log_warn("Unable to register logger: " + zookeeperLogger.getName())
//    }
//} else {
//    log(" Discovered existing logger: " + zookeeperLogger.getName())
//}
//
//// If we don't have a handler, create one and add it.
//if (zookeeperLogger.getHandlers().length == 0) {
//    def zookeeperLogHandler = new ConsoleHandler()
//    zookeeperLogHandler.setLevel(zookeeperLogLevel)
//    zookeeperLogger.addHandler(zookeeperLogHandler)
//    log("No previous handlers - added console handler to " + zookeeperLogger.getName())
//}
//
//// Make sure all the handlers have the appropriate level set
//LogManager.getLogManager().getLogger(zookeeperLogName).getHandlers().each {
//    handler ->
//        log("Setting log level to '" + zookeeperLogLevel + "' on handler: " + handler)
//        handler.setLevel(zookeeperLogLevel)
//}

///////////////////////////////////////////////////////////////////////////////
// Logger Setup Summary
///////////////////////////////////////////////////////////////////////////////
//log("Loggers:")
//LogManager.getLogManager().getLoggerNames().toList().sort().each {
//    loggerName -> log(sprintf("  Logger: %s", loggerName))
//}
logger.log(Level.INFO, "Rackspace Loggers:")
LogManager.getLogManager().getLoggerNames().toList().findAll { name -> name.startsWith("com.rackspace") }.sort().each {
    loggerName ->
        logger.log(Level.INFO, sprintf("  Logger Name: %s, Level: %s", loggerName, LogManager.getLogManager().getLogger(loggerName).getLevel()))
        logger.log(Level.INFO, sprintf("  Setting level to: %s", Level.ALL))
        LogManager.getLogManager().getLogger(loggerName).setLevel(Level.ALL)

        logger.log(Level.INFO, sprintf("  Logger Name: %s, Level: %s", loggerName, LogManager.getLogManager().getLogger(loggerName).getLevel()))
        logger.log(Level.INFO, sprintf("  Reviewing handlers for Logger Name: %s", loggerName))
        LogManager.getLogManager().getLogger(loggerName).getHandlers().each {
            handler ->
                logger.log(sprintf("    Discovered logger: %s with handler: %s...", loggerName, handler))
                //log(sprintf("    Setting log level to: %s on logger: %s with handler: %s", Level.ALL, loggerName, handler))
                //handler.setLevel(Level.ALL)
        }
}

logger.log(Level.INFO, sprintf("Reviewing Parent Loggers of com.rackspace..."))
LogManager.getLogManager().getLoggerNames().toList().findAll { name -> name.startsWith("com.rackspace") }.sort().each {
    loggerName ->
        parent = LogManager.getLogManager().getLogger(loggerName).getParent()

        logger.log(Level.INFO, sprintf("  Discovered parent logger %s with level: %s", parent.getName(), parent.getLevel()))
        //log(sprintf("  Parent logger %s level to: %s", parent.getName(), parent.getLevel()))

        //log(sprintf("  Setting parent logger %s level to: %s", parent.getName(), Level.ALL))
        //parent.setLevel(Level.ALL)

        //log(sprintf("  Parent logger %s level set to: %s", parent.getName(), parent.getLevel()))

        logger.log(Level.INFO, sprintf("  Reviewing handlers for parent logger Name: %s", loggerName))
        LogManager.getLogManager().getLogger(loggerName).getParent().getHandlers().each {
            handler ->
                logger.log(Level.INFO, sprintf("    Discovered parent logger: %s with handler: %s with handler level: %s", parent, handler, handler.getLevel()))
                //log(sprintf("    Setting log level to: %s on parent logger: %s with handler: %s", Level.ALL, loggerName, handler))
                handler.setLevel(Level.ALL)
        }
}
