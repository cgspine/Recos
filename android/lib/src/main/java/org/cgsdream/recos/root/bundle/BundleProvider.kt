package org.cgsdream.recos.root.bundle

interface BundleProvider {
    suspend fun prepare(): String

    suspend fun getBundlePath(bundleName: String): String

    suspend fun getBundleContent(bundleName: String): String
}