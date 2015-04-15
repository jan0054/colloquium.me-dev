package com.squint.app.data;

import java.util.ArrayList;
import java.util.List;

import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class PeopleDAO {

	public static final String 	TAG 						= PeopleDAO.class.getSimpleName();
	public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.person";
	public static final String 	ACTION_QUERY_DATA		 	= "action.query.data.person";
	public static final String 	DATA						= "data.person";
	
	// Column Name
	public static String		EMAIL		= "email";
	public static String		FIRSTNAME	= "first_name";
	public static String		LASTNAME	= "last_name";
	public static String		INSTITUTION = "institution";
	public static String		LINK		= "link";
	public static String		USEROBJ		= "user";		// ParseObject
	public static String		ISUSER		= "is_user";	// boolean
	public static String		CREATEDAT	= "createdAt";	// Date
	public static String		UPDATEDAT	= "updatedAt";	// Date
	
	private Context				mContext;
	private List<ParseObject> 	mData;
	private ParseObject			mObject = null;

    public ArrayList<String> search_array;
	
	public PeopleDAO(Context context, ArrayList<String> searcharray) {
		mContext = context;
		mData = new ArrayList<ParseObject>();
        search_array = searcharray;
		loadData();
	}
	
	public PeopleDAO(Context context, String objectId) {
		mContext = context;
		query(objectId);
	}
	
	private void query(String objectId) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_PERSON);
		query.getInBackground(objectId, new GetCallback<ParseObject>() {
		  public void done(ParseObject object, ParseException e) {
		    if (e == null) {
		    	onReceived(object);
		    } else {
		    	Log.d(TAG, e.getMessage());
	            onFailed(_ERROR.PARSE_ERROR.ERROR_GET_PERSON);
		    }
		  }
		});
	}
	
	public void refresh(String objectId) {
		query(objectId);
	}
	
	private void loadData() {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_PERSON);
        query.orderByAscending("last_name");
        query.whereNotEqualTo("debug", 1);
		query.setLimit(500);
        if (search_array != null && search_array.size()>0)
        {
            query.whereContainsAll("words", search_array);
        }
		//query.whereNear(key, point);
		//query.whereContains(key, substring);
		//String[] names = {"userid"};
		//query.whereContainedIn("playerName", Arrays.asList(names));
		query.findInBackground(new FindCallback<ParseObject>() {
		     public void done(List<ParseObject> objects, ParseException e) {
		         if (e == null) {
		             onReceived(objects);
		             
		         } else {
		        	 Log.d(TAG, e.getMessage());
		             onFailed(_ERROR.PARSE_ERROR.ERROR_GET_PERSON);
		         }
		     }
		});		
	}
	

	public List<ParseObject> getData() {
		return mData;
	}
	
	public ParseObject getPersonData() {
		return mObject;
	}
	
	// Send intent as callback for finished tasks
	private void onReceived(List<ParseObject> objects) {		
		if (objects == null) {
			onFailed(_ERROR.PARSE_ERROR.ERROR_GET_PERSON);
			return;
		} else {
			mData = objects;
			Log.d(TAG, "Person: " + objects.size());
			Intent intent = new Intent(ACTION_LOAD_DATA);
            if (objects.size() > 0)
            {
                intent.putExtra(DATA, mData.get(0).getObjectId());
            }
			mContext.sendBroadcast(intent);
		}	
	}
	
	private void onReceived(ParseObject object) {		
		if (object == null) {
			onFailed(_ERROR.PARSE_ERROR.ERROR_GET_PERSON);
			return;
		} else {
			mObject = object;
			Intent intent = new Intent(ACTION_QUERY_DATA);
			intent.putExtra(DATA, mObject.getObjectId());
			mContext.sendBroadcast(intent);
		}	
	}
	
	private void onFailed(_ERROR.PARSE_ERROR error) {
		Log.d(TAG, "Error: " + error.getMessage());
	}
	
}
