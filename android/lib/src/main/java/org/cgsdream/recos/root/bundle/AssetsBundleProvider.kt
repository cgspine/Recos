package org.cgsdream.recos.root.bundle

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.cgsdream.recos.root.util.ConcurrencyShare
import org.cgsdream.recos.root.util.Files
import org.cgsdream.recos.root.util.LogHelper
import java.io.*

private const val TAG = "AssetBundleProvider"

open class AssetBundleProvider(
    val context: Context,
    val bundleSourceDirPath: String,
    val drawableSourceDirPath: String,
    val storageDir: File,
    val version: String,
    val coreBundle: String,
    val preloadBundles: List<String> = emptyList(),
    val checkAndDeleteOldBundles: Boolean = true,
    val supportedDrawableSuffixList: Array<String> = arrayOf(".png", ".jpg")
) : BundleProvider {

    val currentVersionRoot = File(storageDir, version).apply {
        Files.tryMakeDirs(this)
    }

    private val concurrentShare = ConcurrencyShare()

    init {
        if (checkAndDeleteOldBundles) {
            GlobalScope.launch(Dispatchers.IO) {
                deleteOldBundles()
            }
        }
    }


    override suspend fun prepare(): String {
        val isCoreBundleCopied = isBundleCopied(coreBundle)
        val coreBundlePath = if (!isCoreBundleCopied) {
            copyDrawables()
            copyBundle(coreBundle)
        } else {
            File(currentVersionRoot, coreBundle).absolutePath
        }
        try {
            preloadBundles.forEach { bundle ->
                if (bundle != coreBundle) {
                    concurrentShare.joinPreviousOrRun(bundle) {
                        copyBundle(bundle)
                    }
                }
            }
        } catch (e: IOException) {
            LogHelper.e(TAG, "preload bundle failed: ", e)
        }
        return coreBundlePath
    }

    override suspend fun getBundlePath(bundleName: String): String {
        return concurrentShare.joinPreviousOrRun("getBundlePath-$bundleName") {
            copyBundle(bundleName)
        }
    }

    override suspend fun getBundleContent(bundleName: String): String {
        val sourcePath = if (bundleSourceDirPath == "") bundleName else "$bundleSourceDirPath/$bundleName"
        return concurrentShare.joinPreviousOrRun("getBundleContent-$bundleName") {
            withContext(Dispatchers.IO){
                context.assets.open(sourcePath).use {
                    val byteArrayOutput = ByteArrayOutputStream()
                    BufferedOutputStream(byteArrayOutput).use { out ->
                        it.copyTo(out)
                    }
                    byteArrayOutput.toString()
                }
            }
        }
    }

    protected open fun isOldBundleStorage(file: File): Boolean {
        return file.name != version
    }

    private fun deleteOldBundles() {
        storageDir.listFiles()?.forEach {
            if (it.isDirectory && isOldBundleStorage(it)) {
                try {
                    it.deleteRecursively()
                } catch (e: IOException) {
                    LogHelper.e(TAG, "delete old bundle(${it.name}) failed.", e)
                }

            }
        }
    }

    private fun isBundleCopied(bundle: String): Boolean {
        return File(currentVersionRoot, bundle).exists()
    }

    private fun copyBundle(bundle: String): String {
        val installDestination = File(currentVersionRoot, bundle)
        val sourcePath = if (bundleSourceDirPath == "") bundle else "$bundleSourceDirPath/$bundle"
        context.assets.open(sourcePath).use {
            BufferedOutputStream(FileOutputStream(installDestination)).use { out ->
                if (it.copyTo(out) <= 0) {
                    installDestination.deleteRecursively()
                    throw RuntimeException("copy bundle $bundle faild.")
                }
            }
        }
        return installDestination.absolutePath
    }

    private fun copyDrawables() {
        val drawableFolders = context.assets.list(drawableSourceDirPath)
        if (drawableFolders.isNullOrEmpty()) {
            return
        }

        for (folder in drawableFolders) {
            if (!folder.startsWith("drawable")) {
                continue
            }

            val drawableList = context.assets.list("$drawableSourceDirPath/$folder")
            if (drawableList.isNullOrEmpty()) continue

            val installDrawableFolder = File(currentVersionRoot, folder)
            Files.tryMakeDirs(installDrawableFolder)

            for (drawableName in drawableList) {
                if (supportedDrawableSuffixList.find { drawableName.endsWith(it) } == null) {
                    continue
                }
                val file = File(installDrawableFolder, drawableName)
                context.assets.open("$currentVersionRoot/$folder/$drawableName").use {
                    BufferedOutputStream(FileOutputStream(file)).use { out ->
                        it.copyTo(out)
                    }
                }
            }
        }
    }
}