package com.cmmath.app;

import com.parse.ParseUser;
import com.cmmath.app.widget.BaseActivity;
import android.content.Intent;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.TextView;

public class PosterDetailsActivity extends BaseActivity {
	
	public static final String TAG = PosterDetailsActivity.class.getSimpleName();
	public static final String 		ACTION_SELECT 			    	= "com.squint.action.poster.select";
	public static final String 		EXTRA_POSTER_ID	  			    = "com.squint.data.poster.ID";
	public static final String 		EXTRA_POSTER_NAME	  			= "com.squint.data.poster.NAME";
	public static final String 		EXTRA_POSTER_AUTHOR	  		    = "com.squint.data.poster.AUTHOR";
	public static final String 		EXTRA_POSTER_CONTENT	  	    = "com.squint.data.poster.CONTENT";
	public static final String 		EXTRA_POSTER_AUTHOR_ID	    	= "com.squint.data.poster.AUTHOR_ID";
	public static final String 		EXTRA_POSTER_LOCATION_NAME 	    = "com.squint.data.poster.LOCATION.NAME";
	public static final String 		EXTRA_POSTER_ATTACHMENT_ID 	    = "com.squint.data.poster.ATTACHMENT_ID";
	public static final String 		EXTRA_POSTER_ATTACHMENT_PDF 	= "com.squint.data.poster.ATTACHMENT_PDF";
	public static final String 		EXTRA_POSTER_ATTACHMENT_CONTENT = "com.squint.data.poster.ATTACHMENT_CONTENT";
    public static final String 		EXTRA_POSTER_AUTHOR_INSTITUTION = "com.squint.data.poster.AUTHOR_INSITUTION";
    public static final String 		EXTRA_POSTER_AUTHOR_EMAIL		= "com.squint.data.poster.AUTHOR_EMAIL";
    public static final String 		EXTRA_POSTER_AUTHOR_WEBSITE	    = "com.squint.data.poster.AUTHOR_WEBSITE";

	private TextView 		mName;
	private TextView 		mAuthor;
	private TextView 		mLocation;
	private TextView 		mDetails;
	private TextView 		mContent;
	private TextView 		mAttachment;
	
	// ParseObject
	private static String  oid;
	private static String  absPdf;
	private static String  absContent;
    private static String  authorId;
    private static String  author;
    private static String  website;
    private static String  email;
    private static String  institution;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.details_poster);
		// Header Configuration
		mTitle.setText(getString(R.string.title_section1));
		configOptions(OPTION_BACK, OPTION_NONE);
				
		mName 			= (TextView)findViewById(R.id.name);
		mAuthor	 		= (TextView)findViewById(R.id.author);
		mLocation 		= (TextView)findViewById(R.id.location);
		mContent 	= (TextView)findViewById(R.id.description);
		mDetails 		= (TextView)findViewById(R.id.author_details);
		mAttachment		= (TextView)findViewById(R.id.btn_attachment);

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
		oid	= intent.getStringExtra(EXTRA_POSTER_ID);

		absContent = intent.getStringExtra(EXTRA_POSTER_ATTACHMENT_CONTENT);
		
		
		mName.setText(intent.getStringExtra(EXTRA_POSTER_NAME));
		mAuthor.setText(intent.getStringExtra(EXTRA_POSTER_AUTHOR));
		mLocation.setText(intent.getStringExtra(EXTRA_POSTER_LOCATION_NAME));
		mContent.setText(intent.getStringExtra(EXTRA_POSTER_CONTENT));

        authorId	= intent.getStringExtra(EXTRA_POSTER_AUTHOR_ID);
        author		= intent.getStringExtra(EXTRA_POSTER_AUTHOR);
        institution	= intent.getStringExtra(EXTRA_POSTER_AUTHOR_INSTITUTION);
        website		= intent.getStringExtra(EXTRA_POSTER_AUTHOR_WEBSITE);
        email		= intent.getStringExtra(EXTRA_POSTER_AUTHOR_EMAIL);

		mDetails.setContentDescription(intent.getStringExtra(EXTRA_POSTER_AUTHOR_ID));
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

        //check if there's an abstract set
        String absid = intent.getStringExtra(EXTRA_POSTER_ATTACHMENT_ID);
        if (absid.length()>=1)
        {
            //yea there's an abstract, continue on
            absPdf = intent.getStringExtra(EXTRA_POSTER_ATTACHMENT_PDF);
            mAttachment.setContentDescription(intent.getStringExtra(EXTRA_POSTER_ATTACHMENT_ID));
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
            //there's no abstract, grey out the button
            mAttachment.setTextColor(getResources().getColor(R.color.button_title));
        }

		
	}
	
	private String getName() {
		return mName.getText().toString();
	}
	
	private String getAuthor() {
		return mAuthor.getText().toString();
	}
	
	private String getAuthorId() {
		return mDetails.getContentDescription().toString();
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
                discussionIntent.putExtra("event_type",  1);
                startActivity(discussionIntent);
            }
        }

    }
}
