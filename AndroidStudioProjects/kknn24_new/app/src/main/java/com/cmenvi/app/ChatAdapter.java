package com.cmenvi.app;

/**
 * Created by chishengjan on 12/15/14.
 */
import java.text.Format;
        import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import android.content.Context;
import android.util.Log;
import android.view.View;
        import android.view.ViewGroup;
        import android.widget.TextView;

        import com.cmenvi.app.data._PARAMS;
        import com.parse.ParseObject;
        import com.parse.ParseQuery;
        import com.parse.ParseQueryAdapter;
import com.parse.ParseRelation;
import com.parse.ParseUser;



public class ChatAdapter extends ParseQueryAdapter<ParseObject> {

    public static final String 	TAG 						= ChatAdapter.class.getSimpleName();
    public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.chat";
    public static final String 	ACTION_QUERY_DATA		 	= "action.query.data.chat";
    public static final String 	DATA						= "data.chat";

    // Column Name
    public static String		AUTHOR				= "author";	        // Pointer User
    public static String		CONTENT 			= "content";	    // String
    public static String		CONVERSATION		= "conversation";	// Pointer Conversation
    public static String		READ 				= "read";   		// Relation User
    public static String		CREATEDAT			= "createdAt";	// Date
    public static String		UPDATEDAT			= "updatedAt";	// Date

    public static String convid;

    public ChatAdapter(Context context) {
        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {
                ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery(_PARAMS.TABLE_CONVERSATION);
                innerQuery.whereEqualTo(ConversationAdapter.OBJECTID, convid);
                ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_CHAT);
                query.whereMatchesQuery(CONVERSATION, innerQuery);
                query.include(AUTHOR);
                query.include(READ);
                query.orderByAscending("createdAt");
                //query.orderByDescending("createdAt");
                return query;
            }
        });
    }

    @Override
    public View getItemView(ParseObject chatobj, View v, ViewGroup parent) {
        super.getItemView(chatobj, v, parent);

        ParseUser currentUser = ParseUser.getCurrentUser();
        ParseUser author = chatobj.getParseUser(AUTHOR);

            if (author.getObjectId().equals(currentUser.getObjectId()))
            {
                Log.d("chat", "author is me "+author.getObjectId()+", "+currentUser.getObjectId());
                //msg is from current user, load chat_me_row
                v = View.inflate(getContext(), R.layout.chat_me_row, null);
                //chat time data
                TextView chattimeTextView = (TextView) v.findViewById(R.id.chatTime);
                Date date = chatobj.getCreatedAt();
                Format formatter = new SimpleDateFormat("MM-dd HH:mm");
                String datestr = formatter.format(date);
                chattimeTextView.setText(datestr);

                //chat content data
                TextView chatcontentTextView = (TextView) v.findViewById(R.id.text1);
                chatcontentTextView.setText(chatobj.getString(CONTENT));
            }
            else
            {
                Log.d("chat", "author is not me "+author.getObjectId()+", "+currentUser.getObjectId());
                //msg is to current user, load chat_you_row
                v = View.inflate(getContext(), R.layout.chat_you_row, null);
                //chat time data
                TextView chattimeTextView = (TextView) v.findViewById(R.id.chatTime);
                Date date = chatobj.getCreatedAt();
                Format formatter = new SimpleDateFormat("MM-dd HH:mm");
                String datestr = formatter.format(date);
                chattimeTextView.setText(datestr);

                //chat content data
                TextView chatcontentTextView = (TextView) v.findViewById(R.id.text1);
                chatcontentTextView.setText(chatobj.getString(CONTENT));

                TextView chatauthorTextView = (TextView)v.findViewById(R.id.chatAuthor);
                chatauthorTextView.setText(author.getUsername());
            }

        List<ParseUser> read_list = chatobj.getList(READ);
        if(read_list == null) {
            read_list = new ArrayList<ParseUser>();
            chatobj.put(READ, read_list);
        }
        read_list.add(currentUser);
        chatobj.saveInBackground();

        return v;
    }

}
