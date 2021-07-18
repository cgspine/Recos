package org.cgsdream.recos.root.js

interface JsMemberProvider {
    fun getMemberValue(name: Any): Any?
    fun setMemberValue(name: Any, value: Any?)
}

class JsObject: JsMemberProvider {
    private var fields: MutableMap<Any, Any?> = hashMapOf()

    fun getValue(variable: Any): Any? {
        return fields[variable] ?: (fields["__proto__"] as? JsObject)?.fields?.get(variable)
    }

    fun setValue(variable: Any, value: Any?) {
        fields[variable] = value
    }

    override fun setMemberValue(name: Any, value: Any?) {
        setValue(name, value)
    }

    override fun getMemberValue(name: Any): Any?{
        return getValue(name)
    }
}

class JsArray: JsMemberProvider {
    private var list = arrayListOf<Any?>()

    fun push(item: Any?) {
        list.add(item)
    }

    fun get(index: Int): Any? {
        return list[index]
    }

    fun itemCount(): Int {
        return list.size
    }

    override fun hashCode(): Int {
        return 31 + list.hashCode()
    }

    override fun equals(other: Any?): Boolean {
        if (other !is JsArray) {
            return false
        }
        if (other.list.size != list.size) {
            return false
        }
        for (i in 0 until other.list.size) {
            if (list[i] != other.list[i]) {
                return false
            }
        }
        return true
    }

    override fun toString(): String {
        return "[JsArray(size = ${itemCount()}, hashCode = ${hashCode()})]"
    }

    override fun getMemberValue(name: Any): Any? {
        return when (name) {
            "push" -> return JsArrayPushMethod(this)
            "length" -> list.size
            else -> {
                return if (name is Float) {
                    list[name.toInt()]
                } else if (name is Int) {
                    list[name]
                } else {
                    throw RuntimeException("Not supported member: $name")
                }
            }
        }
    }

    override fun setMemberValue(name: Any, value: Any?) {
        if (name is Float) {
            list[name.toInt()] = value
        } else if (name is Int) {
            list[name] = value
        } else {
            throw RuntimeException("Not supported memberSetter: $name")
        }
    }
}

class JsMember(
    val obj: JsMemberProvider,
    val name: Any,
)