package com.ashvale.cmmath_one;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ListView;

import com.ashvale.cmmath_one.adapter.DiscussionAdapter;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;


public class DiscussionActivity extends DetailActivity {

    private DiscussionAdapter talk_adapter;
    public String event_objid;
    public int event_type;
    public ParseObject cur_person;
    public ParseObject event_obj;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_discussion);
        super.onCreateView();

        event_objid = this.getIntent().getExtras().getString("event_objid");
        event_type = this.getIntent().getExtras().getInt("event_type");
        Log.d("DISCUSS", "DISCUSS: " + event_objid + "TYPE " + event_type);
        if (event_type == 0)
        {
            //talk
            talk_adapter = new DiscussionAdapter(this);
            ListView listview = (ListView) findViewById(R.id.discussioncontent);
            talk_adapter.event_objid = event_objid;
            talk_adapter.setPaginationEnabled(false);
            talk_adapter.loadObjects();
            listview.setAdapter(talk_adapter);
        }

        ParseUser cur_user = ParseUser.getCurrentUser();
        cur_person = cur_user.getParseObject("Person");
        switch (event_type)
        {
            case 0:
                //talk
                ParseQuery<ParseObject> tquery = ParseQuery.getQuery("Talk");
                tquery.getInBackground(event_objid, new GetCallback<ParseObject>() {
                    @Override
                    public void done(ParseObject object, ParseException e) {
                        event_obj = object;
                    }
                });
                break;
            case 1:
                //poster
                ParseQuery<ParseObject> pquery = ParseQuery.getQuery("Poster");
                pquery.getInBackground(event_objid, new GetCallback<ParseObject>() {
                    @Override
                    public void done(ParseObject object, ParseException e) {
                        event_obj = object;
                    }
                });
                break;
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        //inflater.inflate(R.menu.menu_event_wrapper, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
            return true;
        } else {
            Intent intent = new Intent(this, TalkDetailActivity.class);
            intent.putExtra("itemID", item.getItemId());
            startActivity(intent);
            return super.onOptionsItemSelected(item);
        }
    }

    public void sendDiscussion(View view) {
        final EditText editText = (EditText) findViewById(R.id.discussioninput);
        final String message = editText.getText().toString();
        Log.i("sendDiscussion", message);

        ParseObject discussion_msg = new ParseObject("Forum");
        discussion_msg.put("content", message);
        discussion_msg.put("author", ParseUser.getCurrentUser());
        switch (event_type) {
            case 0:
                discussion_msg.put("source", event_obj);
                break;
            case 1:
                discussion_msg.put("source", event_obj);
                break;
        }
        discussion_msg.saveInBackground(new SaveCallback() {
            @Override
            public void done(ParseException e) {
                editText.setText("");
                if (event_type == 0)
                {
                    talk_adapter.loadObjects();
                }
            }
        });
    }
}
