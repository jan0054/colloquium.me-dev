package com.cmenvi.app;

/**
 * Created by chishengjan on 12/15/14.
 */
        import java.text.Format;
        import java.text.SimpleDateFormat;
        import java.util.Date;
        import android.content.Context;
        import android.view.View;
        import android.view.ViewGroup;
        import android.widget.TextView;

        import com.parse.ParseObject;
        import com.parse.ParseQuery;
        import com.parse.ParseQueryAdapter;
        import com.parse.ParseUser;



public class ChatAdapter extends ParseQueryAdapter<ParseObject> {

    public static String convid;

    public ChatAdapter(Context context) {
        super(context, new ParseQueryAdapter.QueryFactory<ParseObject>() {
            public ParseQuery<ParseObject> create() {
                ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Conversation");
                innerQuery.whereEqualTo("objectId", convid);
                ParseQuery<ParseObject> query = ParseQuery.getQuery("Chat");
                query.whereMatchesQuery("conversation", innerQuery);
                query.include("from");
                query.include("to");
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
        ParseUser user_from = chatobj.getParseUser("from");
        ParseUser user_to = chatobj.getParseUser("to");
        String fid = user_from.getObjectId();
        String tid = user_to.getObjectId();
        String cid = currentUser.getObjectId();
        String fromname = user_from.getString("username");
        Integer fromto = 0;

        //if (v == null) {
            if (fid.equals(cid))
            {
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
                chatcontentTextView.setText(chatobj.getString("content"));
                fromto = 1;
            }
            else if (tid.equals(cid))
            {
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
                chatcontentTextView.setText(chatobj.getString("content"));

                TextView chatauthorTextView = (TextView)v.findViewById(R.id.chatAuthor);
                chatauthorTextView.setText(fromname);

                fromto = 2;
            }

        //}


        return v;
    }

}
