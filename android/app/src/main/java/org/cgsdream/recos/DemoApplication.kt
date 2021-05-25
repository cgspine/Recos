package org.cgsdream.recos

import android.app.Application
import android.content.Context
import android.util.Log
import kotlinx.coroutines.GlobalScope
import org.cgsdream.recos.root.bundle.AssetBundleProvider
import org.cgsdream.recos.root.ds.DefaultRecosDataSource
import org.cgsdream.recos.root.ds.RecosDataSource
import org.cgsdream.recos.root.util.Files
import java.io.File
lateinit var recosDataSource: RecosDataSource

class DemoApplication: Application() {

    override fun onCreate() {
        super.onCreate()
        Thread.setDefaultUncaughtExceptionHandler { t, e ->
            Log.i("cgine", e.stackTraceToString())
        }
        val bundleRootDir =  applicationContext.getDir("bundles", Context.MODE_PRIVATE).apply {
            Files.tryMakeDirs(this)
        }
        val bundleInDir = File(bundleRootDir, "buildIn").apply {
            Files.tryMakeDirs(this)
        }
        val bundleProvider = AssetBundleProvider(
            applicationContext,
            "",
            "assets",
            bundleInDir,
            "1",
            "platform.bundle"
        )


        recosDataSource = DefaultRecosDataSource(bundleProvider)
    }
}