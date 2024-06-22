package com.example.cyber_safeguard

import androidx.multidex.MultiDexApplication
import android.content.Context
import androidx.multidex.MultiDex

class MultiDexApp : MultiDexApplication() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
}
