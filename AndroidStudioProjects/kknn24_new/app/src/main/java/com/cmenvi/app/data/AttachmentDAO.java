package com.cmenvi.app.data;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.ArrayList;
import java.util.List;

public class AttachmentDAO {

	public static final String 	TAG 						= AttachmentDAO.class.getSimpleName();
	public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.abstract";
	public static final String 	DATA						= "data.abstract";
	// Column Name
	public static String		NAME						= "name";
	public static String		CONTENT						= "content";
	public static String		AUTHOR 						= "author";		// ParseObject
	public static String		PDF							= "pdf";		// ParseFile
	public static String		CREATEDAT					= "createdAt";	// Date
	public static String		UPDATEDAT					= "updatedAt";	// Date

	private Context				mContext;
	private ParseObject mUser;
	private List<ParseObject>	mData;

	public AttachmentDAO(Context context) {
		mContext = context;
		mData = new ArrayList<ParseObject>();
		query(null);
	}

	public AttachmentDAO(Context context, ParseObject object) {
		mContext = context;
		mUser = object;
		mData = new ArrayList<ParseObject>();
		query(mUser);
	}
	
	private void query(ParseObject object) {
		ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_ABSTRACT);
		query.orderByDescending("name");
		query.setCachePolicy(ParseQuery.CachePolicy.CACHE_ELSE_NETWORK);
		query.setMaxCacheAge(_PARAMS.MILLISEC_ONEDAY);
		if (object != null) query.whereEqualTo(AUTHOR, object);
		query.include(AUTHOR);
		//query.setLimit(ITEM_LIMIT);		
		query.findInBackground(new FindCallback<ParseObject>() {
		     public void done(List<ParseObject> objects, ParseException e) {
		         if (e == null) {
		             onReceived(objects);
		             
		         } else {
		        	 Log.d(TAG, e.getMessage());
		             onFailed(_ERROR.PARSE_ERROR.ERROR_GET_ABSTRACT);
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
