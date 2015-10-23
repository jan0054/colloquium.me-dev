package com.ashvale.cmmath_one;

import android.content.ComponentName;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.LabeledIntent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.webkit.URLUtil;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.cmmath_one.adapter.PersonalTalkAdapter;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;

public class PeopleDetailActivity extends AppCompatActivity {
    public static final String TAG = PeopleDetailActivity.class.getSimpleName();

    public String personID;
    public String content;
    public ParseObject personObject;
    public  List<ParseObject> talkObjList;
    private String emailStr;
    private String linkStr;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_people_detail);

        personID = this.getIntent().getExtras().getString("personID");
        Log.d("cm_app", "personID = " + personID);
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Person");
        query.orderByDescending("createdAt");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.getInBackground(personID, new GetCallback<ParseObject>() {
            @Override
            public void done(final ParseObject obj, ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "person query ok");
                    personObject = obj;
                    TextView nameLabel = (TextView) findViewById(R.id.person_name);
                    TextView institutionLabel = (TextView) findViewById(R.id.person_institution);
                    Button emailBtn = (Button) findViewById(R.id.person_email);
                    Button linkBtn = (Button) findViewById(R.id.person_link);
                    Button messageBtn = (Button) findViewById(R.id.person_message);

                    nameLabel.setText(personObject.getString("last_name") + ", " + personObject.getString("first_name"));
                    institutionLabel.setText(personObject.getString("institution"));
                    int email_status = personObject.getInt("email_status");
                    int chat_status = personObject.getInt("chat_status");
                    emailStr = personObject.getString("email");
                    linkStr = personObject.getString("link");

                    if(email_status == 1 && emailStr != null) {
                        emailBtn.setEnabled(true);
                        emailBtn.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                try {
                                    sendEmail("", "", new String[] {emailStr}, null);
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            }
                        });
                    } else {
                        emailBtn.setEnabled(false);
                    }

                    if(linkStr != null) {
                        linkBtn.setEnabled(true);
                        linkBtn.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                getSite(linkStr);
                            }
                        });
                    } else {
                        linkBtn.setEnabled(false);
                    }

                    if(chat_status == 1) {
                        messageBtn.setEnabled(true);
                        messageBtn.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                processConversation(personObject.getParseUser("user"));
                            }
                        });
                    } else {
                        messageBtn.setEnabled(false);
                    }
                } else {
                    Log.d("cm_app", "postdetail query error: " + e);
                }
            }
        });

        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Person");
        innerQuery.whereEqualTo("objectId", personID);

        ParseQuery<ParseObject> queryComment = ParseQuery.getQuery("Talk");
        queryComment.orderByDescending("createdAt");
        queryComment.whereMatchesQuery("author", innerQuery);
        queryComment.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        queryComment.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "talk of person result number: "+objects.size());
                    talkObjList = objects;
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "talk of person query error: " + e);
                }
            }
        });
    }

    public void setAdapter(final List results)
    {
        PersonalTalkAdapter adapter = new PersonalTalkAdapter(this, results);
        ListView talkList = (ListView)this.findViewById(R.id.talkListView);
        talkList.setAdapter(adapter);

        talkList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //Toast.makeText(HomeActivity.this, "home event item selected " + position, Toast.LENGTH_SHORT).show();
                ParseObject talk = talkObjList.get(position);
                Intent intent = new Intent(PeopleDetailActivity.this, TalkDetailActivity.class);
                intent.putExtra("talkID", talk.getObjectId());
                startActivity(intent);
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

    private void sendEmail(String title, String content, String[] emails, Uri imageUri) throws IOException {

        Intent emailIntent = new Intent();
        emailIntent.setAction(Intent.ACTION_SEND);
        emailIntent.setType("application/image");
        if (imageUri != null) {
            emailIntent.putExtra(Intent.EXTRA_STREAM, imageUri);
        }

        Intent openInChooser = Intent.createChooser(emailIntent, "Share");

        // Extract all package labels
        PackageManager pm = getPackageManager();

        Intent sendIntent = new Intent(Intent.ACTION_SEND);
        sendIntent.setType("text/plain");

        List<ResolveInfo> resInfo = pm.queryIntentActivities(sendIntent, 0);
        List<LabeledIntent> intentList = new ArrayList<LabeledIntent>();

        for (int i = 0; i < resInfo.size(); i++) {
            ResolveInfo ri = resInfo.get(i);
            String packageName = ri.activityInfo.packageName;
            Log.d(TAG, "package: " + packageName);
            // Append and repackage the packages we want into a LabeledIntent
            if(packageName.contains("android.email")) {
                emailIntent.setPackage(packageName);
            } else if (packageName.contains("android.gm")) 	{
                Intent intent = new Intent();
                intent.setComponent(new ComponentName(packageName, ri.activityInfo.name));
                intent.setAction(Intent.ACTION_SEND);
                intent.setType("text/plain");
                intent.putExtra(Intent.EXTRA_EMAIL,  emails);
                intent.putExtra(Intent.EXTRA_SUBJECT, title);
                intent.putExtra(Intent.EXTRA_TEXT, content);
                if (imageUri != null) {
                    intent.setType("message/rfc822");
                    intent.putExtra(Intent.EXTRA_STREAM, imageUri);
                }
                intentList.add(new LabeledIntent(intent, packageName, ri.loadLabel(pm), ri.icon));
            }
        }
        // convert intentList to array
        LabeledIntent[] extraIntents = intentList.toArray( new LabeledIntent[ intentList.size() ]);

        openInChooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraIntents);
        startActivity(openInChooser);

    }

    private void getSite(String url) {
        if(url != null && URLUtil.isValidUrl(url)==true) {
            Intent ie = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            startActivity(ie);
        } else {

        }
    }

    public void processConversation (final ParseUser theguy)
    {
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

    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }
}
