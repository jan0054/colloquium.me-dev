package com.ashvale.cmmath_one;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.widget.DrawerLayout;
import android.os.Bundle;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.SubMenu;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import com.ashvale.cmmath_one.adapter.CareerAdapter;
import com.ashvale.cmmath_one.adapter.ConversationAdapter;
import com.ashvale.cmmath_one.adapter.DrawerAdapter;
import com.parse.FindCallback;
import com.parse.Parse;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;


public class BaseActivity extends AppCompatActivity {

    public DrawerLayout drawerLayout;
    public String mActivityTitle;
    private SharedPreferences savedEvents;
    public ActionBarDrawerToggle mDrawerToggle;
    private Context context;
    public  List<ParseObject> eventObjList;
    protected cmmathApplication app;
    public NavigationView leftDrawerView;

    protected void onCreateDrawer() {
        mActivityTitle = getTitle().toString();
        context = this;
        drawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        leftDrawerView = (NavigationView) findViewById(R.id.left_drawer);

        Toolbar mainToolBar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(mainToolBar);

        leftDrawerView.setNavigationItemSelectedListener(new NavigationView.OnNavigationItemSelectedListener() {
            @Override
            public boolean onNavigationItemSelected(MenuItem menuItem) {
                //toggle checked state: current bugged (Google's fault), so we don't use it for now (1/4/2016)
                //reference: https://code.google.com/p/android/issues/detail?id=176300
                //if (menuItem.isChecked()) menuItem.setChecked(false);
                //else menuItem.setChecked(true);

                //determine selected item
                switch (menuItem.getItemId()) {
                    case R.id.drawer_choose:
                        drawerGoTo(0);
                        return true;
                    case R.id.drawer_home:
                        drawerGoTo(1);
                        return true;
                    case R.id.drawer_chat:
                        drawerGoTo(2);
                        return true;
                    case R.id.drawer_career:
                        drawerGoTo(3);
                        return true;
                    case R.id.drawer_settings:
                        drawerGoTo(4);
                        return true;
                    default:
                        ParseObject event = eventObjList.get(menuItem.getItemId());
                        String eventid = event.getObjectId();
                        savedEvents = getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
                        SharedPreferences.Editor editor = savedEvents.edit();
                        editor.putString("currenteventid", eventid);
                        editor.commit();
                        drawerGoTo(5);
                        return true;
                }
            }
        });

        setDrawer();

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);
        setupDrawerAndActionbar();
    }

    public void setDrawer()
    {
        savedEvents = getSharedPreferences("EVENTS", 6);
        Set<String> eventIdSet = savedEvents.getStringSet("eventids", null);
        if (eventIdSet != null)   //there were some saved events
        {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
            query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
            query.whereContainedIn("objectId", eventIdSet);
            query.orderByDescending("start_time");
            query.findInBackground(new FindCallback<ParseObject>() {
                public void done(List<ParseObject> objects, com.parse.ParseException e) {
                    if (e == null) {
                        Menu drawerMenu = leftDrawerView.getMenu();
                        String subTitle = context.getString(R.string.title_pinned);
                        SubMenu savedEventsMenu = drawerMenu.addSubMenu(R.id.drawer_events_group,Menu.NONE,1,subTitle);
                        eventObjList = objects;
                        List<String> eventNames = new ArrayList<String>();
                        int itemCount = 0;
                        for (ParseObject object : objects) {
                            String name = object.getString("name");
                            eventNames.add(name);
                            savedEventsMenu.add(Menu.NONE,itemCount,Menu.NONE,name);
                            itemCount = itemCount+1;
                        }

                        //this is a temp workaround for adding new items and forcing a refresh (Google's bug) (1/4/2016)
                        //reference: https://code.google.com/p/android/issues/detail?id=176300
                        MenuItem mi = drawerMenu.getItem(drawerMenu.size()-1);
                        mi.setTitle(mi.getTitle());
                    } else {
                        Log.d("cm_app", "drawer query error: " + e);
                    }
                }
            });
        }
        else   //no saved events found
        {

        }
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        app=(cmmathApplication)getApplication();
        app.isVisible = true;
        Log.d("cm_app", "APP visible now");
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        app=(cmmathApplication)getApplication();
        app.isVisible = false;
        Log.d("cm_app", "APP not visible");
    }

    public void refreshDrawer()
    {
        setDrawer();
    }

    public void drawerGoTo (int selection)
    {
        if (selection == 0)
        {
            startActivity(new Intent(this, AddeventActivity.class));
        }
        else if (selection ==1)
        {
            startActivity(new Intent(this, HomeActivity.class));
        }
        else if (selection ==2)
        {
            ParseUser selfuser = ParseUser.getCurrentUser();
            if (selfuser == null) {
                toast(getString(R.string.error_not_login));
                SharedPreferences userStatus;
                userStatus = this.getSharedPreferences("LOGIN", 0); //6 = readable+writable by other apps, use 0 for private
                SharedPreferences.Editor editor = userStatus.edit();
                editor.putInt("skiplogin", 0);
                editor.commit();
                Intent intent = new Intent(this, LoginActivity.class);
                startActivity(intent);
                return;
            }
            startActivity(new Intent(this, ConversationActivity.class));
        }
        else if (selection ==3)
        {
            startActivity(new Intent(this, CareerActivity.class));
        }
        else if (selection ==4)
        {
            startActivity(new Intent(this, SettingsActivity.class));
        }
        else
        {
            startActivity(new Intent(this, EventWrapperActivity.class));
        }
        drawerLayout.closeDrawers();
    }

    public void startDrawerActivity (int position)
    {
        savedEvents = getSharedPreferences("EVENTS", 6);
        Set<String> eventIdSet = savedEvents.getStringSet("eventids", null);
        int total;
        if(eventIdSet != null)
            total = eventIdSet.size();
        else
            total = 0;

        if (position == 0)
        {
            startActivity(new Intent(this, AddeventActivity.class));
            drawerLayout.closeDrawers();
        }
        else if (position == 1)
        {
            startActivity(new Intent(this, HomeActivity.class));
        }
        else if (position == 5 + total - 1)
        {
            startActivity(new Intent(this, SettingsActivity.class));
        }
        else if (position == 5 + total - 2)
        {
            startActivity(new Intent(this, CareerActivity.class));
        }
        else if (position == 5 + total - 3)
        {
            ParseUser selfuser = ParseUser.getCurrentUser();
            if (selfuser == null) {
                toast(getString(R.string.error_not_login));
                SharedPreferences userStatus;
                userStatus = this.getSharedPreferences("LOGIN", 0); //6 = readable+writable by other apps, use 0 for private
                SharedPreferences.Editor editor = userStatus.edit();
                editor.putInt("skiplogin", 0);
                editor.commit();
                Intent intent = new Intent(this, LoginActivity.class);
                startActivity(intent);
                return;
            }
            startActivity(new Intent(this, ConversationActivity.class));
        }
        else
        {
            ParseObject event = eventObjList.get(position - 2);
            String eventid = event.getObjectId();
            savedEvents = getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
            SharedPreferences.Editor editor = savedEvents.edit();
            editor.putString("currenteventid", eventid);
            editor.commit();
            startActivity(new Intent(this, EventWrapperActivity.class));
        }
    }

    private void setupDrawerAndActionbar() {
        mDrawerToggle = new ActionBarDrawerToggle(this, drawerLayout,
                R.string.drawer_open, R.string.drawer_close) {

            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                //getSupportActionBar().setTitle(getString(R.string.app_name));
                invalidateOptionsMenu(); // creates call to onPrepareOptionsMenu()
            }

            public void onDrawerClosed(View view) {
                super.onDrawerClosed(view);
                //getSupportActionBar().setTitle(mActivityTitle);
                invalidateOptionsMenu(); // creates call to onPrepareOptionsMenu()
            }
        };

        mDrawerToggle.setDrawerIndicatorEnabled(true);
        drawerLayout.setDrawerListener(mDrawerToggle);
    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        mDrawerToggle.syncState();
    }
    /*
        @Override
        public boolean onCreateOptionsMenu(Menu menu) {
            // Inflate the menu; this adds items to the action bar if it is present.
            //getMenuInflater().inflate(R.menu.menu_base, menu);
            //return true;
            MenuInflater inflater = getMenuInflater();
            inflater.inflate(R.menu.menu_base, menu);
            return super.onCreateOptionsMenu(menu);
        }
    */
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        if (mDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
}
