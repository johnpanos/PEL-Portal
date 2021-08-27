package com.pel.zelda.service;

import com.google.gson.Gson;
import com.pel.zelda.model.User;
import com.pel.zelda.model.Team;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.pel.zelda.Application.db;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 8:03 AM
 */
public class UserService {

    Gson gson = new Gson();

    public static List<User> getAllUsers() throws SQLException {
        List<User> returnList = new ArrayList<>();
        // Get Users
        String sql = "SELECT * FROM \"user\"";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            User user = new User();
            user.id = (rs.getString("id"));
            user.firstName = (rs.getString("first_name"));
            user.lastName = (rs.getString("last_name"));
            user.email = (rs.getString("email"));
            user.school = (rs.getString("school"));
            user.gradYear = (rs.getInt("grad_year"));
            user.gender = (rs.getString("gender"));
            user.profilePicture = (rs.getString("profile_picture"));
            user.createdAt = (rs.getTimestamp("created_at"));
            user.updatedAt = (rs.getTimestamp("updated_at"));
            // Get Roles for User
            String rolesSql = "select role from role where role.user_id='" + user.id + "'";
            ResultSet rs2 = db.createStatement().executeQuery(rolesSql);
            while (rs2.next()) {
                user.roles.add(rs2.getString("role"));
            }
            rs2.close();
            // Get Connections for User
            String connectionsSql = "select * from connection where connection.user_id='" + user.id + "'";
            ResultSet rs3 = db.createStatement().executeQuery(connectionsSql);
            while (rs3.next()) {
                user.connections.userId = (rs3.getString("user_id"));
                user.connections.discordTag = (rs3.getString("discord_tag"));
                user.connections.discordToken = (rs3.getString("discord_token"));
                user.connections.valorantId = (rs3.getString("valorant_id"));
                user.connections.leagueId = (rs3.getString("league_id"));
                user.connections.battleTag = (rs3.getString("battle_tag"));
                user.connections.battleToken = (rs3.getString("battle_token"));
                user.connections.steamId = (rs3.getString("steam_id"));
                user.connections.steamToken = (rs3.getString("steam_token"));
                user.connections.rocketId = (rs3.getString("rocket_id"));
            }
            rs3.close();
            // Get Verification for User
            String verificationSql = "select * from verification where verification.user_id='" + user.id + "'";
            ResultSet rs4 = db.createStatement().executeQuery(verificationSql);
            while (rs4.next()) {
                user.verification.userId = (rs4.getString("user_id"));
                user.verification.fileUrl = (rs4.getString("file_url"));
                user.verification.status = (rs4.getString("status"));
                user.verification.createdAt = (rs4.getTimestamp("created_at"));
                user.verification.updatedAt = (rs4.getTimestamp("updated_at"));
            }
            rs4.close();
            returnList.add(user);
        }
        rs.close();
        return returnList;
    }

    public static User getUser(String id) throws SQLException {
        User user = new User();
        String sql = "SELECT * FROM \"user\" WHERE id='" + id + "'";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            user.id = (rs.getString("id"));
            user.firstName = (rs.getString("first_name"));
            user.lastName = (rs.getString("last_name"));
            user.email = (rs.getString("email"));
            user.school = (rs.getString("school"));
            user.gradYear = (rs.getInt("grad_year"));
            user.gender = (rs.getString("gender"));
            user.profilePicture = (rs.getString("profile_picture"));
            user.createdAt = (rs.getTimestamp("created_at"));
            user.updatedAt = (rs.getTimestamp("updated_at"));
            // Get Roles for User
            String rolesSql = "select role from role where role.user_id='" + user.id + "'";
            ResultSet rs2 = db.createStatement().executeQuery(rolesSql);
            while (rs2.next()) {
                user.roles.add(rs2.getString("role"));
            }
            rs2.close();
            // Get Connections for User
            String connectionsSql = "select * from connection where connection.user_id='" + user.id + "'";
            ResultSet rs3 = db.createStatement().executeQuery(connectionsSql);
            while (rs3.next()) {
                user.connections.userId = (rs3.getString("user_id"));
                user.connections.discordTag = (rs3.getString("discord_tag"));
                user.connections.discordToken = (rs3.getString("discord_token"));
                user.connections.valorantId = (rs3.getString("valorant_id"));
                user.connections.leagueId = (rs3.getString("league_id"));
                user.connections.battleTag = (rs3.getString("battle_tag"));
                user.connections.battleToken = (rs3.getString("battle_token"));
                user.connections.steamId = (rs3.getString("steam_id"));
                user.connections.steamToken = (rs3.getString("steam_token"));
                user.connections.rocketId = (rs3.getString("rocket_id"));
            }
            rs3.close();
            // Get Verification for User
            String verificationSql = "select * from verification where verification.user_id='" + user.id + "'";
            ResultSet rs4 = db.createStatement().executeQuery(verificationSql);
            while (rs4.next()) {
                user.verification.userId = (rs4.getString("user_id"));
                user.verification.fileUrl = (rs4.getString("file_url"));
                user.verification.status = (rs4.getString("status"));
                user.verification.createdAt = (rs4.getTimestamp("created_at"));
                user.verification.updatedAt = (rs4.getTimestamp("updated_at"));
            }
            rs4.close();
        }
        rs.close();
        return user;
    }

    public static void addUser(User user) throws SQLException {
        String sql = "INSERT INTO \"user\" VALUES " +
                "(" +
                "'" + user.id + "'," +
                "'" + user.firstName + "'," +
                "'" + user.lastName + "'," +
                "'" + user.email + "'," +
                "'" + user.school + "'," +
                user.gradYear + "," +
                "'" + user.gender + "'," +
                "'" + user.profilePicture + "'," +
                "'" + user.createdAt + "'," +
                "'" + user.updatedAt + "'" +
                ")";
        db.createStatement().executeUpdate(sql);
        for (String role : user.roles) {
            sql = "INSERT INTO \"role\" VALUES " +
                    "(" +
                    "'" + user.id + "'," +
                    "'" + role + "'" +
                    ")";
            db.createStatement().executeUpdate(sql);
        }
        if (user.connections.userId != null) {
            sql = "INSERT INTO \"connection\" VALUES " +
                    "(" +
                    "'" + user.connections.userId + "'," +
                    "'" + user.connections.discordTag + "'," +
                    "'" + user.connections.discordToken + "'," +
                    "'" + user.connections.valorantId + "'," +
                    "'" + user.connections.leagueId + "'," +
                    "'" + user.connections.battleTag + "'," +
                    "'" + user.connections.battleToken + "'," +
                    "'" + user.connections.steamId + "'," +
                    "'" + user.connections.steamToken + "'," +
                    "'" + user.connections.rocketId + "'" +
                    ")";
            db.createStatement().executeUpdate(sql);
        }
        if (user.verification.userId != null) {
            sql = "INSERT INTO \"verification\" VALUES " +
                    "(" +
                    "'" + user.verification.userId + "'," +
                    "'" + user.verification.fileUrl + "'," +
                    "'" + user.verification.status + "'," +
                    "'" + Timestamp.valueOf(LocalDateTime.now()) + "'," +
                    "'" + Timestamp.valueOf(LocalDateTime.now()) + "'" +
                    ")";
            db.createStatement().executeUpdate(sql);
        }
        db.commit();
    }

    public static void updateUser(User user) throws SQLException {
        if (user.id != null) {
            String sql  = "DELETE FROM \"user\" WHERE id='" + user.id + "';";
            db.createStatement().executeUpdate(sql);
            sql = "INSERT INTO \"user\" VALUES " +
                    "(" +
                    "'" + user.id + "'," +
                    "'" + user.firstName + "'," +
                    "'" + user.lastName + "'," +
                    "'" + user.email + "'," +
                    "'" + user.school + "'," +
                    user.gradYear + "," +
                    "'" + user.gender + "'," +
                    "'" + user.profilePicture + "'," +
                    "'" + user.createdAt + "'," +
                    "'" + user.updatedAt + "'" +
                    ")";
            db.createStatement().executeUpdate(sql);
            sql  = "DELETE FROM role WHERE role.user_id='" + user.id + "';";
            db.createStatement().executeUpdate(sql);
            for (String role : user.roles) {
                sql = "INSERT INTO \"role\" VALUES " +
                        "(" +
                        "'" + user.id + "'," +
                        "'" + role + "'" +
                        ")";
                db.createStatement().executeUpdate(sql);
            }
        }
        if (user.connections.userId != null) {
            String sql  = "DELETE FROM connection WHERE connection.user_id='" + user.connections.userId + "';";
            db.createStatement().executeUpdate(sql);
            sql = "INSERT INTO \"connection\" VALUES " +
                    "(" +
                    "'" + user.connections.userId + "'," +
                    "'" + user.connections.discordTag + "'," +
                    "'" + user.connections.discordToken + "'," +
                    "'" + user.connections.valorantId + "'," +
                    "'" + user.connections.leagueId + "'," +
                    "'" + user.connections.battleTag + "'," +
                    "'" + user.connections.battleToken + "'," +
                    "'" + user.connections.steamId + "'," +
                    "'" + user.connections.steamToken + "'," +
                    "'" + user.connections.rocketId + "'" +
                    ")";
            db.createStatement().executeUpdate(sql);
        }
        if (user.verification.userId != null) {
            String sql  = "DELETE FROM verification WHERE verification.user_id='" + user.verification.userId + "';";
            db.createStatement().executeUpdate(sql);
            sql = "INSERT INTO \"verification\" VALUES " +
                    "(" +
                    "'" + user.verification.userId + "'," +
                    "'" + user.verification.fileUrl + "'," +
                    "'" + user.verification.status + "'," +
                    "'" + user.verification.createdAt + "'," +
                    "'" + Timestamp.valueOf(LocalDateTime.now()) + "'" +
                    ")";
            db.createStatement().executeUpdate(sql);
        }
        db.commit();
    }

    public static List<Team> getAllUserTeams(String id) throws SQLException {
        List<Team> returnList = new ArrayList<>();
        // Get Teams
        String sql = "select * from \"user_team\" where user_team.user_id = '" + id + "';";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            Team team = TeamService.getTeam(rs.getInt("team_id"));
            Map map = new HashMap<>();
            map.put("createdAt", rs.getTimestamp("created_at"));
            map.put("user", getUser(id));
            team.users.clear();
            team.users.add(map);
            returnList.add(team);
        }
        rs.close();
        return returnList;
    }

    public static void addUserTeam(String uid, Integer tid) throws SQLException {
        String sql = "select count(1) from \"user_team\" where user_team.user_id = '" + uid + "' and user_team.team_id = " + tid + ";";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            if (rs.getInt("count") == 0) {
                sql = "insert into \"user_team\" values\n" +
                        "(\n" +
                        " '" + uid + "',\n" +
                        "" + tid + ",\n" +
                        " '" + Timestamp.valueOf(LocalDateTime.now()) + "'\n" +
                        ");";
                db.createStatement().executeUpdate(sql);
                db.commit();
            }
        }
        rs.close();
    }

    public static void removeUserTeam(String uid, Integer tid) throws SQLException {
        String sql = "delete from \"user_team\" where user_team.user_id = '" + uid + "' and user_team.team_id = " + tid + ";";
        db.createStatement().executeUpdate(sql);
        db.commit();
    }

}
