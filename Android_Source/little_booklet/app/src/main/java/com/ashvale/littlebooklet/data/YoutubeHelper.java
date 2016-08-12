package com.ashvale.littlebooklet.data;

import android.content.Context;
import android.util.Log;

import com.ashvale.littlebooklet.R;
import com.google.api.client.http.HttpRequest;
import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.youtube.YouTube;
import com.google.api.services.youtube.model.SearchListResponse;
import com.google.api.services.youtube.model.SearchResult;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by csjan on 3/21/16.
 */
public class YoutubeHelper {
    private YouTube youtube;
    private YouTube.Search.List query;

    public static final String KEY
            = "AIzaSyCyA3EXv5cl3bMfnFvwhg5SNRT5cjExb0c";

    public YoutubeHelper(Context context) {
        youtube = new YouTube.Builder(new NetHttpTransport(),
                new JacksonFactory(), new HttpRequestInitializer() {
            @Override
            public void initialize(HttpRequest hr) throws IOException {}
        }).setApplicationName(context.getString(R.string.app_name)).build();

        try{
            query = youtube.search().list("id,snippet");
            query.setKey(KEY);
            query.setType("video");
            query.setChannelId("UCqiUSoddzJL3MZqr_Wr_96w");
            query.setOrder("date");
            query.setFields("items(id/videoId,snippet/title,snippet/description,snippet/thumbnails/default/url, snippet/liveBroadcastContent)");
        }catch(IOException e){
            Log.d("cm_app", "Could not initialize youtube library" + e);
        }
    }

    public List<YoutubeVideoItem> channelSearch(){
        //query.setQ("keywords");
        try{
            SearchListResponse response = query.execute();
            List<SearchResult> results = response.getItems();

            List<YoutubeVideoItem> items = new ArrayList<YoutubeVideoItem>();
            for(SearchResult result:results){
                YoutubeVideoItem item = new YoutubeVideoItem();
                item.setTitle(result.getSnippet().getTitle());
                item.setDescription(result.getSnippet().getDescription());
                item.setThumbnailURL(result.getSnippet().getThumbnails().getDefault().getUrl());
                item.setId(result.getId().getVideoId());
                item.setLiveStatus(result.getSnippet().getLiveBroadcastContent());
                items.add(item);
            }
            return items;
        }catch(IOException e){
            Log.d("cm_app", "Could not search youtube: "+e);
            return null;
        }
    }
}
