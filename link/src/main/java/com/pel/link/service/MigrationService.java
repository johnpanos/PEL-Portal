package com.pel.link.service;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 2:37 PM
 */
public class MigrationService {
    public static void v1(Connection db) throws SQLException {
        // API KEY table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'api_key');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE API_KEY ALREADY EXISTS!");
                }
                else {
                    sql = "CREATE TABLE \"api_key\" (\n" +
                            "     \"id\" text,\n" +
                            "     \"permission\" integer,\n" +
                            "     \"created\" timestamp" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED API_KEY TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
    }
}
