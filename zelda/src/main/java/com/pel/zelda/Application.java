package com.pel.zelda;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 1:46 PM
 */

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.pel.zelda.service.MigrationService;
import com.pel.zelda.controller.TeamController;
import com.pel.zelda.controller.UserController;

import java.io.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import static spark.Spark.*;
import java.util.Date;
import java.util.Properties;

public class Application {

    public static Connection db;

    public static void main(String[] args) throws SQLException, IOException, FirebaseMessagingException {
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
        FileInputStream serviceAccount = new FileInputStream("src/main/resources/serviceAccountKey.json");

        FirebaseOptions options = new FirebaseOptions.Builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .setProjectId("pacific-esports")
                .build();

        FirebaseApp.initializeApp(options);

        // logging
        before((request, response) -> {
            System.out.println();
            System.out.println(new Date());
            System.out.println("REQUESTED ROUTE: " + request.url() + " [" + request.requestMethod() + "]");
            System.out.println("REQUEST BODY: " + request.body());
            response.type("application/json");
        });
        // Initialize request logging
        after((request, response) -> {
            System.out.println("RESPONSE CODE: " + response.status());
            System.out.println("RESPONSE BODY: " + response.body());
            System.out.println();
        });
        // Initialize Object Controllers
        get("/zelda/test", (req, res) -> {
            res.body("{\"message\": \"" + "Zelda v" + Constants.VERSION + "\"}");
            return res;
        });
        UserController userController = new UserController();
        TeamController teamController = new TeamController();
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