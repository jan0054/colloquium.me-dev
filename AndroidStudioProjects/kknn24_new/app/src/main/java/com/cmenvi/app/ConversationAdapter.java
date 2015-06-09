package com.cmenvi.app;

/**
 * Created by chishengjan on 12/13/14.
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

import com.cmenvi.app.data._ERROR;
import com.cmenvi.app.data._PARAMS;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;
import com.parse.ParseRelation;
import com.parse.ParseUser;



public class ConversationAdapter extends ParseQueryAdapter<ParseObject> {

    public static final String 	TAG 						= ConversationAdapter.class.getSimpleName();
    public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.conversation";
    public static final String 	ACTION_QUERY_DATA		 	= "action.query.data.conversation";
    public static final String 	DATA						= "data.conversation";

    // Column Name
    public static String        OBJECTID            = "objectId";   // String
    public static String		LASTMSG				= "last_msg";	// String
    public static String		LASTTIME			= "last_time";	// Date
    public static String		NAME				= "name";		// String
    public static String		UNREAD 				= "unread";		// Array
    public static String		PARTICIPANTS		= "participants";	// Relation
    public static String		ISGROUP				= "is_group";	// Number
    public static String		CREATEDAT			= "createdAt";	// Date
    public static String		UPDATEDAT			= "updatedAt";	// Date

    String conv_name = "";
    ParseUser currentUser = ParseUser.getCurrentUser();;
    String cid = currentUser.getObjectId();

    public ConversationAdapter(Context context) {
        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {
                ParseUser currentUser = ParseUser.getCurrentUser();

                ParseQuery<ParseObject> user_conv = ParseQuery.getQuery(_PARAMS.TABLE_CONVERSATION);
                ArrayList<ParseUser> user_list = new ArrayList<ParseUser>();
                user_list.add(currentUser);
                user_conv.whereContainsAll(PARTICIPANTS, user_list);

                List<ParseQuery<ParseObject>> queries = new ArrayList<ParseQuery<ParseObject>>();
                queries.add(user_conv);

                ParseQuery<ParseObject> mainQuery = ParseQuery.or(queries);
                mainQuery.orderByDescending(CREATEDAT);
                mainQuery.include(PARTICIPANTS);

                return mainQuery;

            }
        });
    }

    @Override
    public View getItemView(ParseObject convobj, View v, ViewGroup parent) {

        if (v == null) {
            v = View.inflate(getContext(), R.layout.conversation_row, null);
        }

        super.getItemView(convobj, v, parent);
        final TextView convauthorTextView = (TextView) v.findViewById(R.id.convauthor);

        //conversation author data
        List<ParseUser> user_relation = convobj.getList(PARTICIPANTS);
        conv_name = "";
        Log.d("conv_name", "size = " + user_relation.size());
        int i = 0;
        for (i = 0; i < user_relation.size(); i++) {
            if (!user_relation.get(i).getObjectId().equals(cid)) {
                if (conv_name != "") {
                    conv_name += ", ";
                }
                conv_name += user_relation.get(i).getUsername();
                Log.d("conv_name", "name = " + conv_name);
            }
        }
        convauthorTextView.setText(conv_name);
        Log.d("conv_name", "final = " + conv_name);

        List<ParseUser> unread_list = convobj.getList(UNREAD);

        //chat content data
        TextView lastmsgTextView = (TextView) v.findViewById(R.id.lastmsg);
        lastmsgTextView.setText(convobj.getString(LASTMSG));

        //conversation last message time data
        TextView lasttimeTextView = (TextView) v
                .findViewById(R.id.lasttime);
        Date lastdate = convobj.getDate(LASTTIME);
        Format convdateformatter = new SimpleDateFormat("MM-dd HH:mm");
        String lastdatestr = convdateformatter.format(lastdate);
        lasttimeTextView.setText(lastdatestr);

        return v;
    }

}
