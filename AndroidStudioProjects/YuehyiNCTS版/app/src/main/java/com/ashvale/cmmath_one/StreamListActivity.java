package com.ashvale.cmmath_one;

import android.content.Intent;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.ashvale.cmmath_one.adapter.StreamListAdapter;
import com.ashvale.cmmath_one.data.YoutubeHelper;
import com.ashvale.cmmath_one.data.YoutubeVideoItem;
import com.google.api.services.youtube.YouTube;

import java.util.List;

public class StreamListActivity extends BaseActivity {
    SwipeRefreshLayout swipeRefresh;
    private List<YoutubeVideoItem> ytResults;
    public Handler handler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stream_list);
        super.onCreateDrawer();
        handler = new Handler();
        getStreams();

        swipeRefresh = (SwipeRefreshLayout) findViewById(R.id.pulltorefresh);
        swipeRefresh.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                getStreams();
            }
        });
    }

    private void getStreams()
    {
        new Thread(){
            public void run(){
                YoutubeHelper ythelper = new YoutubeHelper(StreamListActivity.this);
                ytResults = ythelper.channelSearch();
                handler.post(new Runnable(){
                    public void run(){
                        setAdapter(ytResults);
                        swipeRefresh.setRefreshing(false);
                    }
                });
            }
        }.start();
    }

    private void setAdapter(final List<YoutubeVideoItem> results)
    {
        StreamListAdapter adapter = new StreamListAdapter(this, results);
        ListView streamListView = (ListView)findViewById(R.id.streamListView);
        streamListView.setAdapter(adapter);
        streamListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                YoutubeVideoItem videoItem = results.get(position);
                String vid = videoItem.getId();
                openPlayerWithId(vid);
            }
        });
    }

    private void openPlayerWithId(String videoId)
    {
        Intent intent = new Intent(this, YoutubePlayerActivity.class);
        intent.putExtra("selectedId", videoId);
        startActivity(intent);
    }
}
