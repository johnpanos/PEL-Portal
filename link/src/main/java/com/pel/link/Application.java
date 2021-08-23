package com.pel.link;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 1:46 PM
 */

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.pel.link.controller.RouteController;
import com.pel.link.service.AuthService;
import com.pel.link.service.MigrationService;
import com.pel.link.service.RouteService;
import com.pel.link.model.StandardResponse;

import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import static spark.Spark.*;
import java.util.Date;
import java.util.Properties;

public class Application {

    public static Connection db;

    public static void main(String[] args) throws SQLException, IOException {
        // Start Spark Webserver
        port(Constants.PORT);
        init();
        // Connect to Postgres DB
        Application app = new Application();
        db = app.connect();
        db.setAutoCommit(false);
        // Initialize DB
        MigrationService.v1(db);

        // Firebase admin time
        try {
            InputStream serviceAccount = Application.class.getClassLoader().getResourceAsStream("serviceAccountKey.json");
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .setProjectId("pacific-esports")
                    .setDatabaseUrl("https://pacific-esports-default-rtdb.firebaseio.com/")
                    .build();
            FirebaseApp.initializeApp(options);
        } catch (NullPointerException err) {
            FileInputStream serviceAccount = new FileInputStream("src/main/resources/serviceAccountKey.json");
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                    .setProjectId("pacific-esports")
                    .setDatabaseUrl("https://pacific-esports-default-rtdb.firebaseio.com/")
                    .build();
            FirebaseApp.initializeApp(options);
        }

        Constants.tokenList = AuthService.getAllTokens();
        RouteService.getRoutes();

        // Handle cors
        options("/*", (request, response) -> {
            String accessControlRequestHeaders = request.headers("Access-Control-Request-Headers");
            if (accessControlRequestHeaders != null) {
                response.header("Access-Control-Allow-Headers", accessControlRequestHeaders);
            }
            String accessControlRequestMethod = request.headers("Access-Control-Request-Method");
            if (accessControlRequestMethod != null) {
                response.header("Access-Control-Allow-Methods", accessControlRequestMethod);
            }
            return "OK";
        });
        // Check authentication and log
        before((request, response) -> {
            System.out.println();
            System.out.println(new Date());
            System.out.println("REQUESTED ROUTE: " + request.url() + " [" + request.requestMethod() + "]");
            System.out.println("REQUEST BODY: " + request.body());
            System.out.println("REQUEST ORIGIN: " + request.host() + " [" + request.ip() + "]");
            if (!request.requestMethod().equals("OPTIONS") && !request.url().contains("/auth")) {
                if (request.headers("Authorization") != null) {
                    boolean authenticated;
                    String key = request.headers("Authorization").replaceAll(" ", "");
                    System.out.println("API KEY: " + key);
                    authenticated = AuthService.checkToken(key);
                    if (!authenticated) {
                        System.out.println("INVALID AUTHENTICATION!");
                        response.type("application/json");
                        halt(401, StandardResponse.error("{\"message\": \"" + "Invalid authentication token" + "\"}"));
                    }
                }
                else {
                    System.out.println("NOT AUTHENTICATED!");
                    response.type("application/json");
                    halt(401, StandardResponse.error("{\"message\": \"" + "Request not authenticated" + "\"}"));
                }
            }
            // More cors
            response.header("Access-Control-Allow-Origin", "*");
            response.header("Access-Control-Allow-Headers", "*");
            response.header("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,OPTIONS");
            response.header("Access-Control-Allow-Credentials", "true");
            response.type("application/json");
        });
        // Initialize request logging
        after((request, response) -> {
            System.out.println("RESPONSE CODE: " + response.status());
            System.out.println("RESPONSE BODY: " + response.body());
            System.out.println();
        });
        // Initialize Object Controllers
        get("/api/test", (req, res) -> {
            res.body(StandardResponse.success("{\"message\": \"" + "Link v" + Constants.VERSION + "\"}"));
            return res;
        });
        RouteController routeController = new RouteController();
    }

    public Connection connect() {
        Connection conn = null;
        try {
            Properties props = new Properties();
            props.setProperty("user", Constants.USER);
            props.setProperty("password", Constants.PASSWORD);
            props.setProperty("autosave", "always");
            conn = DriverManager.getConnection(Constants.URL, props);
            System.out.println("Connected to the PostgreSQL server successfully.");
            System.out.println(Constants.URL);
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
        return conn;
    }

}