package com.cmmath.app;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.cmmath.app.adapter.PeopleAdapter;
import com.cmmath.app.adapter.PersonalAbstractAdapter;
import com.cmmath.app.adapter.PersonalPosterAdapter;
import com.cmmath.app.adapter.PersonalTalkAdapter;
import com.cmmath.app.data.AbstractDAO;
import com.cmmath.app.data.PosterDAO;
import com.cmmath.app.data.PeopleDAO;
import com.cmmath.app.data.TalkDAO;
import com.cmmath.app.widget.BaseActivity;

import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.LabeledIntent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

public class PeopleDetailsActivity extends BaseActivity {
	
	public static final String TAG = PeopleDetailsActivity.class.getSimpleName();
	
	public static final String ACTION_TALK     = "com.squint.app.action.talk";
	public static final String EXTRA_FROM_USER = "com.squint.app.talk.FROM_USER";
	public static final String EXTRA_TO_USER   = "com.squint.app.talk.TO_USER";

	
	public static final String 			ACTION_PERSON_SELECT 		= "com.squint.action.person.select";
	public static final String 			EXTRA_PERSON_ID	  			= "com.squint.data.person.ID";
	public static final String 			EXTRA_PERSON_NAME			= "com.squint.data.person.NAME";
	public static final String 			EXTRA_PERSON_INSTITUTION	= "com.squint.data.person.INSTITUTION";
	public static final String 			EXTRA_PERSON_EMAIL			= "com.squint.data.person.EMAIL";
	public static final String 			EXTRA_PERSON_LINK			= "com.squint.data.person.LINK";
    public static final String 			EXTRA_PERSON_CHATSTATUS		= "com.squint.data.person.CHATSTATUS";
    public static final String 			EXTRA_PERSON_EMAILSTATUS	= "com.squint.data.person.EMAILSTATUS";
    public static final String 			EXTRA_PERSON_ISUSER		    = "com.squint.data.person.ISUSER";

	
	private IntentFilter			filter	 = null;  
    private BroadcastReceiver 		receiver = null;
    
	private TextView mAuthor;
	private TextView mInstitution;
	private TextView mEmail;
	private TextView mLink;
	private TextView mMessage;

    public String conv_objid;
    public int chat_status;
    public int email_status;
    private String email;
	
	// ParseObject
    public ParseUser                      personuser;
	private ParseObject					  mPerson = null;
	private String						  oId;
	private PeopleDAO					  mPeopleDAO;
	// List
	private TalkDAO 					  mTalkDAO;
	private PosterDAO 					  mPosterDAO;
	private AbstractDAO 				  mAttachmentDAO;
	public static List<ParseObject> 	  mTalkData;
	public static List<ParseObject> 	  mPosterData;
	public static List<ParseObject> 	  mAbstractData;
	
	public static PersonalTalkAdapter	  mTalkAdapter;
	public static PersonalPosterAdapter	  mPosterAdapter;
	public static PersonalAbstractAdapter mAbstractAdapter;
	
	public ListView 					  mList;
	private Button 						  mTalk;
	private Button 						  mPoster;
	private Button 						  mAttachment;

	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.details_people);
		// Header Configuration
		mTitle.setText(getString(R.string.title_section2));
		configOptions(OPTION_BACK, OPTION_NONE);
		
		
		Intent intent 	= getIntent();
		oId	= intent.getStringExtra(PeopleAdapter.EXTRA_PERSON_ID);
		email 		            = intent.getStringExtra(PeopleAdapter.EXTRA_PERSON_EMAIL);
		final String link 	= intent.getStringExtra(PeopleAdapter.EXTRA_PERSON_LINK);
        chat_status             = intent.getExtras().getInt(PeopleAdapter.EXTRA_PERSON_CHATON);
        email_status            = intent.getExtras().getInt(PeopleAdapter.EXTRA_PERSON_EMAILON);

		// Retrieve the person data
		//mPeopleDAO = new PeopleDAO(this, oid);	
		
		// Switcher, List, and its data

		mTalkData	= new ArrayList<ParseObject>();
		mPosterData	= new ArrayList<ParseObject>();	
		mAbstractData = new ArrayList<ParseObject>();
		mTalk = (Button)findViewById(R.id.switch_talk);
		mPoster = (Button)findViewById(R.id.switch_poster);
		mAttachment = (Button)findViewById(R.id.switch_attachment);
		mTalk.setOnClickListener(this);
		mPoster.setOnClickListener(this);
		mAttachment.setOnClickListener(this);
		mList = (ListView)findViewById(android.R.id.list);
		mList.setEmptyView(findViewById(android.R.id.empty));
		
		mTalkAdapter = new PersonalTalkAdapter(this, mTalkData);
		mPosterAdapter = new PersonalPosterAdapter(this, mPosterData);
		mAbstractAdapter = new PersonalAbstractAdapter(this, mAbstractData);
		onClick(mTalk);		
	
		mInstitution 	= (TextView)findViewById(R.id.institution);
		mAuthor	 		= (TextView)findViewById(R.id.author);
		mLink 			= (TextView)findViewById(R.id.link);
		mMessage 		= (TextView)findViewById(R.id.message);
		mEmail			= (TextView)findViewById(R.id.email);
		
		mAuthor.setText(intent.getStringExtra(PeopleAdapter.EXTRA_PERSON_NAME));
		mInstitution.setText(intent.getStringExtra(PeopleAdapter.EXTRA_PERSON_INSTITUTION));

        if (link.length()<=1)
        {
            //no valid website
            mLink.setTextColor(getResources().getColor(R.color.button_title));
        }
        else
        {
            mLink.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (link != null && !link.isEmpty()) getSite(link);
                }
            });
        }

        //set up email stuff
        checkSelfPriv();
        //set up chat stuff
        checkIsUser();

	}
	

	@Override  
    public void onResume() {
        super.onResume();
        
        if (receiver == null) receiver = new IntentReceiver();  
        registerReceiver(receiver, getIntentFilter());
        Log.d(TAG, "onResume");
        if (oId == null) return;
        if (mPerson != null) {
        	Log.d(TAG, "Refresh: " + mPerson.getObjectId());
	        mTalkDAO.refresh();		// = new TalkDAO(this, mPerson);
			mPosterDAO.refresh();	// = new PosterDAO(this, mPerson);
			mAttachmentDAO.refresh();	// = new AbstractDAO(this, mPerson);
        } else {
        	if (mPeopleDAO == null) mPeopleDAO = new PeopleDAO(this, oId);
        	else mPeopleDAO.refresh(oId);
        }
    }
	
	@Override  
    public void onPause() {  
        super.onPause();  
        unregisterReceiver(receiver);
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
        Intent ie = new Intent(Intent.ACTION_VIEW,Uri.parse(url));
        startActivity(ie);
    }
    
    private void getConversation(String fromId, String toId) {
    	Log.d(TAG, fromId + " wants to talk with " + toId);
    	/* TODO
    	 * 1) Put extra values about device user id and another person id
    	 * 2) Redefine target Class
    	 */
    	//Intent intent = new Intent(ACTION_TALK);
    	//intent.putExtra(EXTRA_FROM_USER, fromId);
    	//intent.putExtra(EXTRA_TO_USER, toId);
    	//toPage(intent, ConversationActivity.class);


    }
    
	@Override
	public void onClick(View v) {
		switch (v.getId()) {
		case R.id.opt_left:
			onBackPressed();
			break;
		case R.id.switch_talk:
			mList.setAdapter(mTalkAdapter);
			mTalk.setSelected(true);
			mPoster.setSelected(false);
			mAttachment.setSelected(false);
			mTalk.setEnabled(false);
			mPoster.setEnabled(true);
			mAttachment.setEnabled(true);
			break;
		case R.id.switch_poster:
			mList.setAdapter(mPosterAdapter);
			mTalk.setSelected(false);
			mPoster.setSelected(true);
			mAttachment.setSelected(false);
			mTalk.setEnabled(true);
			mPoster.setEnabled(false);
			mAttachment.setEnabled(true);
			break;
		case R.id.switch_attachment:
			mList.setAdapter(mAbstractAdapter);
			mTalk.setSelected(false);
			mPoster.setSelected(false);
			mAttachment.setSelected(true);
			mTalk.setEnabled(true);
			mPoster.setEnabled(true);
			mAttachment.setEnabled(false);
			break;
		}
		
	}
	
	private IntentFilter getIntentFilter() {  
        if (filter == null) {  
        	filter = new IntentFilter();  
        	filter.addAction(TalkDAO.ACTION_LOAD_DATA);
        	filter.addAction(PosterDAO.ACTION_LOAD_DATA);
        	filter.addAction(AbstractDAO.ACTION_LOAD_DATA);
        	filter.addAction(PeopleDAO.ACTION_QUERY_DATA);
        	filter.addAction(TalkDetailsActivity.ACTION_SELECT);
        	filter.addAction(PosterDetailsActivity.ACTION_SELECT);
        	filter.addAction(AttachmentDetailsActivity.ACTION_SELECT);
        }  
        return filter;
    }
	
	class IntentReceiver extends BroadcastReceiver {		  
        @Override  
        public void onReceive(Context context, Intent intent) {
        	Log.d(TAG, "onReceive");	
        	String action = intent.getAction(); 
        	if (action.equals(PeopleDAO.ACTION_QUERY_DATA)) {
            	mPerson = mPeopleDAO.getPersonData();
        		mTalkDAO = new TalkDAO(context, mPerson);
        		mPosterDAO = new PosterDAO(context, mPerson);
        		mAttachmentDAO = new AbstractDAO(context, mPerson);
        		
            } else if (action.equals(TalkDAO.ACTION_LOAD_DATA)) {
            	//mTalkData.clear();
            	//mTalkData.addAll(mTalkDAO.getData());
            	try {
	            	mTalkData = mTalkDAO.getData();
	            	mTalkAdapter.update(mTalkData);
            	} catch (Exception e) { Log.d(TAG, "Talk data is null!"); }
            } else if (action.equals(PosterDAO.ACTION_LOAD_DATA)) {
            	//mPosterData.clear();
            	//mPosterData.addAll(mPosterDAO.getData());
            	try {
            	mPosterData = mPosterDAO.getData();
            	mPosterAdapter.update(mPosterData);
            	} catch (Exception e) { Log.d(TAG, "Poster data is null!"); }
            } else if (action.equals(AbstractDAO.ACTION_LOAD_DATA)) {
            	//mAbstractData.clear();
            	//mAbstractData.addAll(mAbstractDAO.getData());
            	try {
            	mAbstractData = mAttachmentDAO.getData();
            	mAbstractAdapter.update(mAbstractData);
            	} catch (Exception e) { Log.d(TAG, "Attachment data is null!"); }
            } else if (action.equals(TalkDetailsActivity.ACTION_SELECT)) {
            	toPage(intent, TalkDetailsActivity.class);

            } else if (action.equals(PosterDetailsActivity.ACTION_SELECT)) {
            	toPage(intent, PosterDetailsActivity.class);
            	
            } else if (action.equals(AttachmentDetailsActivity.ACTION_SELECT)) {
            	toPage(intent, AttachmentDetailsActivity.class);
            	
            }       
        }  
    }

    public void checkIsUser()
    {
        //check if target person is user
        ParseQuery<ParseObject> personquery = ParseQuery.getQuery("Person");
        personquery.include("user");
        personquery.getInBackground(oId, new GetCallback<ParseObject>() {
            public void done(ParseObject object, ParseException e) {
                if (e == null) {
                    int is_user = object.getInt("is_user");
                    if (is_user == 1)
                    {
                        //the person is a user, check if it is self
                        ParseUser currentUser = ParseUser.getCurrentUser();
                        String self_id = "";
                        int self_chat_on = 0;
                        if (currentUser != null)
                        {
                            self_id= currentUser.getObjectId();
                            self_chat_on = currentUser.getInt("chat_status");
                        }
                        personuser = object.getParseUser("user");
                        String personuser_id = personuser.getObjectId();
                        if (self_id.equals(personuser_id))
                        {
                            //we're looking at ourselves!
                            Log.d(TAG, "looking at self");
                            mMessage.setTextColor(getResources().getColor(R.color.button_title));
                        }
                        else
                        {
                            //target person is user and not self, check both chat_on to see if can chat
                            if (chat_status==1 && self_chat_on==1)
                            {
                                //both sides chat_on=1, set onclick for chat button
                                mMessage.setOnClickListener(new OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        if (oId != null && !oId.isEmpty()) {
                                            ParseUser user = ParseUser.getCurrentUser();
                                            if (user != null)
                                            {
                                                //getConversation(user.getObjectId(), oId);
                                                processConversation(personuser);
                                            }
                                            else {
                                                // If user not signed in
                                                toast("Please sign in first!");
                                                toLoginPage(MessageActivity.class, oId);
                                            }
                                        }
                                    }
                                });
                            }
                            else
                            {
                                //someone doesn't want to chat
                                mMessage.setTextColor(getResources().getColor(R.color.button_title));
                            }
                        }
                    }
                    else
                    {
                        //this guy isn't a user
                        Log.d(TAG, "person not a user");
                        mMessage.setTextColor(getResources().getColor(R.color.button_title));
                    }
                } else {
                    // something went wrong with the query data
                }
            }
        });
    }

    public void checkSelfPriv()
    {
        ParseUser currentUser = ParseUser.getCurrentUser();

        if (currentUser == null)
        {
            //not logged in, cant use email
            mEmail.setTextColor(getResources().getColor(R.color.button_title));
        }
        else
        {
            //logged in, check if is person
            int isperson = currentUser.getInt("is_person");
            if (isperson != 1)
            {
                //not a person, can't use email
                mEmail.setTextColor(getResources().getColor(R.color.button_title));
            }
            else
            {
                //finally, check if target person wants to share email
                if (email_status == 1 && email.length()>1)
                {
                    mEmail.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            try {
                                if (email != null && !email.isEmpty()) sendEmail("", "", new String[] {email}, null);
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        }
                    });
                }
                else
                {
                    //email set to private or no valid email string
                    mEmail.setTextColor(getResources().getColor(R.color.button_title));
                }
            }

        }
    }

    public void goChat(String convid)
    {
        Intent chatIntent = new Intent(this, ChatActivity.class);
        chatIntent.putExtra("selected_conv",  convid);

        startActivity(chatIntent);
    }

    public void processConversation (final ParseUser theguy)
    {
        final ParseUser currentUser = ParseUser.getCurrentUser();
        ParseQuery<ParseObject> me_to_him = ParseQuery.getQuery("Conversation");
        me_to_him.whereEqualTo("user_a", currentUser);
        me_to_him.whereEqualTo("user_b", theguy);

        ParseQuery<ParseObject> him_to_me = ParseQuery.getQuery("Conversation");
        him_to_me.whereEqualTo("user_b", currentUser);
        him_to_me.whereEqualTo("user_a", theguy);

        List<ParseQuery<ParseObject>> queries = new ArrayList<ParseQuery<ParseObject>>();
        queries.add(me_to_him);
        queries.add(him_to_me);

        ParseQuery<ParseObject> mainQuery = ParseQuery.or(queries);
        mainQuery.getFirstInBackground(new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject object, final ParseException e) {
                if (e == null) {

                    //found existing conversation
                    conv_objid = object.getObjectId();
                    goChat(conv_objid);
                }
                else
                {
                    Log.d(TAG, "conversation search error: "+e);
                    if (e.getMessage().equals("no results found for query"))
                    {
                        //no existing conversation, create new
                        ParseObject new_conv = new ParseObject("Conversation");
                        new_conv.put("last_msg", "no messages yet");
                        Date date = new Date();
                        new_conv.put("last_time", date);
                        new_conv.put("user_a_unread", 0);
                        new_conv.put("user_b_unread", 0);
                        new_conv.put("user_a", currentUser);
                        new_conv.put("user_b", theguy);
                        new_conv.saveInBackground(new SaveCallback() {
                            @Override
                            public void done(ParseException ee) {
                                if (ee==null)
                                {
                                    //new conversation created, get the id
                                    ParseQuery<ParseObject> newconvquery = ParseQuery.getQuery("Conversation");
                                    newconvquery.whereEqualTo("user_a", currentUser);
                                    newconvquery.whereEqualTo("user_b", theguy);
                                    newconvquery.getFirstInBackground(new GetCallback<ParseObject>() {
                                        @Override
                                        public void done(ParseObject object, ParseException eee) {
                                            if (eee == null)
                                            {
                                                //retrieved the newly created conv
                                                conv_objid = object.getObjectId();
                                                goChat(conv_objid);
                                            }
                                            else
                                            {
                                                //something went wrong with fetching the new conv
                                                Log.d(TAG, "conversation fetch error");
                                            }
                                        }
                                    });
                                }
                                else
                                {
                                    //something went wrong creating the conversation
                                    Log.d(TAG, "conversation create error");
                                }
                            }
                        });
                    }
                }
            }
        });
    }
	
}
