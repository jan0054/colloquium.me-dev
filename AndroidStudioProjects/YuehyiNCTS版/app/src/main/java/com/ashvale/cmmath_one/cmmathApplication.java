package com.ashvale.cmmath_one;

import android.app.Activity;
import android.app.Application;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.provider.Settings;
import android.util.Base64;
import android.util.Log;

import com.ashvale.cmmath_one.data._PARAMS;
import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseFacebookUtils;
import com.parse.ParseInstallation;
import com.parse.ParsePush;
import com.parse.PushService;
import com.parse.SaveCallback;

import com.facebook.FacebookSdk;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;



public class cmmathApplication extends Application {

    public boolean isVisible;
    public boolean isChat;
    public boolean isPerson;
    public int whereToLogin;
    public int eventNest;

    @Override
    public void onCreate() {
        super.onCreate();
        isVisible = false;
        isChat = false;
        isPerson = false;
        eventNest = 0;
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
