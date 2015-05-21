package com.cmmath.app.data;

import java.util.List;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class VenueDAO {

	public static final String 	TAG 						= VenueDAO.class.getSimpleName();
	public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.poi";
	public static final String 	DATA_POI					= "data.poi";
	// Column Name
	public static String		ADDRESS						= "address";
	public static String		DESCRIPTION					= "content";
	public static String		NAME 						= "name";
	public static String		PHONE						= "phone";
	public static String		COORD						= "coord";		// GeoPoint
	public static String		IMAGE						= "image";		// File
	public static String		CREATEDAT					= "createdAt";	// Date
	public static String		UPDATEDAT					= "updatedAt";	// Date
	public static String        ORDER                       = "order";
	public static String        EVENT                       = "event";

	private Context				mContext;
	private List<ParseObject> 	mData;
	
	public VenueDAO(Context context) {
		mContext = context;
		loadData();
	}
	
	private void loadData() {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_POI);
		query.orderByDescending("order");
		//query.setLimit(ITEM_LIMIT);		
		query.findInBackground(new FindCallback<ParseObject>() {
		     public void done(List<ParseObject> objects, ParseException e) {
		         if (e == null) {
		             onReceived(objects);
		             
		         } else {
		        	 Log.d(TAG, e.getMessage());
		             onFailed(_ERROR.PARSE_ERROR.ERROR_GET_POI);
		         }
		     }
		});		
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
			intent.putExtra(DATA_POI, mData.get(0).getObjectId());
			mContext.sendBroadcast(intent);
		}	
	}
	
	private void onFailed(_ERROR.PARSE_ERROR error) {
		Log.d(TAG, "Error: " + error.getMessage());
	}
}
