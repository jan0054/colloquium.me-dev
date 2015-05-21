package com.cmmath.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import java.util.Date;

import com.parse.GetCallback;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParsePush;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.cmmath.app.widget.BaseActivity;

import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ListView;

import org.json.JSONException;
import org.json.JSONObject;

public class ChatActivity extends BaseActivity implements  AdapterView.OnItemClickListener {

    public ParseObject pfconversation;
    public ParseUser otherguy;
    private ChatAdapter chatAdapter;
    public String conversationid;
    protected static boolean isChat = false;
    protected cmmathApplication app;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_chat);
        mTitle.setText(getString(R.string.title_conversation));

        //get the conversation id from the intent extras
        conversationid = this.getIntent().getExtras().getString("selected_conv");
        //get the conversation object
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Conversation");
        query.include("user_a");
        query.include("user_b");
        query.getInBackground(conversationid, new GetCallback<ParseObject>() {
            public void done(ParseObject object, ParseException e) {
                if (e == null) {
                    pfconversation = object;
                    //reset the unread count to zero, whether its unread_a or b
                    ParseUser currentUser = ParseUser.getCurrentUser();
                    final String cid = currentUser.getObjectId();
                    ParseUser user_a = pfconversation.getParseUser("user_a");
                    ParseUser user_b = pfconversation.getParseUser("user_b");
                    final String aid = user_a.getObjectId();
                    final String bid = user_b.getObjectId();
                    if (cid.equals(aid))
                    {
                        //user_b is the other guy
                        Log.i("sendChat", "user_b is the other guy");
                        pfconversation.put("user_a_unread", 0);
                        pfconversation.saveInBackground();
                    }
                    else if (cid.equals(bid))
                    {
                        //user_a is the other guy
                        Log.i("sendChat", "user_a is the other guy");
                        pfconversation.put("user_b_unread", 0);
                        pfconversation.saveInBackground();
                    }
                } else {
                    // something went wrong
                }
            }
        });

        chatAdapter = new ChatAdapter(this);
        ListView listview = (ListView) findViewById(R.id.chatcontent);
        chatAdapter.convid = conversationid;
        chatAdapter.setPaginationEnabled(false);
        chatAdapter.loadObjects();
        listview.setAdapter(chatAdapter);
        listview.setOnItemClickListener(this);

        this.registerReceiver(mMessageReceiver, new IntentFilter("got_chat_intent"));
    }

    @Override
    protected void onResume()
    {
        super.onResume();
        app=(cmmathApplication)getApplication();
        app.isChat=true;
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
            chatAdapter.loadObjects();
            //String message = intent.getStringExtra("message");
        }
    };

    public void sendChat(View view) {
        Log.i("sendChat", "send chat button pressed");
        //setup all the data for the new chat object
        EditText editText = (EditText) findViewById(R.id.chatinput);
        final String message = editText.getText().toString();
        Log.i("sendChat", message);
        ParseUser currentUser = ParseUser.getCurrentUser();
        //get the other guy
        final String cid = currentUser.getObjectId();
        ParseUser user_a = pfconversation.getParseUser("user_a");
        ParseUser user_b = pfconversation.getParseUser("user_b");
        final String aid = user_a.getObjectId();
        final String bid = user_b.getObjectId();
        if (cid.equals(aid))
        {
            //user_b is the other guy
            Log.i("sendChat", "user_b is the other guy");
            otherguy = user_b;
        }
        else if (cid.equals(bid))
        {
            //user_a is the other guy
            Log.i("sendChat", "user_a is the other guy");
            otherguy = user_a;
        }

        //create and save the chat object
        ParseObject chatmsg = new ParseObject("Chat");
        chatmsg.put("content",message);
        chatmsg.put("conversation", pfconversation);
        chatmsg.put("from", currentUser);
        chatmsg.put("to", otherguy);
        ParseACL chatACL = new ParseACL(ParseUser.getCurrentUser());
        chatACL.setPublicReadAccess(true);
        chatACL.setPublicWriteAccess(true);
        chatmsg.setACL(chatACL);
        chatmsg.saveInBackground(new SaveCallback() {
            public void done(ParseException e) {
                if (e == null) {
                    //saved complete
                    EditText edt = (EditText) findViewById(R.id.chatinput);
                    edt.setText("");
                    Log.i("sendChat", "save success");
                    chatAdapter.loadObjects();

                    //sent! now send the push notification: first prepare the message payload
                    JSONObject pn = new JSONObject();
                    try {
                        pn.put("alert", message);
                        pn.put("sound", "default");
                        pn.put("badge", "Increment");
                    } catch (JSONException e1) {
                        e1.printStackTrace();
                    }
                    // Create our Installation query
                    ParseQuery pushQuery = ParseInstallation.getQuery();
                    pushQuery.whereEqualTo("user", otherguy);
                    // Send push notification to query
                    ParsePush push = new ParsePush();
                    push.setQuery(pushQuery); // Set our Installation query
                    //push.setMessage(message);
                    push.setData(pn);
                    push.sendInBackground();

                    //also update the conversation last msg/last msg time/unread count
                    Date date = new Date();
                    pfconversation.put("last_time", date);
                    pfconversation.put("last_msg", message);
                    if (cid.equals(aid))
                    {
                        //user_b is the other guy
                        pfconversation.increment("user_b_unread");
                    }
                    else if (cid.equals(bid))
                    {
                        //user_a is the other guy
                        pfconversation.increment("user_a_unread");
                    }
                    pfconversation.saveInBackground();

                }
                else {
                    Log.i("sendChat", "save fail");
                    //did not save successfully
                }
            }
        });
    }
/*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_chat, menu);
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
    @Override
    public void onItemClick(AdapterView parent, View view, int position, long id) {
        //selected some conversation at index:position
        Log.d("listview_selection", "SELECTED ROW INDEX:"+Integer.toString(position));

    }
}
