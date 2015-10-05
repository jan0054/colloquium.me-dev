package com.ashvale.cmmath_one;

import android.app.Application;
import android.util.Log;

import com.ashvale.cmmath_one.data._PARAMS;
import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParsePush;
import com.parse.PushService;
import com.parse.SaveCallback;


public class cmmathApplication extends Application {

    public boolean isVisible;
    public boolean isChat;
    public boolean isPerson;
    public int whereToLogin;

    @Override
    public void onCreate() {
        super.onCreate();
        isVisible = false;
        isChat = false;
        isPerson = false;

        Parse.initialize(this, _PARAMS.APPLICATION_ID, _PARAMS.CLIENT_KEY);
        ParseInstallation.getCurrentInstallation().saveInBackground();
        ParsePush.subscribeInBackground("global");
        PushService.startServiceIfRequired(getApplicationContext());

        /*
        Parse.initialize(getBaseContext(), _PARAMS.APPLICATION_ID, _PARAMS.CLIENT_KEY);
        ParsePush.subscribeInBackground("global", new SaveCallback() {
            @Override
            public void done(ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "successfully subscribed to the broadcast channel.");
                } else {
                    Log.e("cm_app", "failed to subscribe for push", e);
                }
            }
        });
        */

    }

}
