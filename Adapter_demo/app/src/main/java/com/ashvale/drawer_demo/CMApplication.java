package com.ashvale.drawer_demo;

import android.app.Application;

import com.parse.Parse;
import com.parse.ParseInstallation;
import com.parse.ParsePush;
import com.parse.PushService;

/**
 * Created by csjan on 7/9/15.
 */

public class CMApplication extends Application {


    @Override
    public void onCreate() {
        super.onCreate();
        Parse.initialize(this, "2JF8yrgsM5H261Gju4rzKfxFurDZluOfWUq9UnCV", "9pGuToEnzGXInGk7vTtfKzpU5rfvNAU0EBHdMPsZ");
        ParseInstallation.getCurrentInstallation().saveInBackground();
        ParsePush.subscribeInBackground("Global");
        PushService.startServiceIfRequired(getApplicationContext());
    }

}