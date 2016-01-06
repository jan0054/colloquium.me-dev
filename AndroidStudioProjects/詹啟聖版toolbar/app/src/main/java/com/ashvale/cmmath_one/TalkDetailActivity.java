package com.ashvale.cmmath_one;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.SharedPreferences;
import android.media.Image;
import android.net.Uri;
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
import com.parse.GetDataCallback;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;

public class TalkDetailActivity extends DetailActivity {
    public static final String TAG = TalkDetailActivity.class.getSimpleName();

    private SimpleDateFormat sdf;
    public String talkID;
    public String content;
    public ParseObject talkObject;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_talk_detail);
        super.onCreateView();

        sdf = new SimpleDateFormat("MM/dd hh:mm a", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getDefault());

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
                    Button pdfBtn = (Button) findViewById(R.id.talk_pdfbtn);
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
                    if (talkObject.getParseFile("pdf") != null)
                    {
                        pdfBtn.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                toPdfReader();
                            }
                        });
                    }
                    else
                    {
                        pdfBtn.setEnabled(false);
                    }


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

    public void toPdfReader() {
        if (talkObject.getParseFile("pdf") != null)
        {
            //check to see if pdf already exist
            final ParseFile pdfParseFile = talkObject.getParseFile("pdf");
            String name = pdfParseFile.getName();
            File dir = new File("/sdcard/ColloquiumMe/");
            File outputFile = new File(dir, name);
            if (outputFile.exists())
            {
                openPDF(name);
            }
            else
            {
                toast(getResources().getString(R.string.alert_download_pdf));
                pdfParseFile.getDataInBackground(new GetDataCallback() {
                    public void done(byte[] data, ParseException e) {
                        if (e == null) {
                            Log.d("cm_app", "pdf file retrieval done");
                            savePDF(data, pdfParseFile.getName());
                        } else {
                            Log.d("cm_app", "pdf file retrieval error: " + e);
                        }
                    }
                });
            }
        }
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

    public void savePDF(byte[] data, String name)
    {
        //create the file first
        //File dir = Environment.getExternalStorageDirectory();  //this is a better way i think...
        File dir = new File("/sdcard/ColloquiumMe/");
        dir.mkdirs();
        String filename = name;
        File outputFile = new File(dir, filename);
        FileOutputStream fos;
        try {
            fos = new FileOutputStream(outputFile);
            fos.close();
        }catch (Exception e) {
            System.out.println(e);
            Log.d("cm_app", "pdf file creation error: " + e);
        }

        //write pdf data
        String filePath = "/sdcard/ColloquiumMe/"+name;
        try {
            OutputStream ops = new FileOutputStream(filePath);
            ops.write(data);
            ops.close();
        }catch (Exception e) {
            System.out.println(e);
            Log.d("cm_app", "pdf file write error: " + e);
        }

        //open the pdf
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(Uri.fromFile(outputFile), "application/pdf");
        intent.setFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
        Intent intentOpenWith = Intent.createChooser(intent, "Open With");
        try {
            startActivity(intentOpenWith);
        } catch (ActivityNotFoundException e) {
            Log.d("cm_app", "pdf file open error: " + e);
            toast(getResources().getString(R.string.alert_no_pdf));
        }
    }

    public void openPDF(String name)
    {
        File dir = new File("/sdcard/ColloquiumMe/");
        String filename = name;
        File outputFile = new File(dir, filename);
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setDataAndType(Uri.fromFile(outputFile), "application/pdf");
        intent.setFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
        Intent intentOpenWith = Intent.createChooser(intent, "Open With");
        try {
            startActivity(intentOpenWith);
        } catch (ActivityNotFoundException e) {
            Log.d("cm_app", "pdf file open error: " + e);
            toast(getResources().getString(R.string.alert_no_pdf));
        }
    }

}
