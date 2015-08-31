package com.ashvale.cmmath_one;

import android.content.Intent;
import android.support.v4.widget.DrawerLayout;
import android.os.Bundle;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;


public class BaseActivity extends AppCompatActivity {

    public DrawerLayout drawerLayout;
    private String[] drawerArray;
    public ListView drawerListView;
    public String mActivityTitle;

    public ActionBarDrawerToggle mDrawerToggle;

    //@Override
    protected void onCreateDrawer() {
        //protected void onCreate(Bundle savedInstanceState) {
        //super.onCreate(savedInstanceState);
        //setContentView(R.layout.activity_base);

        mActivityTitle = getTitle().toString();

        drawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawerArray = getResources().getStringArray(R.array.drawer_array);
        drawerListView = (ListView) findViewById(R.id.left_drawer);

        drawerListView.setAdapter(new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, drawerArray));
        drawerListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Toast.makeText(BaseActivity.this, "drawer item selected", Toast.LENGTH_SHORT).show();
                startDrawerActivity(position);
            }
        });

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        getSupportActionBar().setHomeButtonEnabled(true);

        setupDrawerAndActionbar();
    }

    public void startDrawerActivity (int position)
    {
        switch(position) {
            case 0:
                startActivity(new Intent(this, AddeventActivity.class)); break;
            case 1:
                startActivity(new Intent(this, EventActivity.class)); break;
            case 2:
                startActivity(new Intent(this, ThirdActivity.class)); break;
            case 3:
                startActivity(new Intent(this, ConversationActivity.class)); break;
            case 4:
                startActivity(new Intent(this, SettingsActivity.class)); break;
        }
    }

    private void setupDrawerAndActionbar() {
        mDrawerToggle = new ActionBarDrawerToggle(this, drawerLayout,
                R.string.drawer_open, R.string.drawer_close) {

            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                getSupportActionBar().setTitle("Choose Event");
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
