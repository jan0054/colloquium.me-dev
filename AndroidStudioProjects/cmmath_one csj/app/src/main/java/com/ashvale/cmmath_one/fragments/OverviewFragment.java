package com.ashvale.cmmath_one.fragments;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.AddEventAdapter;
import com.ashvale.cmmath_one.adapter.AnnounceAdapter;
import com.ashvale.cmmath_one.adapter.VenueAdapter;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;

import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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

        savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
        String currentId = savedEvents.getString("currenteventid", "");

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Event");
        query.include("admin");
        query.getInBackground(currentId, new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject parseObject, ParseException e) {
                if (e==null)
                {
                    String eventName = parseObject.getString("name");
                    Date startdate = parseObject.getDate("start_time");
                    Date enddate = parseObject.getDate("end_time");
                    Format dateformatter = new SimpleDateFormat("MM/dd");
                    String startstr = dateformatter.format(startdate);
                    String endstr = dateformatter.format(enddate);
                    String eventOrganizer = parseObject.getString("organizer");
                    String eventContent = parseObject.getString("content");
                    TextView nameLabel = (TextView) getView().findViewById(R.id.overview_name);
                    TextView dateLabel = (TextView) getView().findViewById(R.id.overview_date);
                    TextView organizerLabel = (TextView) getView().findViewById(R.id.overview_organizer);
                    TextView contentLabel = (TextView) getView().findViewById(R.id.overview_content);

                    nameLabel.setText(eventName);
                    dateLabel.setText(startstr+" ~ "+endstr);
                    organizerLabel.setText(eventOrganizer);
                    contentLabel.setText(eventContent);

                    //attendance not prepared
//                    int eventAttending = ParseUser.getCurrentUser().get

                    savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
                    String currentId = savedEvents.getString("currenteventid", "");

                    ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
                    innerQuery.whereEqualTo("objectId", currentId);

                    ParseQuery<ParseObject> query = ParseQuery.getQuery("Announce");
                    query.whereMatchesQuery("event", innerQuery);
                    query.orderByDescending("order");
                    query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
                    query.findInBackground(new FindCallback<ParseObject>() {
                        public void done(List<ParseObject> objects, com.parse.ParseException e) {
                            if (e == null) {
                                if(objects.size()!=0) {
                                    setAdapter(objects);
                                    TextView emptyText = (TextView)getView().findViewById(R.id.announceempty);
                                    emptyText.setVisibility(View.INVISIBLE);
                                }
                                else {
                                    ListView announceList = (ListView) getView().findViewById(R.id.announceListView);
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

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_overview, container, false);
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

    public void setAdapter(final List results)
    {
        AnnounceAdapter adapter = new AnnounceAdapter(getActivity(), results);
        ListView announceList = (ListView)getActivity().findViewById(R.id.announceListView);
        announceList.setAdapter(adapter);
    }
}
