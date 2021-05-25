package org.cgsdream.recos.root.util

import java.io.Closeable
import java.io.File
import java.io.IOException

object Files {
    @Synchronized
    fun tryMakeDirs(dir: File): Boolean {
        if (!dir.exists() || !dir.isDirectory) {
            return dir.mkdirs()
        }
        return true
    }

    @Synchronized
    fun tryMakeDirs(url: String): Boolean {
        return tryMakeDirs(File(url))
    }

    fun closeQuietly(c: Closeable?) {
        if (c != null) {
            try {
                c.close()
            } catch (e: IOException) {
            }
        }
    }
}