package com.ashvale.uiucalum;

import android.app.Application;

import com.ashvale.uiucalum.data._PARAMS;
import com.parse.Parse;
import com.parse.ParseFacebookUtils;
import com.parse.ParseInstallation;
import com.parse.ParsePush;

import com.facebook.FacebookSdk;


public class uiucalumApplication extends Application {

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
        FacebookSdk.sdkInitialize(getApplicationContext());
        Parse.initialize(this, _PARAMS.APPLICATION_ID, _PARAMS.CLIENT_KEY);
        ParseInstallation.getCurrentInstallation().saveInBackground();
        ParsePush.subscribeInBackground("global");
        ParseFacebookUtils.initialize(getApplicationContext());



        //old stuff to fix some bugs?
        //PushService.startServiceIfRequired(getApplicationContext());

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
