package com.ashvale.cmmath_one;

import android.content.Intent;
import android.content.SharedPreferences;
import android.media.Image;
import android.os.Bundle;
import android.provider.CalendarContract;
import android.support.v7.app.AppCompatActivity;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;

public class TalkDetailActivity extends AppCompatActivity{
    public static final String TAG = TalkDetailActivity.class.getSimpleName();

    private SimpleDateFormat sdf;
    public String talkID;
    public String content;
    public ParseObject talkObject;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_talk_detail);

        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));

        talkID = this.getIntent().getExtras().getString("talkID");
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Talk");
        query.orderByDescending("createdAt");
        query.include("session");
        query.include("author");
        query.include("location");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.getInBackground(talkID, new GetCallback<ParseObject>() {
            @Override
            public void done(final ParseObject obj, ParseException e) {
                if (e == null) {
                    talkObject = obj;
                    TextView sessionLabel = (TextView) findViewById(R.id.talk_session);
                    TextView nameLabel = (TextView) findViewById(R.id.talk_name);
                    TextView authornameLabel = (TextView) findViewById(R.id.talk_authorname);
                    TextView locationLabel = (TextView) findViewById(R.id.talk_location);
                    TextView timeLabel = (TextView) findViewById(R.id.talk_time);
                    TextView contentLabel = (TextView) findViewById(R.id.talk_content);
                    Button discussBtn = (Button) findViewById(R.id.talk_discussionbtn);
                    Button calendarBtn = (Button) findViewById(R.id.talk_calendarbtn);
                    ImageButton fullscreenBtn = (ImageButton) findViewById(R.id.talk_fullscreen);

                    //contentLabel.setMovementMethod(new ScrollingMovementMethod());
                    fullscreenBtn.setOnClickListener(new TextView.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            toFullScreenReader();
                        }
                    });

                    sessionLabel.setText(talkObject.getParseObject("session").getString("name"));
                    nameLabel.setText(talkObject.getString("name"));
                    authornameLabel.setText(getAuthor(talkObject));
                    locationLabel.setText(talkObject.getParseObject("location").getString("name"));
                    timeLabel.setText(getTime(talkObject));
                    contentLabel.setText(getContent(talkObject));

                    authornameLabel.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            toAuthor();
                        }
                    });
                    discussBtn.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            toDiscuss();
                        }
                    });
                    calendarBtn.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            toCalendar();
                        }
                    });

                } else {
                    Log.d("cm_app", "postdetail query error: " + e);
                }
            }
        });

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
        if (item.getItemId() == android.R.id.home) {
                onBackPressed();
                return true;
        } else {
            Intent intent = new Intent(this, EventWrapperActivity.class);
            intent.putExtra("itemID", item.getItemId());
            startActivity(intent);
            return super.onOptionsItemSelected(item);
        }
    }

    private String getAuthor(ParseObject object) {
        ParseObject author = object.getParseObject("author");
        return (author == null) ? this.getString(R.string.unknown) : author.getString("last_name") + ", " + author.getString("first_name");
    }

    private String getTime(ParseObject object) {
        String start_time = sdf.format(object.getDate("start_time"));
        String end_time = sdf.format(object.getDate("end_time"));
        return start_time+" ~ "+end_time;
    }

    private String getContent(ParseObject object) {
        return object.getString("content");
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public void toFullScreenReader() {
        Intent intent = new Intent(this, FullscreenReaderActivity.class);
        intent.putExtra("content", getContent(talkObject));
        startActivity(intent);
    }

    public void toAuthor() {
        Intent intent = new Intent(this, PeopleDetailActivity.class);
        intent.putExtra("personID", talkObject.getParseObject("author").getObjectId());
        startActivity(intent);
    }

    public void toDiscuss() {
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
        Log.d(TAG, "DISCUSS: " + talkObject.getObjectId());
        Intent discussionIntent = new Intent(this, DiscussionActivity.class);
        discussionIntent.putExtra("event_objid",  talkObject.getObjectId());
        discussionIntent.putExtra("event_type",  0);
        startActivity(discussionIntent);
    }

    public void toCalendar() {
        Calendar beginTime = Calendar.getInstance();
        beginTime.setTime(talkObject.getDate("start_time"));
        Calendar endTime = Calendar.getInstance();
        endTime.setTime(talkObject.getDate("end_time"));
        Intent intent = new Intent(Intent.ACTION_INSERT)
                .setData(CalendarContract.Events.CONTENT_URI)
                .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, beginTime.getTimeInMillis())
                .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endTime.getTimeInMillis())
                .putExtra(CalendarContract.Events.TITLE, talkObject.getString("name"))
                .putExtra(CalendarContract.Events.DESCRIPTION, talkObject.getString("name"))
                .putExtra(CalendarContract.Events.EVENT_LOCATION, talkObject.getParseObject("location").getString("name"))
                .putExtra(CalendarContract.Events.AVAILABILITY, CalendarContract.Events.AVAILABILITY_BUSY);
        //.putExtra(Intent.EXTRA_EMAIL, "rowan@example.com,trevor@example.com");
        startActivity(intent);
    }

    public <T> void toPage(Intent intent, Class<T> cls) {
        intent.setClass(this, cls); //PeopleDetailsActivity.class);
        startActivity(intent);
    }

}
