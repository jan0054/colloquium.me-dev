package com.ashvale.cmmath_one.adapter;

import android.app.Fragment;
import android.app.FragmentManager;
import android.content.Context;
import android.support.v13.app.FragmentPagerAdapter;
import com.ashvale.cmmath_one.fragments.AttendeeFragment;
import com.ashvale.cmmath_one.fragments.OverviewFragment;
import com.ashvale.cmmath_one.fragments.WordReceiveFragment;
import com.ashvale.cmmath_one.fragments.WordUploadFragment;

/**
 * Created by csjan on 4/25/16.
 */
public class SharingViewPagerAdapter extends FragmentPagerAdapter {
    final int PAGE_COUNT = 2;
    private String tabTitles[] = new String[] { "Receive", "Upload" };
    private Context context;

    public SharingViewPagerAdapter(FragmentManager fm, Context context) {
        super(fm);
        this.context = context;
    }

    @Override
    public int getCount() {
        return PAGE_COUNT;
    }

    @Override
    public Fragment getItem(int position) {
        switch (position)
        {
            case 0:
                return WordReceiveFragment.newInstance();

            case 1:
                return WordUploadFragment.newInstance();
            default:
                return null;
        }
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return null;
    }
}
