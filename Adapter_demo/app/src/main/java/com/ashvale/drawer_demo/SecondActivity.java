package com.ashvale.drawer_demo;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.net.Uri;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.Toast;


public class SecondActivity extends BaseActivity implements ProgramFragment.OnFragmentInteractionListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_second);
        super.onCreateDrawer();
        FragmentManager fragmentManager = getFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        ProgramFragment fragment = new ProgramFragment();
        Bundle bundle = new Bundle();
        bundle.putString("param1", "1111111");
        bundle.putString("param2", "2222222");
        fragment.setArguments(bundle);
        fragmentTransaction.add(R.id.fragmentcontainer, fragment);
        fragmentTransaction.commit();
    }

    @Override
    public void onFragmentInteraction(String fragmentstring)
    {
        Toast.makeText(SecondActivity.this, "Program Fragment Passed Data: "+ fragmentstring, Toast.LENGTH_SHORT).show();
    }
    public void functionone()
    {

    }
    public void functiontwo()
    {

    }
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        //getMenuInflater().inflate(R.menu.menu_base, menu);
        //return true;
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_base, menu);
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
            case R.id.action_program:
                Toast.makeText(SecondActivity.this, "action bar program", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager = getFragmentManager();
                FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
                ProgramFragment programFragment = new ProgramFragment();
                fragmentTransaction.replace(R.id.fragmentcontainer, programFragment);
                fragmentTransaction.commit();

                return true;
            case R.id.action_people:
                Toast.makeText(SecondActivity.this, "action bar people", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager2 = getFragmentManager();
                FragmentTransaction fragmentTransaction2 = fragmentManager2.beginTransaction();
                PeopleFragment peopleFragment = new PeopleFragment();
                fragmentTransaction2.replace(R.id.fragmentcontainer, peopleFragment);
                fragmentTransaction2.commit();
                return true;
            case R.id.action_venue:
                Toast.makeText(SecondActivity.this, "action bar venue", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager3 = getFragmentManager();
                FragmentTransaction fragmentTransaction3 = fragmentManager3.beginTransaction();
                VenueFragment venueFragment = new VenueFragment();
                fragmentTransaction3.replace(R.id.fragmentcontainer, venueFragment);
                fragmentTransaction3.commit();
                return true;
            case R.id.action_wall:
                Toast.makeText(SecondActivity.this, "action bar wall", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager4 = getFragmentManager();
                FragmentTransaction fragmentTransaction4 = fragmentManager4.beginTransaction();
                WallFragment wallFragment = new WallFragment();
                fragmentTransaction4.replace(R.id.fragmentcontainer, wallFragment);
                fragmentTransaction4.commit();
                return true;
            case R.id.action_news:
                Toast.makeText(SecondActivity.this, "action bar news", Toast.LENGTH_SHORT).show();
                FragmentManager fragmentManager5 = getFragmentManager();
                FragmentTransaction fragmentTransaction5 = fragmentManager5.beginTransaction();
                NewsFragment newsFragment = new NewsFragment();
                fragmentTransaction5.replace(R.id.fragmentcontainer, newsFragment);
                fragmentTransaction5.commit();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }


}