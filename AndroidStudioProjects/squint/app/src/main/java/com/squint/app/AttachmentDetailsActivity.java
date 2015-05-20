package com.squint.app;

import com.squint.app.data._PARAMS;
import com.squint.app.widget.BaseActivity;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.webkit.WebSettings.PluginState;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;


@SuppressLint("SetJavaScriptEnabled")
public class AttachmentDetailsActivity extends BaseActivity {
	
	public static final String TAG = AttachmentDetailsActivity.class.getSimpleName();
	public static final String 		ACTION_SELECT 					  	= "com.squint.action.attachment.select";
	public static final String 		EXTRA_ATTACHMENT_ID	  			  	= "com.squint.data.attachment.ID";
	public static final String 		EXTRA_ATTACHMENT_NAME	  		  	= "com.squint.data.attachment.NAME";
	public static final String 		EXTRA_ATTACHMENT_CONTENT	  	  	= "com.squint.data.attachment.CONTENT";
	public static final String 		EXTRA_ATTACHMENT_PDF			  	= "com.squint.data.attachment.PDF";
	public static final String 		EXTRA_ATTACHMENT_AUTHOR			  	= "com.squint.data.attachment.AUTHOR";
	public static final String 		EXTRA_ATTACHMENT_AUTHOR_ID		  	= "com.squint.data.attachment.AUTHOR_ID";
	public static final String 		EXTRA_ATTACHMENT_AUTHOR_INSTITUTION = "com.squint.data.attachment.AUTHOR_INSITUTION";
	public static final String 		EXTRA_ATTACHMENT_AUTHOR_EMAIL		= "com.squint.data.attachment.AUTHOR_EMAIL";
	public static final String 		EXTRA_ATTACHMENT_AUTHOR_LINK	  	= "com.squint.data.attachment.AUTHOR_LINK";
	
	private TextView 		mName;
	private TextView 		mAuthor;
	private TextView 		mDetails;
	private TextView 		mContent;
	private TextView		mPdf;
	private WebView			mPdfViewer;
		
	// ParseObject
	private static String  absId;
	private static String  authorId;
	private static String  author;
	private static String  link;
	private static String  email;
	private static String  institution;
	
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.details_attachment);
		// Header Configuration
		mTitle.setText(getString(R.string.title_section1));
		configOptions(OPTION_BACK, OPTION_NONE);
				
		mName 			= (TextView)findViewById(R.id.name);
		mAuthor	 		= (TextView)findViewById(R.id.author);
		mContent	 	= (TextView)findViewById(R.id.content);
		mDetails 		= (TextView)findViewById(R.id.author_details);
		mPdf			= (TextView)findViewById(R.id.pdf);
		mPdfViewer	 	= (WebView)findViewById(R.id.pdf_viewer);
		mPdfViewer.getSettings().setJavaScriptEnabled(true);
		mPdfViewer.getSettings().setPluginState(PluginState.ON);
		mPdfViewer.setWebViewClient(new WebViewClient() {
			@Override
	        public boolean shouldOverrideUrlLoading(WebView view, String url) {
	            return(false);
	        }
		});
        mContent.setMovementMethod(new ScrollingMovementMethod());
	}
	
	@Override
	public void onResume() {
		super.onResume();
		
		Intent intent 	= getIntent();		
		absId = intent.getStringExtra(EXTRA_ATTACHMENT_ID);
		
		authorId	= intent.getStringExtra(EXTRA_ATTACHMENT_AUTHOR_ID);
		author		= intent.getStringExtra(EXTRA_ATTACHMENT_AUTHOR);
		institution	= intent.getStringExtra(EXTRA_ATTACHMENT_AUTHOR_INSTITUTION);
		link		= intent.getStringExtra(EXTRA_ATTACHMENT_AUTHOR_LINK);
		email		= intent.getStringExtra(EXTRA_ATTACHMENT_AUTHOR_EMAIL);
		
		
		mName.setText(intent.getStringExtra(EXTRA_ATTACHMENT_NAME));
		mAuthor.setText(author);
		mContent.setText(intent.getStringExtra(EXTRA_ATTACHMENT_CONTENT));
		
		mPdf.setContentDescription(intent.getStringExtra(EXTRA_ATTACHMENT_PDF));
        if (mPdf.getContentDescription().toString().length() < 1)
        {
            mPdf.setTextColor(getResources().getColor(R.color.company_gray_light));
        }
		mPdf.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				openPdf(v.getContentDescription().toString());				
			}		
		});

		mDetails.setContentDescription(intent.getStringExtra(EXTRA_ATTACHMENT_AUTHOR_ID));
		mDetails.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				Log.d(TAG, "oid/details: " + absId + "/ " + authorId);				

				Intent intent = new Intent(PeopleDetailsActivity.ACTION_PERSON_SELECT);
				intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_ID, authorId);				
				intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_NAME, author);
				intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_INSTITUTION, institution);
				intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_EMAIL, email);
				intent.putExtra(PeopleDetailsActivity.EXTRA_PERSON_LINK, link);
				toPage(intent, PeopleDetailsActivity.class);
			}
		});
		
		// Load PDF within embedded WebView
		//loadPdf(intent.getStringExtra(EXTRA_ATTACHMENT_PDF));
	}
	
	// Use WebView via google docs engine	
	public void loadPdf(String url) {	
		mPdfViewer.loadUrl(_PARAMS.GOOGLE_DOCS_URL_EXTERNAL + url);
		//mPdfViewer.loadUrl(_PARAMS.GOOGLE_DOCS_URL_INTERNAL + url);
	}
	
	private void openPdf(String url) {
        if (url.length() > 1)
        {
            //non-empty url
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setDataAndType(Uri.parse(_PARAMS.GOOGLE_DOCS_URL_EXTERNAL + url), "text/html");
            startActivity(intent);
        }

	}
	
	/*
	private void convertPdfToImage() {
	        try {
	            String sourceDir = "C:/Documents/Chemistry.pdf";// PDF file must be placed in DataGet folder
	            String destinationDir = "C:/Documents/Converted/";//Converted PDF page saved in this folder

	        File sourceFile = new File(sourceDir);
	        File destinationFile = new File(destinationDir);

	        String fileName = sourceFile.getName().replace(".pdf", "_cover");

	        if (sourceFile.exists()) {
	            if (!destinationFile.exists()) {
	                destinationFile.mkdir();
	                System.out.println("Folder created in: "+ destinationFile.getCanonicalPath());
	            }

	            RandomAccessFile raf = new RandomAccessFile(sourceFile, "r");
	            FileChannel channel = raf.getChannel();
	            ByteBuffer buf = channel.map(FileChannel.MapMode.READ_ONLY, 0, channel.size());
	            PDFFile pdf = new PDFFile(buf);
	            int pageNumber = 62;// which PDF page to be convert
	            PDFPage page = pdf.getPage(pageNumber);
	            Log.d(TAG, "PDF TOTAL PAGES: " + pdf.getNumPages());

	            
	            // create the image
	            Rectangle rect = new Rectangle(0, 0, (int) page.getBBox().getWidth(), (int) page.getBBox().getHeight());
	            BufferedImage bufferedImage = new BufferedImage(rect.width, rect.height, BufferedImage.TYPE_INT_RGB);

	            // width & height, // clip rect, // null for the ImageObserver, // fill background with white, // block until drawing is done
	            Image image = page.getImage(rect.width, rect.height, rect, null, true, true );
	            Graphics2D bufImageGraphics = bufferedImage.createGraphics();
	            bufImageGraphics.drawImage(image, 0, 0, null);

	            File imageFile = new File( destinationDir + fileName +"_"+ pageNumber +".png" );// change file format here. Ex: .png, .jpg, .jpeg, .gif, .bmp

	            ImageIO.write(bufferedImage, "png", imageFile);

	            System.out.println(imageFile.getName() +" File created in: "+ destinationFile.getCanonicalPath());
	        } else {
	            System.err.println(sourceFile.getName() +" File not exists");
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}
	*/

}
