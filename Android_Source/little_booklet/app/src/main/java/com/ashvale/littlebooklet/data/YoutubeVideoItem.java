package com.ashvale.littlebooklet.data;

/**
 * Created by csjan on 3/21/16.
 */
public class YoutubeVideoItem {
    private String title;
    private String description;
    private String thumbnailURL;
    private String vid;
    private String liveStatus;

    public String getId() {
        return vid;
    }

    public void setId(String id) {
        this.vid = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getThumbnailURL() {
        return thumbnailURL;
    }

    public void setThumbnailURL(String thumbnail) {
        this.thumbnailURL = thumbnail;
    }

    public void setLiveStatus(String liveStatus) { this.liveStatus = liveStatus; }

    public String getLiveStatus() {return liveStatus; }
}
