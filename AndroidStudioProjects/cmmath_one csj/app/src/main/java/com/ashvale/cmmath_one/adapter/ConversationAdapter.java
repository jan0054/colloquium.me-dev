package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;
import com.parse.ParseUser;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by csjan on 9/3/15.
 */
public class ConversationAdapter extends BaseAdapter {
    private final Context context;
    private final List conversations;

    public ConversationAdapter(Context context, List queryresults) {
        this.context = context;
        this.conversations = queryresults;
    }

    @Override
    public int getCount()
    {
        return conversations.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  conversations.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_conversation, vg, false);
        }

        ParseObject conversation = (ParseObject)conversations.get(position);

        TextView timeLabel = (TextView)view.findViewById(R.id.conversationTime);
        TextView msgLabel = (TextView)view.findViewById(R.id.conversationMsg);
        TextView namelabel = (TextView)view.findViewById(R.id.conversationName);

        List<ParseUser> participants;
        participants = conversation.getList("participants");
        final ParseUser selfUser = ParseUser.getCurrentUser();
        String nameList = "";
        for (ParseUser user : participants)
        {
            String fullName = user.getString("first_name")+" "+user.getString("last_name");
            if (!user.getObjectId().equals(selfUser.getObjectId()))
            {
                if (nameList.length()>1)
                {
                    nameList = nameList+", "+fullName;
                }
                else
                {
                    nameList = fullName;
                }
            }
        }

        Date lastdate = conversation.getDate("last_time");
        Format convdateformatter = new SimpleDateFormat("MM-dd HH:mm");

        String timestr = convdateformatter.format(lastdate);
        String msgstr = conversation.getString("last_msg");
        String namestr = nameList;

        timeLabel.setText(timestr);
        msgLabel.setText(msgstr);
        namelabel.setText(namestr);

        return view;
    }
}