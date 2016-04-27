package com.ashvale.cmmath_one.fragments;

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
import android.widget.Toast;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;
import com.parse.SaveCallback;

/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link WordUploadFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link WordUploadFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class WordUploadFragment extends BaseFragment {
    private OnFragmentInteractionListener mListener;
    private EditText searchInput1;
    private EditText searchInput2;
    private EditText searchInput3;
    private EditText uploadInputContent;
    private Menu searchMenu;

    public WordUploadFragment() {
        // Required empty public constructor
    }

    public static WordUploadFragment newInstance() {
        WordUploadFragment fragment = new WordUploadFragment();
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
        View view = inflater.inflate(R.layout.fragment_word_upload, container, false);
        searchInput1 = (EditText)view.findViewById(R.id.upload_input_1);
        searchInput2 = (EditText)view.findViewById(R.id.upload_input_2);
        searchInput3 = (EditText)view.findViewById(R.id.upload_input_3);
        uploadInputContent = (EditText)view.findViewById(R.id.upload_input_content);
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

    private void doUploadWithWords(String word1, String word2, String word3, String content) {
        ParseObject object = new ParseObject("Shared");
        object.put("type", 0);
        object.put("word1", word1);
        object.put("word2", word2);
        object.put("word3", word3);
        object.put("content", content);
        object.saveInBackground(new SaveCallback() {
            @Override
            public void done(com.parse.ParseException e) {
                if (e == null) {
                    Log.d("cm_app", "sharing upload success");
                    toast(getString(R.string.upload_success));
                } else {
                    Log.d("cm_app", "sharing upload error: " + e);
                }
            }
        });
    }

    private void tappedUpload() {
        String word1 = searchInput1.getText().toString();
        String word2 = searchInput2.getText().toString();
        String word3 = searchInput3.getText().toString();
        String toShare = uploadInputContent.getText().toString();
        if (word2.length() == 0)
        {
            word2 = "";
        }
        if (word3.length() == 0)
        {
            word3 = "";
        }
        if (word1.length()>0 && toShare.length()>0)
        {
            doUploadWithWords(word1, word2, word3, toShare);
        }
    }

    public void toast(String message) {
        Toast.makeText(this.getActivity(), message, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.menu_sharing_upload, menu);
        this.searchMenu = menu;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.sharing_upload:
                tappedUpload();
                return true;
            default:
                return true;
        }
    }
}
