package com.squint.app.data;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.TimeZone;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class TalkDAO {

	public static final String 	TAG 						= TalkDAO.class.getSimpleName();
	public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.talk";
	public static final String 	DATA						= "data.talk";
	// Column Name
	public static String		NAME						= "name";
	public static String		DESCRIPTION					= "content";
	public static String		START_TIME					= "start_time";
	// Pointers
	public static String		AUTHOR						= "author";    	// "first_name" of author
	public static String		LOCATION					= "location"; 	// "name" of location
	public static String		ABSTRACT					= "abstract";
	public static String		SESSION						= "session";

	public static String		POSTEDBY					= "posted_by";	// (ParseObject - person)
	public static String		CREATEDAT					= "createdAt";	// Date
	public static String		UPDATEDAT					= "updatedAt";	// Date
	
	private Context				mContext;
	private ParseObject			mUser;
	private List<ParseObject>	mData;
	
	public ArrayList<String> search_array;
    public int talk_day;

	public TalkDAO(Context context, ArrayList<String> searcharray, int talkday) {
		mContext = context;
		mData = new ArrayList<ParseObject>();
        search_array = searcharray;
        talk_day = talkday;
		query(null);
	}
	
	public TalkDAO(Context context, ParseObject object) {
		mContext = context;
		mUser = object;
		mData = new ArrayList<ParseObject>();
		query(mUser);
	}

	
	private void query(ParseObject object) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_TALK);
		query.orderByAscending(START_TIME);
		//query.setLimit(ITEM_LIMIT);
		if (object != null) query.whereEqualTo(AUTHOR, object);
        if (search_array != null && search_array.size()>0)
        {
            query.whereContainsAll("words", search_array);
        }
        if (talk_day != 0)
        {
            Date startdate = getStartTimeForDay(talk_day).getTime();
            Date enddate = getStartTimeForDay(talk_day+1).getTime();
            query.whereGreaterThan("start_time",startdate);
            query.whereLessThan("start_time",enddate);
            Log.d(TAG, "DATE constraint " + talk_day +" | "+ startdate);
        }
		query.include(AUTHOR);
		query.include(LOCATION);
		query.include(SESSION);
		query.include(ABSTRACT);
		query.findInBackground(new FindCallback<ParseObject>() {
		     public void done(List<ParseObject> objects, ParseException e) {
		         if (e == null) {
		             onReceived(objects);
		             
		         } else {
		        	 Log.d(TAG, "Error Data: " + e.getMessage());
		             onFailed(_ERROR.PARSE_ERROR.ERROR_GET_CAREER);
		         }
		     }
		});		
	}
	
	public void refresh() {
		query(mUser);
	}
	
	public List<ParseObject> getData() {
		return mData;
	}
		
	// Send intent as callback for finished tasks
	private void onReceived(List<ParseObject> objects) {		
		if (objects == null){
            Log.d(TAG, "talkDAO = 0");
            return;
        }
		else {
			Log.d(TAG, "Talk query results: " + objects.size());
			mData = objects;
			Intent intent = new Intent(ACTION_LOAD_DATA);
			if (objects.size() > 0) intent.putExtra(DATA, mData.get(0).getObjectId());
			mContext.sendBroadcast(intent);			
		}	
	}
	
	private void onFailed(_ERROR.PARSE_ERROR error) {
		Log.d(TAG, "Error: " + error.getMessage());
	}

    public Calendar getStartTimeForDay(int day_num) {
        Calendar day1 = new GregorianCalendar(2015,01,19,01,01);
        day1.setTimeZone(TimeZone.getTimeZone("GMT"));
        Calendar day2 = new GregorianCalendar(2015,01,20,01,01);
        day2.setTimeZone(TimeZone.getTimeZone("GMT"));
        Calendar day3 = new GregorianCalendar(2015,01,21,01,01);
        day3.setTimeZone(TimeZone.getTimeZone("GMT"));
        Calendar day4 = new GregorianCalendar(2015,01,22,01,01);
        day4.setTimeZone(TimeZone.getTimeZone("GMT"));
        List<Calendar> daylist = new ArrayList<Calendar>();
        daylist.add(day1);
        daylist.add(day2);
        daylist.add(day3);
        daylist.add(day4);
        if (day_num<1)
        {
            return day1;
        }
        else if (day_num>4)
        {
            return  day4;
        }
        else
        {
            return daylist.get(day_num-1);
        }
    }

}
