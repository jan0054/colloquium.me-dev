package com.ashvale.cmmath_one;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import com.parse.ParseException;
import com.parse.ParseUser;
import com.parse.RequestPasswordResetCallback;

public class ResetPasswordActivity extends Activity {

    public static final String TAG = ResetPasswordActivity.class.getSimpleName();
    private EditText mUsername;
    private Button   btnResetPwd;
    private Button   btnCancel;


    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_reset_password);
        mUsername 	= (EditText) findViewById(R.id.username);
        btnResetPwd   = (Button) findViewById(R.id.btn_resetpwd);
        btnCancel   = (Button) findViewById(R.id.btn_cancel);
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    public void toast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public void resetpwd(View view) {
        btnResetPwd.setEnabled(false);
        String username     = mUsername.getText().toString();
        if (username.isEmpty()) {
            toast("Please fill in all fields");
            btnResetPwd.setEnabled(true);
            return;
        }

        ParseUser.requestPasswordResetInBackground(username, new RequestPasswordResetCallback() {
            public void done(ParseException e) {
                if (e == null) {
                    // An email was successfully sent with reset instructions.
                    toLoginPage();
                } else {
                    // Something went wrong. Look at the ParseException to see what's up.
                    Log.d("cm_app", "Reset Pwd: " + "failed" + e.getMessage());
                    onResetFailed(e.getCode(), e.getMessage());
                }
            }
        });
    }

    private void onResetFailed(int code, String msg) {
        toast("Error (" + code + "): " + msg + "!");
        btnResetPwd.setEnabled(true);
    }

    private void toLoginPage() {
        Toast.makeText(this, getString(R.string.resetpwd_message), Toast.LENGTH_LONG).show();
        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
        finish();
    }

    public void toLoginPage(View view) {
        Intent intent = new Intent(this, LoginActivity.class);
        startActivity(intent);
        finish();
    }
}
