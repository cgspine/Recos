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
import kotlinx.serialization.json.decodeFromJsonElement
import org.cgsdream.recos.root.bundle.BundleProvider
import org.cgsdream.recos.root.util.ConcurrencyShare
import java.util.concurrent.ConcurrentHashMap

class DefaultRecosDataSource(val bundleProvider: BundleProvider): RecosDataSource {

    private val functionList = ConcurrentHashMap<String, FunctionDecl>()
    private val waitingChannel = ConcurrentHashMap<String, ArrayList<SendChannel<FunctionDecl>>>()
    private val loadedBundle = mutableSetOf<String>()
    private val concurrencyShare = ConcurrencyShare()
    private val mutex = Mutex()

    override suspend fun parse(bundleName: String) {
        if(loadedBundle.contains(bundleName)){
            return
        }
        concurrencyShare.joinPreviousOrRun("parse_${bundleName}"){
            withContext(Dispatchers.IO){
                val text = bundleProvider.getBundleContent(bundleName)
                val ret: List<Node> = Json.decodeFromString(text)
                ret.forEach {
                    if(it.type == TYPE_DECL_FUNC){
                        val func = Json.decodeFromJsonElement<FunctionDecl>(it.content)
                        mutex.withLock {
                            functionList[func.name] = func
                            waitingChannel[func.name]?.forEach {  channel ->
                                channel.send(func)
                            }
                        }
                    }else{
                        throw RuntimeException("Not support global var or program")
                    }
                }
            }
        }
        mutex.withLock {
            loadedBundle.add(bundleName)
        }
    }

    override suspend fun getModule(moduleName: String): FunctionDecl {
        val exist = functionList[moduleName]
        if(exist != null){
            return exist
        }
        val channel = Channel<FunctionDecl>(1, BufferOverflow.DROP_OLDEST)
        val ret = mutex.withLock {
            val exist1 = functionList[moduleName]
            if(exist1 != null){
                return@withLock exist1
            }
            val list = waitingChannel[moduleName]
            if(list != null){
                list.add(channel)
            }else{
                val toPut = arrayListOf<SendChannel<FunctionDecl>>()
                val old = waitingChannel.putIfAbsent(moduleName, toPut)
                old?.add(channel)
            }
            null
        }
        return if(ret == null){
            val value = channel.receive()
            waitingChannel[moduleName]?.let { list ->
                mutex.withLock {
                    list.remove(channel)
                }
            }
            channel.close()
            value
        }else{
            channel.close()
            ret
        }
    }
}