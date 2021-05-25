package org.cgsdream.recos.root.page

import android.util.Log
import androidx.compose.ui.platform.ComposeView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import org.cgsdream.recos.root.ds.FunctionDecl
import org.cgsdream.recos.root.ds.JsEvaluator
import org.cgsdream.recos.root.ds.RecosDataSource

class RecosPage(val dataSource: RecosDataSource,
                val bundleName: String,
                val moduleName: String): LifecycleObserver {
    private var composeView: ComposeView? = null
    private var isResumed: Boolean = false
    private var pageData: FunctionDecl? = null
    private val job: Job = Job()
    private var scope = CoroutineScope(Dispatchers.Main + job)
    private var jsEvaluator = JsEvaluator()

    init {
        scope.launch {
            try {
                dataSource.parse(bundleName)
            }catch (e: Throwable){
                Log.i("cgine", e.stackTraceToString())
            }

            val data = dataSource.getModule(moduleName)
            pageData = data
            composeView?.setContent {
                jsEvaluator.Eval(functionDecl = data)
            }
        }
    }

    fun attach(composeView: ComposeView){
        this.composeView = composeView
        pageData?.let {
            composeView.setContent {
                jsEvaluator.Eval(functionDecl = it)
            }
        }
    }

    fun detach() {
        composeView?.setContent { }
        composeView = null
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    fun onCreate() {

    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onResume() {
        isResumed = true
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    fun onPause() {
        isResumed = false
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    fun onDestroy() {
        detach()
        job.cancel()
    }
}