package com.ashvale.cmmath_one.fragments;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.Toast;

import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.ConversationAdapter;
import com.ashvale.cmmath_one.adapter.VenueAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link VenueFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link VenueFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class VenueFragment extends BaseFragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    public static final String		TAG = VenueFragment.class.getSimpleName();
    private IntentFilter			filter	 = null;
    private BroadcastReceiver 		receiver = null;
    private static final String ARG_PARAM1 = "param1";
    private static final String ARG_PARAM2 = "param2";
    private SharedPreferences savedEvents;

    // TODO: Rename and change types of parameters
    private String mParam1;
    private String mParam2;

    private OnFragmentInteractionListener mListener;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment VenueFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static VenueFragment newInstance(String param1, String param2) {
        VenueFragment fragment = new VenueFragment();
        Bundle args = new Bundle();
        args.putString(ARG_PARAM1, param1);
        args.putString(ARG_PARAM2, param2);
        fragment.setArguments(args);
        return fragment;
    }

    public VenueFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
            mParam1 = getArguments().getString(ARG_PARAM1);
            mParam2 = getArguments().getString(ARG_PARAM2);
        }

        savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
        String currentId = savedEvents.getString("currenteventid", "");

        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
        innerQuery.whereEqualTo("objectId", currentId);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Venue");
        query.whereMatchesQuery("event", innerQuery);
        query.orderByDescending("order");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "venue query error: " + e);
                }
            }
        });
    }

    public void setAdapter(final List results)
    {
        VenueAdapter adapter = new VenueAdapter(getActivity(), results);
        ListView venueList = (ListView)getActivity().findViewById(R.id.venueListView);
        venueList.setAdapter(adapter);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        return inflater.inflate(R.layout.fragment_venue, container, false);
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
        if (receiver == null) receiver = new IntentReceiver();
        getActivity().registerReceiver(receiver, getIntentFilter());
    }

    @Override
    public void onPause() {
        super.onPause();
        getActivity().unregisterReceiver(receiver);
    }

    private void getCall(String number) {
        Intent dial = new Intent();
        dial.setAction(Intent.ACTION_CALL);
        dial.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        dial.setData(Uri.parse("tel:" + number));
        startActivity(dial);
    }

    private void getSite(String url) {
        Intent ie = new Intent(Intent.ACTION_VIEW,Uri.parse(url));
        startActivity(ie);
    }

    private void getMap(double lat, double lng) {
        try {
            //String label = _PARAMS.COMPANY;
            String uriBegin = "geo:" + lat + "," + lng;
            //String query = _PARAMS.LATITUDE + "," + _PARAMS.LONGITUDE + "(" + label + ")";
            //String encodedQuery = Uri.encode(query);
            //String uriString = uriBegin + "?q=" + encodedQuery + "&z=16"; // if label required
            String uriString = uriBegin + "?q=" + "&z=16"; // if label required
            Uri mapUri = Uri.parse(uriString); // if label required

            //Uri mapUri = Uri.parse(uriBegin);
            Intent maps = new Intent(android.content.Intent.ACTION_VIEW, mapUri);
            startActivity(maps);
        } catch (Exception e) {
            toast("The application of Google Maps is not found!");
        }
    }

    private IntentFilter getIntentFilter() {
        if (filter == null) {
            filter = new IntentFilter();
            filter.addAction(VenueAdapter.ACTION_VENUE_WEBSITE);
            filter.addAction(VenueAdapter.ACTION_VENUE_CALL);
            filter.addAction(VenueAdapter.ACTION_VENUE_NAVIGATE);
        }
        return filter;
    }

    class IntentReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "onReceive");
            String action = intent.getAction();
            if (action.equals(VenueAdapter.ACTION_VENUE_WEBSITE)) {
                getSite(intent.getStringExtra(VenueAdapter.ACTION_VENUE_URL));

            } else if (action.equals(VenueAdapter.ACTION_VENUE_CALL)) {
                getCall(intent.getStringExtra(VenueAdapter.ACTION_VENUE_PHONE));

            } else if (action.equals(VenueAdapter.ACTION_VENUE_NAVIGATE)) {
                double lat = intent.getDoubleExtra(VenueAdapter.EXTRA_VENUE_LAT, 0);
                double lng = intent.getDoubleExtra(VenueAdapter.EXTRA_VENUE_LNG, 0);
                if (lat != 0 && lng != 0) getMap(lat, lng);

            }
        }
    }

    public void toast(String message) {
        Toast.makeText(getActivity(), message, Toast.LENGTH_SHORT).show();
    }

}
