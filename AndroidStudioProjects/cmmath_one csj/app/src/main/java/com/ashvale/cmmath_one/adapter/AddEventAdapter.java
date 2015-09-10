package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.SharedPreferences;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Set;

/**
 * Created by csjan on 9/3/15.
 */
public class AddEventAdapter extends BaseAdapter {
    private final Context context;
    private final List events;
    private final int[] selectedPositions;

    public AddEventAdapter(Context context, List queryresults, int[] selectedpositions) {
        this.context = context;
        this.events = queryresults;
        this.selectedPositions = selectedpositions;
    }

    @Override
    public int getCount()
    {
        return events.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  events.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_eventpicker, vg, false);
        }

        ParseObject event = (ParseObject)events.get(position);

        ImageView imagelabel = (ImageView)view.findViewById(R.id.imageLabel);
        TextView namelabel = (TextView)view.findViewById(R.id.nameLabel);
        TextView timelabel = (TextView)view.findViewById(R.id.timeLabel);
        TextView organizerlabel = (TextView)view.findViewById(R.id.organizerLabel);
        TextView contentlabel = (TextView)view.findViewById(R.id.contentLabel);

        Date startdate = event.getDate("start_time");
        Date enddate = event.getDate("end_time");
        Format dateformatter = new SimpleDateFormat("MM/dd");
        String startstr = dateformatter.format(startdate);
        String endstr = dateformatter.format(enddate);
        String contentstr = event.getString("content");
        String namestr = event.getString("name");
        String orgstr = event.getString("organizer");
        String selectednamestr = "-Selected- "+namestr;

        /*
        SharedPreferences savedEvents = context.getSharedPreferences("EVENTS", 6);
        Set<String> eventIdSet = savedEvents.getStringSet("eventids", null);
        if (eventIdSet != null)   //there were some saved events
        {
            String eventid = event.getObjectId();
            int contained = 0;
            for (String idSet : eventIdSet)
            {
                if (eventid.equals(idSet))
                {
                    contained = 1;
                }
            }
            if (contained == 1)
            {
                imagelabel.setImageResource(R.drawable.checkevent);
            }
            else
            {
                imagelabel.setImageResource(0);
            }
        }
        else
        {
            imagelabel.setImageResource(0);
        }
        */
        int selected = selectedPositions[position];
        if (selected == 1)
        {
            imagelabel.setImageResource(R.drawable.checkevent);
        }
        else
        {
            imagelabel.setImageResource(0);
        }

        namelabel.setText(namestr);
        organizerlabel.setText(orgstr);
        contentlabel.setText(contentstr);
        timelabel.setText(startstr+" ~ "+endstr);

        return view;
    }
}