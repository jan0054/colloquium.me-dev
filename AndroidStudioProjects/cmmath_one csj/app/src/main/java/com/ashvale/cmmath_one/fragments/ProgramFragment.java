package com.ashvale.cmmath_one.fragments;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;

import com.ashvale.cmmath_one.PostDetailActivity;
import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.TalkDetailActivity;
import com.ashvale.cmmath_one.adapter.AttendeeAdapter;
import com.ashvale.cmmath_one.adapter.ProgramAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link ProgramFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link ProgramFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class ProgramFragment extends BaseFragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    private SharedPreferences savedEvents;
    public  List<ParseObject> talkObjList;
    public EditText searchinput;
    public ImageButton dosearch;
    public ArrayList<String> searcharray;
    public String currentId;
    public ParseObject event;
    ListView talkList;

    // TODO: Rename and change types of parameters

    private OnFragmentInteractionListener mListener;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment ProgramFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static ProgramFragment newInstance(String param1, String param2) {
        ProgramFragment fragment = new ProgramFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public ProgramFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
        }
        //loadProgram();
    }

    public void setAdapter(final List results)
    {
        ProgramAdapter adapter = new ProgramAdapter(getActivity(), results);
        talkList = (ListView)getActivity().findViewById(R.id.programListView);
        talkList.setAdapter(adapter);

        talkList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //Toast.makeText(HomeActivity.this, "home event item selected " + position, Toast.LENGTH_SHORT).show();

                ParseObject talk = talkObjList.get(position);
                Intent intent = new Intent(getActivity(), TalkDetailActivity.class);
                intent.putExtra("talkID", talk.getObjectId());
                startActivity(intent);
            }
        });
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_program, container, false);
        searchinput = (EditText)view.findViewById(R.id.searchinput);
        dosearch = (ImageButton)view.findViewById(R.id.dosearch);
        dosearch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setSearchString();
                event = ParseObject.createWithoutData("Event", currentId);
                getProgramSearch(event, 0, searcharray, 0);
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
                    getProgram(event, 0, 0);
                }
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
        loadProgram();
    }

    public void loadProgram() {
        searcharray = new ArrayList<String>();
        savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
        currentId = savedEvents.getString("currenteventid", "");

        event = ParseObject.createWithoutData("Event", currentId);

        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
        innerQuery.whereEqualTo("objectId", currentId);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Talk");
        query.whereMatchesQuery("event", innerQuery);
        query.include("author");
        query.include("session");
        query.include("location");
        //type = 0 for talk, =1 for poster, can add others in future if needed
        query.whereEqualTo("type", 0);
        query.orderByDescending("start_time");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "program query result: " + objects.size());
                    talkObjList = objects;
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "program query error: " + e);
                }
            }
        });
    }

    public void setSearchString()
    {
        String raw_input = searchinput.getText().toString();
        String lower_raw = raw_input.toLowerCase();
        String [] split_string = lower_raw.split("\\s+");
        searcharray = new ArrayList<String>(Arrays.asList(split_string));
    }

    public void getProgram(ParseObject event, int type, int order)
    {
        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
        innerQuery.whereEqualTo("objectId", currentId);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Talk");
        query.whereMatchesQuery("event", innerQuery);
        query.include("author");
        query.include("session");
        query.include("location");
        //type = 0 for talk, =1 for poster, can add others in future if needed
        query.whereEqualTo("type", type);
        //order = 0 start_time, order = 1 name, can add others in future if needed
        if (order == 0)
        {
            query.orderByDescending("start_time");
        }
        else if (order==1)
        {
            query.orderByDescending("name");
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "program query result: "+ objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "program query error: " + e);
                }
            }
        });
    }

    public void getProgramSearch(ParseObject event, int type, List<String> searchArray, int order)
    {
        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
        innerQuery.whereEqualTo("objectId", currentId);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Talk");
        query.whereMatchesQuery("event", innerQuery);
        query.include("author");
        query.include("session");
        query.include("location");
        //type = 0 for talk, =1 for poster, can add others in future if needed
        query.whereEqualTo("type", type);
        //order = 0 start_time, order = 1 name, can add others in future if needed
        if (order == 0)
        {
            query.orderByDescending("start_time");
        }
        else if (order==1)
        {
            query.orderByDescending("name");
        }
        if (searchArray.size()>0)
        {
            query.whereContainsAll("words", searchArray);
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "program query result: "+ objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "program query error: " + e);
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


}
