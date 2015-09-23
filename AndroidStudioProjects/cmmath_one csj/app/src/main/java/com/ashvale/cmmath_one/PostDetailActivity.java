package com.ashvale.cmmath_one;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ListView;
import android.widget.TextView;

import com.ashvale.cmmath_one.adapter.CommentAdapter;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseImageView;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

public class PostDetailActivity extends AppCompatActivity {

    private SimpleDateFormat sdf;
    public String postID;
    public String content;
    public ParseObject postObject;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_post_detail);

        sdf = new SimpleDateFormat("MM-dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));

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
                    createdAtLabel.setTag(getCreatedAt(postObject));
                    contentLabel.setText(getContent(postObject));
                } else {
                    Log.d("cm_app", "postdetail query error: " + e);
                }
            }
        });

        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Post");
        innerQuery.whereEqualTo("objectId", postID);

        ParseQuery<ParseObject> queryComment = ParseQuery.getQuery("Comment");
        queryComment.orderByDescending("createdAt");
        queryComment.whereEqualTo("post", innerQuery);
        queryComment.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        queryComment.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "comment query error: " + e);
                }
            }
        });
    }

    public void setAdapter(final List results)
    {
        CommentAdapter adapter = new CommentAdapter(this, results);
        ListView postList = (ListView)this.findViewById(R.id.commentListView);
        postList.setAdapter(adapter);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_post_detail, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
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
}
