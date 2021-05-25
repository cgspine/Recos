package org.cgsdream.recos.root.ds

interface RecosDataSource {
    suspend fun parse(bundleName: String)

    suspend fun getModule(moduleName: String): FunctionDecl
}

