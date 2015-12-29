package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.cmmath_one.R;

import java.util.List;
import java.util.Set;

/**
 * Created by csjan on 9/7/15.
 */
public class DrawerAdapter extends BaseAdapter {

    private final Context context;
    private final List<String> eventNames;

    public DrawerAdapter(Context context, List<String> eventNames) {
        this.context = context;
        this.eventNames = eventNames;
    }


    @Override
    public int getCount()
    {
        return eventNames.size()+5;
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        int total = eventNames.size()+5;

        String returnobject;

        if (position == 0)
        {
            returnobject = context.getString(R.string.title_eventpicker);
        }
        else if (position == 1)
        {
            returnobject = context.getString(R.string.title_home);
        }
        else if (position == total-1)
        {
            returnobject = context.getString(R.string.title_settings);
        }
        else if (position == total-2)
        {
            returnobject = context.getString(R.string.title_career);
        }
        else if (position == total-3)
        {
            returnobject = context.getString(R.string.title_chat);
        }
        else
        {
            String eventname = eventNames.get(position-2);
            returnobject = eventname;
        }

        return  returnobject;
    }

    @Override
    public int getViewTypeCount()
    {
        return 2;
    }

    @Override
    public int getItemViewType(int position)
    {
        int total = eventNames.size()+5;
        if (position == 0)
        {
            return 0;
        }
        else if (position == 1)
        {
            return 0;
        }
        else if (position == total-1)
        {
            return  0;
        }
        else if (position == total-2)
        {
            return  0;
        }
        else if (position == total-3)
        {
            return  0;
        }
        else
        {
            return  1;
        }
    }

    @Override
    public View getView(int position, View view, ViewGroup vg)
    {
        int type = getItemViewType(position);
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            if (type==0)
            {
                view = inflater.inflate(R.layout.listitem_drawer, vg, false);
            }
            else
            {
                view = inflater.inflate(R.layout.listitem_drawersmall, vg, false);
            }
        }

        ImageView imageLabel = (ImageView)view.findViewById(R.id.drawer_image);
        TextView textLabel = (TextView)view.findViewById(R.id.drawer_text);
        View topDivider = (View)view.findViewById(R.id.drawer_topdivider);
        View bottomDivider = (View)view.findViewById(R.id.drawer_bottomdivider);
        int total = eventNames.size()+5;

        String text;
        int image;
        if (position == 0)
        {
            text = context.getString(R.string.title_eventpicker);
            image = R.drawable.addevent;
        }
        else if (position == 1)
        {
            text = context.getString(R.string.title_home);
            image = R.drawable.eventhome;
            bottomDivider.setBackgroundColor(context.getResources().getColor(R.color.divider_color));
        }
        else if (position == total-1)
        {
            text = context.getString(R.string.title_settings);
            image = R.drawable.setting;
        }
        else if (position == total-2)
        {
            text = context.getString(R.string.title_career);
            image = R.drawable.career;
        }
        else if (position == total-3)
        {
            text = context.getString(R.string.title_chat);
            image = R.drawable.chat;
            topDivider.setBackgroundColor(context.getResources().getColor(R.color.divider_color));
        }
        else
        {
            String eventname = eventNames.get(position-2);
            text = eventname;
            image = R.drawable.event;
        }
        textLabel.setText(text);
        imageLabel.setImageResource(image);

        return view;
    }
}
