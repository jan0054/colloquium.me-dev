package com.ashvale.cmmath_one;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.ChatAdapter;
import com.ashvale.cmmath_one.adapter.ConversationAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.List;

public class ChatActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);

        String convId = this.getIntent().getExtras().getString("convid");
        ParseObject convObject = ParseObject.createWithoutData("Conversation", convId);
        convObject.fetchInBackground();
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Chat");
        query.whereEqualTo("conversation", convObject);
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
}
