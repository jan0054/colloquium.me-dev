package com.ashvale.uiucalum;

import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;

public class DetailActivity extends AppCompatActivity {

    protected void onCreateView() {
        Toolbar mainToolBar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(mainToolBar);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);
    }
}
