package com.ashvale.cmmath_one;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.annotation.NonNull;
import android.support.v4.widget.DrawerLayout;
import android.os.Bundle;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.MenuItem;
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

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;


public class BaseActivity extends AppCompatActivity {

    public DrawerLayout drawerLayout;
    private String[] drawerArray;
    public ListView drawerListView;
    public String mActivityTitle;
    private SharedPreferences savedEvents;
    public ActionBarDrawerToggle mDrawerToggle;
    private Context context;
    public  List<ParseObject> eventObjList;
    public DrawerAdapter drawerAdapter;

    //@Override
    protected void onCreateDrawer() {
        mActivityTitle = getTitle().toString();
        context = this;
        drawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawerArray = getResources().getStringArray(R.array.drawer_array);
        drawerListView = (ListView) findViewById(R.id.left_drawer);

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
            query.setCachePolicy(ParseQuery.CachePolicy.CACHE_THEN_NETWORK);
            query.whereContainedIn("objectId", eventIdSet);
            query.orderByDescending("start_time");
            query.findInBackground(new FindCallback<ParseObject>() {
                public void done(List<ParseObject> objects, com.parse.ParseException e) {
                    if (e == null) {
                        eventObjList = objects;
                        List<String> eventNames = new ArrayList<String>();
                        for (ParseObject object : objects) {
                            String name = object.getString("name");
                            eventNames.add(name);
                        }
                        drawerAdapter = new DrawerAdapter(context, eventNames);
                        drawerListView.setAdapter(drawerAdapter);
                        drawerListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                            @Override
                            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                                //Toast.makeText(BaseActivity.this, "drawer item selected "+position, Toast.LENGTH_SHORT).show();
                                startDrawerActivity(position);
                            }
                        });

                    } else {
                        Log.d("cm_app", "drawer query error: " + e);
                    }
                }
            });
        }
        else   //no saved events found
        {
            List<String> eventNames = new ArrayList<>();
            drawerAdapter = new DrawerAdapter(context, eventNames);
            drawerListView.setAdapter(drawerAdapter);
            drawerListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    //Toast.makeText(BaseActivity.this, "drawer item selected", Toast.LENGTH_SHORT).show();
                    startDrawerActivity(position);
                }
            });
        }

    }

    public void refreshDrawer()
    {
        //Toast.makeText(BaseActivity.this, "drawer refreshed", Toast.LENGTH_SHORT).show();
        setDrawer();
        drawerLayout.openDrawer(drawerListView);
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
                getSupportActionBar().setTitle(getString(R.string.app_name));
                invalidateOptionsMenu(); // creates call to onPrepareOptionsMenu()
            }

            public void onDrawerClosed(View view) {
                super.onDrawerClosed(view);
                getSupportActionBar().setTitle(mActivityTitle);
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
/*
        switch (item.getItemId()) {
            case R.id.action_program:
                Toast.makeText(BaseActivity.this, "action bar program", Toast.LENGTH_SHORT).show();


                return true;
            case R.id.action_people:
                Toast.makeText(BaseActivity.this, "action bar people", Toast.LENGTH_SHORT).show();
                return true;
            case R.id.action_venue:
                Toast.makeText(BaseActivity.this, "action bar venue", Toast.LENGTH_SHORT).show();
                return true;
            case R.id.action_wall:
                Toast.makeText(BaseActivity.this, "action bar wall", Toast.LENGTH_SHORT).show();
                return true;
            case R.id.action_news:
                Toast.makeText(BaseActivity.this, "action bar news", Toast.LENGTH_SHORT).show();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
*/

    }

}
