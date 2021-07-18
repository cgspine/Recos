package org.cgsdream.recos.root.util

import org.cgsdream.recos.root.js.JsObject

fun Map<String, Any?>.getAsInt(key: String): Int? {
    val value = get(key)
    if(value is Int){
        return value
    }
    return (get(key) as? Float)?.toInt()
}

fun Map<String, Any?>.getAsInt(key: String, defaultValue: Int): Int {
    return getAsInt(key) ?: defaultValue
}

fun Map<String, Any?>.getAsBool(key: String): Boolean? {
    return get(key) as? Boolean
}

fun Map<String, Any?>.getAsBool(key: String, defaultValue: Boolean): Boolean {
    return get(key) as? Boolean ?: defaultValue
}

fun Map<String, Any?>.getAsString(key: String): String? {
    return get(key) as? String
}

fun Map<String, Any?>.getAsString(key: String, defaultValue: String): String {
    return get(key) as? String ?: defaultValue
}

fun Map<String, Any?>.getAsFloat(key: String): Float? {
    val value = get(key)
    if(value is Float){
        return value
    }
    return (get(key) as? Int)?.toFloat()
}

fun Map<String, Any?>.getAsFloat(key: String, defaultValue: Float): Float {
    return getAsFloat(key) ?: defaultValue
}


fun JsObject.getAsInt(key: String): Int? {
    val value = getValue(key)
    if(value is Int){
        return value
    }
    return (value as? Float)?.toInt()
}

fun JsObject.getAsInt(key: String, defaultValue: Int): Int {
    return getAsInt(key) ?: defaultValue
}

fun JsObject.getAsBool(key: String): Boolean? {
    return getValue(key) as? Boolean
}

fun JsObject.getAsBool(key: String, defaultValue: Boolean): Boolean {
    return getValue(key) as? Boolean ?: defaultValue
}

fun JsObject.getAsString(key: String): String? {
    return getValue(key) as? String
}

fun JsObject.getAsString(key: String, defaultValue: String): String {
    return getValue(key) as? String ?: defaultValue
}

fun JsObject.getAsFloat(key: String): Float? {
    val value = getValue(key)
    if(value is Float){
        return value
    }
    return (value as? Int)?.toFloat()
}

fun JsObject.getAsFloat(key: String, defaultValue: Float): Float {
    return getAsFloat(key) ?: defaultValue
}