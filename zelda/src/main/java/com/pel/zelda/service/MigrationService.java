package com.pel.zelda.service;

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
        // Users table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE USER ALREADY EXISTS!");
                }
                else {
                    sql = "create table \"user\"\n" +
                            "(\n" +
                            "\tid varchar\n" +
                            "\t\tconstraint user_pk\n" +
                            "\t\t\tprimary key,\n" +
                            "\tfirst_name varchar,\n" +
                            "\tlast_name varchar,\n" +
                            "\temail varchar,\n" +
                            "\tschool varchar,\n" +
                            "\tgrad_year int,\n" +
                            "\tgender varchar,\n" +
                            "\tprofile_picture varchar,\n" +
                            "\tcreated_at timestamp,\n" +
                            "\tupdated_at timestamp\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED USER TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
        // Role table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'role');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE ROLE ALREADY EXISTS!");
                }
                else {
                    sql = "CREATE TABLE \"role\" (\n" +
                            "    \"user_id\" text,\n" +
                            "    \"role\" text\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED ROLE TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
        // Connections table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'connection');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE CONNECTION ALREADY EXISTS!");
                }
                else {
                    sql = "create table connection\n" +
                            "(\n" +
                            "\tuser_id varchar\n" +
                            "\t\tconstraint connection_pk\n" +
                            "\t\t\tprimary key,\n" +
                            "\tdiscord_id int,\n" +
                            "\tdiscord_tag varchar,\n" +
                            "\tdiscord_token varchar,\n" +
                            "\triot_id varchar,\n" +
                            "\tbattle_tag varchar,\n" +
                            "\tbattle_token varchar,\n" +
                            "\trocket_id varchar\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED CONNECTION TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
        // Verification table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'verification');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE VERIFICATION ALREADY EXISTS!");
                }
                else {
                    sql = "create table verification\n" +
                            "(\n" +
                            "\tuser_id varchar\n" +
                            "\t\tconstraint verification_pk\n" +
                            "\t\t\tprimary key,\n" +
                            "\tfile_url varchar,\n" +
                            "\tstatus varchar,\n" +
                            "\tcreated_at timestamp,\n" +
                            "\tupdated_at timestamp\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED VERIFICATION TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
        // Teams table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'team');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE TEAM ALREADY EXISTS!");
                }
                else {
                    sql = "create table team\n" +
                            "(\n" +
                            "\tid serial\n" +
                            "\t\tconstraint teams_pk\n" +
                            "\t\t\tprimary key,\n" +
                            "\tname varchar,\n" +
                            "\tlogo_url varchar,\n" +
                            "\tgame varchar,\n" +
                            "\tavg_rank varchar,\n" +
                            "\tcreated_at timestamp,\n" +
                            "\tupdated_at timestamp\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED TEAM TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
        // User_Team table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'user_team');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE USER_TEAM ALREADY EXISTS!");
                }
                else {
                    sql = "create table user_team\n" +
                            "(\n" +
                            "\tuser_id varchar,\n" +
                            "\tteam_id int,\n" +
                            "\tcreated_at timestamp\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED USER_TEAM TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
    }
}
