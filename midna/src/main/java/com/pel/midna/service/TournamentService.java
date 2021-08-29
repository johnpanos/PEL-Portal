package com.pel.midna.service;

import com.google.gson.Gson;
import com.pel.midna.model.Tournament;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.pel.midna.Application.db;

/**
 * User: bharat
 * Date: 8/10/21
 * Time: 1:59 PM
 */
public class TournamentService {

    Gson gson = new Gson();

    public static List<Tournament> getAllTournaments() throws SQLException {
        List<Tournament> returnList = new ArrayList<>();
        String sql = "select * from \"tournament\";";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            Tournament tournament = new Tournament();
            tournament.id = (rs.getInt("id"));
            tournament.name = rs.getString("name");
            tournament.desc = rs.getString("desc");
            tournament.game = rs.getString("game");
            tournament.type = rs.getString("type");
            tournament.division = rs.getString("division");
            tournament.registrationStart = rs.getTimestamp("registration_start");
            tournament.registrationEnd = rs.getTimestamp("registration_end");
            tournament.seasonStart = rs.getTimestamp("season_start");
            tournament.seasonEnd = rs.getTimestamp("season_end");
            tournament.playoffStart = rs.getTimestamp("playoff_start");
            tournament.createdAt = rs.getTimestamp("created_at");
            tournament.updatedAt = rs.getTimestamp("updated_at");
            // Get Teams for Tournament
            String usersSql = "select * from \"team_tournament\" where team_tournament.tournament_id = '" + tournament.id + "';";
            ResultSet rs2 = db.createStatement().executeQuery(usersSql);
            while (rs2.next()) {
                Map map = new HashMap<>();
                map.put("createdAt", rs2.getTimestamp("created_at"));
                map.put("teamId", rs2.getInt("team_id"));
                tournament.teams.add(map);
            }
            rs2.close();
            returnList.add(tournament);
        }
        rs.close();
        return returnList;
    }

    public static Tournament getTournament(Integer id) throws SQLException {
        Tournament tournament = new Tournament();
        String sql = "select * from \"tournament\" where tournament.id = " + id + ";";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            tournament.id = (rs.getInt("id"));
            tournament.name = rs.getString("name");
            tournament.desc = rs.getString("desc");
            tournament.game = rs.getString("game");
            tournament.type = rs.getString("type");
            tournament.division = rs.getString("division");
            tournament.registrationStart = rs.getTimestamp("registration_start");
            tournament.registrationEnd = rs.getTimestamp("registration_end");
            tournament.seasonStart = rs.getTimestamp("season_start");
            tournament.seasonEnd = rs.getTimestamp("season_end");
            tournament.playoffStart = rs.getTimestamp("playoff_start");
            tournament.createdAt = rs.getTimestamp("created_at");
            tournament.updatedAt = rs.getTimestamp("updated_at");
            // Get Teams for Tournament
            String usersSql = "select * from \"team_tournament\" where team_tournament.tournament_id = '" + tournament.id + "';";
            ResultSet rs2 = db.createStatement().executeQuery(usersSql);
            while (rs2.next()) {
                Map map = new HashMap<>();
                map.put("createdAt", rs2.getTimestamp("created_at"));
                map.put("teamId", rs2.getInt("team_id"));
                tournament.teams.add(map);
            }
            rs2.close();
        }
        rs.close();
        return tournament;
    }

    public static Integer addTournament(Tournament tournament) throws SQLException {
        String sql = "insert into \"tournament\" values\n" +
                "(\n" +
                " default,\n" +
                " '" + tournament.name.replace("'", "''") + "',\n" +
                " '" + tournament.desc.replace("'", "''") + "',\n" +
                " '" + tournament.game + "',\n" +
                " '" + tournament.type + "',\n" +
                " '" + tournament.division + "',\n" +
                " '" + tournament.registrationStart + "',\n" +
                " '" + tournament.registrationEnd + "',\n" +
                " '" + tournament.seasonStart + "',\n" +
                " '" + tournament.seasonEnd + "',\n" +
                " '" + tournament.playoffStart + "',\n" +
                " '" + tournament.createdAt + "',\n" +
                " '" + tournament.updatedAt + "'\n" +
                ") returning id;";
        ResultSet rs = db.createStatement().executeQuery(sql);
        db.commit();
        while (rs.next()) {
            return rs.getInt("id");
        }
        rs.close();
        return 0;
    }

    public static void updateTournament(Tournament tournament) throws SQLException {
        String sql  = "DELETE FROM \"tournament\" WHERE id='" + tournament.id + "';";
        db.createStatement().executeUpdate(sql);
        sql = "insert into \"tournament\" values\n" +
                "(\n" +
                "" + tournament.id + ",\n" +
                " '" + tournament.name.replace("'", "''")+ "',\n" +
                " '" + tournament.desc.replace("'", "''") + "',\n" +
                " '" + tournament.game + "',\n" +
                " '" + tournament.type + "',\n" +
                " '" + tournament.division + "',\n" +
                " '" + tournament.registrationStart + "',\n" +
                " '" + tournament.registrationEnd + "',\n" +
                " '" + tournament.seasonStart + "',\n" +
                " '" + tournament.seasonEnd + "',\n" +
                " '" + tournament.playoffStart + "',\n" +
                " '" + tournament.createdAt + "',\n" +
                " '" + tournament.updatedAt + "'\n" +
                ");";
        db.createStatement().executeUpdate(sql);
        db.commit();
    }

    public static List<Tournament> getTeamTournaments(Integer teamId) throws SQLException {
        List<Tournament> returnList = new ArrayList<>();
        String sql = "select * from \"team_tournament\" where team_tournament.team_id = '" + teamId + "';";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            Tournament tournament = new Tournament();
            Map map = new HashMap<>();
            map.put("createdAt", rs.getTimestamp("created_at"));
            map.put("teamId", rs.getInt("team_id"));
            tournament.teams.add(map);
            sql = "select * from \"tournament\" where tournament.id = " + rs.getInt("tournament_id") + ";";
            ResultSet rs2 = db.createStatement().executeQuery(sql);
            while (rs2.next()) {
                tournament.id = (rs2.getInt("id"));
                tournament.name = rs2.getString("name");
                tournament.desc = rs2.getString("desc");
                tournament.game = rs2.getString("game");
                tournament.type = rs2.getString("type");
                tournament.division = rs2.getString("division");
                tournament.registrationStart = rs2.getTimestamp("registration_start");
                tournament.registrationEnd = rs2.getTimestamp("registration_end");
                tournament.seasonStart = rs2.getTimestamp("season_start");
                tournament.seasonEnd = rs2.getTimestamp("season_end");
                tournament.playoffStart = rs2.getTimestamp("playoff_start");
                tournament.createdAt = rs2.getTimestamp("created_at");
                tournament.updatedAt = rs2.getTimestamp("updated_at");
            }
            rs2.close();
            returnList.add(tournament);
        }
        rs.close();
        return returnList;
    }

    public static void addTournamentTeam(Integer tournamentId, Integer teamId) throws SQLException {
        String sql = "select count(1) from \"team_tournament\" where team_tournament.tournament_id = '" + tournamentId + "' and team_tournament.team_id = " + teamId + ";";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            if (rs.getInt("count") == 0) {
                sql = "insert into \"team_tournament\" values\n" +
                        "(\n" +
                        "" + teamId + ",\n" +
                        "" + tournamentId + ",\n" +
                        " '" + Timestamp.valueOf(LocalDateTime.now()) + "'\n" +
                        ");";
                db.createStatement().executeUpdate(sql);
                db.commit();
            }
        }
        rs.close();
    }

    public static void removeTournamentTeam(Integer tournamentId, Integer teamId) throws SQLException {
        String sql = "delete from \"team_tournament\" where team_tournament.tournament_id = '" + tournamentId + "' and team_tournament.team_id = " + teamId + ";";
        db.createStatement().executeUpdate(sql);
        db.commit();
    }

    public static void addtTournamentCode(Integer tournamentId, String code) throws SQLException {
        String sql = "insert into \"tournament_code\" values\n" +
                "(\n" +
                "" + tournamentId + ",\n" +
                " '" + code + "',\n" +
                " '" + Timestamp.valueOf(LocalDateTime.now()) + "'\n" +
                ");";
        db.createStatement().executeUpdate(sql);
        db.commit();
    }

    public static String getTournamentCode(Integer tournamentId) throws SQLException {
        String code = "No codes available! Please please DM the ModMail bot on Discord or email us at contact@pacificesports.org.";
        String sql = "select * from tournament_code where tournament_code.tournament_id= " + tournamentId + "limit 1;";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while (rs.next()) {
            code = rs.getString("code");
            String deletesql = "delete from \"tournament_code\" where tournament_code.tournament_id = " + tournamentId + " and tournament_code.code = '" + code + "';";
            db.createStatement().executeUpdate(deletesql);
            db.commit();
        }
        rs.close();
        return code;
    }

}
