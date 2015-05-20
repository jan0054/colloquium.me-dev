package com.squint.app;

/**
 * Created by chishengjan on 12/13/14.
 */
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseImageView;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseQueryAdapter;
import com.parse.ParseUser;



public class ConversationAdapter extends ParseQueryAdapter<ParseObject> {



    public ConversationAdapter(Context context) {
        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {
                ParseUser currentUser = ParseUser.getCurrentUser();

                ParseQuery<ParseObject> usera_conv = ParseQuery.getQuery("Conversation");
                usera_conv.whereEqualTo("user_a", currentUser);

                ParseQuery<ParseObject> userb_conv = ParseQuery.getQuery("Conversation");
                userb_conv.whereEqualTo("user_b", currentUser);

                List<ParseQuery<ParseObject>> queries = new ArrayList<ParseQuery<ParseObject>>();
                queries.add(usera_conv);
                queries.add(userb_conv);

                ParseQuery<ParseObject> mainQuery = ParseQuery.or(queries);
                mainQuery.orderByDescending("createdAt");
                mainQuery.include("user_a");
                mainQuery.include("user_b");

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

        //conversation author data
        ParseUser currentUser = ParseUser.getCurrentUser();
        String cid = currentUser.getObjectId();
        ParseUser user_a = convobj.getParseUser("user_a");
        ParseUser user_b = convobj.getParseUser("user_b");
        String aid = user_a.getObjectId();
        String bid = user_b.getObjectId();
        int aunread = convobj.getInt("user_a_unread");
        int bunread = convobj.getInt("user_b_unread");
        TextView convauthorTextView = (TextView) v
                .findViewById(R.id.convauthor);
        if (cid.equals(aid))
        {
            //user_b is the other guy
            convauthorTextView.setText(user_b.getString("username"));
            //check user_a_unread count to see if there are unread messages
            if (aunread >=1)
            {
                TextView unreadview = (TextView)v.findViewById(R.id.unreadnotice);
                unreadview.setText("new message");
            }
            else
            {
                TextView unreadview = (TextView)v.findViewById(R.id.unreadnotice);
                unreadview.setText("");
            }
        }
        else if (cid.equals(bid))
        {
            //user_a is the other guy
            convauthorTextView.setText(user_a.getString("username"));
            //check user_b_unread count to see if there are unread messages
            if (bunread >=1)
            {
                TextView unreadview = (TextView)v.findViewById(R.id.unreadnotice);
                unreadview.setText("new message");
            }
            else
            {
                TextView unreadview = (TextView)v.findViewById(R.id.unreadnotice);
                unreadview.setText("");
            }
        }

        //chat content data
        TextView lastmsgTextView = (TextView) v.findViewById(R.id.lastmsg);
        lastmsgTextView.setText(convobj.getString("last_msg"));

        //conversation last message time data
        TextView lasttimeTextView = (TextView) v
                .findViewById(R.id.lasttime);
        Date lastdate = convobj.getDate("last_time");
        Format convdateformatter = new SimpleDateFormat("MM-dd HH:mm");
        String lastdatestr = convdateformatter.format(lastdate);
        lasttimeTextView.setText(lastdatestr);

        return v;
    }

}
