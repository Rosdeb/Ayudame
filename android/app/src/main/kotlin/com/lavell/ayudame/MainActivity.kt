package com.lavell.ayudame

import android.os.Bundle
import android.util.Log
import android.util.TypedValue
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Ensure AppCompat theme is active before Stripe plugin attaches.
        setTheme(R.style.AppTheme)
        val tv = TypedValue()
        val hasColorPrimary = theme.resolveAttribute(androidx.appcompat.R.attr.colorPrimary, tv, true)
        Log.d(
            "StripeThemeCheck",
            "MainActivity theme=${theme} hasColorPrimary=$hasColorPrimary value=0x${tv.data.toString(16)}",
        )
        super.onCreate(savedInstanceState)
    }
}
