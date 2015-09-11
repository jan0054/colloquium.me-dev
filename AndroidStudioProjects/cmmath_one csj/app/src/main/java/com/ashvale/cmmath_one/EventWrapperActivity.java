package com.ashvale.cmmath_one;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.Toast;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.fragments.AttendeeFragment;
import com.ashvale.cmmath_one.fragments.BaseFragment;
import com.ashvale.cmmath_one.fragments.OverviewFragment;
import com.ashvale.cmmath_one.fragments.ProgramFragment;
import com.ashvale.cmmath_one.fragments.TimelineFragment;
import com.ashvale.cmmath_one.fragments.VenueFragment;

public class EventWrapperActivity extends BaseActivity implements BaseFragment.OnFragmentInteractionListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_event_wrapper);
        super.onCreateDrawer();

        FragmentManager fragmentManager = getFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        OverviewFragment fragment = new OverviewFragment();
        Bundle bundle = new Bundle();
        bundle.putString("param1", "1111111");
        bundle.putString("param2", "2222222");
        fragment.setArguments(bundle);
        fragmentTransaction.add(R.id.fragmentcontainer, fragment);
        fragmentTransaction.commit();
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

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_event_wrapper, menu);
        return super.onCreateOptionsMenu(menu);
    }

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
}
