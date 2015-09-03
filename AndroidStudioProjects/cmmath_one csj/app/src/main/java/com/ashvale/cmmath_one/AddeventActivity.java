package com.ashvale.cmmath_one;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;
import com.ashvale.cmmath_one.adapter.AddEventAdapter;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class AddeventActivity extends BaseActivity {

    private List selectedEvents;
    private List totalEvents;
    private int[] selectedIPositions;
    private SharedPreferences savedEvents;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_addevent);
            super.onCreateDrawer();

        ParseQuery query = new ParseQuery("Event");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> list, ParseException e) {
                //Toast.makeText(FirstActivity.this, "event query returned:" + list.size(), Toast.LENGTH_SHORT).show();
                setAdapter(list);
            }
        });
    }

    public void setAdapter(final List results)
    {
        AddEventAdapter adapter = new AddEventAdapter(this, results);
        ListView eventlist = (ListView)findViewById(R.id.eventListView);
        eventlist.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        eventlist.setAdapter(adapter);

        selectedIPositions = new int[results.size()];
        for (int i = 0; i< results.size(); i++)
        {
            selectedIPositions[i] = 0;
        }
        totalEvents = new ArrayList();
        totalEvents = results;

        eventlist.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position,
                                    long id) {
                ParseObject event = (ParseObject) totalEvents.get(position);
                String eventid = event.getObjectId();
                //Toast.makeText(FirstActivity.this, "eventID:" + eventid, Toast.LENGTH_SHORT).show();
                if (selectedIPositions[position] == 0) {
                    selectedEvents.add(eventid);
                    selectedIPositions[position] = 1;
                } else {
                    selectedEvents.remove(eventid);
                    selectedIPositions[position] = 0;
                }

                Toast.makeText(AddeventActivity.this, "event item selections:" + selectedEvents.size(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    public void saveEvents(List eventlist)
    {
        savedEvents = getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
        SharedPreferences.Editor editor = savedEvents.edit();
        Set<String> set = new HashSet<String>();
        set.addAll(eventlist);
        editor.putStringSet("events", set);
        editor.commit();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_addevent, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.saveevents) {
            saveEvents(selectedEvents);
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    }
