package com.pel.zelda.service;

import com.google.gson.Gson;
import com.pel.zelda.Application;
import com.pel.zelda.model.Team;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.pel.zelda.Application.db;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 1:59 PM
 */
public class TeamService {

    Gson gson = new Gson();

    public static List<Team> getAllTeams() throws SQLException {
        List<Team> returnList = new ArrayList<>();
        // Get Teams
        String sql = "select * from \"team\";";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            Team team = new Team();
            team.id = (rs.getInt("id"));
            team.name = rs.getString("name");
            team.logoUrl = rs.getString("logo_url");
            team.game = rs.getString("game");
            team.avgRank = rs.getString("avg_rank");
            team.createdAt = rs.getTimestamp("created_at");
            team.updatedAt = rs.getTimestamp("updated_at");
            // Get Users for Team
            String usersSql = "select * from \"user_team\" where user_team.team_id = '" + team.id + "';";
            ResultSet rs2 = db.createStatement().executeQuery(usersSql);
            while (rs2.next()) {
                Map map = new HashMap<>();
                map.put("createdAt", rs2.getTimestamp("created_at"));
                map.put("user", UserService.getUser(rs2.getString("user_id")));
                team.users.add(map);
            }
            rs2.close();
            returnList.add(team);
        }
        rs.close();
        return returnList;
    }

    public static Team getTeam(Integer id) throws SQLException {
        Team team = new Team();
        String sql = "select * from \"team\" where team.id = " + id + ";";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            team.id = (rs.getInt("id"));
            team.name = rs.getString("name");
            team.logoUrl = rs.getString("logo_url");
            team.game = rs.getString("game");
            team.avgRank = rs.getString("avg_rank");
            team.createdAt = rs.getTimestamp("created_at");
            team.updatedAt = rs.getTimestamp("updated_at");
            // Get Users for Team
            String usersSql = "select * from \"user_team\" where user_team.team_id = '" + team.id + "';";
            ResultSet rs2 = db.createStatement().executeQuery(usersSql);
            while (rs2.next()) {
                Map map = new HashMap<>();
                map.put("createdAt", rs2.getTimestamp("created_at"));
                map.put("user", UserService.getUser(rs2.getString("user_id")));
                team.users.add(map);
            }
            rs2.close();
        }
        rs.close();
        return team;
    }

    public static Integer addTeam(Team team) throws SQLException {
        String sql = "insert into \"team\" values\n" +
                "(\n" +
                " default,\n" +
                " '" + team.name + "',\n" +
                " '" + team.logoUrl + "',\n" +
                " '" + team.game + "',\n" +
                " '" + team.avgRank + "',\n" +
                " '" + team.createdAt + "',\n" +
                " '" + team.updatedAt + "'\n" +
                ") returning id;";
        ResultSet rs = db.createStatement().executeQuery(sql);
        db.commit();
        while (rs.next()) {
            return rs.getInt("id");
        }
        rs.close();
        return 0;
    }

    public static void updateTeam(Team team) throws SQLException {
        String sql  = "DELETE FROM \"team\" WHERE id='" + team.id + "';";
        db.createStatement().executeUpdate(sql);
        sql = "insert into \"team\" values\n" +
                "(\n" +
                "" + team.id + ",\n" +
                " '" + team.name + "',\n" +
                " '" + team.logoUrl + "',\n" +
                " '" + team.game + "',\n" +
                " '" + team.avgRank + "',\n" +
                " '" + team.createdAt + "',\n" +
                " '" + team.updatedAt + "'\n" +
                ");";
        db.createStatement().executeUpdate(sql);
    }

}
