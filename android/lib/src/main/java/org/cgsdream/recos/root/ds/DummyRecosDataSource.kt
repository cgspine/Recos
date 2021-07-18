package org.cgsdream.recos.root.ds

import org.cgsdream.recos.root.js.JsMemberProvider
import org.cgsdream.recos.root.js.JsScope

class DummyRecosDataSource(override val rootScope: JsScope) : RecosDataSource {
    override suspend fun parse(bundleName: String) {
        throw RuntimeException("Not matched method")
    }

    override fun getMemberProvider(name: String): JsMemberProvider? {
        return null
    }

    override suspend fun getEntranceFunction(moduleName: String): FunctionDecl {
        throw RuntimeException("Not matched method")
    }
}