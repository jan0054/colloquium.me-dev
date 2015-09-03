package com.ashvale.cmmath_one;

import android.content.SharedPreferences;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ListView;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.CareerAdapter;
import com.ashvale.cmmath_one.adapter.HomeAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.List;
import java.util.Set;

public class HomeActivity extends BaseActivity {

    private SharedPreferences savedEvents;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        super.onCreateDrawer();

        savedEvents = getSharedPreferences("EVENTS", 6);
        Set<String> eventset = savedEvents.getStringSet("events", null);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.whereContainedIn("objectId", eventset);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "home query error: " + e);
                }
            }
        });
    }

    public void setAdapter(final List results)
    {
        HomeAdapter adapter = new HomeAdapter(this, results);
        ListView homeListView = (ListView)findViewById(R.id.homeListView);
        homeListView.setAdapter(adapter);
    }

/*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_home, menu);
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
*/
}
