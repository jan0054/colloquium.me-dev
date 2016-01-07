package com.ashvale.cmmath_one;

import android.app.FragmentManager;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.cmmath_one.adapter.CommentAdapter;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseImageView;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

public class PostDetailActivity extends DetailActivity {
    public static final String TAG = PostDetailActivity.class.getSimpleName();

    private SimpleDateFormat sdf;
    public String postID;
    public String content;
    public ParseObject postObject;
    TextView emptyText;
    ListView commentList;
    SwipeRefreshLayout swipeRefresh;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_detail);
        super.onCreateView();

        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getDefault());

        postID = this.getIntent().getExtras().getString("postID");
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Post");
        query.orderByDescending("createdAt");
        query.include("author");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.getInBackground(postID, new GetCallback<ParseObject>() {
            @Override
            public void done(final ParseObject obj, ParseException e) {
                if (e == null) {
                    postObject = obj;
                    TextView authornameLabel = (TextView) findViewById(R.id.post_authorname);
                    TextView createdAtLabel = (TextView) findViewById(R.id.post_createdAt);
                    TextView contentLabel = (TextView) findViewById(R.id.post_content);
                    ParseImageView imageLabel = (ParseImageView) findViewById(R.id.post_image);

                    ParseFile image = postObject.getParseFile("image");
                    imageLabel.setParseFile(image);
                    imageLabel.loadInBackground();
                    authornameLabel.setText(getAuthor(postObject));
                    createdAtLabel.setText(getCreatedAt(postObject));
                    contentLabel.setText(getContent(postObject));
                } else {
                    Log.d("cm_app", "postdetail query error: " + e);
                }
            }
        });

        emptyText = (TextView) findViewById(R.id.commentempty);
        commentList = (ListView) findViewById(R.id.commentListView);
        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Post");
        innerQuery.whereEqualTo("objectId", postID);

        ParseQuery<ParseObject> queryComment = ParseQuery.getQuery("Comment");
        queryComment.orderByDescending("createdAt");
        queryComment.whereMatchesQuery("post", innerQuery);
        queryComment.include("author");
        queryComment.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        queryComment.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "comment query number: " + objects.size());
                    setAdapter(objects);
                    swipeRefresh.setRefreshing(false);
                } else {
                    Log.d("cm_app", "comment query error: " + e);
                }
            }
        });

        swipeRefresh = (SwipeRefreshLayout) findViewById(R.id.pulltorefresh);
        swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                loadPost();
            }
        });

    }

    public void setAdapter(final List results)
    {
        Log.d("cm_app", "start Adapter");
        CommentAdapter adapter = new CommentAdapter(this, results);
        commentList.setAdapter(adapter);
        getListHeight(commentList);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        //inflater.inflate(R.menu.menu_event_wrapper, menu);
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        Log.d("cm_app", "itemID = "+item.getItemId());
        if(item.getItemId()== android.R.id.home) {
                onBackPressed();
                return true;
        } else {
            Intent intent = new Intent(this, EventWrapperActivity.class);
            intent.putExtra("itemID", item.getItemId());
            Log.d("cm_app", "itemID 2 = " + item.getItemId());
            startActivity(intent);
            return super.onOptionsItemSelected(item);
        }
    }

    public void getListHeight(ListView listView)
    {
        int totalHeight = 0;
        View view = null;
        for (int i =0; i < listView.getAdapter().getCount(); i++) {
            int desiredWidth = View.MeasureSpec.makeMeasureSpec(listView.getWidth(), View.MeasureSpec.AT_MOST);
            view = listView.getAdapter().getView(i, view, listView);
            if(i == 0)
                view.setLayoutParams(new ViewGroup.LayoutParams(desiredWidth, ViewGroup.LayoutParams.MATCH_PARENT));
            view.measure(desiredWidth, View.MeasureSpec.UNSPECIFIED);
            totalHeight += view.getMeasuredHeight();
        }
        Log.d(TAG, "getcount "+listView.getAdapter().getCount());
        Log.d(TAG, "totalHeight "+totalHeight);
        listView.getLayoutParams().height = totalHeight + (listView.getDividerHeight() * listView.getAdapter().getCount()) + (int)getResources().getDimension(R.dimen.listitem_bottom);
        listView.setLayoutParams(listView.getLayoutParams());
        listView.requestLayout();
    }

    private String getAuthor(ParseObject object) {
        ParseObject author = object.getParseObject("author");
        return (author == null) ? this.getString(R.string.unknown) : author.getString("last_name") + ", " + author.getString("first_name");
    }

    private String getCreatedAt(ParseObject object) {
        return sdf.format(object.getCreatedAt());
    }

    private String getContent(ParseObject object) {
        return object.getString("content");
    }

    public void sendComment(View view) {
        Log.i(TAG, "send comment button pressed");
        ParseUser selfuser = ParseUser.getCurrentUser();
        if (selfuser == null) {
            toast(getString(R.string.error_not_login));
            SharedPreferences userStatus;
            userStatus = this.getSharedPreferences("LOGIN", 0); //6 = readable+writable by other apps, use 0 for private
            SharedPreferences.Editor editor = userStatus.edit();
            editor.putInt("skiplogin", 0);
            editor.commit();
            Intent intent = new Intent(this, LoginActivity.class);
            startActivity(intent);
            return;
        }
        //setup all the data for the new comment object
        EditText editText = (EditText) findViewById(R.id.commentinput);
        final String message = editText.getText().toString();
        Log.i(TAG, message);
        ParseUser currentUser = ParseUser.getCurrentUser();
        //get the other guy

        if(message.length()<1) {
            toast("Empty imput.");
            return;
        }
        //create and save the chat object
        ParseObject commentmsg = new ParseObject("Comment");
        commentmsg.put("content", message);
        commentmsg.put("post", postObject);
        commentmsg.put("author", currentUser);
        ParseACL commentACL = new ParseACL(ParseUser.getCurrentUser());
        commentACL.setPublicReadAccess(true);
        commentACL.setPublicWriteAccess(true);
        commentmsg.setACL(commentACL);
        commentmsg.saveInBackground(new SaveCallback() {
            public void done(ParseException e) {
                if (e == null) {
                    //saved complete
                    EditText edt = (EditText) findViewById(R.id.commentinput);
                    edt.setText("");
                    Log.i(TAG, "new comment save success");
                    loadPost();
                } else {
                    Log.i(TAG, "sendComment save fail");
                    //did not save successfully
                }
            }
        });
    }

    public void loadPost()
    {
        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getDefault());

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Post");
        query.orderByDescending("createdAt");
        query.include("author");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.getInBackground(postID, new GetCallback<ParseObject>() {
            @Override
            public void done(final ParseObject obj, ParseException e) {
                if (e == null) {
                    postObject = obj;
                    TextView authornameLabel = (TextView) findViewById(R.id.post_authorname);
                    TextView createdAtLabel = (TextView) findViewById(R.id.post_createdAt);
                    TextView contentLabel = (TextView) findViewById(R.id.post_content);
                    ParseImageView imageLabel = (ParseImageView) findViewById(R.id.post_image);

                    ParseFile image = postObject.getParseFile("image");
                    imageLabel.setParseFile(image);
                    imageLabel.loadInBackground();
                    authornameLabel.setText(getAuthor(postObject));
                    createdAtLabel.setText(getCreatedAt(postObject));
                    contentLabel.setText(getContent(postObject));
                } else {
                    Log.d("cm_app", "postdetail query error: " + e);
                }
            }
        });

        emptyText = (TextView) findViewById(R.id.commentempty);
        commentList = (ListView) findViewById(R.id.commentListView);
        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Post");
        innerQuery.whereEqualTo("objectId", postID);

        ParseQuery<ParseObject> queryComment = ParseQuery.getQuery("Comment");
        queryComment.orderByDescending("createdAt");
        queryComment.whereMatchesQuery("post", innerQuery);
        queryComment.include("author");
        queryComment.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        queryComment.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "comment query number: "+objects.size());
                    setAdapter(objects);
                    swipeRefresh.setRefreshing(false);
                } else {
                    Log.d("cm_app", "comment query error: " + e);
                }
            }
        });
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public <T> void toPage(Intent intent, Class<T> cls) {
        intent.setClass(this, cls); //PeopleDetailsActivity.class);
        startActivity(intent);
    }

}
