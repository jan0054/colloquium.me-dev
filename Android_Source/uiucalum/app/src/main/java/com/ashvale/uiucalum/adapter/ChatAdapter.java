package com.ashvale.uiucalum.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.uiucalum.R;
import com.parse.ParseObject;
import com.parse.ParseUser;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Created by csjan on 9/15/15.
 */
public class ChatAdapter extends BaseAdapter {
    private final Context context;
    private final List chats;

    public ChatAdapter(Context context, List<ParseObject> queryresults) {
        this.context = context;
        this.chats = queryresults;
    }

    @Override
    public int getCount()
    {
        return chats.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  chats.get(position);
    }

    @Override
    public int getViewTypeCount()
    {
        return 3;
    }

    @Override
    public int getItemViewType(int position)
    {
        ParseObject chatObject = (ParseObject)chats.get(position);
        ParseUser currentUser = ParseUser.getCurrentUser();
        ParseUser author = chatObject.getParseUser("author");
        int broadcast = chatObject.getInt("broadcast");

        if (broadcast == 1)
        {
            return 2;
        }
        else if (author.getObjectId().equals(currentUser.getObjectId()))
        {
            return 0;
        }
        else
        {
            return 1;
        }
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        ParseObject chatObject = (ParseObject)chats.get(position);
        ParseUser currentUser = ParseUser.getCurrentUser();
        ParseUser author = chatObject.getParseUser("author");
        Date date = chatObject.getCreatedAt();
        Format formatter = new SimpleDateFormat("MM/dd HH:mm");
        String datestr = formatter.format(date);
        String msgstr = chatObject.getString("content");
        String authorstr = author.getString("first_name")+" "+author.getString("last_name");

        int type = getItemViewType(position);

        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            if (type == 0)
            {
                view = inflater.inflate(R.layout.listitem_mechat, vg, false);
            }
            else if (type == 1)
            {
                view = inflater.inflate(R.layout.listitem_youchat, vg, false);
            }
            else
            {
                view = inflater.inflate(R.layout.listitem_broadcast, vg, false);
            }
        }

        if (type == 0)
        {
            TextView msgLabel = (TextView)view.findViewById(R.id.chat_content);
            TextView timeLabel = (TextView)view.findViewById(R.id.chat_time);
            msgLabel.setText(msgstr);
            timeLabel.setText(datestr);
        }
        else if (type == 1)
        {
            TextView msgLabel = (TextView)view.findViewById(R.id.chat_content);
            TextView timeLabel = (TextView)view.findViewById(R.id.chat_time);
            TextView authorLabel = (TextView)view.findViewById(R.id.chat_author);
            msgLabel.setText(msgstr);
            timeLabel.setText(datestr);
            authorLabel.setText(authorstr);
        }
        else
        {
            TextView msgLabel = (TextView)view.findViewById(R.id.chat_content);
            msgLabel.setText(msgstr);
        }

        return view;
    }
}