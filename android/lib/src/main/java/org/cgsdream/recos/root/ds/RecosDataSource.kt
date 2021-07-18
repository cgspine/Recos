package org.cgsdream.recos.root.ds

import org.cgsdream.recos.root.js.JsMemberProvider
import org.cgsdream.recos.root.js.JsScope

interface RecosDataSource {

    val rootScope: JsScope

    suspend fun parse(bundleName: String)

    fun getMemberProvider(name: String): JsMemberProvider?

    suspend fun getEntranceFunction(functionName: String): FunctionDecl
}

