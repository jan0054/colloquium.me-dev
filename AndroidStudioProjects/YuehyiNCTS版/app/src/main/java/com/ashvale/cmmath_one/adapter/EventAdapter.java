package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.ashvale.cmmath_one.AddeventActivity;
import com.ashvale.cmmath_one.EventWrapperActivity;
import com.ashvale.cmmath_one.HomeActivity;
import com.ashvale.cmmath_one.R;
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
    private final Context context;
    private final List<ParseObject> events;

    /*
    public EventAdapter(Context context, List<ParseObject> queryresults, int[] selectedpositions) {
        this.context = context;
        this.events = queryresults;
        this.selectedPositions = selectedpositions;
        selectedEvents = new ArrayList<ParseObject>();
        Log.d("cm_app", "array :"+this.events.size());
    }
    */

    public EventAdapter(Context context, List<ParseObject> queryresults) {
        this.context = context;
        this.events = queryresults;
        selectedEvents = new ArrayList<>();
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

        //UI elements
        ImageButton followImage = (ImageButton)view.findViewById(R.id.followImage);
        Button followButton = (Button)view.findViewById(R.id.followButton);
        TextView nameLabel = (TextView)view.findViewById(R.id.eventName);
        TextView timeLabel = (TextView)view.findViewById(R.id.eventTime);
        TextView organizerLabel = (TextView)view.findViewById(R.id.eventOrg);
        TextView contentLabel = (TextView)view.findViewById(R.id.eventContent);
        Button detailButton = (Button)view.findViewById(R.id.detailButton);

        //Data
        ParseObject event = events.get(position);
        Date startdate = event.getDate("start_time");
        Date enddate = event.getDate("end_time");
        Format dateformatter = new SimpleDateFormat("MM/dd");
        String startstr = dateformatter.format(startdate);
        String endstr = dateformatter.format(enddate);
        String contentstr = event.getString("content");
        String namestr = event.getString("name");
        String orgstr = event.getString("organizer");

        //Determine follow status
        if (isSelected(event))
        {
            followImage.setImageResource(R.drawable.star_full64);
            followImage.setColorFilter(context.getResources().getColor(R.color.primary_color_icon));
            followButton.setText(R.string.unfollow_event);
            selectedEvents.add(event);
        }
        else
        {
            followImage.setImageResource(R.drawable.star_empty64);
            followImage.setColorFilter(context.getResources().getColor(R.color.unselected_icon));
            followButton.setText(R.string.follow_event);
        }

        //Write data to UI
        nameLabel.setText(namestr);
        organizerLabel.setText(orgstr);
        contentLabel.setText(contentstr);
        timeLabel.setText(startstr + " ~ " + endstr);
        detailButton.setTag(position);
        followButton.setTag(position);
        followImage.setTag(position);

        //Detail button tap
        detailButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                savedEvents = context.getSharedPreferences("EVENTS", 6);
                SharedPreferences.Editor editor = savedEvents.edit();
                int itemPosition = (int) v.getTag();
                ParseObject event = events.get(itemPosition);
                editor.putString("currenteventid", event.getObjectId());
                editor.commit();
                List<ParseObject> children = event.getList("childrenEvent");
                if (children == null || children.size() == 0) { //no childrenEvent
                    context.startActivity(new Intent(context, EventWrapperActivity.class));
                } else {
                    Intent intentHome = new Intent(context, HomeActivity.class);
                    intentHome.putExtra("nestedView", true);
                    intentHome.putExtra("parentName", event.getString("name"));
                    context.startActivity(intentHome);
                }
            }
        });

        //Follow button tap
        followButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clickFollow(v);
            }
        });
        followImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clickFollow(v);
            }
        });

/*        followButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int itemPosition = (int) v.getTag();
                Button followButton = (Button)v;
                View parent = (View)v.getParent();
                ImageView followImage = (ImageView)parent.findViewById(R.id.followImage);
                ParseObject event = (ParseObject)getItem(itemPosition);

                Log.d("cm_app", "Event follow/unfollow tap at position: " + itemPosition + " with id: " + event.getObjectId());

                if(isSelected(event))   //need to unfollow
                {
                    changeFollowStatus(false, event);

                    //UI change
                    followButton.setText(R.string.follow_event);
                    followImage.setImageResource(R.drawable.star_empty64);
                    followImage.setColorFilter(context.getResources().getColor(R.color.unselected_icon));
                }
                else   //need to follow
                {
                    changeFollowStatus(true, event);

                    //UI change
                    followButton.setText(R.string.unfollow_event);
                    followImage.setImageResource(R.drawable.star_full64);
                    followImage.setColorFilter(context.getResources().getColor(R.color.primary_color_icon));
                }
            }
        });
        */

        return view;
    }

    public void clickFollow(View v)
    {
        int itemPosition = (int) v.getTag();
        Button followButton;
        ImageButton followImage;
        if (v instanceof Button) {
            followButton = (Button) v;
            View parent = (View) v.getParent();
            followImage = (ImageButton) parent.findViewById(R.id.followImage);
        } else {
            followImage = (ImageButton) v;
            View parent = (View) v.getParent();
            followButton = (Button) parent.findViewById(R.id.followButton);
        }
        ParseObject event = (ParseObject)getItem(itemPosition);

        Log.d("cm_app", "Event follow/unfollow tap at position: " + itemPosition + " with id: " + event.getObjectId());

        if(isSelected(event))   //need to unfollow
        {
            changeFollowStatus(false, event);

            //UI change
            followButton.setText(R.string.follow_event);
            followImage.setImageResource(R.drawable.star_empty64);
            followImage.setColorFilter(context.getResources().getColor(R.color.unselected_icon));
        }
        else   //need to follow
        {
            changeFollowStatus(true, event);

            //UI change
            followButton.setText(R.string.unfollow_event);
            followImage.setImageResource(R.drawable.star_full64);
            followImage.setColorFilter(context.getResources().getColor(R.color.primary_color_icon));
        }
    }

    public void changeFollowStatus(boolean doFollow, ParseObject selectedEvent)
    {
        String selectedId = selectedEvent.getObjectId();
        String selectedName = selectedEvent.getString("name");

        //Write to shared preferences
        savedEvents = context.getSharedPreferences("EVENTS", 6);
        SharedPreferences.Editor editor = savedEvents.edit();
        Set<String> eventIdSet = new HashSet<String>(savedEvents.getStringSet("eventids", new HashSet<String>()));
        Set<String> eventNameSet = new HashSet<String>(savedEvents.getStringSet("eventnames", new HashSet<String>()));

        if (doFollow)
        {
            eventIdSet.add(selectedId);
            eventNameSet.add(selectedName);
            selectedEvents.add(selectedEvent);
        }
        else
        {
            eventIdSet.remove(selectedId);
            eventNameSet.remove(selectedName);
            selectedEvents.remove(selectedEvent);
        }
        editor.putStringSet("eventids", eventIdSet);
        editor.putStringSet("eventnames", eventNameSet);
        Log.d("cm_app", "id: "+eventIdSet);
        editor.commit();

        //Update drawer and refresh list if needed
        if(context instanceof HomeActivity) {
            ((HomeActivity)context).updateList();
            ((HomeActivity)context).refreshDrawer();
        } else if(context instanceof AddeventActivity) {
            ((AddeventActivity)context).refreshDrawer();
        }

        //Upload to Parse
        if(ParseUser.getCurrentUser()!=null) {
            ParseUser user = ParseUser.getCurrentUser();
            user.put("events", selectedEvents);
            user.saveInBackground();
        }
    }

    public boolean isSelected(ParseObject event)
    {
        savedEvents = context.getSharedPreferences("EVENTS", 6);
        Set<String> eventIdSet = savedEvents.getStringSet("eventids", new HashSet<String>());
        String eventId = event.getObjectId();
        return eventIdSet.contains(eventId);
    }
    
}