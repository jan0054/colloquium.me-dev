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
import com.parse.ParseUser;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Created by csjan on 9/3/15.
 */
public class EventAdapter extends BaseAdapter {
    private SharedPreferences savedEvents;
    private List<ParseObject> selectedEvents;
    private List<String> selectedEventIds;
    private List<String> selectedEventNames;
    private final Context context;
    private final List<ParseObject> events;
    private final int[] selectedPositions;

    public EventAdapter(Context context, List<ParseObject> queryresults, int[] selectedpositions) {
        this.context = context;
        this.events = queryresults;
        this.selectedPositions = selectedpositions;
        selectedEvents = new ArrayList<ParseObject>();
        selectedEventIds = new ArrayList<String>();
        selectedEventNames = new ArrayList<String>();
        Log.d("cm_app", "array :"+this.events.size());
    }

    public EventAdapter(Context context, List queryresults) {
        this.context = context;
        this.events = queryresults;
        int arraySize = queryresults.size();
        this.selectedPositions = new int[arraySize];
        for (int i = 0; i < arraySize; i++) {
            this.selectedPositions[i] = 1;
        }
        selectedEvents = new ArrayList<ParseObject>();
        selectedEventIds = new ArrayList<String>();
        selectedEventNames = new ArrayList<String>();
        Log.d("cm_app", "array :"+this.events.size());
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

        final int selected = selectedPositions[position];
        if (selected == 1)
        {
            followImage.setImageResource(R.drawable.star_full64);
            followImage.setColorFilter(context.getResources().getColor(R.color.primary_color_icon));
            followString.setText(R.string.unfollow_event);
/*            if(!selectedEventIds.contains(event.getObjectId())) {
                selectedEventIds.add(event.getObjectId());
                selectedEventNames.add(event.getString("name"));
                selectedEvents.add(event);
            }*/
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

                saveEvents(selectedPositions[itemPosition], curEvent);
                if(selectedPositions[itemPosition] == 1) //need unfollow
                {
                    selectedPositions[itemPosition] = 0;
                    saveEvents(1, curEvent);
                } else { //new follow
                    selectedPositions[itemPosition] = 1;
                    saveEvents(0, curEvent);
                }
//                saveEvents();
            }
        });

        return view;
    }

    public void saveEvents(int positionValue, ParseObject curEvent)
    {
        savedEvents = context.getSharedPreferences("EVENTS", 6); //6 = readable+writable by other apps, use 0 for private
        SharedPreferences.Editor editor = savedEvents.edit();
        Set<String> eventIdSet = savedEvents.getStringSet("eventids", null);
        if (eventIdSet != null)   //there were some saved events
        {
            Log.d("cm_app", "savedEvents size = "+eventIdSet.size());
            for (int i = 0; i< events.size(); i++)   //iterate over total number of events
            {
                ParseObject event = events.get(i);   //get the parse object at position i
                String eventid = event.getObjectId();
                int contained = 0;
                for (String idSet : eventIdSet)       //1: the parse object at position i is contained in local storage saved list, 0: otherwise
                {
                    if (eventid.equals(idSet))
                    {
                        contained = 1;
                    }
                }
                if (contained == 1)
                {
                    selectedEventIds.add(eventid);
                    selectedEventNames.add(event.getString("name"));
                    selectedEvents.add(event);
                }
            }
        }
        if(positionValue == 1) { //already followed
            selectedEventIds.remove(curEvent.getObjectId());
            selectedEventNames.remove(curEvent.getString("name"));
            selectedEvents.remove(curEvent);
            Log.d("cm_app", "remove: " + selectedEventIds.size() + " , " + selectedEventNames.size());

        } else { //new follow
            selectedEventIds.add(curEvent.getObjectId());
            selectedEventNames.add(curEvent.getString("name"));
            selectedEvents.add(curEvent);
            Log.d("cm_app", "add: " + selectedEventIds.size() + " , " + selectedEventNames.size());

        }
        Set<String> setId = new HashSet<String>();
        Set<String> setName = new HashSet<String>();
        setId.addAll(selectedEventIds);
        setName.addAll(selectedEventNames);
        editor.putStringSet("eventids", setId);
        editor.putStringSet("eventnames", setName);
        editor.commit();

        if(ParseUser.getCurrentUser()!=null) {
            ParseUser user = ParseUser.getCurrentUser();
            user.put("events", selectedEvents);
            user.saveInBackground();
        }
        if(context instanceof HomeActivity) {
            ((HomeActivity)context).refreshList();
            ((HomeActivity)context).refreshDrawer();
        } else if(context instanceof AddeventActivity) {
            ((AddeventActivity)context).refreshList();
            ((AddeventActivity)context).refreshDrawer();
        }
    }
}