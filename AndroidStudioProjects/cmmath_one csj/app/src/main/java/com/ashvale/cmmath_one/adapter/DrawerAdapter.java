package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.content.SharedPreferences;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
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
        String eventpicker = "Edit Events";
        String home = "Home";
        String chat = "Chat";
        String career = "Career";
        String settings = "Settings";

        String returnobject;

        if (position == 0)
        {
            returnobject = eventpicker;
        }
        else if (position == 1)
        {
            returnobject = home;
        }
        else if (position == total-1)
        {
            returnobject = settings;
        }
        else if (position == total-2)
        {
            returnobject = career;
        }
        else if (position == total-3)
        {
            returnobject = chat;
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

        TextView textLabel = (TextView)view.findViewById(R.id.drawertext);
        int total = eventNames.size()+5;
        String eventpicker = "Edit Events";
        String home = "Home";
        String chat = "Chat";
        String career = "Career";
        String settings = "Settings";

        String text;
        if (position == 0)
        {
            text = eventpicker;
        }
        else if (position == 1)
        {
            text = home;
        }
        else if (position == total-1)
        {
            text = settings;
        }
        else if (position == total-2)
        {
            text = career;
        }
        else if (position == total-3)
        {
            text = chat;
        }
        else
        {
            String eventname = eventNames.get(position-2);
            text = eventname;
        }
        textLabel.setText(text);

        return view;
    }
}
