package org.cgsdream.recos.root.js

import java.lang.IllegalArgumentException
import java.lang.RuntimeException

class JsVarExistException(val name: String): RuntimeException("$name is already existed in current scope.")

class JsVarOptionException(msg: String): RuntimeException(msg)

class JsIllegalArgumentException(msg: String): IllegalArgumentException(msg)