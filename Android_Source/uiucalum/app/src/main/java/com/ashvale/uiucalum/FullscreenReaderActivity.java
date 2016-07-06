package com.ashvale.uiucalum;

import android.annotation.SuppressLint;
import android.content.SharedPreferences;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.os.Handler;
import android.text.method.ScrollingMovementMethod;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

/**
 * An example full-screen activity that shows and hides the system UI (i.e.
 * status bar and navigation/system bar) with user interaction.
 */
public class FullscreenReaderActivity extends AppCompatActivity {
    /**
     * Whether or not the system UI should be auto-hidden after
     * {@link #AUTO_HIDE_DELAY_MILLIS} milliseconds.
     */
    private static final boolean AUTO_HIDE = true;

    /**
     * If {@link #AUTO_HIDE} is set, the number of milliseconds to wait after
     * user interaction before hiding the system UI.
     */
    private static final int AUTO_HIDE_DELAY_MILLIS = 3000;

    /**
     * Some older devices needs a small delay between UI widget updates
     * and a change of the status and navigation bar.
     */
    private static final int UI_ANIMATION_DELAY = 300;

    private TextView mContentView;
    private View mControlsView;
    private View backgroundFrame;
    private View controlBar;
    private boolean mVisible;
    public String contentString;
    public Button colorToggleButton;
    public int colorMode;   // 0(default) = black text on white background, 1= white text on black background
    private SharedPreferences savedColorMode;
    private float downX;
    private float downY;
    private boolean isOnClick;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_fullscreen_reader);

        mVisible = true;
        mControlsView = findViewById(R.id.fullscreen_content_controls);
        mContentView = (TextView) findViewById(R.id.fullscreen_textview);
        backgroundFrame = findViewById(R.id.fullscreen_parent);
        controlBar = findViewById(R.id.fullscreen_content_controls);

        // Set up the user interaction to manually show or hide the system UI.
        mContentView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {

                switch (event.getAction() & MotionEvent.ACTION_MASK) {
                    case MotionEvent.ACTION_DOWN:
                        downX = event.getX();
                        downY = event.getY();
                        isOnClick = true;
                        break;
                    case MotionEvent.ACTION_UP:
                        if (isOnClick) {
                            //recognize as tap
                            toggle();
                            return  true;       //return true only when we release our finger, and have not moved more than 5 pixels: we also trigger toggle in this case
                        }
                        break;
                    case MotionEvent.ACTION_MOVE:
                        if (isOnClick && (Math.abs(downX - event.getX()) > 5 || Math.abs(downY - event.getY()) > 5)) {
                            isOnClick = false;
                        }
                        break;
                    default:
                        break;
                }
                return false;     //under most situations we want to return false, so that the scroll can work
            }
        });

        mContentView.setMovementMethod(new ScrollingMovementMethod());      //this is the scroll!

        //old onclick does not work very well, since it is triggered by the scroll
        /*
        mContentView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                toggle();
            }
        });
        */

        // Upon interacting with UI controls, delay any scheduled hide()
        // operations to prevent the jarring behavior of controls going away
        // while interacting with the UI.
        findViewById(R.id.color_toggle_button).setOnTouchListener(mDelayHideTouchListener);

        contentString = this.getIntent().getExtras().getString("content");
        mContentView.setText(contentString);

        savedColorMode = getSharedPreferences("COLORMODE", 0);
        colorMode = savedColorMode.getInt("readercolormode", 0);
        if (colorMode == 1)
        {
            mContentView.setTextColor(getResources().getColor(R.color.white));
            mContentView.setBackgroundColor(getResources().getColor(R.color.black));
            backgroundFrame.setBackgroundColor(getResources().getColor(R.color.black));
            controlBar.setBackgroundColor(getResources().getColor(R.color.primary_text));
        }
        else if (colorMode == 0)
        {
            mContentView.setTextColor(getResources().getColor(R.color.black));
            mContentView.setBackgroundColor(getResources().getColor(R.color.white));
            backgroundFrame.setBackgroundColor(getResources().getColor(R.color.white));
            controlBar.setBackgroundColor(getResources().getColor(R.color.black_overlay));
        }

        colorToggleButton = (Button) findViewById(R.id.color_toggle_button);
        colorToggleButton.setOnClickListener(new Button.OnClickListener() {
            @Override
            public void onClick(View view) {
                toggleColorMode();
            }
        });

    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);

        // Trigger the initial hide() shortly after the activity has been
        // created, to briefly hint to the user that UI controls
        // are available.
        delayedHide(100);
    }

    /**
     * Touch listener to use for in-layout UI controls to delay hiding the
     * system UI. This is to prevent the jarring behavior of controls going away
     * while interacting with activity UI.
     */
    private final View.OnTouchListener mDelayHideTouchListener = new View.OnTouchListener() {
        @Override
        public boolean onTouch(View view, MotionEvent motionEvent) {
            if (AUTO_HIDE) {
                delayedHide(AUTO_HIDE_DELAY_MILLIS);
            }
            return false;
        }
    };

    private void toggle() {
        if (mVisible) {
            hide();
        } else {
            show();
        }
    }

    public void toggleColorMode() {
        if (colorMode == 0)
        {
            mContentView.setTextColor(getResources().getColor(R.color.white));
            mContentView.setBackgroundColor(getResources().getColor(R.color.black));
            backgroundFrame.setBackgroundColor(getResources().getColor(R.color.black));
            controlBar.setBackgroundColor(getResources().getColor(R.color.primary_text));
            colorMode = 1;
        }
        else if (colorMode == 1)
        {
            mContentView.setTextColor(getResources().getColor(R.color.black));
            mContentView.setBackgroundColor(getResources().getColor(R.color.white));
            backgroundFrame.setBackgroundColor(getResources().getColor(R.color.white));
            controlBar.setBackgroundColor(getResources().getColor(R.color.black_overlay));
            colorMode = 0;
        }
        SharedPreferences.Editor editor = savedColorMode.edit();
        editor.putInt("readercolormode", colorMode);
        editor.commit();
    }

    private void hide() {
        // Hide UI first
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.hide();
        }
        mControlsView.setVisibility(View.GONE);
        mVisible = false;

        // Schedule a runnable to remove the status and navigation bar after a delay
        mHideHandler.removeCallbacks(mShowPart2Runnable);
        mHideHandler.postDelayed(mHidePart2Runnable, UI_ANIMATION_DELAY);
    }

    private final Runnable mHidePart2Runnable = new Runnable() {
        @SuppressLint("InlinedApi")
        @Override
        public void run() {
            // Delayed removal of status and navigation bar

            // Note that some of these constants are new as of API 16 (Jelly Bean)
            // and API 19 (KitKat). It is safe to use them, as they are inlined
            // at compile-time and do nothing on earlier devices.
            mContentView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE
                    | View.SYSTEM_UI_FLAG_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION);
        }
    };

    @SuppressLint("InlinedApi")
    private void show() {
        // Show the system bar
        mContentView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        mVisible = true;

        // Schedule a runnable to display UI elements after a delay
        mHideHandler.removeCallbacks(mHidePart2Runnable);
        mHideHandler.postDelayed(mShowPart2Runnable, UI_ANIMATION_DELAY);
    }

    private final Runnable mShowPart2Runnable = new Runnable() {
        @Override
        public void run() {
            // Delayed display of UI elements
            ActionBar actionBar = getSupportActionBar();
            if (actionBar != null) {
                actionBar.show();
            }
            mControlsView.setVisibility(View.VISIBLE);
        }
    };

    private final Handler mHideHandler = new Handler();
    private final Runnable mHideRunnable = new Runnable() {
        @Override
        public void run() {
            hide();
        }
    };

    /**
     * Schedules a call to hide() in [delay] milliseconds, canceling any
     * previously scheduled calls.
     */
    private void delayedHide(int delayMillis) {
        mHideHandler.removeCallbacks(mHideRunnable);
        mHideHandler.postDelayed(mHideRunnable, delayMillis);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        }
        else
        {
            return false;
        }
    }
}
