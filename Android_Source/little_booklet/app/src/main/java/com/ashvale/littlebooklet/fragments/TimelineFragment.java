package com.ashvale.littlebooklet.fragments;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.ashvale.littlebooklet.EventWrapperActivity;
import com.ashvale.littlebooklet.PostDetailActivity;
import com.ashvale.littlebooklet.R;
import com.ashvale.littlebooklet.adapter.TimelineAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link TimelineFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link TimelineFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class TimelineFragment extends BaseFragment {
    // TODO: Rename parameter arguments, choose names that match
    // the fragment initialization parameters, e.g. ARG_ITEM_NUMBER
    public static final String TAG = TimelineFragment.class.getSimpleName();
    private SharedPreferences savedEvents;
    public  List<ParseObject> postObjList;
    SwipeRefreshLayout swipeRefresh;
    ListView postList;
    TextView postEmptyText;

    // TODO: Rename and change types of parameters

    private OnFragmentInteractionListener mListener;

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @return A new instance of fragment TimelineFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static TimelineFragment newInstance(String param1, String param2) {
        TimelineFragment fragment = new TimelineFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    public TimelineFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
        }
        loadTimeline();
    }

    public void setAdapter(final List results)
    {
        if(results.size()==0) {
            listEmpty();
            return;
        }
        postList.setVisibility(View.VISIBLE);
        postEmptyText.setVisibility(View.INVISIBLE);
        TimelineAdapter adapter = new TimelineAdapter(getActivity(), results);
        postList.setAdapter(adapter);

        postList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                //Toast.makeText(HomeActivity.this, "home event item selected " + position, Toast.LENGTH_SHORT).show();

                ParseObject post = postObjList.get(position);
                Intent intent = new Intent(getActivity(), PostDetailActivity.class);
                intent.putExtra("postID", post.getObjectId());
                startActivity(intent);
            }
        });
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View view = inflater.inflate(R.layout.fragment_timeline, container, false);
        swipeRefresh = (SwipeRefreshLayout) view.findViewById(R.id.pulltorefresh);
        swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                loadTimeline();
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
        loadTimeline();
    }

    @Override
    public void setUserVisibleHint(boolean isVisibleToUser) {
        super.setUserVisibleHint(isVisibleToUser);
        if (isVisibleToUser)
        {
            ((EventWrapperActivity) getActivity()).setTitleByFragment(3, null);
        }
    }

    public void loadTimeline() {
        postList = (ListView)getActivity().findViewById(R.id.timelineListView);
        postEmptyText = (TextView)getActivity().findViewById(R.id.timelineempty);
        savedEvents = getActivity().getSharedPreferences("EVENTS", 0);
        String currentId = savedEvents.getString("currenteventid", "");

        ParseQuery<ParseObject> innerQuery = ParseQuery.getQuery("Event");
        innerQuery.whereEqualTo("objectId", currentId);

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Post");
        query.orderByDescending("createdAt");
        query.whereMatchesQuery("event", innerQuery);
        query.include("author");
        query.setLimit(1000);
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "timeline query result: " + objects.size());
                    postObjList = objects;
                    setAdapter(objects);
                    swipeRefresh.setRefreshing(false);
                } else {
                    Log.d("cm_app", "timeline query error: " + e);
                    listEmpty();
                }
            }
        });
    }

    public void listEmpty()
    {
        postEmptyText.setVisibility(View.VISIBLE);
        postList.setVisibility(View.INVISIBLE);
    }
}
