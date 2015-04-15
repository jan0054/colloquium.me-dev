package com.squint.app.data;

public class _ERROR {

	public enum PARSE_ERROR {
		ERROR_GET_PERSON			(1000, "Can not retrieve data of person"),
	    ERROR_GET_CAREER  			(1001, "Can not retrieve data of career"),
	    ERROR_GET_POI		   	 	(1002, "Can not retrieve data of pois"),
	    ERROR_GET_ABSTRACT	    	(1003, "Can not retrieve data of abstract"),
	    ERROR_GET_CONVERSATION		(1004, "Can not retrieve data of conversation"),
	    ERROR_GET_LOCATION  	    (1005, "Can not retrieve data of location"),
	    ERROR_GET_POSTER			(1006, "Can not retrieve data of poster"),
	    ERROR_GET_SESSION			(1006, "Can not retrieve data of session"),
	    ERROR_GET_TALK				(1006, "Can not retrieve data of talk");

	    private String message;
	    private int value;
	    private PARSE_ERROR(int value, String message) {
	        this.message = message;
	        this.value = value;
	    }

	    public String getMessage() {
	    	return message;
	    }
	    
	    public int getValue() {
	    	return value;
	    }
	    
	    @Override
	    public String toString() {
	        return getMessage();
	    }
	}
	
}
