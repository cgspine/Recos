package org.cgsdream.recos.root.ds

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.channels.SendChannel
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import org.cgsdream.recos.root.bundle.BundleProvider
import org.cgsdream.recos.root.js.*
import org.cgsdream.recos.root.cls.JsColsole
import org.cgsdream.recos.root.cls.ClsProvider
import java.util.concurrent.ConcurrentHashMap

class DefaultRecosDataSource(val bundleProvider: BundleProvider,
                             val clsProvider: ClsProvider? = null): RecosDataSource {
    private val waitingChannel = ConcurrentHashMap<String, ArrayList<SendChannel<FunctionDecl>>>()
    private val loadedBundle = mutableSetOf<String>()
    private val mutex = Mutex()
    private val globalStackFrame = JsStackFrame(null)
    private val dummyJsEvaluator = JsEvaluator(DummyRecosDataSource(globalStackFrame.scope))

    override val rootScope: JsScope = globalStackFrame.scope

    override suspend fun parse(bundleName: String) {
        if(loadedBundle.contains(bundleName)){
            return
        }
        mutex.withLock {
            if(loadedBundle.contains(bundleName)){
                return
            }
            withContext(Dispatchers.IO){
                val text = bundleProvider.getBundleContent(bundleName)
                val ret: List<Node?> = Json.decodeFromString(text)
                ret.forEach { node ->
                    if(node != null){
                        dummyJsEvaluator.runNode(globalStackFrame, rootScope, node)
                    }
                }
            }
            loadedBundle.add(bundleName)
            waitingChannel.keys.forEach { name ->
                rootScope.getFunction(name)?.let { func ->
                    waitingChannel[name]?.forEach {  channel ->
                        channel.send(func)
                    }
                }
            }
        }
    }

    override fun getMemberProvider(name: String): JsMemberProvider? {
        if(name == "console"){
            return JsColsole()
        }
        return clsProvider?.provide(name)
    }

    override suspend fun getEntranceFunction(functionName: String): FunctionDecl {
        val exist = rootScope.getFunction(functionName)
        if(exist != null){
            return exist
        }
        val channel = Channel<FunctionDecl>(1, BufferOverflow.DROP_OLDEST)
        val ret = mutex.withLock {
            val exist1 = rootScope.getFunction(functionName)
            if(exist1 != null){
                return@withLock exist1
            }
            val list = waitingChannel[functionName]
            if(list != null){
                list.add(channel)
            }else{
                val toPut = arrayListOf<SendChannel<FunctionDecl>>()
                val old = waitingChannel.putIfAbsent(functionName, toPut)
                old?.add(channel)
            }
            null
        }
        return if(ret == null){
            val value = channel.receive()
            waitingChannel.remove(functionName)
            channel.close()
            value
        }else{
            channel.close()
            ret
        }
    }
}