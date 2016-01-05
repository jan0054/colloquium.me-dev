package com.ashvale.cmmath_one;

import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.LabeledIntent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.URLUtil;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import com.ashvale.cmmath_one.R;
import com.parse.ParseObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class CareerDetailActivity extends DetailActivity {

    public String institute;
    public String contactName;
    public String contactMail;
    public String contentString;
    public String contactLink;
    protected static boolean isChat = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_career_detail);

        super.onCreateView();

        institute = this.getIntent().getExtras().getString("inst");
        contactName = this.getIntent().getExtras().getString("name");
        contactMail = this.getIntent().getExtras().getString("mail");
        contactLink = this.getIntent().getExtras().getString("link");
        contentString = this.getIntent().getExtras().getString("content");

        TextView instLabel = (TextView)findViewById(R.id.inst_label);
        TextView nameLabel = (TextView)findViewById(R.id.contact_name_label);
        TextView contentLabel = (TextView)findViewById(R.id.content_label);
        TextView sendMail = (TextView)findViewById(R.id.email_button);
        TextView openBrowswer = (TextView)findViewById(R.id.web_button);

        sendMail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    sendEmail("", "", new String[]{contactMail}, null);
                } catch (Exception e){
                    e.getStackTrace();
                }
            }
        });

        openBrowswer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(contactLink != null && URLUtil.isValidUrl(contactLink)==true) {
                    Intent ie = new Intent(Intent.ACTION_VIEW, Uri.parse(contactLink));
                    startActivity(ie);
                } else {
                    toast(getString(R.string.error_invalidlink));
                }
            }
        });

        instLabel.setText(institute);
        nameLabel.setText(contactName);
        contentLabel.setText(contentString);


    }



    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_career_detail, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show();
    }

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
