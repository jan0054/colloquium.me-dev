package com.ashvale.uiucalum;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageButton;
import android.widget.RadioGroup;
import android.widget.Toast;

import com.ashvale.uiucalum.adapter.IntroViewPagerAdapter;

import java.util.ArrayList;

public class IntroActivity extends Activity {
    ViewPager mViewPager;
    ArrayList<View> viewList;
    RadioGroup mRadio;
    ImageButton btnLeave;
    ImageButton btnFinish;
    public String src_act;
    private SharedPreferences appStatus;
    int pageNumber = 4;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_intro);

        src_act = this.getIntent().getExtras().getString("src");

        mViewPager = (ViewPager) findViewById(R.id.introPages);
        mRadio = (RadioGroup) findViewById(R.id.radiogroup);
        btnLeave = (ImageButton) findViewById(R.id.leaveIntrohBtn);
        btnFinish = (ImageButton) findViewById(R.id.finishIntrohBtn);

        final LayoutInflater mInflater = getLayoutInflater().from(this);

        mViewPager.setAdapter(new IntroViewPagerAdapter(this, pageNumber));
        mViewPager.setCurrentItem(0);
        btnFinish.setVisibility(View.INVISIBLE);
        btnFinish.setEnabled(false);
        btnFinish.setClickable(false);

        mViewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            }

            @Override
            public void onPageSelected(int position) {
                if (position == 0) {
                    mRadio.check(R.id.radioButton);
                    btnLeave.setVisibility(View.INVISIBLE);
                    btnLeave.setEnabled(false);
                    btnLeave.setClickable(true);
                    btnFinish.setVisibility(View.INVISIBLE);
                    btnFinish.setEnabled(false);
                    btnFinish.setClickable(false);
                } else if (position == pageNumber-1) {
                    mRadio.check(R.id.radioButtonEnd);
                    btnLeave.setVisibility(View.INVISIBLE);
                    btnLeave.setEnabled(false);
                    btnLeave.setClickable(false);
                    btnFinish.setVisibility(View.VISIBLE);
                    btnFinish.setEnabled(true);
                    btnFinish.setClickable(true);
                } else if (position == 1){
                    mRadio.check(R.id.radioButton2);
                    btnLeave.setVisibility(View.INVISIBLE);
                    btnLeave.setEnabled(false);
                    btnLeave.setClickable(false);
                    btnFinish.setVisibility(View.INVISIBLE);
                    btnFinish.setEnabled(false);
                    btnFinish.setClickable(false);
                } else if (position == 2){
                    mRadio.check(R.id.radioButton3);
                    btnLeave.setVisibility(View.INVISIBLE);
                    btnLeave.setEnabled(false);
                    btnLeave.setClickable(false);
                    btnFinish.setVisibility(View.INVISIBLE);
                    btnFinish.setEnabled(false);
                    btnFinish.setClickable(false);
                } else {
                    mRadio.check(R.id.radioButton2);
                    btnLeave.setVisibility(View.INVISIBLE);
                    btnLeave.setEnabled(false);
                    btnLeave.setClickable(false);
                    btnFinish.setVisibility(View.INVISIBLE);
                    btnFinish.setEnabled(false);
                    btnFinish.setClickable(false);
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public void skip(View view) {
        appStatus = getSharedPreferences("INTRO", 0); //6 = readable+writable by other apps, use 0 for private
        SharedPreferences.Editor editor = appStatus.edit();
        editor.putInt("skipintro", 1);
        editor.commit();

        Intent intent;
        if(src_act.equals("settings")) {
            intent = new Intent(this, SettingsActivity.class);
        } else {
            intent = new Intent(this, LoginActivity.class);
        }
        startActivity(intent);
        finish();

    }
}
