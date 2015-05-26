package com.cmenvi.app.data;

import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.TimeZone;

/**
 * Created by huangyueh-yi on 5/26/15.
 */
public class PostDAO {
    public static final String 	TAG 						= PostDAO.class.getSimpleName();
    public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.post";
    public static final String 	DATA						= "data.post";
    // Column Name
    public static String		NAME						= "name";
    public static String        ATTACHMENT                  = "attachment"; // (parseObject - attachment)
    public static String		AUTHOR						= "author";     // (parseObject - user)
    public static String		AUTHORNAME					= "author_name";// "name" of author
    public static String		COMMENTS					= "comments"; 	// (parseObject - comment)
    public static String		CONTENT 					= "content";
    public static String		DATE						= "date";       // Date
    public static String		IMAGE   					= "image";      // (ParseObject - person)
    public static String		CREATEDAT					= "createdAt";	// Date
    public static String		UPDATEDAT					= "updatedAt";	// Date

    private Context mContext;
    private ParseObject mUser;
    private List<ParseObject> mData;

    public ArrayList<String> search_array;

    public PostDAO(Context context, ArrayList<String> searcharray) {
        mContext = context;
        mData = new ArrayList<ParseObject>();
        search_array = searcharray;
        query(null);
    }

    public PostDAO(Context context, ParseObject object) {
        mContext = context;
        mUser = object;
        mData = new ArrayList<ParseObject>();
        query(mUser);
    }


    private void query(ParseObject object) {
        ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_POST);
        query.orderByAscending(NAME);
        //query.setLimit(ITEM_LIMIT);
        if (object != null) query.whereEqualTo(NAME, object);
        if (search_array != null && search_array.size()>0)
        {
            query.whereContainsAll("words", search_array);
        }
        query.include(NAME);
        query.include(AUTHORNAME);
        query.include(CONTENT);
        query.include(IMAGE);
        query.include(CREATEDAT);
        query.include(COMMENTS);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    onReceived(objects);

                } else {
                    Log.d(TAG, "Error Data: " + e.getMessage());
                    onFailed(_ERROR.PARSE_ERROR.ERROR_GET_POST);
                }
            }
        });
    }

    private void loadData() {
        ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_POST);
        query.orderByAscending(CREATEDAT);
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
                    onFailed(_ERROR.PARSE_ERROR.ERROR_GET_POST);
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
            Log.d(TAG, "postDAO = 0");
            return;
        }
        else {
            Log.d(TAG, "Post query results: " + objects.size());
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
