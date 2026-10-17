package com.bitbirds.simplymuslim

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Typeface
import android.os.Build
import android.text.SpannableString
import android.text.Spanned
import android.text.style.StyleSpan
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

/** 4x1 home-screen widget: Fajr..Isha in one row, highlighted prayer bold with a
 * gold dot under the current prayer (or the next one between windows). Renders only from the `prayer_widget_data` JSON Dart persists
 * (PrayerWidgetService) — never calculates prayer times natively, same
 * contract as BootReceiver/alarm_api_contract.md. Re-renders itself at the
 * next prayer boundary (or midnight) via its own AlarmManager broadcast. */
class PrayerWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "PrayerWidgetProvider"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_DATA = "flutter.prayer_widget_data"

        const val ACTION_REFRESH = "com.bitbirds.simplymuslim.PRAYER_WIDGET_REFRESH"
        const val ACTION_PINNED = "com.bitbirds.simplymuslim.PRAYER_WIDGET_PINNED"
        const val EXTRA_OPEN_ROUTE = "open_route"
        const val ROUTE_PRAYER_TIME = "/prayer-time"

        // Distinct from AlarmArmer's request codes (0..n prayer indexes).
        private const val REFRESH_REQUEST_CODE = 9100
        private const val OPEN_REQUEST_CODE = 9101
        private const val PRAYER_COUNT = 5

        private val nameIds = intArrayOf(R.id.name_0, R.id.name_1, R.id.name_2, R.id.name_3, R.id.name_4)
        private val timeIds = intArrayOf(R.id.time_0, R.id.time_1, R.id.time_2, R.id.time_3, R.id.time_4)
        private val dotIds = intArrayOf(R.id.dot_0, R.id.dot_1, R.id.dot_2, R.id.dot_3, R.id.dot_4)
        private val defaultNames = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")

        /** Re-render every placed instance and reschedule the next refresh. */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, PrayerWidgetProvider::class.java))
            if (ids.isEmpty()) {
                cancelRefresh(context)
                return
            }
            val state = loadState(context)
            val views = buildViews(context, state)
            manager.updateAppWidget(ids, views)
            scheduleRefresh(context, state?.nextChangeAt)
        }

        private class State(
            val names: List<String>,
            val times: List<Long>?, // null = no usable data
            val highlight: Int, // -1 = none
            val nextChangeAt: Long?,
        )

        private fun loadState(context: Context): State? {
            val raw = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getString(KEY_DATA, null) ?: return null
            return try {
                val root = JSONObject(raw)
                val namesJson = root.optJSONArray("names")
                val names = if (namesJson != null && namesJson.length() == PRAYER_COUNT) {
                    List(PRAYER_COUNT) { namesJson.getString(it) }
                } else defaultNames

                val now = System.currentTimeMillis()
                val days = root.optJSONArray("days")
                val rows = mutableListOf<Pair<List<Long>, List<Long>>>() // starts, ends
                if (days != null) {
                    for (i in 0 until days.length()) {
                        val day = days.getJSONObject(i)
                        val starts = day.optJSONArray("starts") ?: continue
                        val ends = day.optJSONArray("ends") ?: continue
                        if (starts.length() != PRAYER_COUNT || ends.length() != PRAYER_COUNT) continue
                        rows += List(PRAYER_COUNT) { starts.getLong(it) } to List(PRAYER_COUNT) { ends.getLong(it) }
                    }
                }
                // Current prayer = the window containing now (same windows as
                // the app: Fajr ends at sunrise, Isha at mid-night). Between
                // windows (sunrise..Dhuhr, late night) highlight the next one.
                // Rows are persisted ascending, starting at yesterday.
                for ((starts, ends) in rows) {
                    for (p in 0 until PRAYER_COUNT) {
                        if (now >= starts[p] && now < ends[p]) {
                            val nextStart = rows.flatMap { it.first }.firstOrNull { it > now }
                            val change = if (nextStart != null) minOf(ends[p], nextStart) else ends[p]
                            return State(names, starts, p, change)
                        }
                    }
                }
                for ((starts, _) in rows) {
                    val next = starts.indexOfFirst { it > now }
                    if (next != -1) return State(names, starts, next, starts[next])
                }
                State(names, null, -1, null)
            } catch (e: Exception) {
                Log.w(TAG, "Bad widget data", e)
                null
            }
        }

        private fun buildViews(context: Context, state: State?): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.widget_prayer_times)
            val names = state?.names ?: defaultNames
            val timeFormat = SimpleDateFormat("h:mm a", Locale.US)

            for (i in 0 until PRAYER_COUNT) {
                val highlighted = state?.highlight == i
                val time = state?.times?.get(i)?.let { timeFormat.format(Date(it)) } ?: "—"
                views.setTextViewText(nameIds[i], styled(names[i], highlighted))
                views.setTextViewText(timeIds[i], styled(time, highlighted))
                val colorRes = if (highlighted) R.color.widget_text_primary else R.color.widget_text_secondary
                setTextColorRes(context, views, nameIds[i], colorRes)
                setTextColorRes(context, views, timeIds[i], colorRes)
                views.setViewVisibility(dotIds[i], if (highlighted) View.VISIBLE else View.INVISIBLE)
            }

            val open = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                putExtra(EXTRA_OPEN_ROUTE, ROUTE_PRAYER_TIME)
            }
            views.setOnClickPendingIntent(
                R.id.widget_root,
                PendingIntent.getActivity(
                    context, OPEN_REQUEST_CODE, open,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )
            return views
        }

        /** API 31+: pass the color *resource* so the launcher resolves it
         * against its own config — the widget follows a later system
         * dark/light switch without us re-rendering. Older: resolve now. */
        private fun setTextColorRes(context: Context, views: RemoteViews, viewId: Int, colorRes: Int) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                views.setColorStateList(viewId, "setTextColor", colorRes)
            } else {
                views.setTextColor(viewId, context.getColor(colorRes))
            }
        }

        private fun styled(text: String, bold: Boolean): CharSequence {
            if (!bold) return text
            return SpannableString(text).apply {
                setSpan(StyleSpan(Typeface.BOLD), 0, length, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE)
            }
        }

        private fun refreshIntent(context: Context): PendingIntent = PendingIntent.getBroadcast(
            context,
            REFRESH_REQUEST_CODE,
            Intent(context, PrayerWidgetProvider::class.java).setAction(ACTION_REFRESH),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        /** Next re-render at the next prayer boundary or local midnight,
         * whichever is first. Exact when permitted, otherwise inexact (may
         * lag up to ~10 min, or longer under Doze). */
        private fun scheduleRefresh(context: Context, nextChangeAt: Long?) {
            val midnight = Calendar.getInstance().apply {
                add(Calendar.DAY_OF_YEAR, 1)
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }.timeInMillis
            val at = minOf(nextChangeAt ?: midnight, midnight) + 1_000L
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            val pending = refreshIntent(context)
            val canExact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarmManager.canScheduleExactAlarms()
            if (canExact) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, pending)
            } else {
                // setAndAllowWhileIdle may defer by up to an hour; a 10-min
                // window (Android 12+'s minimum) keeps the highlight close.
                alarmManager.setWindow(AlarmManager.RTC_WAKEUP, at, 10 * 60 * 1000L, pending)
            }
        }

        private fun cancelRefresh(context: Context) {
            context.getSystemService(AlarmManager::class.java).cancel(refreshIntent(context))
        }

    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        refreshAll(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_REFRESH,
            ACTION_PINNED,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_LOCALE_CHANGED -> refreshAll(context)
        }
    }

    override fun onDisabled(context: Context) {
        cancelRefresh(context)
    }
}
