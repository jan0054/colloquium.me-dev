package com.cmenvi.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.cmenvi.app.adapter.CommentAdapter;
import com.cmenvi.app.adapter.PostAdapter;
import com.cmenvi.app.data.AttachmentDAO;
import com.cmenvi.app.data.CommentDAO;
import com.cmenvi.app.data.PeopleDAO;
import com.cmenvi.app.data.PostDAO;
import com.cmenvi.app.data.PosterDAO;
import com.cmenvi.app.data.TalkDAO;
import com.cmenvi.app.widget.BaseActivity;
import com.cmenvi.app.widget.BitmapManager;
import com.parse.GetCallback;
import com.parse.ParseACL;
import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParsePush;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

public class PostDetailsActivity extends BaseActivity {
	
	public static final String TAG = PostDetailsActivity.class.getSimpleName();
	
	public static final String ACTION_TALK     = "com.cmenvi.app.action.talk";
	public static final String EXTRA_FROM_USER = "com.cmenvi.app.talk.FROM_USER";
	public static final String EXTRA_TO_USER   = "com.cmenvi.app.talk.TO_USER";

	public static final String 			ACTION_SELECT 		= "com.cmenvi.action.post.select";
	public static final String 			EXTRA_POST_ID	  		= "com.cmenvi.data.post.ID";
	public static final String 			EXTRA_POST_NAME			= "com.cmenvi.data.post.NAME";
	public static final String 			EXTRA_POST_ATTACHMENT	= "com.cmenvi.data.post.ATTACHMENT";
	public static final String 			EXTRA_POST_AUTHORNAME	= "com.cmenvi.data.post.AUTHORNAME";
	public static final String 			EXTRA_POST_CONTENT		= "com.cmenvi.data.post.CONTENT";
	public static final String 			EXTRA_POST_IMAGE	    = "com.cmenvi.data.post.IMAGE";
	public static final String 			EXTRA_POST_CREATEDAT	= "com.cmenvi.data.post.CREATEDAT";
	public static final String 			EXTRA_POST_DATE		    = "com.cmenvi.data.post.DATE";

	private Context 					context;
	private SimpleDateFormat 			sdf;
	private List<ParseObject>	 		data;

    protected cmenviApplication app;

	private IntentFilter			filter	 = null;  
    private BroadcastReceiver 		receiver = null;

	private TextView mAuthorname;
	private TextView mCreatedAt;
	private TextView mContent;
	private ImageView mImage;

    public String post_objid;

	// ParseObject
    public ParseUser                    personuser;
	private ParseObject					mPost;
	private String						oId;
	private PostDAO						mPostDAO;
	private CommentDAO					mCommentDAO;
	// List
	public static List<ParseObject> 	  mCommentData;

	public static CommentAdapter mCommentAdapter;

	public ListView 					  mList;
	private Button 						  mSendComment;
    private EditText                      mCommentInput;
    public ArrayList<String> searcharray;


	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.details_post);
		// Header Configuration
		mTitle.setText(getString(R.string.title_timeline));
		configOptions(OPTION_BACK, OPTION_NONE);

		Intent intent 	= getIntent();
		oId	= intent.getStringExtra(PostAdapter.EXTRA_POST_ID);
		// Retrieve the person data
		mAuthorname 	= (TextView)findViewById(R.id.author_name);
		mCreatedAt		= (TextView)findViewById(R.id.createdAt);
		mContent 		= (TextView)findViewById(R.id.content);
		mImage	 		= (ImageView)findViewById(R.id.image);

		mAuthorname.setText(intent.getStringExtra(PostAdapter.EXTRA_POST_AUTHORNAME));
		mCreatedAt.setText(intent.getStringExtra(PostAdapter.EXTRA_POST_CREATEDAT));
		mContent.setText(intent.getStringExtra(PostAdapter.EXTRA_POST_CONTENT));
		BitmapManager.INSTANCE.loadBitmap(intent.getStringExtra(PostAdapter.EXTRA_POST_IMAGE), mImage, 0, 0);

		mCommentData	= new ArrayList<ParseObject>();
		mList = (ListView)findViewById(android.R.id.list);
		mList.setEmptyView(findViewById(android.R.id.empty));
		mCommentAdapter = new CommentAdapter(this, mCommentData);
		mList.setAdapter(mCommentAdapter);
//        mCommentInput = (EditText)findViewById(R.id.commentinput);
//        mSendComment = (Button)findViewById(R.id.sendcomment);
//        mSendComment.setOnClickListener(this);
	}

	@Override  
    public void onResume() {
        super.onResume();

        if (receiver == null) receiver = new IntentReceiver();
        registerReceiver(receiver, getIntentFilter());
        if (oId == null) return;
        if (mPost != null) {
            Log.d(TAG, "Refresh: " + mPost.getObjectId());
            mCommentDAO.refresh();		// = new CommentDAO(this, mPerson);
        } else {
            if (mPostDAO == null) mPostDAO = new PostDAO(this, oId);
            else mPostDAO.refresh(oId);
        }
    }
	
	@Override  
    public void onPause() {
        super.onPause();
        unregisterReceiver(receiver);
    }
	
	@Override
	public void onClick(View v) {
        switch (v.getId()) {
            case R.id.opt_left:
                onBackPressed();
                break;
/*            case R.id.sendcomment:
                ParseUser selfuser = ParseUser.getCurrentUser();
                if (selfuser != null) {
                    app = (cmenviApplication) getApplication();
                    if (!app.isPerson) { // not person, can not comment
                        toPage(new Intent(), UserAttendeeActivity.class);
                    } else {
                        sendComment();
                    }
                } else {
                    toast("Please log in first!");
                    toLoginPage(ConversationActivity.class);
                }
                break;*/
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
        listView.getLayoutParams().height = totalHeight + (listView.getDividerHeight() * listView.getAdapter().getCount());
        listView.setLayoutParams(listView.getLayoutParams());
        listView.requestLayout();
    }
    public void sendComment(View view) {
        Log.i(TAG, "send comment button pressed");
        ParseUser selfuser = ParseUser.getCurrentUser();
        if (selfuser != null) {
            app = (cmenviApplication) getApplication();
            if (!app.isPerson) { // not person, can not comment
                updateIsPerson(selfuser);
            } else {
            }
        } else {
            toast("Please log in first!");
            toLoginPage(ConversationActivity.class);
            return;
        }
        //setup all the data for the new comment object
        EditText editText = (EditText) findViewById(R.id.commentinput);
        final String message = editText.getText().toString();
        Log.i(TAG, message);
        ParseUser currentUser = ParseUser.getCurrentUser();
        //get the other guy
        final String cid = currentUser.getObjectId();

        if(message.length()<1) {
            toast("Empty imput.");
            return;
        }
        //create and save the chat object
        ParseObject commentmsg = new ParseObject("Comment");
        commentmsg.put(CommentDAO.CONTENT, message);
        commentmsg.put(CommentDAO.POST, mPost);
        commentmsg.put(CommentDAO.AUTHOR, currentUser);
        commentmsg.put(CommentDAO.AUTHORNAME, currentUser.getUsername());
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
                    Intent intent = getIntent();
//                    intent.putExtra(EXTRA_POST_ID, item.getObjectId());
//                    intent.putExtra(EXTRA_POST_AUTHORNAME, getAuthorname(item));
//                    intent.putExtra(EXTRA_POST_CREATEDAT, getCreatedAt(item));
//                    intent.putExtra(EXTRA_POST_CONTENT, getContent(item));
//                    intent.putExtra(EXTRA_POST_IMAGE, getPhotoUrl(item));
                    toPage(intent, PostDetailsActivity.class);
                } else {
                    Log.i(TAG, "sendComment save fail");
                    //did not save successfully
                }
            }
        });
    }
	private IntentFilter getIntentFilter() {
        if (filter == null) {
        	filter = new IntentFilter();  
        	filter.addAction(CommentDAO.ACTION_LOAD_DATA);
            filter.addAction(PostDAO.ACTION_QUERY_DATA);
            filter.addAction(PostDetailsActivity.ACTION_SELECT);
        }
        return filter;
    }
	
	class IntentReceiver extends BroadcastReceiver {
        @Override  
        public void onReceive(Context context, Intent intent) {
        	String action = intent.getAction();
            if (action.equals(PostDAO.ACTION_QUERY_DATA)) {
                mPost = mPostDAO.getPostData();
                mCommentDAO = new CommentDAO(context, mPost);
            } else if (action.equals(CommentDAO.ACTION_LOAD_DATA)) {
            	//mTalkData.clear();
            	//mTalkData.addAll(mTalkDAO.getData());
            	try {
	            	mCommentData = mCommentDAO.getData();
	            	mCommentAdapter.update(mCommentData);
                    getListHeight(mList);
            	} catch (Exception e) { Log.d(TAG, "Comment data is null!"); }
            }
        }  
    }

/*    public void checkIsUser()
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
				} else {
					Log.d(TAG, "conversation search error: " + e);
					if (e.getMessage().equals("no results found for query")) {
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
								if (ee == null) {
									//new conversation created, get the id
									ParseQuery<ParseObject> newconvquery = ParseQuery.getQuery("Conversation");
									newconvquery.whereEqualTo("user_a", currentUser);
									newconvquery.whereEqualTo("user_b", theguy);
									newconvquery.getFirstInBackground(new GetCallback<ParseObject>() {
										@Override
										public void done(ParseObject object, ParseException eee) {
											if (eee == null) {
												//retrieved the newly created conv
												conv_objid = object.getObjectId();
												goChat(conv_objid);
											} else {
												//something went wrong with fetching the new conv
												Log.d(TAG, "conversation fetch error");
											}
										}
									});
								} else {
									//something went wrong creating the conversation
									Log.d(TAG, "conversation create error");
								}
							}
						});
					}
				}
			}
		});
    }*/
}
