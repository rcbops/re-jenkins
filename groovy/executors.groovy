/*
 * Set the number of executors available on the master
 */

import jenkins.model.*
import java.util.logging.LogManager
import java.util.logging.Level

private log(String msg) {
    log_info(msg)
}

date_time_format="yyyy-MM-dd'T'HH:mm:ssZ"

private log_debug(String msg) {
    def now = new Date().format(date_time_format)
    println(sprintf("[%s][DEBUG] %s", [now, msg]))
}

private log_info(String msg) {
    def now = new Date().format(date_time_format)
    println(sprintf("[%s][INFO] %s", [now, msg]))
}

private log_warn(String msg) {
    def now = new Date().format(date_time_format)
    println(sprintf("[%s][WARN] %s", [now, msg]))
}

num_executors = 2
log("Setting executors to: " + num_executors)
Jenkins.instance.setNumExecutors(num_executors)