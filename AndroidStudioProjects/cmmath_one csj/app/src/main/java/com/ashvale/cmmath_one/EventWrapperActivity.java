package com.ashvale.cmmath_one;

import android.app.ActionBar;
import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Toast;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.FragmentViewPagerAdapter;
import com.ashvale.cmmath_one.fragments.AttendeeFragment;
import com.ashvale.cmmath_one.fragments.BaseFragment;
import com.ashvale.cmmath_one.fragments.OverviewFragment;
import com.ashvale.cmmath_one.fragments.ProgramFragment;
import com.ashvale.cmmath_one.fragments.TimelineFragment;
import com.ashvale.cmmath_one.fragments.VenueFragment;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

public class EventWrapperActivity extends BaseActivity implements BaseFragment.OnFragmentInteractionListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event_wrapper);
        super.onCreateDrawer();

        ViewPager viewPager = (ViewPager) findViewById(R.id.viewpager);
        viewPager.setAdapter(new FragmentViewPagerAdapter(getFragmentManager(), EventWrapperActivity.this));
        TabLayout tabLayout = (TabLayout) findViewById(R.id.sliding_tabs);
        tabLayout.setTabMode(TabLayout.MODE_FIXED);
        tabLayout.setupWithViewPager(viewPager);
        tabLayout.getTabAt(0).setIcon(R.drawable.home64);
        tabLayout.getTabAt(1).setIcon(R.drawable.program64);
        tabLayout.getTabAt(2).setIcon(R.drawable.people64);
        tabLayout.getTabAt(3).setIcon(R.drawable.timeline64);
        tabLayout.getTabAt(4).setIcon(R.drawable.venue64);

        getEventName();
    }

    @Override
    public void onFragmentInteraction(String fragmentstring, String tag)
    {
        Toast.makeText(EventWrapperActivity.this, "Fragment Passed Data: " + fragmentstring, Toast.LENGTH_SHORT).show();
    }
    public void functionone()
    {

    }
    public void functiontwo()
    {

    }
/*
    class IntentReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            int itemID = intent.getIntExtra("itemID", 0);
            Log.d("cm_app", "itemID receive = "+itemID);
            onOptionsItemSelectedwithID(itemID);
        }
    }
*/
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        return super.onCreateOptionsMenu(menu);
    }


    public void newPost(View view) {
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
        toPage(new Intent(), NewPostActivity.class);
    }

    public void getEventName()
    {
        SharedPreferences savedEvents = getSharedPreferences("EVENTS", 0);
        String currentId = savedEvents.getString("currenteventid", "");
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
        query.getInBackground(currentId, new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject parseObject, ParseException e) {
                if(e == null) {
                    mActivityTitle = parseObject.getString("name");
                    Log.d("cm_app", "event name: "+mActivityTitle);
                    getSupportActionBar().setTitle(mActivityTitle);
                } else {
                    Log.d("cm_app", "get event name error: no event");
                }
            }
        });
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public <T> void toPage(Intent intent, Class<T> cls) {
        intent.setClass(this, cls); //PeopleDetailsActivity.class);
        startActivity(intent);
    }
    /*
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.

        if (mDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }

        switch (item.getItemId()) {
            case R.id.action_overview:
                //Toast.makeText(EventWrapperActivity.this, "action bar program", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager = getFragmentManager();
                FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
                OverviewFragment overviewFragment = new OverviewFragment();
                fragmentTransaction.replace(R.id.fragmentcontainer, overviewFragment);
                fragmentTransaction.commit();

                return true;
            case R.id.action_program:
                //Toast.makeText(EventWrapperActivity.this, "action bar people", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager2 = getFragmentManager();
                FragmentTransaction fragmentTransaction2 = fragmentManager2.beginTransaction();
                ProgramFragment programFragment = new ProgramFragment();
                fragmentTransaction2.replace(R.id.fragmentcontainer, programFragment);
                fragmentTransaction2.commit();
                return true;
            case R.id.action_attendee:
                //Toast.makeText(EventWrapperActivity.this, "action bar venue", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager3 = getFragmentManager();
                FragmentTransaction fragmentTransaction3 = fragmentManager3.beginTransaction();
                AttendeeFragment attendeeFragment = new AttendeeFragment();
                fragmentTransaction3.replace(R.id.fragmentcontainer, attendeeFragment);
                fragmentTransaction3.commit();
                return true;
            case R.id.action_timeline:
                //Toast.makeText(EventWrapperActivity.this, "action bar wall", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager4 = getFragmentManager();
                FragmentTransaction fragmentTransaction4 = fragmentManager4.beginTransaction();
                TimelineFragment timelineFragment = new TimelineFragment();
                fragmentTransaction4.replace(R.id.fragmentcontainer, timelineFragment);
                fragmentTransaction4.addToBackStack(null);
                fragmentTransaction4.commit();
                return true;
            case R.id.action_venue:
                //Toast.makeText(EventWrapperActivity.this, "action bar news", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager5 = getFragmentManager();
                FragmentTransaction fragmentTransaction5 = fragmentManager5.beginTransaction();
                VenueFragment venueFragment = new VenueFragment();
                fragmentTransaction5.replace(R.id.fragmentcontainer, venueFragment);
                fragmentTransaction5.commit();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }

    }

    public boolean onOptionsItemSelectedwithID(int itemID)
    {

        switch (itemID) {
            case R.id.action_overview:
                //Toast.makeText(EventWrapperActivity.this, "action bar program", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager = getFragmentManager();
                FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
                OverviewFragment overviewFragment = new OverviewFragment();
                fragmentTransaction.replace(R.id.fragmentcontainer, overviewFragment);
                fragmentTransaction.commit();
                return true;
            case R.id.action_program:
                //Toast.makeText(EventWrapperActivity.this, "action bar people", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager2 = getFragmentManager();
                FragmentTransaction fragmentTransaction2 = fragmentManager2.beginTransaction();
                ProgramFragment programFragment = new ProgramFragment();
                fragmentTransaction2.replace(R.id.fragmentcontainer, programFragment);
                fragmentTransaction2.commit();
                return true;
            case R.id.action_attendee:
                //Toast.makeText(EventWrapperActivity.this, "action bar venue", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager3 = getFragmentManager();
                FragmentTransaction fragmentTransaction3 = fragmentManager3.beginTransaction();
                AttendeeFragment attendeeFragment = new AttendeeFragment();
                fragmentTransaction3.replace(R.id.fragmentcontainer, attendeeFragment);
                fragmentTransaction3.commit();
                return true;
            case R.id.action_timeline:
                //Toast.makeText(EventWrapperActivity.this, "action bar wall", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager4 = getFragmentManager();
                FragmentTransaction fragmentTransaction4 = fragmentManager4.beginTransaction();
                TimelineFragment timelineFragment = new TimelineFragment();
                fragmentTransaction4.replace(R.id.fragmentcontainer, timelineFragment);
                fragmentTransaction4.commit();
                return true;
            case R.id.action_venue:
                //Toast.makeText(EventWrapperActivity.this, "action bar news", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager5 = getFragmentManager();
                FragmentTransaction fragmentTransaction5 = fragmentManager5.beginTransaction();
                VenueFragment venueFragment = new VenueFragment();
                fragmentTransaction5.replace(R.id.fragmentcontainer, venueFragment);
                fragmentTransaction5.commit();
                return true;
            default:
                return false;
        }

    }
    */
}
