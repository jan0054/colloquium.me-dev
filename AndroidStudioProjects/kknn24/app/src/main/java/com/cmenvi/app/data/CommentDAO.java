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

/**
 * Created by huangyueh-yi on 5/26/15.
 */
public class CommentDAO {
    public static final String 	TAG 						= CommentDAO.class.getSimpleName();
    public static final String 	ACTION_LOAD_DATA		 	= "action.load.data.comment";
    public static final String 	DATA						= "data.comment";
    // Column Name
    public static String        POST                        = "post";       // (parseObject - post)
    public static String		AUTHOR						= "author";     // (parseObject - user)
    public static String		AUTHORNAME					= "author_name";// "name" of author
    public static String		CONTENT 					= "content";
    public static String		DATE						= "date";       // Date
    public static String		CREATEDAT					= "createdAt";	// Date
    public static String		UPDATEDAT					= "updatedAt";	// Date

    private Context mContext;
    private ParseObject mUser;
    private List<ParseObject> mData;

    public ArrayList<String> search_array;

    public CommentDAO(Context context, ArrayList<String> searcharray, int talkday) {
        mContext = context;
        mData = new ArrayList<ParseObject>();
        search_array = searcharray;
        query(null);
    }

    public CommentDAO(Context context, ParseObject object) {
        mContext = context;
        mUser = object;
        mData = new ArrayList<ParseObject>();
        query(mUser);
    }


    private void query(ParseObject object) {
        ParseQuery<ParseObject> query = ParseQuery.getQuery(_PARAMS.TABLE_COMMENT);
        query.orderByAscending(CREATEDAT);
        //query.setLimit(ITEM_LIMIT);
        if (object != null) query.whereEqualTo(POST, object);
        if (search_array != null && search_array.size()>0)
        {
            query.whereContainsAll("words", search_array);
        }
        query.include(AUTHORNAME);
        query.include(CONTENT);
        query.include(CREATEDAT);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    onReceived(objects);

                } else {
                    Log.d(TAG, "Error Data: " + e.getMessage());
                    onFailed(_ERROR.PARSE_ERROR.ERROR_GET_COMMENT);
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
            Log.d(TAG, "commentDAO = 0");
            return;
        }
        else {
            Log.d(TAG, "Comment query results: " + objects.size());
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
