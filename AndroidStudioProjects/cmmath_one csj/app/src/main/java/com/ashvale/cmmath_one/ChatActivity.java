package com.ashvale.cmmath_one;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.ChatAdapter;
import com.ashvale.cmmath_one.adapter.ConversationAdapter;
import com.ashvale.cmmath_one.fragments.AttendeeFragment;
import com.ashvale.cmmath_one.fragments.OverviewFragment;
import com.ashvale.cmmath_one.fragments.ProgramFragment;
import com.ashvale.cmmath_one.fragments.TimelineFragment;
import com.ashvale.cmmath_one.fragments.VenueFragment;
import com.parse.FindCallback;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParsePush;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Date;
import java.util.List;

public class ChatActivity extends AppCompatActivity {

    public ParseObject conversationObject;
    protected cmmathApplication app;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        String convId = this.getIntent().getExtras().getString("convid");
        conversationObject = ParseObject.createWithoutData("Conversation", convId);
        conversationObject.fetchInBackground();
        getChatList();

        final Button sendChat = (Button)findViewById(R.id.send_chat);
        sendChat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sendChat();
            }
        });
    }

    public void getChatList() {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Chat");
        query.whereEqualTo("conversation", conversationObject);
        query.include("author");
        query.orderByAscending("createdAt");
        query.setLimit(500);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "chat query result: " + objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "chat query error: " + e);
                }
            }
        });
    }

    public void setAdapter(final List<ParseObject> results)
    {
        ChatAdapter adapter = new ChatAdapter(this, results);
        ListView chatListView = (ListView)findViewById(R.id.chat_listview);
        chatListView.setAdapter(adapter);
    }

    public void sendChat() {
        Log.i("cm_app", "send chat button pressed");

        //setup data for the new chat object
        EditText editText = (EditText) findViewById(R.id.chat_input);
        final String msgContent = editText.getText().toString();
        final ParseUser currentUser = ParseUser.getCurrentUser();

        //create and save the chat object
        ParseObject chatObj = new ParseObject("Chat");
        chatObj.put("author", currentUser);
        chatObj.put("content", msgContent);
        chatObj.put("conversation", conversationObject);

        chatObj.saveInBackground(new SaveCallback() {
            public void done(ParseException e) {
                if (e == null) {
                    //saved complete
                    EditText edt = (EditText) findViewById(R.id.chat_input);
                    edt.setText("");
                    Log.i("sendChat", "save success");
                    getChatList();

                    //sent! now send the push notification: first prepare the message payload
                    JSONObject pn = new JSONObject();
                    try {
                        pn.put("alert", msgContent);
                        pn.put("sound", "default");
                        pn.put("badge", "Increment");
                    } catch (JSONException e1) {
                        e1.printStackTrace();
                    }
                    // Create our Installation query
                    List<ParseUser> allParticipants = conversationObject.getList("participants");
                    for (ParseUser user : allParticipants) {
                        if (user.getObjectId().equals(currentUser.getObjectId())) {
                            allParticipants.remove(user);
                        }
                    }

                    ParseQuery pushQuery = ParseInstallation.getQuery();
                    pushQuery.whereContainedIn("user", allParticipants);
                    // Send push notification to query
                    ParsePush push = new ParsePush();
                    push.setQuery(pushQuery); // Set our Installation query
                    //push.setMessage(message);
                    push.setData(pn);
                    push.sendInBackground();

                    //also update the conversation last msg/last msg time/unread count
                    Date date = new Date();
                    conversationObject.put("last_time", date);
                    conversationObject.put("last_msg", msgContent);
                    conversationObject.saveInBackground();

                } else {
                    Log.i("cm_app", "send chat failed");
                }
            }
        });
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        app=(cmmathApplication)getApplication();
        app.isChat=true;
        this.registerReceiver(mMessageReceiver, new IntentFilter("got_chat_intent"));
    }

    @Override
    protected void onPause()
    {
        super.onPause();
        app=(cmmathApplication)getApplication();
        app.isChat = false;
        this.unregisterReceiver(mMessageReceiver);
    }

    //This is the handler that will listen to process the broadcast intent
    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            getChatList();
        }
    };

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_chat, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
            case R.id.leave_chat:
                //to-do: handle leaving the chat
                return true;

            case R.id.invite_chat:
                //to-do: start the chat invite activity
                return true;

            default:
                return super.onOptionsItemSelected(item);
        }
    }
}
