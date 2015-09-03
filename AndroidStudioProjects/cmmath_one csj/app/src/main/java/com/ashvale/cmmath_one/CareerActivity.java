package com.ashvale.cmmath_one;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.Toast;
import com.ashvale.cmmath_one.R;
import com.ashvale.cmmath_one.adapter.CareerAdapter;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import java.util.ArrayList;
import java.util.List;

public class CareerActivity extends BaseActivity
{

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_career);
        super.onCreateDrawer();

        ParseQuery<ParseObject> query = ParseQuery.getQuery("Career");
        query.orderByDescending("createdAt");
        query.include("author");
        query.setCachePolicy(ParseQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.findInBackground(new FindCallback<ParseObject>() {
            public void done(List<ParseObject> objects, com.parse.ParseException e) {
                if (e == null) {
                    setAdapter(objects);
                } else {
                    Log.d("cm_app", "career query error: "+e);
                }
            }
        });
    }

    public void setAdapter(final List results)
    {
        CareerAdapter adapter = new CareerAdapter(this, results);
        ListView careerListView = (ListView)findViewById(R.id.careerListView);
        careerListView.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
        careerListView.setAdapter(adapter);
    }

}
