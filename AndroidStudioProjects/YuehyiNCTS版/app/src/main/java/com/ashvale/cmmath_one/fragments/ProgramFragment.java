package com.ashvale.cmmath_one.fragments;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;

import com.ashvale.cmmath_one.EventWrapperActivity;
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
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
    private List<ParseObject> sessionList;
    private ParseObject currentFilter;
    private Menu filterMenu;
    SwipeRefreshLayout swipeRefresh;
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
        setHasOptionsMenu(true);
        currentFilter = null;
    }

    public void setAdapter(final List<Integer> headers, final List<ParseObject> objects)
    {
        ProgramAdapter adapter = new ProgramAdapter(getActivity(), headers, objects);
        talkList.setAdapter(adapter);

        talkList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Log.d("cm_app", "Adapter onclick: " + position);
                if (headers.contains(position)) {
                    // Is header, do nothing
                    Log.d("cm_app", "Adapter onclick header: " + position);
                } else   // Normal row
                {
                    Log.d("cm_app", "Adapter onclick normal row: " + position);
                    ParseObject talk = objects.get(position);
                    Intent intent = new Intent(getActivity(), TalkDetailActivity.class);
                    intent.putExtra("talkID", talk.getObjectId());
                    startActivity(intent);
                }
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
                getProgramSearch(0, searcharray, 0);
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
                    loadProgram();
                }
            }
        });
        swipeRefresh = (SwipeRefreshLayout) view.findViewById(R.id.pulltorefresh);
        swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                loadProgram();
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

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser)
        {
            ((EventWrapperActivity) getActivity()).setTitleByFragment(1, null);
        }
    }

    public void loadProgram()
    {
        talkList = (ListView)getActivity().findViewById(R.id.programListView);
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
        query.orderByAscending("start_time");
        if (currentFilter != null)
        {
            query.whereEqualTo("session", currentFilter);
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "program query result: " + objects.size());
                    processPrograms(objects);
                    swipeRefresh.setRefreshing(false);
                } else {
                    Log.d("cm_app", "program query error: " + e);
                }
            }
        });
    }

    public void processPrograms(List<ParseObject> programs)
    {
        List<ParseObject> finalOutput = new ArrayList<>();
        List<Integer> finalHeaderPositions = new ArrayList<>();
        ParseObject previousProgramHolder = new ParseObject("talk");

        if (programs.size()>0)
        {
            previousProgramHolder = programs.get(0);
            finalOutput.add(programs.get(0));
            finalHeaderPositions.add(0);
        }

        for (ParseObject program : programs)
        {
            Date startDate = program.getDate("start_time");
            Calendar cal = Calendar.getInstance();
            cal.setTime(startDate);
            int day = cal.get(Calendar.DAY_OF_MONTH);

            Date prevDate = previousProgramHolder.getDate("start_time");
            cal.setTime(prevDate);
            int prevDay = cal.get(Calendar.DAY_OF_MONTH);

            if (day != prevDay)
            {
                finalHeaderPositions.add(finalOutput.size());
                finalOutput.add(program);
            }
            finalOutput.add(program);

            previousProgramHolder = program;
        }

        Log.d("cm_app", "processPrograms: finalOutputList" + finalOutput);
        Log.d("cm_app", "processPrograms: finalHeaderPositions" + finalHeaderPositions);
        setAdapter(finalHeaderPositions, finalOutput);
    }

    public void setSearchString()
    {
        String raw_input = searchinput.getText().toString();
        String lower_raw = raw_input.toLowerCase();
        String [] split_string = lower_raw.split("\\s+");
        searcharray = new ArrayList<String>(Arrays.asList(split_string));
        Log.d("cm_app", "Search array constructed as: " + searcharray);
    }

    public void getProgramSearch(int type, List<String> searchArray, int order)
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
            query.orderByAscending("start_time");
        }
        else if (order==1)
        {
            query.orderByDescending("name");
        }
        if (searchArray.size()>0)
        {
            query.whereContainsAll("words", searchArray);
        }
        if (currentFilter != null)
        {
            query.whereEqualTo("session", currentFilter);
        }
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "program query result (with search): " + objects.size());
                    processPrograms(objects);
                    swipeRefresh.setRefreshing(false);
                } else {
                    Log.d("cm_app", "program query error (with search): " + e);
                }
            }
        });
    }

    private void getSessions()
    {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Session");
        query.whereEqualTo("event", event);
        query.orderByDescending("name");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "session query result: " + objects.size());
                    constructFilterMenu(objects);
                    sessionList = objects;
                } else {
                    Log.d("cm_app", "session query error: " + e);
                }
            }
        });
    }

    private void constructFilterMenu(List<ParseObject> sessions)
    {
        int sessionCount = sessions.size();
         for (int i = 0 ; i < sessionCount ; i++ )
         {
             ParseObject session = sessions.get(i);
             String name = session.getString("name");
             filterMenu.add(0, i, i+1, name);
         }
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_program_filter, menu);
        this.filterMenu = menu;
        getSessions();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {

            case R.id.filter_all:
                Log.d("cm_app", "Menu id: all");
                currentFilter = null;
                if (searcharray.size() > 0)
                {
                    getProgramSearch(0, searcharray, 0);
                }
                else
                {
                    loadProgram();
                }
                ((EventWrapperActivity) getActivity()).setTitleByFragment(1, null);
                return true;

            default:
                Log.d("cm_app", "Menu id: " + item.getItemId());
                currentFilter = sessionList.get(item.getItemId());
                if (searcharray.size() > 0)
                {
                    getProgramSearch(0, searcharray, 0);
                }
                else
                {
                    loadProgram();
                }
                String name = currentFilter.getString("name");
                ((EventWrapperActivity) getActivity()).setTitleByFragment(1, name);
                return super.onOptionsItemSelected(item);
        }
    }

}
