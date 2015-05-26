package com.cmenvi.app;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import com.parse.ParsePushBroadcastReceiver;

/**
 * Created by chishengjan on 12/15/14.
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

        Log.e("Push", "Received");
        cmenviApplication app = ((cmenviApplication)context.getApplicationContext());
        if (app.isVisible==false)
        {
            super.onPushReceive(context, intent);
        }
        else
        {
            if (app.isChat==false)
            {
                super.onPushReceive(context, intent);
            }
            else
            {
                updateChat(context, "new message");
            }
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
