package com.pel.link.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.cloud.FirestoreClient;
import com.google.firebase.database.*;
import com.pel.link.Constants;
import com.pel.link.model.Token;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

import static com.pel.link.Application.db;

/**
 * User: bharat
 * Date: 7/10/21
 * Time: 2:38 PM
 */
public class AuthService {

    public static List<Token> getAllTokens() throws SQLException {
        List<Token> returnList = new ArrayList<>();
        String sql = "SELECT * FROM \"api_key\"";
        ResultSet rs = db.createStatement().executeQuery(sql);
        while(rs.next()) {
            Token token = new Token(rs.getString("id"), rs.getInt("permission"), rs.getTimestamp("created"));
            System.out.println(token);
            returnList.add(token);
        }
        rs.close();
        return returnList;
    }

    public static boolean checkToken(String token) throws FirebaseAuthException {
        for (int i = 0; i < Constants.tokenList.size(); i++) {
            if (Constants.tokenList.get(i).getId().equals(token)) {
                return true;
            }
        }
        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(token);
            System.out.println("DECODED TOKEN USER \"" + decodedToken.getUid() + "\"");
            return true;
        } catch (FirebaseAuthException error) {
            return false;
        }
    }

    public static void revokeToken(String token) throws ExecutionException, InterruptedException {

    }
}
