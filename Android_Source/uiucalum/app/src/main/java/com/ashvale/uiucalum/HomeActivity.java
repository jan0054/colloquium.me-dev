package com.ashvale.uiucalum;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;

import com.ashvale.uiucalum.adapter.EventAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.util.List;
import java.util.Set;

public class HomeActivity extends BaseActivity {

    private SharedPreferences savedEvents;
    private List<ParseObject> eventObjects;
    private ParseUser curuser;
    private String eventId;
    private EventAdapter adapter;
    private boolean nestedView;
    ListView homeListView;
    TextView emptyLabel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        super.onCreateDrawer();

        savedEvents = getSharedPreferences("EVENTS", 6);
        Set<String> eventSet = savedEvents.getStringSet("eventids", null);
        Log.d("cm_app", "Home eventid: "+eventSet);

        homeListView = (ListView) findViewById(R.id.homeListView);
        emptyLabel = (TextView) findViewById(R.id.homeempty);

        if (this.getIntent().getExtras() != null)
        {
            nestedView = this.getIntent().getExtras().getBoolean("nestedView", false);
        }

        if (nestedView)   //display the children of the parent event
        {
            //set title as the name of the parent event
            String title = this.getIntent().getExtras().getString("parentName");
            getSupportActionBar().setTitle(title);

            eventId = savedEvents.getString("currenteventid", "");

            ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
            innerQuery.whereEqualTo("objectId", eventId);
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
            query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
            query.whereEqualTo("published", 1);
            query.whereMatchesQuery("parentEvent", innerQuery);
            query.orderByDescending("start_time");
            query.findInBackground(new FindCallback<ParseObject>() {
                public void done(List<ParseObject> objects, com.parse.ParseException e) {
                    if (e == null) {
                        eventObjects = objects;
                        setAdapter(objects);
                    } else {
                        Log.d("cm_app", "home query error: " + e);
                    }
                }
            });
        }
        else if (eventSet!=null)
        {
            if (eventSet.size() > 0)  //display all the followed events in "eventset"
            {
                ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
                query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
                query.whereEqualTo("published", 1);
                query.whereContainedIn("objectId", eventSet);
                query.orderByDescending("start_time");
                query.findInBackground(new FindCallback<ParseObject>() {
                    public void done(List<ParseObject> objects, com.parse.ParseException e) {
                        if (e == null) {
                            eventObjects = objects;
                            setAdapter(objects);
                        } else {
                            Log.d("cm_app", "home query error: " + e);
                            listEmpty();
                        }
                    }
                });
            } else {
                listEmpty();
            }
        }
        else
        {
            listEmpty();
        }
    }

    public void setAdapter(final List results)
    {
        if (results.size()!= 0) {
            homeListView.setVisibility(View.VISIBLE);
            emptyLabel.setVisibility(View.INVISIBLE);
            adapter = new EventAdapter(this, results);
            homeListView.setAdapter(adapter);
        } else {
            listEmpty();
        }
    }

    public void listEmpty()
    {
        emptyLabel.setVisibility(View.VISIBLE);
        homeListView.setVisibility(View.INVISIBLE);
    }

    public void updateList()
    {
        if (!nestedView)   //we only need to remove the unfollowed event if we are not in nested view
        {
            savedEvents = getSharedPreferences("EVENTS", 0);
            Set<String> eventSet = savedEvents.getStringSet("eventids", null);
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
            query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
            query.whereContainedIn("objectId", eventSet);
            query.orderByDescending("start_time");
            query.findInBackground(new FindCallback<ParseObject>() {
                public void done(List<ParseObject> objects, com.parse.ParseException e) {
                    if (e == null) {
                        eventObjects = objects;
                        setAdapter(objects);
                    } else {
                        Log.d("cm_app", "home query error: " + e);
                    }
                }
            });
        }
    }

    public void refreshList()
    {
        savedEvents = getSharedPreferences("EVENTS", 6);
        Set<String> eventset = savedEvents.getStringSet("eventids", null);

        int eventNest = 0;
        if(this.getIntent().getExtras() != null) {
            eventNest = this.getIntent().getExtras().getInt("eventNest");
        }

        if (eventNest == 1)
        {
            eventId = savedEvents.getString("currenteventid", "");

            ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
            innerQuery.whereEqualTo("objectId", eventId);

            ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
            query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
            query.whereMatchesQuery("parentEvent", innerQuery);
            query.orderByDescending("start_time");
            query.findInBackground(new FindCallback<ParseObject>() {
                public void done(List<ParseObject> objects, com.parse.ParseException e) {
                    if (e == null) {
                        eventObjects = objects;
                        setAdapter(objects);
                    } else {
                        Log.d("cm_app", "home query error: " + e);
                    }
                }
            });
        } else {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
            query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
            query.whereContainedIn("objectId", eventset);
            query.orderByDescending("start_time");
            query.findInBackground(new FindCallback<ParseObject>() {
                public void done(List<ParseObject> objects, com.parse.ParseException e) {
                    if (e == null) {
                        eventObjects = objects;
                        setAdapter(objects);
                    } else {
                        Log.d("cm_app", "home query error: " + e);
                    }
                }
            });
        }
    }
/*    public void setAdapter(final List results)
    {
        HomeAdapter adapter = new HomeAdapter(this, results);
        ListView homeListView = (ListView)findViewById(R.id.homeListView);
        homeListView.setAdapter(adapter);
        homeListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //Toast.makeText(HomeActivity.this, "home event item selected " + position, Toast.LENGTH_SHORT).show();

                ParseObject event = eventObjList.get(position);
                String eventid = event.getObjectId();
                savedEvents = getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
                SharedPreferences.Editor editor = savedEvents.edit();
                editor.putString("currenteventid", eventid);
                editor.commit();
                List <ParseObject> children = event.getList("childrenEvent");
                if (children == null || children.size()==0) { //no childrenEvent
                    startActivity(new Intent(HomeActivity.this, EventWrapperActivity.class));
                } else {
                    app=(uiucalumApplication)getApplication();
                    app.eventNest = 1;
                    startActivity(new Intent(HomeActivity.this, HomeActivity.class));
                }
            }
        });
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
