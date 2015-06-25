package com.ashvale.drawer_demo;

import android.app.Activity;
import android.content.Intent;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;


public class BaseActivity extends Activity {

    public DrawerLayout drawerLayout;
    private String[] drawerArray;
    public ListView drawerListView;

    //@Override
    protected void onCreateDrawer() {
        //protected void onCreate(Bundle savedInstanceState) {
        //super.onCreate(savedInstanceState);
        //setContentView(R.layout.activity_base);
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
    }

    public void startDrawerActivity (int position)
    {
        switch(position) {
            case 0:
                startActivity(new Intent(this, FirstActivity.class)); break;
            case 1:
                startActivity(new Intent(this, SecondActivity.class)); break;
            case 2:
                startActivity(new Intent(this, ThirdActivity.class)); break;
            case 3:
                startActivity(new Intent(this, FourthActivity.class)); break;
            case 4:
                startActivity(new Intent(this, FifthActivity.class)); break;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_base, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
