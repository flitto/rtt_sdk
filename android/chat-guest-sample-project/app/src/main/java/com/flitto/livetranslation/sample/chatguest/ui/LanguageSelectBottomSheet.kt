package com.flitto.livetranslation.sample.chatguest.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.flitto.livetranslation.sample.chatguest.R
import com.flitto.livetranslation.sample.chatguest.theme.Grey90
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme
import com.flitto.livetranslation.sdk.chatguest.model.LanguageInfoEntity

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LanguageSelectBottomSheet(
    languages: List<LanguageInfoEntity>,
    selectedLanguageCode: String,
    onSelected: (LanguageInfoEntity) -> Unit,
    onDismiss: () -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        dragHandle = null
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(Color.White)
        ) {
            Box(
                modifier = Modifier
                    .padding(top = 32.dp)
                    .fillMaxWidth()
                    .height(56.dp)
            ) {
                IconButton(
                    modifier = Modifier
                        .size(48.dp)
                        .align(Alignment.CenterStart),
                    onClick = onDismiss
                ) {
                    Icon(
                        imageVector = ImageVector.vectorResource(R.drawable.ic_close),
                        contentDescription = "close"
                    )
                }
                Text(
                    text = "언어 선택",
                    style = SampleTheme.typography.bold18,
                    modifier = Modifier.align(Alignment.Center)
                )
            }
            LazyColumn(
                modifier = Modifier.padding(horizontal = 16.dp),
                contentPadding = PaddingValues(vertical = 12.dp)
            ) {
                itemsIndexed(languages, key = { _, language -> language.languageCode }) { index, language ->
                    val isSelected = language.languageCode == selectedLanguageCode

                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                onSelected(language)
                                onDismiss()
                            }
                            .padding(vertical = 12.dp, horizontal = 4.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(
                                modifier = Modifier.weight(1f)
                            ) {
                                Text(
                                    text = language.languageLocal,
                                    style = SampleTheme.typography.regular12,
                                    maxLines = 1,
                                    color = Grey90.copy(alpha = 0.57f),
                                    overflow = TextOverflow.Ellipsis
                                )
                            }
                            if (isSelected) {
                                Icon(
                                    imageVector = ImageVector.vectorResource(R.drawable.ic_check),
                                    contentDescription = "selected",
                                    tint = Color.Unspecified
                                )
                            } else {
                                Spacer(modifier = Modifier.width(24.dp))
                            }
                        }
                    }
                    if (index != languages.lastIndex) {
                        HorizontalDivider(
                            modifier = Modifier.padding(top = 8.dp),
                            color = Grey90.copy(alpha = 0.08f)
                        )
                    }
                }
            }
        }
    }
}
