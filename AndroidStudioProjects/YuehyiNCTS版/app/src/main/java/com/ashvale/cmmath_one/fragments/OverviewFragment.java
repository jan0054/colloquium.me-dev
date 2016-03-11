package com.ashvale.cmmath_one.fragments;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.LabeledIntent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.CompoundButton;
import android.widget.ListView;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.cmmath_one.EventWrapperActivity;
import com.ashvale.cmmath_one.LoginActivity;
import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.AnnounceAdapter;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;

import java.io.IOException;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link OverviewFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link OverviewFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class OverviewFragment extends BaseFragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    public static final String		TAG = OverviewFragment.class.getSimpleName();
    private IntentFilter filter	 = null;
    private BroadcastReceiver receiver = null;
    private SharedPreferences savedEvents;
    private AnnounceAdapter adapter;
    public android.support.v7.widget.SwitchCompat attendEventswitch;
    public int attendEvent_on;
    List<ParseObject> eventAttending;
    ParseObject currenteventObject;
    String contactMail;
    TextView emptyText;
    ListView announceList;
    TextView nameLabel;
    TextView dateLabel;
    TextView organizerLabel;
    TextView contentLabel;
    SwipeRefreshLayout swipeRefresh;

    // TODO: Rename and change types of parameters

    private OnFragmentInteractionListener mListener;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment OverviewFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static OverviewFragment newInstance(String param1, String param2) {
        OverviewFragment fragment = new OverviewFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public OverviewFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
        }
        //loadOverview();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_overview, container, false);
        emptyText = (TextView)view.findViewById(R.id.announceempty);
        announceList = (ListView) view.findViewById(R.id.announceListView);
        swipeRefresh = (SwipeRefreshLayout) view.findViewById(R.id.pulltorefresh);
        swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                loadOverview();
            }
        });
        return view;
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        try {
            mListener = (OnFragmentInteractionListener) activity;
        } catch (ClassCastException e) {
            throw new ClassCastException(activity.toString()
                    + " must implement OnFragmentInteractionListener");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    @Override
    public void onResume() {
        super.onResume();
        loadOverview();

    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser)
        {
            ((EventWrapperActivity) getActivity()).setTitleByFragment(0, null);
        }
    }

    public void loadOverview() {
        savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
        String currentId = savedEvents.getString("currenteventid", "");

        nameLabel = (TextView) getView().findViewById(R.id.overview_name);
        dateLabel = (TextView) getView().findViewById(R.id.overview_date);
        organizerLabel = (TextView) getView().findViewById(R.id.overview_organizer);
        contentLabel = (TextView) getView().findViewById(R.id.overview_content);
        attendEventswitch = (android.support.v7.widget.SwitchCompat) getView().findViewById(R.id.attend_switch);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
        query.include("admin");
        query.getInBackground(currentId, new GetCallback<ParseObject>() {
            @Override
            public void done(final ParseObject obj, ParseException e) {
                if (e==null)
                {
                    currenteventObject = obj;
                    String eventName = currenteventObject.getString("name");
                    Date startdate = currenteventObject.getDate("start_time");
                    Date enddate = currenteventObject.getDate("end_time");
                    Format dateformatter = new SimpleDateFormat("MM/dd");
                    String startstr = dateformatter.format(startdate);
                    String endstr = dateformatter.format(enddate);
                    String eventOrganizer = currenteventObject.getString("organizer");
                    String eventContent = currenteventObject.getString("content");
                    boolean adminexist = currenteventObject.has("admin");
                    if(adminexist) {
                        contactMail = currenteventObject.getParseUser("admin").getUsername().toString();
                    }

                    nameLabel.setText(eventName);
                    dateLabel.setText(startstr+" ~ "+endstr);
                    organizerLabel.setText(eventOrganizer);
                    contentLabel.setText(eventContent);

                    organizerLabel.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            try {
                                if(contactMail!=null && contactMail.length()!=0) {
                                    sendEmail("", "", new String[]{contactMail}, null);
                                }
                            } catch (Exception e){
                                e.getStackTrace();
                            }
                        }
                    });
                    //attendance not prepared
                    final ParseUser curuser = ParseUser.getCurrentUser();
                    if(curuser == null) {
                        attendEventswitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                                toast(getString(R.string.error_not_login));
                                SharedPreferences userStatus;
                                userStatus = getActivity().getSharedPreferences("LOGIN", 0); //6 = readable+writable by other apps, use 0 for private
                                SharedPreferences.Editor editor = userStatus.edit();
                                editor.putInt("skiplogin", 0);
                                editor.commit();
                                Intent intent = new Intent(getActivity(), LoginActivity.class);
                                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP|Intent.FLAG_ACTIVITY_CLEAR_TASK|Intent.FLAG_ACTIVITY_NEW_TASK);
                                startActivity(intent);
                            }
                        });
                    }
                    else
                    {
                        eventAttending = new ArrayList<>();
                        eventAttending = curuser.getList("attendance");

                        attendEvent_on = 0;
                        if(eventAttending == null)
                        {
                            Log.d("cm_app", "attendance is null");
                            eventAttending = new ArrayList<>();
                            attendEvent_on = 0;
                        }
                        else {
                            Log.d("cm_app", "event number: " + eventAttending.size());
                            for (ParseObject eventobject : eventAttending) {
                                if (eventobject.getObjectId().equals(currenteventObject.getObjectId())) {
                                    attendEvent_on = 1;
                                    break;
                                }
                                else {
                                    Log.d("cm_app", "not this event");
                                }
                            }
                        }
                        if (attendEvent_on == 1) {
                            attendEventswitch.setChecked(true);
                        } else {
                            attendEventswitch.setChecked(false);
                        }
                        attendEventswitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                                if (isChecked) {
                                    //email set to public
                                    if (attendEvent_on == 0) {
                                        eventAttending = curuser.getList("attendance");
                                        if(eventAttending == null) {
                                            eventAttending = Arrays.asList(currenteventObject);
                                        } else {
                                            eventAttending.add(currenteventObject);
                                        }
                                        curuser.put("attendance", eventAttending);
                                        curuser.saveInBackground(new SaveCallback() {
                                            @Override
                                            public void done(ParseException e) {
                                                if(e == null) {
                                                    if(currenteventObject != null) {
                                                        List<ParseUser> userAttending = currenteventObject.getList("attendees");
                                                        if(userAttending == null) {
                                                            userAttending = Arrays.asList(curuser);
                                                        } else {
                                                            userAttending.add(curuser);
                                                        }
                                                        currenteventObject.put("attendees", userAttending);
                                                        currenteventObject.saveInBackground();
                                                    } else {
                                                        Log.d("cm_app", "error: currentevent == null");
                                                    }
                                                } else {
                                                    Log.d("cm_app", "write to user failed: "+e);
                                                }
                                            }
                                        });
                                    }
                                    attendEvent_on = 1;
                                } else if (!isChecked) {
                                    //email set to private
                                    if (attendEvent_on == 1) {
                                        curuser.removeAll("attendance", Arrays.asList(currenteventObject));
                                        curuser.saveInBackground(new SaveCallback() {
                                            @Override
                                            public void done(ParseException e) {
                                                if(e == null) {
                                                    if(currenteventObject !=null) {
                                                        currenteventObject.removeAll("attendees", Arrays.asList(curuser));
                                                        currenteventObject.saveInBackground();
                                                    } else {
                                                        Log.d("cm_app", "error: currentevent == null");
                                                    }
                                                } else {
                                                    Log.d("cm_app", "write to user failed"+e);
                                                }
                                            }
                                        });
                                    }
                                    attendEvent_on = 0;
                                }
                            }
                        });
                    }

                    savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
                    String currentId = savedEvents.getString("currenteventid", "");

                    ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
                    innerQuery.whereEqualTo("objectId", currentId);

                    ParseQuery<ParseObject> query = ParseQuery.getQuery("Announcement");
                    query.whereMatchesQuery("event", innerQuery);
                    query.include("author");
                    query.orderByDescending("createdAt");
                    query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
                    query.findInBackground(new FindCallback<ParseObject>() {
                        public void done(List<ParseObject> objects, com.parse.ParseException e) {
                            if (e == null) {
                                if(objects.size()!=0) {
                                    setAdapter(objects);
                                    swipeRefresh.setRefreshing(false);
                                    emptyText.setVisibility(View.INVISIBLE);
                                }
                                else {
                                    announceList.setVisibility(View.INVISIBLE);
                                }
                            } else {
                                Log.d("cm_app", "announcements query error: " + e);
                            }
                        }
                    });

                    //to-do: get all other data and put into UI..
                }
                else
                {
                    Log.d("cm_app", "overview event query error: " + e);
                }
            }
        });
    }
    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p/>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */

    public void addAttendance(ParseObject parseObject)
    {

    }

    public void deleteAttendance(ParseObject parseObject)
    {

    }

    public void toast(String message) {
        Toast.makeText(getActivity(), message, Toast.LENGTH_SHORT).show();
    }

    public void setAdapter(final List results)
    {
        AnnounceAdapter adapter = new AnnounceAdapter(getActivity(), results);
        announceList.setAdapter(adapter);
        announceList.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {

            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
                if(firstVisibleItem == 0) {
                    swipeRefresh.setEnabled(true);
                } else {
                    swipeRefresh.setEnabled(false);
                }
            }
        });
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
        PackageManager pm = getActivity().getPackageManager();

        Intent sendIntent = new Intent(Intent.ACTION_SEND);
        sendIntent.setType("text/plain");

        List<ResolveInfo> resInfo = pm.queryIntentActivities(sendIntent, 0);
        List<LabeledIntent> intentList = new ArrayList<LabeledIntent>();

        for (int i = 0; i < resInfo.size(); i++) {
            ResolveInfo ri = resInfo.get(i);
            String packageName = ri.activityInfo.packageName;
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
}
