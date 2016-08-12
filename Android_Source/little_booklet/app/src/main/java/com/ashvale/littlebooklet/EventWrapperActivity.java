package com.ashvale.littlebooklet;

import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.ashvale.littlebooklet.adapter.FragmentViewPagerAdapter;
import com.ashvale.littlebooklet.fragments.BaseFragment;
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
        viewPager.setOffscreenPageLimit(1);
        TabLayout tabLayout = (TabLayout) findViewById(R.id.sliding_tabs);
        tabLayout.setTabMode(TabLayout.MODE_FIXED);
        tabLayout.setupWithViewPager(viewPager);
        tabLayout.getTabAt(0).setIcon(R.drawable.home64);
        tabLayout.getTabAt(1).setIcon(R.drawable.program64);
        tabLayout.getTabAt(2).setIcon(R.drawable.people64);
        tabLayout.getTabAt(3).setIcon(R.drawable.timeline64);
        tabLayout.getTabAt(4).setIcon(R.drawable.venue64);

        //getEventName();
    }

    @Override
    public void onFragmentInteraction(String fragmentstring, String tag)
    {
        Toast.makeText(EventWrapperActivity.this, "Fragment Passed Data: " + fragmentstring, Toast.LENGTH_SHORT).show();
    }

    /*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        return super.onCreateOptionsMenu(menu);
    }
    */


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
                if (e == null) {
                    mActivityTitle = parseObject.getString("name");
                    Log.d("cm_app", "event name: " + mActivityTitle);
                    getSupportActionBar().setTitle(mActivityTitle);


                } else {
                    Log.d("cm_app", "get event name error: no event");
                }
            }
        });
    }

    public void setTitleByFragment(final int fragIndex, final String eventName)
    {
        Log.d("cm_app", "Set Title Called: "+ fragIndex);
        if (fragIndex == 0)
        {
            getSupportActionBar().setTitle(R.string.title_fragment_overview);
        }
        else if (fragIndex == 1)
        {
            if (eventName == null)
            {
                getSupportActionBar().setTitle(R.string.title_fragment_program);
            }
            else
            {
                getSupportActionBar().setTitle(eventName);
            }

        }
        else if (fragIndex == 2)
        {
            getSupportActionBar().setTitle(R.string.title_fragment_attendee);
        }
        else if (fragIndex == 3)
        {
            getSupportActionBar().setTitle(R.string.title_fragment_timeline);
        }
        else if (fragIndex == 4)
        {
            getSupportActionBar().setTitle(R.string.title_fragment_venue);
        }

    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public <T> void toPage(Intent intent, Class<T> cls) {
        intent.setClass(this, cls); //PeopleDetailsActivity.class);
        startActivity(intent);
    }

}
