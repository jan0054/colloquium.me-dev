package com.ashvale.cmmath_one;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.ashvale.cmmath_one.ConversationActivity;
import com.ashvale.cmmath_one.cmmathApplication;
import com.parse.ParsePushBroadcastReceiver;

/**
 * Created by chishengjan on 10/6/15.
 */
public class ChatReceiver extends ParsePushBroadcastReceiver {

    @Override
    public void onPushOpen(Context context, Intent intent) {
        //super.onPushOpen(context, intent);
        Log.e("Push", "Clicked");
        Intent i = new Intent(context, ConversationActivity.class);
        i.putExtras(intent.getExtras());
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(i);
    }

    @Override
    public void onPushReceive(Context context, Intent intent) {

        Log.d("cm_app", "Received push");
        cmmathApplication app = ((cmmathApplication)context.getApplicationContext());

        if (app.isChat == true)
        {
            updateChat(context, "new message");
            Log.d("cm_app", "sending to in-chat receiver");
        }
        else
        {
            super.onPushReceive(context, intent);
            Log.d("cm_app", "chat not open!");
        }

    }

    // This function will create an intent to notify the chat broadcast receiver to refresh
    static void updateChat(Context context, String message) {

        Intent chatintent = new Intent("got_chat_intent");
        //put whatever data you want to send, if any
        chatintent.putExtra("message", message);
        //send broadcast
        context.sendBroadcast(chatintent);
    }
}