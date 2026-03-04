package com.flitto.livetranslation.sample.chatguest.ui

import android.content.res.Configuration
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.flitto.livetranslation.sample.chatguest.R
import com.flitto.livetranslation.sample.chatguest.theme.Grey30
import com.flitto.livetranslation.sample.chatguest.theme.Grey90
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme

@Composable
fun LanguageSelectorChip(
    modifier: Modifier = Modifier,
    label: String,
    onClick: () -> Unit = {}
) {
    Row(
        modifier = modifier
            .clip(RoundedCornerShape(18.dp))
            .border(BorderStroke(width = 1.dp, Grey30), shape = RoundedCornerShape(18.dp))
            .clickable { onClick() }
            .padding(horizontal = 12.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            modifier = Modifier.size(12.dp),
            imageVector = ImageVector.vectorResource(R.drawable.ic_global),
            contentDescription = "language",
            tint = Grey90
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = label,
            style = SampleTheme.typography.regular14,
            color = Grey90
        )
        Spacer(modifier = Modifier.width(8.dp))
        Icon(
            modifier = Modifier.size(12.dp),
            imageVector = ImageVector.vectorResource(R.drawable.ic_dropdown),
            contentDescription = "open",
            tint = Grey90.copy(alpha = 0.6f)
        )
    }
}

@Preview(uiMode = Configuration.UI_MODE_NIGHT_NO, name = "Light theme", showBackground = true)
@Composable
private fun LanguageSelectorChipPreview() {
    SampleTheme {
        LanguageSelectorChip(
            modifier = Modifier.padding(16.dp),
            label = "English",
        )
    }
}
