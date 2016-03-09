package com.ashvale.cmmath_one.adapter;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import org.w3c.dom.Text;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

/**
 * Created by csjan on 9/14/15.
 */
public class ProgramAdapter extends BaseAdapter {
    private final Context context;
    //private final List talks;
    private final Map<Integer, List<ParseObject>> sectionDayMap;
    private final Map<ParseObject, Integer> originalProgramDayMap;
    private final List<Integer> uniqueDays;
    private SimpleDateFormat sdf;


    public ProgramAdapter(Context context, Map map, Map rawMap, List<Integer> uniqueDays) {
        this.context = context;
        //this.talks = queryresults;
        this.sectionDayMap = map;
        this.originalProgramDayMap = rawMap;
        this.uniqueDays = uniqueDays;
    }

    @Override
    public int getCount()
    {
        return originalProgramDayMap.size()+uniqueDays.size();
    }

    @Override
    public long getItemId(int position)
    {
        return position;
    }

    @Override
    public Object getItem(int position)
    {
        ParseObject returnProgram = new ParseObject("Talk");
        int currentPosition = position;
        for (Integer day : uniqueDays)
        {
            int dayProgramCount = sectionDayMap.get(day).size();
            if (currentPosition > dayProgramCount)  //look in the next day
            {
                currentPosition = currentPosition - dayProgramCount - 1;
            }
            else   //the talk we want to return is on this day
            {
                if (currentPosition == 0)   //header
                {
                    List<ParseObject> programsOnThisDay = sectionDayMap.get(day);
                    ParseObject program = programsOnThisDay.get(0);
                    returnProgram = program;
                }
                else   //non-header object
                {
                    List<ParseObject> programsOnThisDay = sectionDayMap.get(day);
                    ParseObject program = programsOnThisDay.get(currentPosition-1);
                    returnProgram = program;
                }
            }
        }
        return returnProgram;
    }

    @Override
    public int getViewTypeCount() {
        return 2;
    }

    @Override
    public int getItemViewType(int position) {
        List<Integer> headers = setSectionHeaderPositions();
        if (headers.contains(position))
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
        int type = getItemViewType(position);
        if (view == null)
        {
            LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            if (type == 0)   //header
            {
                view = inflater.inflate(R.layout.listitem_program_header, vg, false);
            }
            else   //ordinary talk
            {
                view = inflater.inflate(R.layout.listitem_program, vg, false);
            }
        }

        ParseObject talk = (ParseObject)getItem(position);

        if (type==0)
        {
            TextView headerLabel = (TextView)view.findViewById(R.id.date_label);
            sdf = new SimpleDateFormat("MM/dd/YYYY", Locale.getDefault());
            sdf.setTimeZone(TimeZone.getDefault());
            headerLabel.setText(getStartTime(talk));
        }
        else
        {
            TextView nameLabel = (TextView)view.findViewById(R.id.program_name);
            TextView authornameLabel = (TextView)view.findViewById(R.id.program_authorname);
            TextView contentLabel = (TextView)view.findViewById(R.id.program_content);
            TextView locationLabel = (TextView)view.findViewById(R.id.program_locationname);
            TextView starttimeLabel = (TextView)view.findViewById(R.id.program_starttime);

            sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
            //sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
            sdf.setTimeZone(TimeZone.getDefault());
            nameLabel.setText(talk.getString("name"));
            authornameLabel.setText(getAuthor(talk));
            contentLabel.setText(talk.getString("content"));
            locationLabel.setText(getLocationName(talk));
            starttimeLabel.setText(getStartTime(talk));
        }

        return view;
    }

    private String getAuthor(ParseObject object) {
        ParseObject author = object.getParseObject("author");
        return (author == null) ? context.getString(R.string.unknown) : author.getString("last_name") + ", " + author.getString("first_name");
    }

    private String getLocationName(ParseObject object) {
        ParseObject location = object.getParseObject("location");
        return (location == null) ? "location TBD" : location.getString("name");
    }

    private String getStartTime(ParseObject object) {
        return sdf.format(object.getDate("start_time"));
    }

    private List<Integer> setSectionHeaderPositions()
    {
        List<Integer> headerPositions = new ArrayList<>();
        headerPositions.add(0);
        int totalRows = 1;
        for (Integer day : uniqueDays)
        {
            int dayProgramCount = sectionDayMap.get(day).size();
            totalRows = totalRows+dayProgramCount;
            Integer nextHeader = totalRows;
            headerPositions.add(nextHeader);
        }
        return  headerPositions;
    }

}
