package com.ashvale.uiucalum;

import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.TextView;

import com.ashvale.uiucalum.adapter.StreamListAdapter;
import com.ashvale.uiucalum.data.YoutubeHelper;
import com.ashvale.uiucalum.data.YoutubeVideoItem;

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
        ListView streamListView = (ListView) findViewById(R.id.streamListView);
        TextView emptyLabel = (TextView) findViewById(R.id.streamempty);
        if (results.size()!=0) {
            emptyLabel.setVisibility(View.INVISIBLE);
            streamListView.setVisibility(View.VISIBLE);
            StreamListAdapter adapter = new StreamListAdapter(this, results);
            streamListView.setAdapter(adapter);
            streamListView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    YoutubeVideoItem videoItem = results.get(position);
                    String vid = videoItem.getId();
                    openPlayerWithId(vid);
                }
            });
        } else {
            streamListView.setVisibility(View.INVISIBLE);
            emptyLabel.setVisibility(View.VISIBLE);
        }
    }

    private void openPlayerWithId(String videoId)
    {
        /*
        //String placeholder = "UUFlgARr_pQ";
        Intent intent = new Intent(this, YoutubePlayerActivity.class);
        intent.putExtra("selectedId", videoId);
        //intent.putExtra("selectedId", placeholder);
        Log.d("cm_app", "streaming video id: "+videoId);
        startActivity(intent);
        */
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:" + videoId));
        intent.putExtra("VIDEO_ID", videoId);
        startActivity(intent);
    }
}
