package com.pel.link.service;

import com.pel.link.Application;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 2:44 PM
 */
public class RouteService {

    static Properties properties = new Properties();

    public static void getRoutes() throws IOException {
        try {
            InputStream file = Application.class.getClassLoader().getResourceAsStream("route.properties");
            properties.load(file);
        } catch (NullPointerException err) {
            FileInputStream file = new FileInputStream("src/main/resources/route.properties");
        }
    }

    public static String matchRoute(String route) {
        String parsedKey = route.split("/api/")[1].split("/")[0];
        System.out.println("MAPPED KEY \"" + parsedKey + "\" TO PORT: " + properties.getProperty(parsedKey));
        System.out.println("MAPPED ROUTE: " + "http://localhost:" + properties.getProperty(parsedKey) + "/" + route.split("/api/")[1]);
        return "http://localhost:" + properties.getProperty(parsedKey) + "/" + route.split("/api/")[1];
    }

}
