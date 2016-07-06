package com.ashvale.uiucalum;

import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.LabeledIntent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;

import com.ashvale.uiucalum.adapter.SettingAdapter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;


public class SettingsActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        super.onCreateDrawer();

        SettingAdapter adapter = new SettingAdapter(this);
        ListView settinglist = (ListView)findViewById(R.id.settingListView);
        settinglist.setAdapter(adapter);
        settinglist.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position,
                                    long id) {
                //Toast.makeText(SettingsActivity.this, "Setting item selected:" + position, Toast.LENGTH_SHORT).show();
                switch (position)
                {
                    case 0:
                        break;
                    case 1:
                        //feedback mail
                        try {
                            sendEmail("", "", new String[]{getResources().getString(R.string.feedback_email_address)}, null);
                        } catch (Exception e){
                            e.getStackTrace();
                        }
                        break;
                    case 2:
                        //browser: privacy page
                        Intent privacyWeb = new Intent(Intent.ACTION_VIEW,Uri.parse(getResources().getString(R.string.privacy_url)));
                        startActivity(privacyWeb);
                        break;
                    case 3:
                        //browser: about us page
                        Intent aboutusWeb = new Intent(Intent.ACTION_VIEW,Uri.parse(getResources().getString(R.string.aboutus_url)));
                        startActivity(aboutusWeb);
                        break;
                    case 4:
                        //tutorial page
                        Intent intentTut = new Intent(SettingsActivity.this, IntroActivity.class);
                        intentTut.putExtra("src", "settings");
                        startActivity(intentTut);
                        finish();
                        break;
                    case 5:
                        //preference page
                        Intent intent = new Intent(SettingsActivity.this, UserPreferenceActivity.class);
                        intent.putExtra("src", "settings");
                        startActivity(intent);
                        break;
                }
            }
        });
    }

    /*
    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_settings, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();



        return super.onOptionsItemSelected(item);
    }
    */
    private void sendEmail(String title, String content, String[] emails, Uri imageUri) throws IOException {

        Intent emailIntent = new Intent();
        emailIntent.setAction(Intent.ACTION_SEND);
        emailIntent.setType("application/image");
        if (imageUri != null) {
            emailIntent.putExtra(Intent.EXTRA_STREAM, imageUri);
        }
        Intent openInChooser = Intent.createChooser(emailIntent, "Share");

        // Extract all package labels
        PackageManager pm = this.getPackageManager();

        Intent sendIntent = new Intent(Intent.ACTION_SEND);
        sendIntent.setType("text/plain");

        List<ResolveInfo> resInfo = pm.queryIntentActivities(sendIntent, 0);
        List<LabeledIntent> intentList = new ArrayList<LabeledIntent>();

        for (int i = 0; i < resInfo.size(); i++) {
            ResolveInfo ri = resInfo.get(i);
            String packageName = ri.activityInfo.packageName;
            // Append and repackage the packages we want into a LabeledIntent
            if(packageName.contains("android.email")) {
                emailIntent.setPackage(packageName);
            } else if (packageName.contains("android.gm")) 	{
                Intent intent = new Intent();
                intent.setComponent(new ComponentName(packageName, ri.activityInfo.name));
                intent.setAction(Intent.ACTION_SEND);
                intent.setType("text/plain");
                intent.putExtra(Intent.EXTRA_EMAIL,  emails);
                intent.putExtra(Intent.EXTRA_SUBJECT, title);
                intent.putExtra(Intent.EXTRA_TEXT, content);
                if (imageUri != null) {
                    intent.setType("message/rfc822");
                    intent.putExtra(Intent.EXTRA_STREAM, imageUri);
                }
                intentList.add(new LabeledIntent(intent, packageName, ri.loadLabel(pm), ri.icon));
            }
        }
        // convert intentList to array
        LabeledIntent[] extraIntents = intentList.toArray( new LabeledIntent[ intentList.size() ]);

        openInChooser.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraIntents);
        startActivity(openInChooser);

    }

}
