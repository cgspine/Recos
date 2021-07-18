package org.cgsdream.recos.root.js

enum class VariableKind {
    LET,
    VAR,
    CONST;
    companion object {
        fun from(kind: String): VariableKind {
            return when(kind){
                "let" -> LET
                "const" -> CONST
                else -> VAR
            }
        }
    }
}

data class JsVariable(
    val name: String,
    val kind: VariableKind,
    private var value: Any? = null
) {
    fun getValue(): Any? {
        return value
    }

    fun updateValue(value: Any?) {
        this.value = value
    }
}

fun Any?.checkForJsValue(): Any?{
    if(this is JsVariable){
        return this.getValue()
    }else if(this is JsMember){
        return obj.getMemberValue(name)
    }
    return this
}