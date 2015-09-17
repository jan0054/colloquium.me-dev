package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import java.util.List;

/**
 * Created by csjan on 9/14/15.
 */
public class AttendeeAdapter extends BaseAdapter {
    private final Context context;
    private final List people;

    public AttendeeAdapter(Context context, List queryresults) {
        this.context = context;
        this.people = queryresults;
    }

    @Override
    public int getCount()
    {
        return people.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        return  people.get(position);
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

            view = inflater.inflate(R.layout.listitem_attendee, vg, false);
        }

        ParseObject person = (ParseObject)people.get(position);

        TextView attendeenameLabel = (TextView)view.findViewById(R.id.attendee_name);
        TextView institutionLabel = (TextView)view.findViewById(R.id.attendee_institution);

        attendeenameLabel.setText(getName(person));
        institutionLabel.setText(getInstitution(person));

        return view;
    }
    private String getInstitution(ParseObject object) {
        return object.getString("institution");
    }

    private String getName(ParseObject object) {
        return object.getString("last_name") + ", " + object.getString("first_name");
    }

}
