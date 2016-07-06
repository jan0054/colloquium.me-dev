package com.ashvale.uiucalum.fragments;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ListView;

import com.ashvale.uiucalum.R;
import com.ashvale.uiucalum.adapter.SharingSearchResultsAdapter;
import com.parse.FindCallback;
import com.parse.ParseObject;
import com.parse.ParseQuery;

import java.util.List;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link WordReceiveFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link WordReceiveFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class WordReceiveFragment extends BaseFragment {

    private OnFragmentInteractionListener mListener;
    private EditText searchInput1;
    private EditText searchInput2;
    private EditText searchInput3;
    private ListView resultList;
    private Menu searchMenu;

    public WordReceiveFragment() {
        // Required empty public constructor
    }

    public static WordReceiveFragment newInstance() {
        WordReceiveFragment fragment = new WordReceiveFragment();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_word_receive, container, false);
        searchInput1 = (EditText)view.findViewById(R.id.search_input_1);
        searchInput2 = (EditText)view.findViewById(R.id.search_input_2);
        searchInput3 = (EditText)view.findViewById(R.id.search_input_3);
        resultList = (ListView)view.findViewById(R.id.resultListView);
        return view;
    }

    //factory method
    public void onButtonPressed(Uri uri) {
        if (mListener != null) {
            mListener.onFragmentInteraction(uri);
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        /*
        if (context instanceof OnFragmentInteractionListener) {
            mListener = (OnFragmentInteractionListener) context;
        } else {
            throw new RuntimeException(context.toString()
                    + " must implement OnFragmentInteractionListener");
        }
        */
    }


    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnFragmentInteractionListener {
        void onFragmentInteraction(Uri uri);
    }

    private void tappedSearch() {
        String word1 = searchInput1.getText().toString();
        String word2 = searchInput2.getText().toString();
        String word3 = searchInput3.getText().toString();
        if (word2.length() == 0)
        {
            word2 = "";
        }
        if (word3.length() == 0)
        {
            word3 = "";
        }
        if (word1.length() > 0)
        {
            doSearchWithWords(word1, word2, word3);
        }
    }

    private void doSearchWithWords(String word1, String word2, String word3) {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("Shared");
        query.whereEqualTo("word1", word1);
        query.whereEqualTo("word2", word2);
        query.whereEqualTo("word3", word3);
        query.orderByAscending("createdAt");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "sharing search results: " + objects.size());
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "sharing search error: " + e);
                }
            }
        });
    }

    public void setAdapter(final List<ParseObject> results) {
        if (results.size()!=0) {
            SharingSearchResultsAdapter adapter = new SharingSearchResultsAdapter(getActivity(), results);
            resultList.setAdapter(adapter);
        }
        else {
            //empty
        }
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_sharing_search, menu);
        this.searchMenu = menu;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.sharing_search:
                tappedSearch();
                return true;
            default:
                return true;
        }
    }
}
