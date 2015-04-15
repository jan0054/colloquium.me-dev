package com.squint.app.data;

import java.util.ArrayList;
import java.util.List;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class PosterDAO {

	public static final String 	TAG 						= PosterDAO.class.getSimpleName();
	public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.poster";
	public static final String 	DATA						= "data.poster";
	// Column Name
	public static String		NAME						= "name";
	public static String		DESCRIPTION					= "description";
	public static String		AUTHOR 						= "author";		// ParseObject
	public static String		LOCATION					= "location";	// ParseObject
	public static String		ABSTRACT					= "abstract";	// ParseObject
	public static String		CREATEDAT					= "createdAt";	// Date
	public static String		UPDATEDAT					= "updatedAt";	// Date
	
	private Context				mContext;
	private ParseObject			mUser;
	private List<ParseObject>	mData;

    public ArrayList<String> search_array;

	public PosterDAO(Context context, ArrayList<String> searcharray) {
		mContext = context;
		mData = new ArrayList<ParseObject>();
        search_array = searcharray;
		query(null);
	}
	
	public PosterDAO(Context context, ParseObject object) {
		mContext = context;
		mUser = object;
		mData = new ArrayList<ParseObject>();
		query(mUser);
	}
	
	private void query(ParseObject object) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_POSTER);
		query.orderByAscending("name");
		query.setLimit(500);
		if (object != null) query.whereEqualTo(AUTHOR, object);
        if (search_array != null && search_array.size()>0)
        {
            query.whereContainsAll("words", search_array);
        }
		query.include(AUTHOR);
		query.include(LOCATION);
		query.include(ABSTRACT);
		query.findInBackground(new FindCallback<ParseObject>() {
		     public void done(List<ParseObject> objects, ParseException e) {
		         if (e == null) {
		             onReceived(objects);		             
		         } else {
		        	 Log.d(TAG, e.getMessage());
		             onFailed(_ERROR.PARSE_ERROR.ERROR_GET_POSTER);
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
		if (objects == null) return;
		else {
			mData = objects;
			Intent intent = new Intent(ACTION_LOAD_DATA);
			if (objects.size() > 0) intent.putExtra(DATA, mData.get(0).getObjectId());
			mContext.sendBroadcast(intent);
		}	
	}
	
	private void onFailed(_ERROR.PARSE_ERROR error) {
		Log.d(TAG, "Error: " + error.getMessage());
	}
}
