package com.example.androidnative

import android.os.Bundle
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    external fun stringFromJNI(): String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        System.loadLibrary("native-lib")

        val tv = TextView(this)
        tv.text = stringFromJNI()
        setContentView(tv)
    }
}
