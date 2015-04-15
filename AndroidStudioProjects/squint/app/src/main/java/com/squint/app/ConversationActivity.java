package com.squint.app;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.parse.ParseObject;
import com.squint.app.widget.BaseActivity;

public class ConversationActivity extends BaseActivity implements  AdapterView.OnItemClickListener {
	
	public static final String TAG = ConversationActivity.class.getSimpleName();
    private ConversationAdapter conversationAdapter;


	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_conversation);		
		mTitle.setText(getString(R.string.title_conversation));		
		configOptions(OPTION_BACK, OPTION_NONE);

        conversationAdapter = new ConversationAdapter(this);

        ListView listview = (ListView) findViewById(R.id.listview);
        conversationAdapter.loadObjects();
        listview.setAdapter(conversationAdapter);

        listview.setOnItemClickListener(this);

	}
	
	@Override
	public void onResume() {		
		super.onResume();
	}

    @Override
    protected void onRestart() {
        super.onRestart();
        Log.i("sendChat", "on_restart called");
        conversationAdapter.loadObjects();
    }

    @Override
    public void onItemClick(AdapterView parent, View view, int position, long id) {

        //selected some conversation at index:position, get the object id of this conversation
        Log.d("listview_selection", "SELECTED ROW INDEX:"+Integer.toString(position));
        ListView listview = (ListView) findViewById(R.id.listview);
        ParseObject pfconversation = (ParseObject) listview.getItemAtPosition(position);
        String convid = pfconversation.getObjectId();

        //start chat_detail activity and pass along the conversation id
        Intent chatIntent = new Intent(this, ChatActivity.class);
        chatIntent.putExtra("selected_conv",  convid);

        startActivity(chatIntent);
    }
}
