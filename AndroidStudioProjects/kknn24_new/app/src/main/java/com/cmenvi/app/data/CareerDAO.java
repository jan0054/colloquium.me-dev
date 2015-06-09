package com.cmenvi.app.data;

import java.util.ArrayList;
import java.util.List;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class CareerDAO {

	public static final String 	TAG 						= CareerDAO.class.getSimpleName();
	public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.career";
	public static final String 	DATA						= "data.career";
	// Column Name
	public static String		NAME						= "name";
	public static String		POSITION					= "position";
	public static String		INSTITUTION 				= "institution";
	public static String		NOTE						= "note";
	public static String		SALARY						= "salary";
	public static String		POSTEDBY					= "posted_by";	// (ParseObject - person)
	public static String		CREATEDAT					= "createdAt";	// Date
	public static String		UPDATEDAT					= "updatedAt";	// Date
	
	private Context				mContext;
	//private ParseObject 		mData;
	private List<ParseObject>	mData;
	public CareerDAO(Context context) {
		mContext = context;
		mData = new ArrayList<ParseObject>();
		loadData();
	}
	
	private void loadData() {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_CAREER);
		//query.orderByDescending(NEWS_ORDERBY);
		//query.setLimit(ITEM_LIMIT);
		query.setCachePolicy(ParseQuery.CachePolicy.CACHE_ELSE_NETWORK);
		query.setMaxCacheAge(_PARAMS.MILLISEC_ONEDAY);
        query.orderByDescending(CREATEDAT);
		query.include(POSTEDBY);
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
	
	public List<ParseObject> getData() {
		return mData;
	}
	
	// Send intent as callback for finished tasks
	private void onReceived(List<ParseObject> objects) {		
		if (objects == null) return;
		else {
			Log.d(TAG, "Size: " + objects.size());
			mData = objects;
			Intent intent = new Intent(ACTION_LOAD_DATA);
			intent.putExtra(DATA, mData.get(0).getObjectId());
			mContext.sendBroadcast(intent);			
			
		}	
	}
	
	private void onFailed(_ERROR.PARSE_ERROR error) {
		Log.d(TAG, "Error: " + error.getMessage());
	}
}
