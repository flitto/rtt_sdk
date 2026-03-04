package com.flitto.livetranslation.sample.chatguest

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            SampleTheme {
                SampleMainScreen()
            }
        }
    }
}
