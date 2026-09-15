package com.veil.mobile

import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val METHOD_CHANNEL = "veil_mobile/open_intent"
        private const val EVENT_CHANNEL = "veil_mobile/open_intent_events"
        private const val MAX_OPENABLE_BYTES = 500L * 1024L * 1024L
    }

    private var initialIntentPayload: Map<String, String?>? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initialIntentPayload = extractViewIntent(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialOpenIntent" -> {
                        val payload = initialIntentPayload
                        initialIntentPayload = null
                        result.success(payload)
                    }
                    "resolveOpenablePath" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString.isNullOrEmpty()) {
                            result.success(null)
                        } else {
                            result.success(resolveOpenablePath(Uri.parse(uriString)))
                        }
                    }
                    "queryOpenableSize" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString.isNullOrEmpty()) {
                            result.success(null)
                        } else {
                            result.success(queryOpenableSize(Uri.parse(uriString)))
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        eventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        eventSink = null
                    }
                },
            )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val payload = extractViewIntent(intent) ?: return
        initialIntentPayload = payload
        eventSink?.success(payload)
    }

    override fun getInitialRoute(): String {
        if (isExternalFileViewIntent(intent)) {
            return "/"
        }
        return super.getInitialRoute() ?: "/"
    }

    private fun isExternalFileViewIntent(intent: Intent?): Boolean {
        if (intent == null || intent.action != Intent.ACTION_VIEW) {
            return false
        }
        val scheme = intent.data?.scheme?.lowercase() ?: return false
        return scheme == "content" || scheme == "file"
    }

    private fun extractViewIntent(intent: Intent?): Map<String, String?>? {
        if (intent == null) {
            return null
        }
        if (intent.action != Intent.ACTION_VIEW) {
            return null
        }
        val uri = intent.data ?: return null
        return mapOf(
            "uri" to uri.toString(),
            "mimeType" to intent.type,
            "displayName" to queryDisplayName(uri),
        )
    }

    private fun queryDisplayName(uri: Uri): String? {
        if (uri.scheme != "content") {
            return uri.lastPathSegment
        }
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && cursor.moveToFirst()) {
                return cursor.getString(index)
            }
        }
        return uri.lastPathSegment
    }

    private fun queryOpenableSize(uri: Uri): Long? {
        return when (uri.scheme?.lowercase()) {
            "file" -> uri.path?.let { path ->
                val length = File(path).length()
                if (length > 0L) length else null
            }
            "content" -> {
                contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                    val index = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (index >= 0 && cursor.moveToFirst()) {
                        val size = cursor.getLong(index)
                        if (size > 0L) size else null
                    } else {
                        null
                    }
                }
            }
            else -> null
        }
    }

    private fun resolveOpenablePath(uri: Uri): String? {
        return try {
            when (uri.scheme?.lowercase()) {
                "file" -> uri.path?.let { File(it).absolutePath }
                "content" -> copyContentUriToCache(uri)
                else -> null
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun copyContentUriToCache(uri: Uri): String? {
        val size = queryOpenableSize(uri)
        if (size != null && size > MAX_OPENABLE_BYTES) {
            return null
        }

        val input = contentResolver.openInputStream(uri) ?: return null
        val displayName = queryDisplayName(uri) ?: "opened_file"
        val safeName = displayName.replace(Regex("[^a-zA-Z0-9._-]"), "_")
        val outFile = File(cacheDir, "open_intent_${System.currentTimeMillis()}_$safeName")
        input.use { stream ->
            FileOutputStream(outFile).use { output ->
                stream.copyTo(output)
            }
        }
        return outFile.absolutePath
    }
}
