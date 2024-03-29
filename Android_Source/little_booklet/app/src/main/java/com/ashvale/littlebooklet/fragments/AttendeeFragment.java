package com.ashvale.littlebooklet.fragments;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.ashvale.littlebooklet.EventWrapperActivity;
import com.ashvale.littlebooklet.PeopleDetailActivity;
import com.ashvale.littlebooklet.R;
import com.ashvale.littlebooklet.adapter.AttendeeAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link AttendeeFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link AttendeeFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class AttendeeFragment extends BaseFragment{
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private SharedPreferences savedEvents;
    public  List<ParseObject> personObjList;
    public EditText searchinput;
    public ImageButton dosearch;
    public ArrayList<String> searcharray;
    public String currentId;
    public ParseObject event;
    SwipeRefreshLayout swipeRefresh;
    ListView attendeeList;
    TextView attendeeEmptyText;

    // TODO: Rename and change types of parameters

    private OnFragmentInteractionListener mListener;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment AttendeeFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static AttendeeFragment newInstance(String param1, String param2) {
        AttendeeFragment fragment = new AttendeeFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public AttendeeFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
        }
        //loadAttendee();
    }

    public void setAdapter(final List results)
    {
        if(results.size() == 0) {
            listEmpty();
            return;
        }
        AttendeeAdapter adapter = new AttendeeAdapter(getActivity(), results);
        attendeeEmptyText.setVisibility(View.INVISIBLE);
        attendeeList.setVisibility(View.VISIBLE);
        attendeeList.setAdapter(adapter);

        attendeeList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //Toast.makeText(HomeActivity.this, "home event item selected " + position, Toast.LENGTH_SHORT).show();

                ParseObject person = personObjList.get(position);
                Intent intent = new Intent(getActivity(), PeopleDetailActivity.class);
                intent.putExtra("personID", person.getObjectId());
                startActivity(intent);
            }
        });
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_attendee, container, false);

        searchinput = (EditText)view.findViewById(R.id.searchinput);
        dosearch = (ImageButton)view.findViewById(R.id.dosearch);
        dosearch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setSearchString();
                event = ParseObject.createWithoutData("Event", currentId);
                getPeopleSearch(event, searcharray);
            }
        });
        searchinput.addTextChangedListener(new TextWatcher() {
            @Override
            public void afterTextChanged(Editable s) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start,
                                          int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start,
                                      int before, int count) {
                if (s.length() == 0) {
                    searcharray.clear();
                    event = ParseObject.createWithoutData("Event", currentId);
                    getPeople(event);
                }
            }
        });
        swipeRefresh = (SwipeRefreshLayout) view.findViewById(R.id.pulltorefresh);
        swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                loadAttendee();
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
        loadAttendee();
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser)
        {
            ((EventWrapperActivity) getActivity()).setTitleByFragment(2, null);
        }
    }

    public void loadAttendee() {
        attendeeList = (ListView)getActivity().findViewById(R.id.attendeeListView);
        attendeeEmptyText = (TextView) getActivity().findViewById(R.id.attendeeempty);
        searcharray = new ArrayList<String>();
        savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
        currentId = savedEvents.getString("currenteventid", "");

        event = ParseObject.createWithoutData("Event", currentId);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Person");
        query.whereEqualTo("events", event);
        query.include("User");
        query.orderByAscending("last_name");
        query.setLimit(1000);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "attendee query result: " + objects.size());
                    personObjList = objects;
                    setAdapter(objects);
                    swipeRefresh.setRefreshing(false);
                } else {
                    Log.d("cm_app", "attendee query error: " + e);
                    listEmpty();
                }
            }
        });
    }

    public void listEmpty()
    {
        attendeeEmptyText.setVisibility(View.VISIBLE);
        attendeeList.setVisibility(View.INVISIBLE);
    }

    public void setSearchString()
    {
        String raw_input = searchinput.getText().toString();
        String lower_raw = raw_input.toLowerCase();
        String [] split_string = lower_raw.split("\\s+");
        searcharray = new ArrayList<String>(Arrays.asList(split_string));
    }

    public void getPeople(ParseObject event)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Person");
        query.whereEqualTo("events", event);
        query.include("User");
        query.orderByAscending("last_name");
        query.setLimit(1000);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "attendee query result: " + objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "attendee query error: " + e);
                }
            }
        });
    }

    public void getPeopleSearch(ParseObject event, List<String> searchArray)
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Person");
        query.whereEqualTo("events", event);
        query.include("User");
        query.orderByAscending("last_name");
        query.setLimit(1000);
        if (searchArray.size()>0)
        {
            query.whereContainsAll("words", searchArray);
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "attendee query result: " + objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "attendee query error: " + e);
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
    /*
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        public void onFragmentInteraction(String string);
        public void functionone();
        public void functiontwo();
    }
    */

}
