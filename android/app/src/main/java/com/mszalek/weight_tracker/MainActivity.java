package com.mszalek.weight_tracker;

import android.content.Intent;
import android.os.Bundle;
import com.google.android.gms.actions.NoteIntents;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    String savedNote;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        Intent intent = getIntent();
        String action = intent.getAction();
        String type = intent.getType();

        if (NoteIntents.ACTION_CREATE_NOTE.equals(action) && type != null) {
            if ("text/plain".equals(type)) {
                handleSendText(intent);
            }
        }

        new MethodChannel(getFlutterView(), "app.channel.shared.data")
                .setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                        if (methodCall.method.contentEquals("getSavedNote")) {
                            result.success(savedNote);
                            savedNote = null;
                        }
                    }
                });
    }


    void handleSendText(Intent intent) {
        savedNote = intent.getStringExtra(Intent.EXTRA_TEXT);
    }
}