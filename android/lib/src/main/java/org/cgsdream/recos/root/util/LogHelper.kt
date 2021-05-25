package org.cgsdream.recos.root.util

interface RecosLogger {
    fun v(tag: String, message: String)
    fun i(tag: String, message: String)
    fun w(tag: String, message: String)
    fun d(tag: String, message: String)
    fun e(tag: String, message: String, throwable: Throwable? = null)
}

object LogHelper {
    var logger: RecosLogger? = null

    fun v(tag: String, message: String) {
        logger?.v(tag, message)
    }

    fun i(tag: String, message: String) {
        logger?.i(tag, message)
    }

    fun w(tag: String, message: String) {
        logger?.w(tag, message)
    }

    fun d(tag: String, message: String) {
        logger?.d(tag, message)
    }

    fun e(tag: String, message: String, throwable: Throwable? = null) {
        logger?.e(tag, message, throwable)
    }
}