package com.pel.link.model;

import java.util.Date;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 2:35 PM
 */
public class StandardResponse {

    public static String success(String data) {
        return "{" +
                "\"status\":\"" + "SUCCESS" + "\"," +
                "\"date\":\"" + new Date().toString() + "\"," +
                "\"data\":" + data +
                "}";
    }

    public static String error(String data) {
        return "{" +
                "\"status\":\"" + "ERROR" + "\"," +
                "\"date\":\"" + new Date().toString() + "\"," +
                "\"data\":" + data +
                "}";
    }

}
