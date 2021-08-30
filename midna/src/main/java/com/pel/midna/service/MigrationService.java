package com.pel.midna.service;

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
        // Tournament table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'tournament');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE TOURNAMENT ALREADY EXISTS!");
                }
                else {
                    sql = "create table tournament\n" +
                            "(\n" +
                            "\tid serial\n" +
                            "\t\tconstraint tournament_pk\n" +
                            "\t\t\tprimary key,\n" +
                            "\tname varchar,\n" +
                            "\t\"desc\" varchar,\n" +
                            "\tgame varchar,\n" +
                            "\ttype varchar,\n" +
                            "\tdivision varchar,\n" +
                            "\tregistration_start timestamp,\n" +
                            "\tregistration_end timestamp,\n" +
                            "\tseason_start timestamp,\n" +
                            "\tseason_end timestamp,\n" +
                            "\tplayoff_start timestamp,\n" +
                            "\tcreated_at timestamp,\n" +
                            "\tupdated_at timestamp\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED TOURNAMENT TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
        // Team_Tournament table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'team_tournament');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE TEAM_TOURNAMENT ALREADY EXISTS!");
                }
                else {
                    sql = "create table team_tournament\n" +
                            "(\n" +
                            "\tteam_id int,\n" +
                            "\ttournament_id int,\n" +
                            "\tbattlefy_code varchar,\n" +
                            "\tcreated_at timestamp\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED TEAM_TOURNAMENT TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
        // Tournament_Code table
        try {
            String sql = "SELECT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'public' AND tablename = 'tournament_code');";
            ResultSet rs = db.createStatement().executeQuery(sql);
            while (rs.next()) {
                if (rs.getBoolean("exists")) {
                    System.out.println("TABLE TOURNAMENT_CODE ALREADY EXISTS!");
                }
                else {
                    sql = "create table tournament_code\n" +
                            "(\n" +
                            "\ttournament_id int,\n" +
                            "\tcode varchar,\n" +
                            "\tcreated_at timestamp\n" +
                            ");";
                    db.createStatement().execute(sql);
                    System.out.println("CREATED TOURNAMENT_CODE TABLE");
                    db.commit();
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getLocalizedMessage());
        }
    }
}
