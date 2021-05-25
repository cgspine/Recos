package org.cgsdream.recos.root.util

import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Deferred
import kotlinx.coroutines.async
import kotlinx.coroutines.supervisorScope
import java.util.concurrent.ConcurrentHashMap

class ConcurrencyShare{
    private val caches = ConcurrentHashMap<String, Deferred<*>>()

    suspend fun <T> joinPreviousOrRun(key: String, block: suspend () -> T): T{
        val activeTask = caches[key] as? Deferred<T>
        activeTask?.let{
            return it.await()
        }

        return supervisorScope {
            // Create a new coroutine, but don't start it until it's decided that this block should
            // execute. In the code below, calling await() on newTask will cause this coroutine to
            // start.
            val newTask = async(start = CoroutineStart.LAZY) {
                block()
            }

            newTask.invokeOnCompletion {
                caches.remove(key, newTask)
            }

            val otherTask = caches.putIfAbsent(key, newTask) as? Deferred<T>
            if(otherTask != null){
                // 被抢占了，等待结果
                newTask.cancel()
                otherTask.await()
            }else{
                newTask.await()
            }
        }
    }

    suspend fun <T> cancelPreviousThenRun(key: String, block: suspend () -> T): T{
        return supervisorScope {
            // Create a new coroutine, but don't start it until it's decided that this block should
            // execute. In the code below, calling await() on newTask will cause this coroutine to
            // start.
            val newTask = async(start = CoroutineStart.LAZY) {
                block()
            }

            newTask.invokeOnCompletion {
                caches.remove(key, newTask)
            }

            val oldTask = caches.put(key, newTask) as? Deferred<T>
            oldTask?.cancel()
            newTask.await()
        }
    }
}