package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.ashvale.cmmath_one.AddeventActivity;
import com.ashvale.cmmath_one.EventWrapperActivity;
import com.ashvale.cmmath_one.HomeActivity;
import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.cmmathApplication;
import com.parse.ParseObject;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Created by csjan on 9/3/15.
 */
public class EventAdapter extends BaseAdapter {
    private SharedPreferences savedEvents;
    private final Context context;
    private final List<ParseObject> events;
    private final int[] selectedPositions;

    public EventAdapter(Context context, List<ParseObject> queryresults, int[] selectedpositions) {
        this.context = context;
        this.events = queryresults;
        this.selectedPositions = selectedpositions;
    }

    public EventAdapter(Context context, List queryresults) {
        this.context = context;
        this.events = queryresults;
        int arraySize = queryresults.size();
        this.selectedPositions = new int[arraySize];
        for (int i = 0; i < arraySize; i++) {
            this.selectedPositions[i] = 1;
        }
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

            view = inflater.inflate(R.layout.listitem_event, vg, false);
        }

        ParseObject event = (ParseObject)events.get(position);

        ImageView followImage = (ImageView)view.findViewById(R.id.followImage);
        TextView followString = (TextView)view.findViewById(R.id.followString);
        TextView nameLabel = (TextView)view.findViewById(R.id.eventName);
        TextView timeLabel = (TextView)view.findViewById(R.id.eventTime);
        TextView organizerLabel = (TextView)view.findViewById(R.id.eventOrg);
        TextView contentLabel = (TextView)view.findViewById(R.id.eventContent);
        TextView detailsLabel = (TextView)view.findViewById(R.id.details);
        LinearLayout followLabel = (LinearLayout)view.findViewById(R.id.followLabel);

        Date startdate = event.getDate("start_time");
        Date enddate = event.getDate("end_time");
        Format dateformatter = new SimpleDateFormat("MM/dd");
        String startstr = dateformatter.format(startdate);
        String endstr = dateformatter.format(enddate);
        String contentstr = event.getString("content");
        String namestr = event.getString("name");
        String orgstr = event.getString("organizer");

        int selected = selectedPositions[position];
        if (selected == 1)
        {
            followImage.setImageResource(R.drawable.star_full64);
            followImage.setColorFilter(context.getResources().getColor(R.color.primary_color_icon));
            followString.setText(R.string.unfollow_event);
        }
        else
        {
            followImage.setImageResource(R.drawable.star_empty64);
            followImage.setColorFilter(context.getResources().getColor(R.color.unselected_icon));
            followString.setText(R.string.follow_event);
        }

        nameLabel.setText(namestr);
        organizerLabel.setText(orgstr);
        contentLabel.setText(contentstr);
        timeLabel.setText(startstr+" ~ "+endstr);
        detailsLabel.setTag(position);
        followLabel.setTag(position);

        detailsLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                savedEvents = context.getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
                SharedPreferences.Editor editor = savedEvents.edit();
                int itemPosition = (int) v.getTag();
                ParseObject curEvent = events.get(itemPosition);
                editor.putString("currenteventid", curEvent.getObjectId());
                editor.commit();
                List<ParseObject> children = curEvent.getList("childrenEvent");
                if (children == null || children.size() == 0) { //no childrenEvent
                    context.startActivity(new Intent(context, EventWrapperActivity.class));
                } else {
                    Intent intentHome = new Intent(context, HomeActivity.class);
                    intentHome.putExtra("eventNest", 1);
                    context.startActivity(intentHome);
                }
            }
        });

        followLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int itemPosition = (int) v.getTag();
                ParseObject curEvent = events.get(itemPosition);

                if(context instanceof HomeActivity) {
                    ((HomeActivity)context).refreshList();
                } else if(context instanceof AddeventActivity) {
                    ((AddeventActivity)context).refreshList();
                }
            }
        });

        return view;
    }
}