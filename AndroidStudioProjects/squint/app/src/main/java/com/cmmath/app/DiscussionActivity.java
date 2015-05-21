package com.cmmath.app;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ListView;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.cmmath.app.widget.BaseActivity;


public class DiscussionActivity extends BaseActivity {

    private DiscussionTalkAdapter talk_adapter;
    private DiscussionPosterAdapter poster_adapter;
    public String event_objid;
    public int event_type;
    public ParseObject cur_person;
    public ParseObject event_obj;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_discussion);
        event_objid = this.getIntent().getExtras().getString("event_objid");
        event_type = this.getIntent().getExtras().getInt("event_type");
        Log.d("DISCUSS", "DISCUSS: " + event_objid + "TYPE " + event_type);
        if (event_type == 0)
        {
            //talk
            talk_adapter = new DiscussionTalkAdapter(this);
            ListView listview = (ListView) findViewById(R.id.discussioncontent);
            talk_adapter.event_objid = event_objid;
            talk_adapter.setPaginationEnabled(false);
            talk_adapter.loadObjects();
            listview.setAdapter(talk_adapter);
        }
        else if (event_type == 1)
        {
            //poster
            poster_adapter = new DiscussionPosterAdapter(this);
            ListView listview = (ListView) findViewById(R.id.discussioncontent);
            poster_adapter.event_objid = event_objid;
            poster_adapter.setPaginationEnabled(false);
            poster_adapter.loadObjects();
            listview.setAdapter(poster_adapter);
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

    public void sendDiscussion(View view) {
        final EditText editText = (EditText) findViewById(R.id.discussioninput);
        final String message = editText.getText().toString();
        Log.i("sendDiscussion", message);

        ParseObject discussion_msg = new ParseObject("Forum");
        discussion_msg.put("content", message);
        discussion_msg.put("author_user", ParseUser.getCurrentUser());
        discussion_msg.put("author_person", cur_person);
        switch (event_type) {
            case 0:
                discussion_msg.put("source_talk", event_obj);
                break;
            case 1:
                discussion_msg.put("source_poster", event_obj);
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
                else if (event_type == 1)
                {
                    poster_adapter.loadObjects();
                }
            }
        });
    }
}
