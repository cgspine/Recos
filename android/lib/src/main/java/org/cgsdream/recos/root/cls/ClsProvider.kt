package org.cgsdream.recos.root.cls

import org.cgsdream.recos.root.js.JsMemberProvider

// TODO use annotation
interface ClsProvider {
    fun provide(name: String): JsMemberProvider
}