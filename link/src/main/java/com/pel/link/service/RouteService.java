package com.pel.link.service;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 2:44 PM
 */
public class RouteService {

    static Properties properties = new Properties();

    public static void getRoutes() throws IOException {
        FileInputStream file = new FileInputStream("src/main/resources/route.properties");
        properties.load(file);
    }

    public static String matchRoute(String route) {
        String parsedKey = route.split("/api/")[1].split("/")[0];
        System.out.println("MAPPED KEY \"" + parsedKey + "\" TO PORT: " + properties.getProperty(parsedKey));
        System.out.println("MAPPED ROUTE: " + "http://localhost:" + properties.getProperty(parsedKey) + "/" + route.split("/api/")[1]);
        return "http://localhost:" + properties.getProperty(parsedKey) + "/" + route.split("/api/")[1];
    }

}
