package com.cmenvi.app;

import com.parse.ParseUser;
import com.cmenvi.app.widget.BaseActivity;
import android.content.Intent;
import android.os.Bundle;
import android.provider.CalendarContract;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;

import java.util.Calendar;

public class TalkDetailsActivity extends BaseActivity {
	
	public static final String TAG = TalkDetailsActivity.class.getSimpleName();
	public static final String 		ACTION_SELECT 			    	= "com.squint.action.talk.select";
	public static final String 		EXTRA_TALK_ID	  			    = "com.squint.data.talk.ID";
	public static final String 		EXTRA_TALK_NAME	  			    = "com.squint.data.talk.NAME";
	public static final String 		EXTRA_TALK_AUTHOR	  		    = "com.squint.data.talk.AUTHOR";
	public static final String 		EXTRA_TALK_AUTHOR_ID	  		= "com.squint.data.talk.AUTHOR_ID";
	public static final String 		EXTRA_TALK_CONTENT	  	        = "com.squint.data.talk.CONTENT";
	public static final String 		EXTRA_TALK_START_TIME		    = "com.squint.data.talk.START_TIME";
	public static final String 		EXTRA_TALK_LOCATION_NAME 	    = "com.squint.data.talk.LOCATION.NAME";
	public static final String 		EXTRA_TALK_ATTACHMENT_ID 	    = "com.squint.data.talk.ATTACHMENT_ID";
	public static final String 		EXTRA_TALK_ATTACHMENT_PDF	    = "com.squint.data.talk.ATTACHMENT_PDF";
	public static final String 		EXTRA_TALK_ATTACHMENT_CONTENT   = "com.squint.data.talk.ATTACHMENT_CONTENT";
    public static final String 		EXTRA_TALK_AUTHOR_INSTITUTION   = "com.squint.data.talk.AUTHOR_INSITUTION";
    public static final String 		EXTRA_TALK_AUTHOR_EMAIL		    = "com.squint.data.talk.AUTHOR_EMAIL";
    public static final String 		EXTRA_TALK_AUTHOR_WEBSITE	    = "com.squint.data.talk.AUTHOR_WEBSITE";
    public static final String 		EXTRA_TALK_SESSION	            = "com.squint.data.talk.SESSION";

    public String cal_talk_name;
    public String cal_talk_location;
    public String cal_talk_start_time;
    public String cal_talk_end_time;

	private TextView 		mName;
	private TextView 		mAuthor;
	private TextView 		mLocation;
	private TextView 		mTime;
	private TextView 		mContent;
	private TextView 		mAttachment;
    private TextView 		mDetails;
    private TextView        mCalendar;
	private TextView        mSession;

	// ParseObject
	private static String  oid;
	private static String  authorId;
	private static String  absPdf;
	private static String  absContent;
    private static String  author;
    private static String  website;
    private static String  email;
    private static String  institution;
    private static String  session;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.details_talk);
		// Header Configuration
		mTitle.setText(getString(R.string.title_program));
		configOptions(OPTION_BACK, OPTION_NONE);
				
		mName 			= (TextView)findViewById(R.id.name);
		mAuthor	 		= (TextView)findViewById(R.id.author);
		mLocation 		= (TextView)findViewById(R.id.location);
		mContent 	= (TextView)findViewById(R.id.content);
		mTime 			= (TextView)findViewById(R.id.start_time);
		mAttachment		= (TextView)findViewById(R.id.btn_attachment);
        mDetails 		= (TextView)findViewById(R.id.author_details);
        mCalendar       = (TextView)findViewById(R.id.btn_calendar);
        mSession        = (TextView)findViewById(R.id.session);
        mContent.setMovementMethod(new ScrollingMovementMethod());

        TextView mDiscuss = (TextView)findViewById(R.id.btn_discussion);
        ParseUser cur_user = ParseUser.getCurrentUser();
        if (cur_user != null)
        {
            int isperson = cur_user.getInt("is_person");
            if (isperson != 1)
            {
                mDiscuss.setTextColor(getResources().getColor(R.color.button_title));
            }
        }
        else
        {
            mDiscuss.setTextColor(getResources().getColor(R.color.button_title));
        }

	}
	
	@Override
	public void onResume() {
		super.onResume();
		Intent intent 	= getIntent();
		oid	= intent.getStringExtra(EXTRA_TALK_ID);
		Log.d(TAG, "Talk ID: " + oid);
		authorId = intent.getStringExtra(EXTRA_TALK_AUTHOR_ID);

		cal_talk_name = intent.getStringExtra(EXTRA_TALK_NAME);
        cal_talk_location = intent.getStringExtra(EXTRA_TALK_LOCATION_NAME);
        cal_talk_start_time = intent.getStringExtra(EXTRA_TALK_START_TIME);

        session = intent.getStringExtra(EXTRA_TALK_SESSION);

        mSession.setText(session);
		mName.setText(intent.getStringExtra(EXTRA_TALK_NAME));
		mAuthor.setText(intent.getStringExtra(EXTRA_TALK_AUTHOR));
		mLocation.setText(intent.getStringExtra(EXTRA_TALK_LOCATION_NAME));
		mContent.setText(intent.getStringExtra(EXTRA_TALK_CONTENT));
		mTime.setText(intent.getStringExtra(EXTRA_TALK_START_TIME));

        authorId	= intent.getStringExtra(EXTRA_TALK_AUTHOR_ID);
        author		= intent.getStringExtra(EXTRA_TALK_AUTHOR);
        institution	= intent.getStringExtra(EXTRA_TALK_AUTHOR_INSTITUTION);
        website		= intent.getStringExtra(EXTRA_TALK_AUTHOR_WEBSITE);
        email		= intent.getStringExtra(EXTRA_TALK_AUTHOR_EMAIL);
        
        mDetails.setContentDescription(intent.getStringExtra(EXTRA_TALK_AUTHOR_ID));
        mDetails.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
            Intent intent = new Intent(PeopleDetailsActivity.ACTION_PERSON_SELECT);
            intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_ID, authorId);
            intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_NAME, author);
            intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_INSTITUTION, institution);
            intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_EMAIL, email);
            intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_LINK, website);
            toPage(intent, PeopleDetailsActivity.class);
            }
        });

        String absid = intent.getStringExtra(EXTRA_TALK_ATTACHMENT_ID);
        //check to see if the abstract isn't set and the intents are empty strings
        if (absid.length()>=1)
        {
            absPdf = intent.getStringExtra(EXTRA_TALK_ATTACHMENT_PDF);
            absContent = intent.getStringExtra(EXTRA_TALK_ATTACHMENT_CONTENT);
            mAttachment.setContentDescription(intent.getStringExtra(EXTRA_TALK_ATTACHMENT_ID));
            mAttachment.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    //String abstractId = v.getContentDescription().toString();
                    //Log.d(TAG, "oid/abstract: " + oid + "/ " + abstractId);

                    Intent intent = new Intent(AttachmentDetailsActivity.ACTION_SELECT);

                    intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_ID, getAbstractId());
                    intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_NAME, getName());
                    intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_AUTHOR, getAuthor());
                    intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_AUTHOR_ID, getAuthorId());
                    intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_PDF, getAbstractPdf());
                    intent.putExtra(AttachmentDetailsActivity.EXTRA_ATTACHMENT_CONTENT, getAbstractContent());

                    toPage(intent, AttachmentDetailsActivity.class);
                }
            });
        }
        else
        {
            //abstract wasn't set! disable the abstract button
            mAttachment.setTextColor(getResources().getColor(R.color.button_title));
        }

        mCalendar.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
            //tapped the add-to-calendar button
                Calendar beginTime = Calendar.getInstance();
                beginTime.set(2015, 0, 15, 10, 00);
                Calendar endTime = Calendar.getInstance();
                endTime.set(2015, 0, 15, 11, 30);
                Intent intent = new Intent(Intent.ACTION_INSERT)
                        .setData(CalendarContract.Events.CONTENT_URI)
                        .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, beginTime.getTimeInMillis())
                        .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endTime.getTimeInMillis())
                        .putExtra(CalendarContract.Events.TITLE, cal_talk_name)
                        .putExtra(CalendarContract.Events.DESCRIPTION, cal_talk_name)
                        .putExtra(CalendarContract.Events.EVENT_LOCATION, cal_talk_location)
                        .putExtra(CalendarContract.Events.AVAILABILITY, CalendarContract.Events.AVAILABILITY_BUSY);
                        //.putExtra(Intent.EXTRA_EMAIL, "rowan@example.com,trevor@example.com");
                startActivity(intent);

            }
        });

	}
	
	private String getName() {
		return mName.getText().toString();
	}
	
	private String getAuthor() {
		return mAuthor.getText().toString();
	}
	
	private String getAuthorId() {
		return authorId;
	}
	
	private String getAbstractId() {
		return mAttachment.getContentDescription().toString();
	}
	
	private String getAbstractContent() {
		return absContent;
	}
	
	private String getAbstractPdf() {
		return absPdf;
	}

    public void goDiscuss(View view) {
        ParseUser cur_user = ParseUser.getCurrentUser();
        if (cur_user != null)
        {
            int isperson = cur_user.getInt("is_person");
            if (isperson == 1)
            {
                Log.d(TAG, "DISCUSS: " + oid);
                Intent discussionIntent = new Intent(this, DiscussionActivity.class);
                discussionIntent.putExtra("event_objid",  oid);
                discussionIntent.putExtra("event_type",  0);
                startActivity(discussionIntent);
            }
        }

    }
}
