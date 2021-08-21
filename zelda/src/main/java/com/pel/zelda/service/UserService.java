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
            user.emailVerified = (rs.getBoolean("email_verified"));
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
            user.emailVerified = (rs.getBoolean("email_verified"));
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
                user.emailVerified + "," +
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
        db.commit();
    }

//    public static void updateUser(User user) throws SQLException {
//        String sql = "UPDATE \"user\" SET " +
//                "first_name='" + user.getFirstName() + "'," +
//                "alt_name='" + user.getAltName() + "'," +
//                "last_name='" + user.getLastName() + "'," +
//                "international=" + user.isInternational() + "," +
//                "email='" + user.getEmail() + "'," +
//                "phone='" + user.getPhone() + "'," +
//                "grade=" + user.getGrade() + "," +
//                "gender='" + user.getGender() + "'," +
//                "shirt_size='" + user.getShirtSize() + "'," +
//                "jacket_size='" + user.getJacketSize() + "'," +
//                "profile_picture='" + user.getProfilePicture() + "'," +
//                "discord_id='" + user.getDiscordID() + "'," +
//                "discord_auth_token='" + user.getDiscordAuthToken() + "' " +
//                "WHERE id='" + user.getId() + "'";
//        db.createStatement().executeUpdate(sql);
//        sql = "DELETE FROM \"role\" WHERE user_id='" + user.getId() + "'";
//        db.createStatement().executeUpdate(sql);
//        for (String role : user.roles) {
//            sql = "INSERT INTO role VALUES " +
//                    "(" +
//                    "'" + user.getId() + "'," +
//                    "'" + role + "'" +
//                    ")";
//            db.createStatement().executeUpdate(sql);
//        }
//        db.commit();
//    }

    public static List<Team> getAllUserTeams(String id) throws SQLException {
        List<Team> returnList = new ArrayList<>();
        // Get Teams
        String sql = "select * from \"user_team\" where user_team.user_id = '" + id + "';";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            Team team = new Team();
            team.id = (rs.getInt("team_id"));
            Map map = new HashMap<>();
            map.put("verified", rs.getBoolean("verified"));
            map.put("createdAt", rs.getTimestamp("created_at"));
            map.put("updatedAt", rs.getTimestamp("updated_at"));
            map.put("user", getUser(id));
            team.users.add(map);
            // Get Roles for User
            String rolesSql = "select * from \"team\" where team.id='" + team.id + "'";
            ResultSet rs2 = db.createStatement().executeQuery(rolesSql);
            while (rs2.next()) {
                team.name = rs2.getString("name");
                team.createdAt = rs2.getTimestamp("created_at");
                team.updatedAt = rs2.getTimestamp("updated_at");
            }
            rs2.close();
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
                        " " + false + ",\n" +
                        " '" + Timestamp.valueOf(LocalDateTime.now()) + "',\n" +
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

    public static void verifyUserTeam(String uid, Integer tid) throws SQLException {
        String sql = "update \"user_team\" set verified = true where user_team.user_id = '" + uid + "' and user_team.team_id = " + tid + ";";
        db.createStatement().executeUpdate(sql);
        db.commit();
    }

}
