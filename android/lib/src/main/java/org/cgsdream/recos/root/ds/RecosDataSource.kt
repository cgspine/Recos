package org.cgsdream.recos.root.ds

interface RecosDataSource {
    suspend fun parse(bundleName: String)

    fun getExitModule(moduleName: String): FunctionDecl?

    suspend fun getModuleAndWait(moduleName: String): FunctionDecl
}

