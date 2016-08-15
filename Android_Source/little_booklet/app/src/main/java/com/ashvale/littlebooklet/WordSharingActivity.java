package com.ashvale.littlebooklet;

import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.view.ViewPager;
import android.widget.Toast;

import com.ashvale.littlebooklet.adapter.SharingViewPagerAdapter;
import com.ashvale.littlebooklet.fragments.BaseFragment;

public class WordSharingActivity extends BaseActivity implements BaseFragment.OnFragmentInteractionListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_word_sharing);
        super.onCreateDrawer();

        getSupportActionBar().setTitle(getString(R.string.share_title));

        ViewPager viewPager = (ViewPager) findViewById(R.id.viewpager);
        viewPager.setAdapter(new SharingViewPagerAdapter(getFragmentManager(), WordSharingActivity.this));
        viewPager.setOffscreenPageLimit(1);
        TabLayout tabLayout = (TabLayout) findViewById(R.id.sliding_tabs);
        tabLayout.setTabMode(TabLayout.MODE_FIXED);
        tabLayout.setupWithViewPager(viewPager);
        tabLayout.getTabAt(0).setText(getString(R.string.share_search_tab));
        tabLayout.getTabAt(1).setText(getString(R.string.share_upload_tab));
    }

    @Override
    public void onFragmentInteraction(String fragmentstring, String tag)
    {
        Toast.makeText(WordSharingActivity.this, "Fragment Passed Data: " + fragmentstring, Toast.LENGTH_SHORT).show();
    }





}